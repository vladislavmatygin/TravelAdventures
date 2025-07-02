import SwiftUI

public protocol NavigationID {
    var isRoot: Bool {get}

    var stringValue: String {get}
}

extension String: NavigationID {
    public static let root: NavigationID = ""

    public var stringValue: String {
        self
    }

    public var isRoot: Bool {
        self == .root.stringValue
    }
}

extension View {
    public static var navigationID: NavigationID {
        String(describing: self)
    }

    public var navigationID: NavigationID {
        Self.navigationID
    }

    static func identifier(_ navigationID: NavigationID?) -> String {
        return navigationID?.stringValue ?? Self.navigationID.stringValue
    }
}

