import AppKit

class StatusBarController: NSObject {
    private var statusItem: NSStatusItem
    private var emailItem = NSMenuItem()

    private let firstNames = ["alice", "bob", "carlos", "diana", "ethan", "fatima",
                               "george", "hiroshi", "isabel", "james", "kavya", "liam",
                               "maria", "nadia", "oliver", "priya", "rachel", "samuel"]
    private let lastNames  = ["johnson", "patel", "wu", "martinez", "okafor", "kim",
                               "andersen", "nguyen", "garcia", "rossi", "singh", "taylor"]
    private let domains    = ["gmail.com", "outlook.com", "yahoo.com", "icloud.com",
                               "protonmail.com", "acme-corp.com", "nexustech.net", "fastmail.com"]

    private var usedEmails = Set<String>()

    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()

        if let button = statusItem.button {
            let img = NSImage(systemSymbolName: "envelope.fill", accessibilityDescription: "MailGen")
            img?.isTemplate = true
            button.image = img
        }

        buildMenu()
    }

    private func buildMenu() {
        let menu = NSMenu()

        emailItem.isEnabled = false
        emailItem.attributedTitle = styledEmail(generate())
        menu.addItem(emailItem)

        menu.addItem(.separator())

        let generate = NSMenuItem(title: "Generate New", action: #selector(generateNew), keyEquivalent: "g")
        generate.target = self
        menu.addItem(generate)

        let copy = NSMenuItem(title: "Copy Email", action: #selector(copyEmail), keyEquivalent: "c")
        copy.target = self
        menu.addItem(copy)

        menu.addItem(.separator())

        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    private func generate() -> String {
        let totalCombinations = firstNames.count * lastNames.count * domains.count * 4
        if usedEmails.count >= totalCombinations { usedEmails.removeAll() }

        var candidate: String
        repeat {
            let first = firstNames.randomElement()!
            let last  = lastNames.randomElement()!
            let domain = domains.randomElement()!
            let styles = ["\(first).\(last)", "\(first)\(last)", "\(first.prefix(1)).\(last)", "\(first)"]
            candidate = "\(styles.randomElement()!)@\(domain)"
        } while usedEmails.contains(candidate)

        usedEmails.insert(candidate)
        return candidate
    }

    private func styledEmail(_ address: String) -> NSAttributedString {
        NSAttributedString(string: address, attributes: [
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular),
            .foregroundColor: NSColor.labelColor
        ])
    }

    @objc private func generateNew() {
        emailItem.attributedTitle = styledEmail(generate())
    }

    @objc private func copyEmail() {
        guard let address = emailItem.attributedTitle?.string else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(address, forType: .string)
    }
}
