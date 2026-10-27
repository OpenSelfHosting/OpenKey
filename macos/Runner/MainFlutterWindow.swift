import Cocoa
import FlutterMacOS
import AuthenticationServices
import bitsdojo_window_macos

class MainFlutterWindow: BitsdojoWindow {
  private var autofillChannel: FlutterMethodChannel?

  override func bitsdojo_window_configure() -> UInt {
    return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
  }

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    setupAutofillChannel(flutterViewController)

    super.awakeFromNib()
  }

  private func setupAutofillChannel(_ controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "openkey/autofill",
      binaryMessenger: controller.engine.binaryMessenger
    )
    autofillChannel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handleAutofill(call: call, result: result)
    }
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
      if #available(macOS 11.0, *) {
        ASCredentialIdentityStore.shared.getState { state in
          DispatchQueue.main.async {
            result(state.isEnabled)
          }
        }
      } else {
        result(false)
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
    let candidates = [
      "x-apple.systempreferences:com.apple.Passwords-Settings.extension",
      "x-apple.systempreferences:com.apple.Extensions-Settings.extension",
      "x-apple.systempreferences:com.apple.preference.security?Privacy_Password",
    ]
    for value in candidates {
      if let url = URL(string: value), NSWorkspace.shared.open(url) {
        return
      }
    }
    NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/System Settings.app"))
  }

  private func updateIdentityStore(credentials: [AutofillCredentialRecord]) {
    if #available(macOS 14.0, *) {
      var identities: [any ASCredentialIdentity] = []
      for credential in credentials {
        identities.append(contentsOf: passwordIdentities(for: credential))
        if let pk = credential.passkey,
           pk.privateKeyCipher?.isEmpty == false
        {
          let userName = pk.userName?.isEmpty == false
            ? pk.userName!
            : (credential.username.isEmpty ? credential.title : credential.username)
          identities.append(
            ASPasskeyCredentialIdentity(
              relyingPartyIdentifier: pk.rpId,
              userName: userName,
              credentialID: PasskeyAuthenticator.fromB64Url(pk.credentialId),
              userHandle: pk.userHandle.map { PasskeyAuthenticator.fromB64Url($0) } ?? Data(),
              recordIdentifier: credential.uuid
            )
          )
        }
      }
      ASCredentialIdentityStore.shared.replaceCredentialIdentities(identities) { _, _ in }
      return
    }

    guard #available(macOS 11.0, *) else { return }
    var passwords: [ASPasswordCredentialIdentity] = []
    for credential in credentials {
      passwords.append(contentsOf: passwordIdentities(for: credential))
    }
    ASCredentialIdentityStore.shared.replaceCredentialIdentities(with: passwords) { _, _ in }
  }

  private func passwordIdentities(
    for credential: AutofillCredentialRecord
  ) -> [ASPasswordCredentialIdentity] {
    guard credential.hasPasswordLogin else { return [] }
    return credential.urls.compactMap { url in
      if url.lowercased().hasPrefix("androidapp://") { return nil }
      let service = ASCredentialServiceIdentifier(identifier: url, type: .URL)
      return ASPasswordCredentialIdentity(
        serviceIdentifier: service,
        user: credential.username.isEmpty ? credential.title : credential.username,
        recordIdentifier: credential.uuid
      )
    }
  }

  private func clearIdentityStore() {
    guard #available(macOS 11.0, *) else { return }
    ASCredentialIdentityStore.shared.removeAllCredentialIdentities { _, _ in }
  }
}
