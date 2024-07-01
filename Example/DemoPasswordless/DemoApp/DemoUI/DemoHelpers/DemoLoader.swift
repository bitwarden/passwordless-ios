import SwiftUI

struct DemoLoader: View {
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.5)
                .ignoresSafeArea()

            Color(uiColor: .systemBackground)
                .clipShape(
                    RoundedRectangle(cornerRadius: 8)
                )
                .frame(width: 100, height: 100)

            ProgressView()
                .controlSize(.large)
                .tint(.primary)
        }
    }
}
