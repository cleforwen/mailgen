import AppKit

// Paste your gist's raw URL here (the URL ending in /raw/names.json)
private let namesGistURL = "https://gist.githubusercontent.com/cleforwen/df9835d5558178c2c01cfbb494d42024/raw/609564c6c761b29fcc63048b5efec348df96d012/gistfile1.txt"

private struct NameList: Decodable {
    let firstNames: [String]
    let lastNames: [String]
}

class StatusBarController: NSObject {
    private var statusItem: NSStatusItem
    private var emailItem = NSMenuItem()

    private let defaultFirstNames = ["alice", "bob", "carlos", "diana", "ethan", "fatima",
                                     "george", "hiroshi", "isabel", "james", "kavya", "liam",
                                     "maria", "nadia", "oliver", "priya", "rachel", "samuel"]
    private let defaultLastNames  = ["johnson", "patel", "wu", "martinez", "okafor", "kim",
                                     "andersen", "nguyen", "garcia", "rossi", "singh", "taylor"]
    private let domains           = ["gmail.com", "outlook.com", "yahoo.com", "icloud.com",
                                     "protonmail.com", "acme-corp.com", "nexustech.net", "fastmail.com"]

    private var firstNames: [String] = []
    private var lastNames: [String]  = []
    private var usedEmails = Set<String>()

    override init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()

        firstNames = defaultFirstNames
        lastNames  = defaultLastNames

        if let button = statusItem.button {
            let img = NSImage(systemSymbolName: "envelope.fill", accessibilityDescription: "MailGen")
            img?.isTemplate = true
            button.image = img
        }

        buildMenu()
        fetchRemoteNames()
    }

    private func fetchRemoteNames() {
        guard let url = URL(string: namesGistURL) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data,
                  let list = try? JSONDecoder().decode(NameList.self, from: data),
                  !list.firstNames.isEmpty, !list.lastNames.isEmpty
            else { return }
            DispatchQueue.main.async {
                self.firstNames = list.firstNames
                self.lastNames  = list.lastNames
                self.usedEmails.removeAll()
            }
        }.resume()
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
