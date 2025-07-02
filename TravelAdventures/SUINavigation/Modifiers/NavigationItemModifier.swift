import SwiftUI

struct NavigationItemModifier<Item: Equatable, Value: Equatable, Destination: View>: ViewModifier {
    let item: Binding<Item?>
    let value: Binding<Value?>?
    let identifier: String
    let paramName: String?

    @ViewBuilder
    private var destination: (Item) -> Destination

    @State
    private var isActive: Bool = false

    @State
    private var isOldActive: Bool = false

    @State
    private var oldItem: Item?

    @State
    private var isNavigationStackUsed: Bool = NavigationStorageStrategy.isNavigationStackUsedDefault

    init(item: Binding<Item?>, value: Binding<Value?>?, identifier: String, paramName: String?, @ViewBuilder destination: @escaping (Item) -> Destination) {
        self.item = item
        _oldItem = State(initialValue: item.wrappedValue)
        self.value = value
        self.identifier = identifier
        self.paramName = paramName
        self.destination = destination
    }

    func body(content: Content) -> some View {
        ZStack {
            // #available version should be equal version whith using from NavigationStorageView for trigger using NavigationStack
            if #available(iOS 16.0, *), isNavigationStackUsed {
                // We can't use from iOS 17 .navigationDestination with item param because that has an issue with navigation
                content
                    .navigationDestination(isPresented: $isActive, destination: {
                        if let item = item.wrappedValue ?? oldItem {
                            viewDestination(destination(item))
                        }
                    })
            } else {
                content
                NavigationLinkWrapperView(isActive: $isActive, destination: navigationDestination)
            }
            let _ = update()
            NavigationStorageActionItemView<Destination>(isNavigationStackUsed: $isNavigationStackUsed, isActive: $isActive, identifier: identifier, param: param)
        }
    }

    // Why need it difficult:
    // iOS 16.4 NavigationStack Behavior Unstable (Observation problems)
    // https://forums.developer.apple.com/forums/thread/727282
    private func update(){
        if isOldActive != isActive {
            Task { @MainActor in
                isOldActive = isActive
                if !isActive {
                    item.wrappedValue = nil
                }
            }
        }
        if oldItem != item.wrappedValue {
            Task { @MainActor in
                oldItem = item.wrappedValue
                self.changeItem(item.wrappedValue)
            }
        }
    }

    private func changeItem(_ newItem: Item?){
        if let newItem {
            isActive = true
        } else {
            isActive = false
        }
    }

    private var param: NavigationParameter? {
        if let value = value?.wrappedValue {
            let name = paramName ?? identifier
            return NavigationParameter(name: name, value: "\(value)")
        } else {
            return nil
        }
    }

    private var navigationDestination: Destination? {
        guard let item = item.wrappedValue ?? oldItem else {
            return nil
        }

        return viewDestination(destination(item))
    }

}

extension View {
    func navigation<Item: Equatable, Value: Equatable, Destination: View>(
        item: Binding<Item?>,
        value: Binding<Value?>?,
        id: NavigationID? = nil,
        paramName: String? = nil,
        @ViewBuilder destination: @escaping (Item) -> Destination
    ) -> some View {
        let identifier = Destination.identifier(id)
        staticCheckDestination(item: item, id: identifier, paramName: paramName, destination: destination)
        return navigationModifier(NavigationItemModifier(item: item, value: value, identifier: identifier, paramName: paramName, destination: destination))
    }
}

public extension View {
    func navigation<Item: Equatable, Destination: View>(
        item: Binding<Item?>,
        id: NavigationID? = nil,
        paramName: String? = nil,
        @ViewBuilder destination: @escaping (Item) -> Destination
    ) -> some View {
        navigation(item: item, value: item, id: id, paramName: paramName, destination: destination)
    }
}
