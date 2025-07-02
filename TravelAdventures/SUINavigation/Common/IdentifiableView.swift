import SwiftUI

struct IdentifiableView: Identifiable, Equatable {
    let id = UUID()
    let view: AnyView

    init(view: any View) {
        self.view = AnyView(view)
    }

    static func == (lhs: IdentifiableView, rhs: IdentifiableView) -> Bool {
        lhs.id == rhs.id
    }
}
