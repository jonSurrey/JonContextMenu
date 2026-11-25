import UIKit

public struct ArcMenuItem {
    public let title: String
    public let image: UIImage?
    let handler: @MainActor () -> Void

    /// `handler` runs when the user lifts their finger on this item.
    public init(title: String, image: UIImage?, handler: @escaping @MainActor () -> Void) {
        self.title = title
        self.image = image
        self.handler = handler
    }
}
