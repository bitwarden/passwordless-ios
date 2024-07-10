import Foundation

struct AlertItem: Identifiable {
    var id: String { title }
    let title: String
    let message: String
}
