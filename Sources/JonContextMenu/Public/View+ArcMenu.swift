import SwiftUI

extension View {
    /// Shows the arc menu when the user long-presses this view.
    ///
    /// The menu receives the touches on this view, so taps don't reach controls inside it.
    /// Apply it to content without its own buttons or gestures.
    public func arcMenu(_ items: [ArcMenuItem], style: ArcMenuStyle = ArcMenuStyle()) -> some View {
        overlay(ArcMenuHost(items: items, style: style))
    }
}

private struct ArcMenuHost: UIViewRepresentable {
    let items: [ArcMenuItem]
    let style: ArcMenuStyle

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
    }
}
