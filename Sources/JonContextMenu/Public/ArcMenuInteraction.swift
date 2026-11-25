import UIKit

/// Shows the arc menu when the user long-presses the view it is added to.
///
/// ```swift
/// view.addInteraction(ArcMenuInteraction(items: items))
/// ```
@MainActor
public final class ArcMenuInteraction: NSObject, UIInteraction {
    public static let maximumItemCount = ArcLayout.maximumItemCount

    /// Only the first `maximumItemCount` items are shown. VoiceOver users reach them as custom actions on the view.
    public var items: [ArcMenuItem] {
        didSet { updateAccessibilityActions() }
    }
    public var style: ArcMenuStyle
    public private(set) weak var view: UIView?

    /// Set by the SwiftUI modifier: its view is an empty overlay, so the content is copied
    /// from the window and cut to this path instead of snapshotting the view itself.
    var previewPath: ((CGRect) -> CGPath)?

    private struct OpenMenu {
        let items: [ArcMenuItem]
        let overlay: ArcMenuOverlayView
        var session: MenuSession
    }

    private var openMenu: OpenMenu?
    private var accessibilityActions: [UIAccessibilityCustomAction] = []
    private lazy var longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    private let selectionFeedback = UISelectionFeedbackGenerator()

    public init(items: [ArcMenuItem], style: ArcMenuStyle = ArcMenuStyle()) {
        self.items = items
        self.style = style
    }

    public func willMove(to view: UIView?) {
        closeMenu()
        self.view?.removeGestureRecognizer(longPress)
        removeAccessibilityActions()
    }

    public func didMove(to view: UIView?) {
        self.view = view
        view?.addGestureRecognizer(longPress)
        updateAccessibilityActions()
    }

    private var shownItems: [ArcMenuItem] {
        Array(items.prefix(Self.maximumItemCount))
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            openMenu(at: gesture)
        case .changed:
            moveTouch(of: gesture)
        case .ended:
            selectHighlightedItemAndClose()
        case .cancelled, .failed:
            closeMenu()
        default:
            break
        }
    }

    private func openMenu(at gesture: UILongPressGestureRecognizer) {
        let items = shownItems
        guard let view, let window = view.window, !items.isEmpty else { return }

        let layout = ArcLayout(
            touchPoint: gesture.location(in: window),
            bounds: window.bounds.inset(by: window.safeAreaInsets),
            itemCount: items.count
        )
        let overlay = ArcMenuOverlayView(
            frame: window.bounds,
            layout: layout,
            items: items,
            style: style,
            pressedViewSnapshot: snapshot(of: view, in: window)
        )
        window.addSubview(overlay)
        overlay.present()

        openMenu = OpenMenu(items: items, overlay: overlay, session: MenuSession(layout: layout))
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        selectionFeedback.prepare()
    }

    private func snapshot(of view: UIView, in window: UIWindow) -> UIView? {
        let frame = view.convert(view.bounds, to: window)
        let snapshot: UIView?
        if let previewPath {
            snapshot = window.resizableSnapshotView(from: frame, afterScreenUpdates: false, withCapInsets: .zero)
            let mask = CAShapeLayer()
            mask.path = previewPath(CGRect(origin: .zero, size: frame.size))
            snapshot?.layer.mask = mask
        } else {
            snapshot = view.snapshotView(afterScreenUpdates: false)
        }
        snapshot?.frame = frame
        return snapshot
    }

    private func moveTouch(of gesture: UILongPressGestureRecognizer) {
        guard let overlay = openMenu?.overlay,
              let change = openMenu?.session.moveTouch(to: gesture.location(in: overlay))
        else { return }

        overlay.apply(change)
        if change.current != nil {
            selectionFeedback.selectionChanged()
        }
    }

    private func selectHighlightedItemAndClose() {
        let selectedItem = openMenu.flatMap { menu in
            menu.session.highlightedIndex.map { menu.items[$0] }
        }
        closeMenu()
        selectedItem?.handler()
    }

    private func closeMenu() {
        openMenu?.overlay.dismiss()
        openMenu = nil
    }

    private func updateAccessibilityActions() {
        removeAccessibilityActions()
        accessibilityActions = shownItems.map { item in
            UIAccessibilityCustomAction(name: item.title) { _ in
                item.handler()
                return true
            }
        }
        view?.accessibilityCustomActions = (view?.accessibilityCustomActions ?? []) + accessibilityActions
    }

    private func removeAccessibilityActions() {
        view?.accessibilityCustomActions?.removeAll { action in
            accessibilityActions.contains { $0 === action }
        }
        accessibilityActions = []
    }
}
