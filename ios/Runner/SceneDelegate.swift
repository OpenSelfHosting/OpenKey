import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    super.scene(scene, openURLContexts: URLContexts)
    for context in URLContexts {
      handleAutofillURL(context.url)
    }
  }

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    for context in connectionOptions.urlContexts {
      handleAutofillURL(context.url)
    }
  }

  private func handleAutofillURL(_ url: URL) {
    guard url.scheme?.lowercased() == "openkey" else { return }
    let host = (url.host ?? "").lowercased()
    let path = url.path.lowercased()
    if host == "autofill" && (path.hasPrefix("/save") || path.hasPrefix("/passkey")) {
      (UIApplication.shared.delegate as? AppDelegate)?.notifyAutofillIntent()
    } else if host == "autofill" && path.hasPrefix("/unlock") {
      AutofillCredentialStore.setPendingUnlock(true)
      (UIApplication.shared.delegate as? AppDelegate)?.notifyAutofillIntent()
    }
  }
}
