import JonContextMenu
import SwiftUI

struct SwiftUIExampleView: View {
    @State private var selectedTitle = ""
    @State private var isShowingSelection = false

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(SampleMenu.allCases, id: \.self) { menu in
                        card(for: menu)
                    }
                }
                .padding()
            }
            .navigationTitle("SwiftUI")
            .alert("You selected \(selectedTitle)", isPresented: $isShowingSelection) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private func card(for menu: SampleMenu) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "hand.tap")
                .font(.largeTitle)
            Text(menu.title)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))
        .arcMenu(menu.items(onSelect: showSelection), style: menu.style)
    }

    private func showSelection(_ title: String) {
        selectedTitle = title
        isShowingSelection = true
    }
}
