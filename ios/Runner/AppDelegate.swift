import AuthenticationServices
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var autofillChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let messenger = engineBridge.applicationRegistrar.messenger()
    setupAutofillChannel(messenger)
  }

  private func setupAutofillChannel(_ messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "openkey/autofill", binaryMessenger: messenger)
    autofillChannel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handleAutofill(call: call, result: result)
    }
  }

  /// Called from SceneDelegate when the AutoFill extension opens the app.
  func notifyAutofillIntent() {
    autofillChannel?.invokeMethod("onAutofillIntent", arguments: nil)
  }

  private func handleAutofill(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "syncCredentials":
      guard let raw = call.arguments as? [[String: Any]] else {
        result(FlutterError(code: "bad_args", message: "Expected list", details: nil))
        return
      }
      let credentials: [AutofillCredentialRecord] = raw.map { Self.parseCredential($0) }
      AutofillCredentialStore.sync(credentials: credentials)
      updateIdentityStore(credentials: credentials)
      result(true)

    case "clearCredentials":
      AutofillCredentialStore.clear()
      clearIdentityStore()
      result(true)

    case "isAutofillEnabled":
      ASCredentialIdentityStore.shared.getState { state in
        DispatchQueue.main.async {
          result(state.isEnabled)
        }
      }

    case "openAutofillSettings":
      openAutofillSettings()
      result(true)

    case "setAutofillEnabled":
      openAutofillSettings()
      result(true)

    case "takePendingSave":
      if let save = AutofillCredentialStore.takePendingSave() {
        result(save.asBridgeMap())
      } else {
        result(nil)
      }

    case "takePendingUnlock":
      result(AutofillCredentialStore.takePendingUnlock())

    case "takePendingPasskeySaves":
      result(AutofillCredentialStore.takePendingPasskeySaves().map { $0.asBridgeMap() })

    case "takePendingSignCountUpdates":
      result(AutofillCredentialStore.takePendingSignCountUpdates().map { $0.asBridgeMap() })

    case "setRequireBiometric":
      let enabled = call.arguments as? Bool ?? false
      AutofillCredentialStore.setRequireBiometric(enabled)
      result(true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  static func parseCredential(_ map: [String: Any]) -> AutofillCredentialRecord {
    let urls = (map["urls"] as? [Any])?.compactMap { $0 as? String } ?? []
    var passkey: AutofillPasskeyPayload?
    if let pk = map["passkey"] as? [String: Any] {
      passkey = AutofillPasskeyPayload.fromBridgeMap(pk)
    }
    return AutofillCredentialRecord(
      uuid: map["uuid"] as? String ?? "",
      title: map["title"] as? String ?? "",
      username: map["username"] as? String ?? "",
      password: map["password"] as? String ?? "",
      urls: urls,
      passkey: passkey
    )
  }

  private func openAutofillSettings() {
    // Prefer Passwords settings when available; fall back to this app's settings page.
    let candidates = [
      "App-prefs:PASSWORDS",
      "prefs:root=PASSWORDS",
      UIApplication.openSettingsURLString,
    ]
    for value in candidates {
      if let url = URL(string: value), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
        return
      }
    }
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url)
    }
  }

  private func updateIdentityStore(credentials: [AutofillCredentialRecord]) {
    // ASCredentialIdentity (existential `any`) and ASPasskeyCredentialIdentity
    // require iOS 17+. Keep the protocol type only inside an @available helper
    // so the deployment target (15.5) can still compile this file.
    if #available(iOS 17.0, *) {
      updateIdentityStoreIncludingPasskeys(credentials: credentials)
    } else {
      updateIdentityStorePasswordsOnly(credentials: credentials)
    }
  }

  @available(iOS 17.0, *)
  private func updateIdentityStoreIncludingPasskeys(credentials: [AutofillCredentialRecord]) {
    var identities: [any ASCredentialIdentity] = []
    for credential in credentials {
      if credential.hasPasswordLogin {
        for url in credential.urls {
          if url.lowercased().hasPrefix("androidapp://") { continue }
          let service = ASCredentialServiceIdentifier(
            identifier: url,
            type: .URL
          )
          identities.append(
            ASPasswordCredentialIdentity(
              serviceIdentifier: service,
              user: credential.username.isEmpty ? credential.title : credential.username,
              recordIdentifier: credential.uuid
            )
          )
        }
      }
      if let pk = credential.passkey,
         pk.privateKeyCipher?.isEmpty == false
      {
        let userName = pk.userName?.isEmpty == false
          ? pk.userName!
          : (credential.username.isEmpty ? credential.title : credential.username)
        let identity = ASPasskeyCredentialIdentity(
          relyingPartyIdentifier: pk.rpId,
          userName: userName,
          credentialID: PasskeyAuthenticator.fromB64Url(pk.credentialId),
          userHandle: pk.userHandle.map { PasskeyAuthenticator.fromB64Url($0) } ?? Data(),
          recordIdentifier: credential.uuid
        )
        identities.append(identity)
      }
    }
    ASCredentialIdentityStore.shared.replaceCredentialIdentities(identities) { _, _ in }
  }

  private func updateIdentityStorePasswordsOnly(credentials: [AutofillCredentialRecord]) {
    var passwords: [ASPasswordCredentialIdentity] = []
    for credential in credentials where credential.hasPasswordLogin {
      for url in credential.urls {
        if url.lowercased().hasPrefix("androidapp://") { continue }
        let service = ASCredentialServiceIdentifier(
          identifier: url,
          type: .URL
        )
        passwords.append(
          ASPasswordCredentialIdentity(
            serviceIdentifier: service,
            user: credential.username.isEmpty ? credential.title : credential.username,
            recordIdentifier: credential.uuid
          )
        )
      }
    }
    ASCredentialIdentityStore.shared.replaceCredentialIdentities(with: passwords) { _, _ in }
  }

  private func clearIdentityStore() {
    ASCredentialIdentityStore.shared.removeAllCredentialIdentities { _, _ in }
  }
}
