import SwiftUI

public extension EnvironmentObject {
    var isPresent: Bool {
        (Mirror(reflecting: self).children.first(where: { $0.label == "_store" })?.value as? ObjectType) != nil
    }
}
