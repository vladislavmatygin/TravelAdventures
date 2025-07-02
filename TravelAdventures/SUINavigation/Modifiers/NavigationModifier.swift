import SwiftUI

struct NavigationModifier<Destination: View>: ViewModifier {
    let isActive: Binding<Bool>
    let identifier: String
    let destination: Destination?

    @State
    private var isNavigationStackUsed: Bool = NavigationStorageStrategy.isNavigationStackUsedDefault

    init(isActive: Binding<Bool>, identifier: String, destination: Destination?) {
        self.isActive = isActive
        self.identifier = identifier
        self.destination = destination
    }

    func body(content: Content) -> some View {
        ZStack {
            /// #available version should be equal version whith using from `NavigationStorageView` for trigger using `NavigationStack`
            if #available(iOS 16.0, *), isNavigationStackUsed {
                content
                    .navigationDestination(isPresented: isActive, destination: { viewDestination(destination) })
            } else {
                content
                NavigationLinkWrapperView(isActive: isActive, destination: viewDestination(destination))
            }
            NavigationStorageActionItemView<Destination>(isNavigationStackUsed: $isNavigationStackUsed, isActive: isActive, identifier: identifier)
        }
    }

}

public extension View {
    func navigation<Destination: View>(
        isActive: Binding<Bool>,
        id: NavigationID? = nil,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        let identifier = Destination.identifier(id)
        staticCheckDestination(isActive: isActive, id: identifier, destination: destination)
        return navigationModifier(NavigationModifier(isActive: isActive, identifier: identifier, destination: isActive.wrappedValue ? destination() : nil))
    }
}

