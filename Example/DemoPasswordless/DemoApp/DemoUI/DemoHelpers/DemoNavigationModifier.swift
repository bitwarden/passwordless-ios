import SwiftUI

struct DemoNavigationModifier: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.primaryBitwarden, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

extension View {
    func navigationStyle(
        _ title: String
    ) -> some View {
        modifier(DemoNavigationModifier(title: title))
    }
}
