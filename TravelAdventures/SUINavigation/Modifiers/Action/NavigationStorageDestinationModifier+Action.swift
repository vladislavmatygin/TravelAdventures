import SwiftUI

struct NavigationStorageDestinationActionModifier<Item: Equatable>: ViewModifier where Item: NavigationParameterValue {

    let id: NavigationID
    let paramName: String?
    let isRemovingParam: Bool

    @OptionalEnvironmentObject
    var navigationStorage: NavigationStorage?

    func body(content: Content) -> some View {
        content
            .navigationStorageDestination(for: Item.self, id: id, paramName: paramName)
            .navigateUrlParams(id.stringValue){ path in
                let paramName = paramName ?? id.stringValue
                let item: Item? = isRemovingParam ? path.popParam(paramName) : path.getParam(paramName)
                guard let resultItem = item else {
                    return
                }
                navigationStorage?.changeDestination(with: resultItem)
            }
    }
}

public extension View {

    /// This modifier analogy to `.navigationStorageDestination` for deeplink used.
    func navigationStorageDestinationAction<Item: Equatable, Destination: View>(
        for data: Item.Type = Item.self,
        id: NavigationID,
        paramName: String? = nil,
        isRemovingParam: Bool = false,
        @ViewBuilder destination: @escaping (Item) -> Destination
    ) -> some View where Item: NavigationParameterValue {
        self
            .navigationStorageBinding(for: data, destination: destination)
            .navigationStorageDestinationAction(for: data, id: id, paramName: paramName, isRemovingParam: isRemovingParam)
    }

    /// This modifier analogy to `.navigationStorageDestination` for deeplink used.
    func navigationStorageDestinationAction<Item: Equatable>(
        for data: Item.Type,
        id: NavigationID,
        paramName: String? = nil,
        isRemovingParam: Bool = false
    ) -> some View where Item: NavigationParameterValue {
        navigationModifier(NavigationStorageDestinationActionModifier<Item>(id: id, paramName: paramName, isRemovingParam: isRemovingParam))
    }
}
