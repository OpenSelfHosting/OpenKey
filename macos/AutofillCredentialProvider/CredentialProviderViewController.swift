import AuthenticationServices
import Cocoa
import LocalAuthentication

@objc(CredentialProviderViewController)
final class CredentialProviderViewController: ASCredentialProviderViewController {
  private var serviceIdentifiers: [ASCredentialServiceIdentifier] = []
  private var matches: [AutofillCredentialRecord] = []
  private var rows: [ListRow] = []
  private var tableView: NSTableView?
  private var scrollView: NSScrollView?
  private var statusLabel: NSTextField?

  private enum ListRow {
    case login(AutofillCredentialRecord)
    case suggestPassword
    case managePasswords
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    preferredContentSize = NSSize(width: 420, height: 360)
    buildUI()
  }

  override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
    self.serviceIdentifiers = serviceIdentifiers
    reloadMatches()
  }

  override func provideCredentialWithoutUserInteraction(
    for credentialIdentity: ASPasswordCredentialIdentity
  ) {
    guard AutofillCredentialStore.isUnlocked else {
      self.extensionContext.cancelRequest(
        withError: NSError(
          domain: ASExtensionErrorDomain,
          code: ASExtensionError.userInteractionRequired.rawValue
        )
      )
      return
    }

    if AutofillCredentialStore.requireBiometric {
      self.extensionContext.cancelRequest(
        withError: NSError(
          domain: ASExtensionErrorDomain,
          code: ASExtensionError.userInteractionRequired.rawValue
        )
      )
      return
    }

    let records = AutofillCredentialStore.loadCredentials()
    let match =
      records.first { $0.uuid == credentialIdentity.recordIdentifier }
      ?? records.first { $0.username == credentialIdentity.user }

    guard let match else {
      self.extensionContext.cancelRequest(
        withError: NSError(
          domain: ASExtensionErrorDomain,
          code: ASExtensionError.credentialIdentityNotFound.rawValue
        )
      )
      return
    }

    let credential = ASPasswordCredential(
      user: match.username,
      password: match.password
    )
    self.extensionContext.completeRequest(withSelectedCredential: credential)
  }

  @available(macOSApplicationExtension 14.0, *)
  override func provideCredentialWithoutUserInteraction(for credentialRequest: ASCredentialRequest) {
    if let passkeyRequest = credentialRequest as? ASPasskeyCredentialRequest {
      guard AutofillCredentialStore.isUnlocked else {
        extensionContext.cancelRequest(
          withError: NSError(
            domain: ASExtensionErrorDomain,
            code: ASExtensionError.userInteractionRequired.rawValue
          )
        )
        return
      }
      if AutofillCredentialStore.requireBiometric {
        extensionContext.cancelRequest(
          withError: NSError(
            domain: ASExtensionErrorDomain,
            code: ASExtensionError.userInteractionRequired.rawValue
          )
        )
        return
      }
      do {
        try completePasskeyAssertion(for: passkeyRequest)
      } catch {
        extensionContext.cancelRequest(
          withError: NSError(
            domain: ASExtensionErrorDomain,
            code: ASExtensionError.failed.rawValue
          )
        )
      }
      return
    }
    if let passwordIdentity = credentialRequest.credentialIdentity as? ASPasswordCredentialIdentity {
      provideCredentialWithoutUserInteraction(for: passwordIdentity)
      return
    }
    extensionContext.cancelRequest(
      withError: NSError(
        domain: ASExtensionErrorDomain,
        code: ASExtensionError.failed.rawValue
      )
    )
  }

  @available(macOSApplicationExtension 14.0, *)
  override func prepareInterfaceToProvideCredential(for credentialRequest: ASCredentialRequest) {
    if let passkeyRequest = credentialRequest as? ASPasskeyCredentialRequest {
      do {
        try completePasskeyAssertion(for: passkeyRequest)
      } catch {
        extensionContext.cancelRequest(
          withError: NSError(
            domain: ASExtensionErrorDomain,
            code: ASExtensionError.failed.rawValue
          )
        )
      }
      return
    }
    if let passwordIdentity = credentialRequest.credentialIdentity as? ASPasswordCredentialIdentity {
      prepareCredentialList(for: [passwordIdentity.serviceIdentifier])
    }
  }

  @available(macOSApplicationExtension 14.0, *)
  override func prepareInterface(forPasskeyRegistration registrationRequest: ASCredentialRequest) {
    guard let request = registrationRequest as? ASPasskeyCredentialRequest,
          let identity = request.credentialIdentity as? ASPasskeyCredentialIdentity,
          AutofillCredentialStore.isUnlocked
    else {
      extensionContext.cancelRequest(
        withError: NSError(
          domain: ASExtensionErrorDomain,
          code: ASExtensionError.userInteractionRequired.rawValue
        )
      )
      return
    }
    do {
      let created = try PasskeyAuthenticator.create(
        rpId: identity.relyingPartyIdentifier,
        userName: identity.userName,
        displayName: identity.userName,
        userHandle: identity.userHandle,
        clientDataHash: request.clientDataHash
      )
      let uuid = UUID().uuidString.lowercased()
      let record = AutofillCredentialRecord(
        uuid: uuid,
        title: identity.relyingPartyIdentifier,
        username: identity.userName,
        password: "",
        urls: ["https://\(identity.relyingPartyIdentifier)"],
        passkey: created.passkey
      )
      AutofillCredentialStore.upsertPasskey(record)
      AutofillCredentialStore.enqueuePasskeySave(
        AutofillPendingPasskeySave(
          uuid: uuid,
          title: identity.relyingPartyIdentifier,
          username: identity.userName,
          urls: ["https://\(identity.relyingPartyIdentifier)"],
          passkey: created.passkey
        )
      )
      let credential = ASPasskeyRegistrationCredential(
        relyingParty: identity.relyingPartyIdentifier,
        clientDataHash: request.clientDataHash,
        credentialID: created.credentialId,
        attestationObject: created.attestationObject
      )
      extensionContext.completeRegistrationRequest(using: credential, completionHandler: nil)
    } catch {
      extensionContext.cancelRequest(
        withError: NSError(
          domain: ASExtensionErrorDomain,
          code: ASExtensionError.failed.rawValue
        )
      )
    }
  }

  @available(macOSApplicationExtension 14.0, *)
  private func completePasskeyAssertion(for request: ASPasskeyCredentialRequest) throws {
    guard let identity = request.credentialIdentity as? ASPasskeyCredentialIdentity else {
      throw PasskeyAuthenticator.AuthError.missingPrivateKey
    }
    let records = AutofillCredentialStore.loadCredentials()
    let match =
      records.first { $0.uuid == identity.recordIdentifier } ??
      records.first {
        $0.passkey.map { PasskeyAuthenticator.fromB64Url($0.credentialId) } == identity.credentialID
      }
    guard let match, let passkey = match.passkey else {
      throw PasskeyAuthenticator.AuthError.missingPrivateKey
    }
    let asserted = try PasskeyAuthenticator.assert(
      passkey: passkey,
      clientDataHash: request.clientDataHash
    )
    AutofillCredentialStore.updatePasskeySignCount(
      uuid: match.uuid,
      signCount: asserted.nextSignCount
    )
    let credential = ASPasskeyAssertionCredential(
      userHandle: asserted.userHandle ?? Data(),
      relyingParty: passkey.rpId,
      signature: asserted.signature,
      clientDataHash: request.clientDataHash,
      authenticatorData: asserted.authenticatorData,
      credentialID: asserted.credentialId
    )
    extensionContext.completeAssertionRequest(using: credential, completionHandler: nil)
  }

  private func reloadMatches() {
    let ids = serviceIdentifiers.map(\.identifier)
    if !AutofillCredentialStore.isUnlocked {
      matches = []
      statusLabel?.stringValue =
        "Unlock OpenKey to autofill passwords for this site."
      rebuildRows()
      tableView?.reloadData()
      return
    }

    matches = AutofillCredentialStore.match(serviceIdentifiers: ids)
    if matches.isEmpty {
      statusLabel?.stringValue = "No matching logins in OpenKey for this site."
    } else {
      statusLabel?.stringValue = "Select a login to fill"
    }
    rebuildRows()
    tableView?.reloadData()
  }

  private func rebuildRows() {
    rows = matches.map { .login($0) }
    if matches.isEmpty {
      rows.append(.suggestPassword)
    }
    rows.append(.managePasswords)
  }

  private func buildUI() {
    view.wantsLayer = true

    let title = NSTextField(labelWithString: "OpenKey")
    title.font = .systemFont(ofSize: 18, weight: .semibold)
    title.translatesAutoresizingMaskIntoConstraints = false

    let status = NSTextField(labelWithString: "")
    status.font = .systemFont(ofSize: 12)
    status.textColor = .secondaryLabelColor
    status.translatesAutoresizingMaskIntoConstraints = false
    statusLabel = status

    let cancel = NSButton(
      title: "Cancel",
      target: self,
      action: #selector(cancelTapped)
    )
    cancel.bezelStyle = .rounded
    cancel.translatesAutoresizingMaskIntoConstraints = false

    let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("login"))
    column.title = "Login"
    column.width = 380

    let table = NSTableView()
    table.headerView = nil
    table.addTableColumn(column)
    table.delegate = self
    table.dataSource = self
    table.target = self
    table.doubleAction = #selector(rowDoubleClicked)
    table.translatesAutoresizingMaskIntoConstraints = false
    tableView = table

    let scroll = NSScrollView()
    scroll.documentView = table
    scroll.hasVerticalScroller = true
    scroll.borderType = .bezelBorder
    scroll.translatesAutoresizingMaskIntoConstraints = false
    scrollView = scroll

    view.addSubview(title)
    view.addSubview(status)
    view.addSubview(scroll)
    view.addSubview(cancel)

    NSLayoutConstraint.activate([
      title.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
      title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

      status.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
      status.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      status.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

      scroll.topAnchor.constraint(equalTo: status.bottomAnchor, constant: 12),
      scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      scroll.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -12),

      cancel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      cancel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
    ])
  }

  @objc private func cancelTapped() {
    extensionContext.cancelRequest(
      withError: NSError(
        domain: ASExtensionErrorDomain,
        code: ASExtensionError.userCanceled.rawValue
      )
    )
  }

  @objc private func rowDoubleClicked() {
    fillSelectedRow()
  }

  private func fillSelectedRow() {
    let row = tableView?.selectedRow ?? -1
    guard row >= 0, row < rows.count else { return }
    switch rows[row] {
    case .login(let match):
      confirmBiometricIfNeeded { [weak self] ok in
        guard let self else { return }
        guard ok else {
          self.extensionContext.cancelRequest(
            withError: NSError(
              domain: ASExtensionErrorDomain,
              code: ASExtensionError.userCanceled.rawValue
            )
          )
          return
        }
        let credential = ASPasswordCredential(user: match.username, password: match.password)
        self.extensionContext.completeRequest(withSelectedCredential: credential)
      }
    case .suggestPassword:
      let credential = ASPasswordCredential(
        user: "",
        password: AutofillPasswordGenerator.generate()
      )
      extensionContext.completeRequest(withSelectedCredential: credential)
    case .managePasswords:
      if let url = URL(string: "openkey://autofill/unlock") {
        NSWorkspace.shared.open(url)
      }
      cancelTapped()
    }
  }

  private func confirmBiometricIfNeeded(completion: @escaping (Bool) -> Void) {
    guard AutofillCredentialStore.requireBiometric else {
      completion(true)
      return
    }
    let context = LAContext()
    var error: NSError?
    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
      completion(true)
      return
    }
    context.evaluatePolicy(
      .deviceOwnerAuthenticationWithBiometrics,
      localizedReason: "Confirm Autofill with OpenKey"
    ) { success, _ in
      DispatchQueue.main.async {
        completion(success)
      }
    }
  }
}

extension CredentialProviderViewController: NSTableViewDataSource, NSTableViewDelegate {
  func numberOfRows(in tableView: NSTableView) -> Int {
    rows.count
  }

  func tableView(
    _ tableView: NSTableView,
    viewFor tableColumn: NSTableColumn?,
    row: Int
  ) -> NSView? {
    guard row >= 0, row < rows.count else { return nil }
    let id = NSUserInterfaceItemIdentifier("cell")
    let cell =
      (tableView.makeView(withIdentifier: id, owner: nil) as? NSTableCellView)
      ?? {
        let text = NSTextField(labelWithString: "")
        text.lineBreakMode = .byTruncatingTail
        let view = NSTableCellView()
        view.identifier = id
        view.addSubview(text)
        view.textField = text
        text.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          text.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
          text.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
          text.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        return view
      }()

    switch rows[row] {
    case .login(let match):
      let user = match.username.isEmpty ? match.title : match.username
      cell.textField?.stringValue = "\(user)   ••••••••"
    case .suggestPassword:
      cell.textField?.stringValue = "Suggest password   ••••••••"
    case .managePasswords:
      cell.textField?.stringValue = "Manage passwords..."
    }
    return cell
  }

  func tableViewSelectionDidChange(_ notification: Notification) {
    // Single-click select then require double-click / Return — also fill on single click for speed.
    fillSelectedRow()
  }
}
