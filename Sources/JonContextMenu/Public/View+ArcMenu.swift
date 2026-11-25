import SwiftUI

extension View {
    /// Shows the arc menu when the user long-presses this view.
    ///
    /// The menu receives the touches on this view, so taps don't reach controls inside it.
    /// Apply it to content without its own buttons or gestures.
    public func arcMenu(_ items: [ArcMenuItem], style: ArcMenuStyle = ArcMenuStyle()) -> some View {
        arcMenu(items, style: style, previewShape: Rectangle())
    }

    /// `previewShape` is the outline this view keeps above the dimmed background while the
    /// menu is open. Pass the same shape the view is clipped or filled with.
    public func arcMenu(
        _ items: [ArcMenuItem],
        style: ArcMenuStyle = ArcMenuStyle(),
        previewShape: some Shape
    ) -> some View {
        overlay(ArcMenuHost(items: items, style: style, previewShape: previewShape))
    }
}

private struct ArcMenuHost<PreviewShape: Shape>: UIViewRepresentable {
    let items: [ArcMenuItem]
    let style: ArcMenuStyle
    let previewShape: PreviewShape

    func makeCoordinator() -> ArcMenuInteraction {
        ArcMenuInteraction(items: items, style: style)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.addInteraction(context.coordinator)
        return view
    }

    func updateUIView(_ view: UIView, context: Context) {
        context.coordinator.items = items
        context.coordinator.style = style
        context.coordinator.previewPath = { previewShape.path(in: $0).cgPath }
    }
}
