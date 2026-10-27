import AuthenticationServices
import LocalAuthentication
import UIKit

@objc(CredentialProviderViewController)
final class CredentialProviderViewController: ASCredentialProviderViewController {
  private enum Mode {
    case fill
    case save
    case passkeyFill
    case passkeyRegister
  }

  private var mode: Mode = .fill
  private var serviceIdentifiers: [ASCredentialServiceIdentifier] = []
  private var matches: [AutofillCredentialRecord] = []
  private var passkeyMatches: [AutofillCredentialRecord] = []
  private var pendingSaveRequest: AutofillPendingSave?
  private var passkeyRequest: Any?
  private var passkeyListParameters: Any?
  private var registrationRequest: Any?

  private let tableView = UITableView(frame: .zero, style: .insetGrouped)
  private let statusLabel = UILabel()
  private let saveButton = UIButton(type: .system)
  private let confirmPasskeyButton = UIButton(type: .system)
  private var saveDetailLabels: [UILabel] = []
  private var rows: [ListRow] = []

  private enum ListRow {
    case login(AutofillCredentialRecord)
    case passkey(AutofillCredentialRecord)
    case suggestPassword
    case managePasswords
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemGroupedBackground
    buildUI()
  }

  override func prepareCredentialList(for serviceIdentifiers: [ASCredentialServiceIdentifier]) {
    mode = .fill
    pendingSaveRequest = nil
    passkeyRequest = nil
    passkeyListParameters = nil
    registrationRequest = nil
    self.serviceIdentifiers = serviceIdentifiers
    reloadMatches()
    updateChrome()
  }

  @available(iOSApplicationExtension 17.0, *)
  override func prepareCredentialList(
    for serviceIdentifiers: [ASCredentialServiceIdentifier],
    requestParameters: ASPasskeyCredentialRequestParameters
  ) {
    mode = .passkeyFill
    pendingSaveRequest = nil
    registrationRequest = nil
    passkeyRequest = nil
    passkeyListParameters = requestParameters
    self.serviceIdentifiers = serviceIdentifiers
    passkeyMatches = AutofillCredentialStore.matchPasskeys(
      rpId: requestParameters.relyingPartyIdentifier,
      serviceIdentifiers: serviceIdentifiers.map(\.identifier)
    )
    let allowed = requestParameters.allowedCredentials
    if !allowed.isEmpty {
      passkeyMatches = passkeyMatches.filter { record in
        guard let id = record.passkey?.credentialId else { return false }
        let data = PasskeyAuthenticator.fromB64Url(id)
        return allowed.contains(data)
      }
    }
    matches = []
    if !AutofillCredentialStore.isUnlocked {
      statusLabel.text = "Unlock OpenKey to use passkeys for this site."
    } else if passkeyMatches.isEmpty {
      statusLabel.text = "No matching passkeys in OpenKey for this site."
    } else {
      statusLabel.text = "Select a passkey"
    }
    rebuildRows()
    tableView.reloadData()
    updateChrome()
  }

  override func provideCredentialWithoutUserInteraction(
    for credentialIdentity: ASPasswordCredentialIdentity
  ) {
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

    let records = AutofillCredentialStore.loadCredentials()
    let match =
      records.first { $0.uuid == credentialIdentity.recordIdentifier }
      ?? records.first { $0.username == credentialIdentity.user }

    guard let match else {
      extensionContext.cancelRequest(
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
    extensionContext.completeRequest(withSelectedCredential: credential)
  }

  @available(iOSApplicationExtension 17.0, *)
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
        try completePasskeyAssertion(for: passkeyRequest, recordIdentifier: passkeyRequest.credentialIdentity.recordIdentifier)
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

  @available(iOSApplicationExtension 17.0, *)
  override func prepareInterfaceToProvideCredential(for credentialRequest: ASCredentialRequest) {
    if let passkeyRequest = credentialRequest as? ASPasskeyCredentialRequest {
      mode = .passkeyFill
      self.passkeyRequest = passkeyRequest
      guard let identity = passkeyRequest.credentialIdentity as? ASPasskeyCredentialIdentity else {
        cancelFailed()
        return
      }
      passkeyMatches = AutofillCredentialStore.loadCredentials().filter {
        $0.uuid == identity.recordIdentifier ||
          $0.passkey?.credentialId == PasskeyAuthenticator.toB64Url(identity.credentialID)
      }
      if passkeyMatches.isEmpty {
        passkeyMatches = AutofillCredentialStore.matchPasskeys(
          rpId: identity.relyingPartyIdentifier,
          serviceIdentifiers: [identity.relyingPartyIdentifier]
        )
      }
      statusLabel.text = AutofillCredentialStore.isUnlocked
        ? "Confirm passkey for \(identity.relyingPartyIdentifier)"
        : "Unlock OpenKey to use this passkey."
      rebuildRows()
      tableView.reloadData()
      updateChrome()
      return
    }
    if let passwordIdentity = credentialRequest.credentialIdentity as? ASPasswordCredentialIdentity {
      prepareCredentialList(for: [passwordIdentity.serviceIdentifier])
    }
  }

  @available(iOSApplicationExtension 17.0, *)
  override func prepareInterface(forPasskeyRegistration registrationRequest: ASCredentialRequest) {
    guard let request = registrationRequest as? ASPasskeyCredentialRequest else {
      extensionContext.cancelRequest(
        withError: NSError(
          domain: ASExtensionErrorDomain,
          code: ASExtensionError.failed.rawValue
        )
      )
      return
    }
    mode = .passkeyRegister
    self.registrationRequest = request
    matches = []
    passkeyMatches = []
    let rpId =
      (request.credentialIdentity as? ASPasskeyCredentialIdentity)?.relyingPartyIdentifier
      ?? "this site"
    statusLabel.text = AutofillCredentialStore.isUnlocked
      ? "Create an OpenKey passkey for \(rpId)?"
      : "Unlock OpenKey first, then try creating the passkey again."
    updateChrome()
  }

  // MARK: - Save password (iOS 26.2+)

  @available(iOSApplicationExtension 26.2, *)
  override func performWithoutUserInteractionIfPossible(
    savePasswordRequest: ASSavePasswordRequest
  ) {
    if savePasswordRequest.event == .generatedPasswordFilled {
      let pending = Self.pendingSave(from: savePasswordRequest)
      AutofillCredentialStore.setPendingSave(pending)
      extensionContext.completeSavePasswordRequest(completionHandler: nil)
      return
    }

    extensionContext.cancelRequest(
      withError: NSError(
        domain: ASExtensionErrorDomain,
        code: ASExtensionError.userInteractionRequired.rawValue
      )
    )
  }

  @available(iOSApplicationExtension 26.2, *)
  override func prepareInterface(for savePasswordRequest: ASSavePasswordRequest) {
    mode = .save
    matches = []
    passkeyMatches = []
    pendingSaveRequest = Self.pendingSave(from: savePasswordRequest)
    updateChrome()
  }

  @available(iOSApplicationExtension 26.2, *)
  private static func pendingSave(from request: ASSavePasswordRequest) -> AutofillPendingSave {
    let identifier = request.serviceIdentifier.identifier
    let uri: String
    switch request.serviceIdentifier.type {
    case .URL:
      uri = identifier.contains("://") ? identifier : "https://\(identifier)"
    case .domain:
      uri = identifier.contains("://") ? identifier : "https://\(identifier)"
    @unknown default:
      uri = identifier
    }
    return AutofillPendingSave(
      username: request.credential.user,
      password: request.credential.password,
      uri: uri,
      packageName: "",
      title: request.title
    )
  }

  private func reloadMatches() {
    let ids = serviceIdentifiers.map(\.identifier)
    if !AutofillCredentialStore.isUnlocked {
      matches = []
      statusLabel.text = "Unlock OpenKey to autofill passwords for this site."
      tableView.reloadData()
      return
    }

    matches = AutofillCredentialStore.match(serviceIdentifiers: ids)
    if matches.isEmpty {
      statusLabel.text = "No matching logins in OpenKey for this site."
    } else {
      statusLabel.text = "Select a login to fill"
    }
    rebuildRows()
    tableView.reloadData()
  }

  private func rebuildRows() {
    switch mode {
    case .fill:
      rows = matches.map { .login($0) }
      if matches.isEmpty {
        rows.append(.suggestPassword)
      }
      rows.append(.managePasswords)
    case .passkeyFill:
      rows = passkeyMatches.map { .passkey($0) }
      rows.append(.managePasswords)
    case .save, .passkeyRegister:
      rows = []
    }
  }

  private func updateChrome() {
    rebuildRows()
    tableView.reloadData()
    switch mode {
    case .fill, .passkeyFill:
      statusLabel.isHidden = false
      tableView.isHidden = false
      saveButton.isHidden = true
      confirmPasskeyButton.isHidden = mode != .passkeyFill || passkeyRequest == nil || passkeyMatches.count != 1
      saveDetailLabels.forEach { $0.isHidden = true }
    case .save:
      statusLabel.isHidden = false
      statusLabel.text = "Save this login to your OpenKey vault?"
      tableView.isHidden = true
      saveButton.isHidden = false
      confirmPasskeyButton.isHidden = true
      saveDetailLabels.forEach { $0.isHidden = false }
      applySaveDetails()
    case .passkeyRegister:
      statusLabel.isHidden = false
      tableView.isHidden = true
      saveButton.isHidden = true
      confirmPasskeyButton.isHidden = false
      confirmPasskeyButton.setTitle("Create passkey", for: .normal)
      saveDetailLabels.forEach { $0.isHidden = true }
    }
  }

  private func applySaveDetails() {
    guard let pending = pendingSaveRequest else { return }
    let title =
      (pending.title?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap {
        $0.isEmpty ? nil : $0
      }
      ?? suggestedTitle(for: pending)
    let lines = [
      title,
      pending.username.isEmpty ? "(no username)" : pending.username,
      pending.uri.isEmpty ? "" : pending.uri,
    ]
    for (index, label) in saveDetailLabels.enumerated() {
      label.text = index < lines.count ? lines[index] : ""
    }
  }

  private func suggestedTitle(for pending: AutofillPendingSave) -> String {
    if !pending.uri.isEmpty, let host = URL(string: pending.uri)?.host, !host.isEmpty {
      return host
    }
    if !pending.username.isEmpty { return pending.username }
    return "Login"
  }

  private func buildUI() {
    let title = UILabel()
    title.text = "OpenKey"
    title.font = .systemFont(ofSize: 22, weight: .semibold)
    title.translatesAutoresizingMaskIntoConstraints = false

    statusLabel.font = .systemFont(ofSize: 14)
    statusLabel.textColor = .secondaryLabel
    statusLabel.numberOfLines = 0
    statusLabel.translatesAutoresizingMaskIntoConstraints = false

    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "login")
    tableView.translatesAutoresizingMaskIntoConstraints = false

    let detailStack = UIStackView()
    detailStack.axis = .vertical
    detailStack.spacing = 6
    detailStack.translatesAutoresizingMaskIntoConstraints = false
    for i in 0..<3 {
      let label = UILabel()
      label.numberOfLines = i == 0 ? 1 : 2
      label.font = i == 0
        ? .systemFont(ofSize: 17, weight: .semibold)
        : .systemFont(ofSize: 14)
      label.textColor = i == 0 ? .label : .secondaryLabel
      label.translatesAutoresizingMaskIntoConstraints = false
      label.isHidden = true
      detailStack.addArrangedSubview(label)
      saveDetailLabels.append(label)
    }

    saveButton.setTitle("Save to OpenKey", for: .normal)
    stylePrimaryButton(saveButton)
    saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    saveButton.isHidden = true

    confirmPasskeyButton.setTitle("Use passkey", for: .normal)
    stylePrimaryButton(confirmPasskeyButton)
    confirmPasskeyButton.addTarget(self, action: #selector(confirmPasskeyTapped), for: .touchUpInside)
    confirmPasskeyButton.isHidden = true

    let cancel = UIButton(type: .system)
    cancel.setTitle("Cancel", for: .normal)
    cancel.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    cancel.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(title)
    view.addSubview(statusLabel)
    view.addSubview(tableView)
    view.addSubview(detailStack)
    view.addSubview(saveButton)
    view.addSubview(confirmPasskeyButton)
    view.addSubview(cancel)

    NSLayoutConstraint.activate([
      title.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      title.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

      statusLabel.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
      statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

      tableView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: cancel.topAnchor, constant: -8),

      detailStack.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
      detailStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      detailStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

      saveButton.topAnchor.constraint(equalTo: detailStack.bottomAnchor, constant: 24),
      saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

      confirmPasskeyButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 24),
      confirmPasskeyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      confirmPasskeyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

      cancel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      cancel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
    ])
  }

  private func stylePrimaryButton(_ button: UIButton) {
    button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
    button.backgroundColor = .systemBlue
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 12
    button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
    button.translatesAutoresizingMaskIntoConstraints = false
  }

  @objc private func cancelTapped() {
    extensionContext.cancelRequest(
      withError: NSError(
        domain: ASExtensionErrorDomain,
        code: ASExtensionError.userCanceled.rawValue
      )
    )
  }

  @objc private func saveTapped() {
    guard let pending = pendingSaveRequest else {
      cancelTapped()
      return
    }
    AutofillCredentialStore.setPendingSave(pending)
    openHostApp(path: "save")
  }

  @objc private func confirmPasskeyTapped() {
    if mode == .passkeyRegister {
      createPasskey()
      return
    }
    if #available(iOSApplicationExtension 17.0, *),
       let request = passkeyRequest as? ASPasskeyCredentialRequest,
       let record = passkeyMatches.first
    {
      do {
        try completePasskeyAssertion(for: request, recordIdentifier: record.uuid)
      } catch {
        cancelFailed()
      }
    }
  }

  private func createPasskey() {
    guard #available(iOSApplicationExtension 17.0, *),
          let request = registrationRequest as? ASPasskeyCredentialRequest
    else {
      cancelFailed()
      return
    }
    guard AutofillCredentialStore.isUnlocked else {
      AutofillCredentialStore.setPendingUnlock(true)
      openHostApp(path: "unlock")
      return
    }

    let identity = request.credentialIdentity as? ASPasskeyCredentialIdentity
    guard let identity else {
      cancelFailed()
      return
    }
    let rpId = identity.relyingPartyIdentifier
    let userName = identity.userName
    let userHandle = identity.userHandle
    let clientDataHash = request.clientDataHash

    do {
      let created = try PasskeyAuthenticator.create(
        rpId: rpId,
        userName: userName,
        displayName: userName,
        userHandle: userHandle,
        clientDataHash: clientDataHash
      )
      let uuid = UUID().uuidString.lowercased()
      let record = AutofillCredentialRecord(
        uuid: uuid,
        title: rpId,
        username: userName,
        password: "",
        urls: ["https://\(rpId)"],
        passkey: created.passkey
      )
      AutofillCredentialStore.upsertPasskey(record)
      AutofillCredentialStore.enqueuePasskeySave(
        AutofillPendingPasskeySave(
          uuid: uuid,
          title: rpId,
          username: userName,
          urls: ["https://\(rpId)"],
          passkey: created.passkey
        )
      )
      openHostApp(path: "passkey")

      let credential = ASPasskeyRegistrationCredential(
        relyingParty: rpId,
        clientDataHash: clientDataHash,
        credentialID: created.credentialId,
        attestationObject: created.attestationObject
      )
      extensionContext.completeRegistrationRequest(using: credential, completionHandler: nil)
    } catch {
      cancelFailed()
    }
  }

  @available(iOSApplicationExtension 17.0, *)
  private func completePasskeyAssertion(
    for request: ASPasskeyCredentialRequest,
    recordIdentifier: String?
  ) throws {
    guard let identity = request.credentialIdentity as? ASPasskeyCredentialIdentity else {
      throw PasskeyAuthenticator.AuthError.missingPrivateKey
    }
    try completePasskeyAssertion(
      clientDataHash: request.clientDataHash,
      recordIdentifier: recordIdentifier ?? identity.recordIdentifier,
      credentialID: identity.credentialID
    )
  }

  @available(iOSApplicationExtension 17.0, *)
  private func completePasskeyAssertion(
    clientDataHash: Data,
    recordIdentifier: String?,
    credentialID: Data?
  ) throws {
    let records = AutofillCredentialStore.loadCredentials()
    let match =
      records.first { $0.uuid == recordIdentifier } ??
      records.first { record in
        guard let credentialID, let id = record.passkey?.credentialId else { return false }
        return PasskeyAuthenticator.fromB64Url(id) == credentialID
      }

    guard let match, let passkey = match.passkey else {
      throw PasskeyAuthenticator.AuthError.missingPrivateKey
    }

    let asserted = try PasskeyAuthenticator.assert(
      passkey: passkey,
      clientDataHash: clientDataHash
    )
    AutofillCredentialStore.updatePasskeySignCount(
      uuid: match.uuid,
      signCount: asserted.nextSignCount
    )
    openHostApp(path: "passkey")

    let credential = ASPasskeyAssertionCredential(
      userHandle: asserted.userHandle ?? Data(),
      relyingParty: passkey.rpId,
      signature: asserted.signature,
      clientDataHash: clientDataHash,
      authenticatorData: asserted.authenticatorData,
      credentialID: asserted.credentialId
    )
    extensionContext.completeAssertionRequest(using: credential, completionHandler: nil)
  }

  private func openHostApp(path: String) {
    guard let url = URL(string: "openkey://autofill/\(path)") else { return }
    extensionContext.open(url) { _ in }
  }

  private func completeSaveIfPossible() {
    if #available(iOSApplicationExtension 26.2, *) {
      extensionContext.completeSavePasswordRequest(completionHandler: nil)
    } else {
      extensionContext.cancelRequest(
        withError: NSError(
          domain: ASExtensionErrorDomain,
          code: ASExtensionError.failed.rawValue
        )
      )
    }
  }

  private func cancelFailed() {
    extensionContext.cancelRequest(
      withError: NSError(
        domain: ASExtensionErrorDomain,
        code: ASExtensionError.failed.rawValue
      )
    )
  }

  private func fillPassword(_ match: AutofillCredentialRecord) {
    confirmBiometricIfNeeded { [weak self] ok in
      guard let self else { return }
      guard ok else {
        self.cancelTapped()
        return
      }
      let credential = ASPasswordCredential(user: match.username, password: match.password)
      self.extensionContext.completeRequest(withSelectedCredential: credential)
    }
  }

  private func fillGeneratedPassword() {
    let password = AutofillPasswordGenerator.generate()
    let credential = ASPasswordCredential(user: "", password: password)
    extensionContext.completeRequest(withSelectedCredential: credential)
  }

  private func openManagePasswords() {
    openHostApp(path: "unlock")
    cancelTapped()
  }

  private func fillPasskey(_ match: AutofillCredentialRecord) {
    guard #available(iOSApplicationExtension 17.0, *) else { return }
    confirmBiometricIfNeeded { [weak self] ok in
      guard let self else { return }
      guard ok else {
        self.cancelTapped()
        return
      }
      do {
        if let request = self.passkeyRequest as? ASPasskeyCredentialRequest {
          try self.completePasskeyAssertion(for: request, recordIdentifier: match.uuid)
        } else if let params = self.passkeyListParameters as? ASPasskeyCredentialRequestParameters {
          try self.completePasskeyAssertion(
            clientDataHash: params.clientDataHash,
            recordIdentifier: match.uuid,
            credentialID: match.passkey.map { PasskeyAuthenticator.fromB64Url($0.credentialId) }
          )
        } else {
          self.cancelFailed()
        }
      } catch {
        self.cancelFailed()
      }
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
      // Biometrics unavailable — allow fill so Autofill is not permanently blocked.
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

extension CredentialProviderViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    rows.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "login", for: indexPath)
    var content = UIListContentConfiguration.subtitleCell()
    switch rows[indexPath.row] {
    case .login(let match):
      let user = match.username.isEmpty ? match.title : match.username
      content.image = UIImage(systemName: "key.fill")
      content.text = user
      content.secondaryText = "••••••••"
      cell.accessoryType = .none
    case .passkey(let match):
      let user = match.passkey?.userName?.isEmpty == false
        ? match.passkey!.userName!
        : (match.username.isEmpty ? match.title : match.username)
      content.image = UIImage(systemName: "person.badge.key.fill")
      content.text = user
      content.secondaryText = match.passkey?.rpId ?? match.urls.first
      cell.accessoryType = .none
    case .suggestPassword:
      content.image = UIImage(systemName: "sparkles")
      content.text = "Suggest password"
      content.secondaryText = "••••••••"
      cell.accessoryType = .none
    case .managePasswords:
      content.image = UIImage(systemName: "folder")
      content.text = "Manage passwords..."
      content.secondaryText = nil
      cell.accessoryType = .disclosureIndicator
    }
    cell.contentConfiguration = content
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    switch rows[indexPath.row] {
    case .login(let match):
      fillPassword(match)
    case .passkey(let match):
      fillPasskey(match)
    case .suggestPassword:
      fillGeneratedPassword()
    case .managePasswords:
      openManagePasswords()
    }
  }
}
