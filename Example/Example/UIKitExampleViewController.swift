import JonContextMenu
import SwiftUI
import UIKit

struct UIKitExampleView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: UIKitExampleViewController())
    }

    func updateUIViewController(_ controller: UINavigationController, context: Context) {}
}

final class UIKitExampleViewController: UITableViewController {
    private let menus = SampleMenu.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIKit"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseIdentifier)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menus.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.reuseIdentifier, for: indexPath)
        let menu = menus[indexPath.row]
        (cell as? MenuCell)?.configure(with: menu) { [weak self] title in
            self?.showSelection(title)
        }
        return cell
    }

    private func showSelection(_ title: String) {
        let alert = UIAlertController(title: "You selected \(title)", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

private final class MenuCell: UITableViewCell {
    static let reuseIdentifier = "MenuCell"

    private let menuInteraction = ArcMenuInteraction(items: [])

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        addInteraction(menuInteraction)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func configure(with menu: SampleMenu, onSelect: @escaping @MainActor (String) -> Void) {
        var content = defaultContentConfiguration()
        content.text = menu.title
        content.secondaryText = "Long-press to open the menu"
        content.image = UIImage(systemName: "hand.tap")
        contentConfiguration = content

        menuInteraction.items = menu.items(onSelect: onSelect)
        menuInteraction.style = menu.style
    }
}
