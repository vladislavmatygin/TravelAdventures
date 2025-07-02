import SwiftUI

public extension View {

    /// Facade target with optimisation
    /// for revert just edit to call self.modifier(modifier)
    @inlinable func navigationModifier<T: ViewModifier>(_ modifier: T) -> some View
    {
        self.backgroundModifier(modifier)
    }

    /// Modifier with optimisation, but can down performance on first showing becase use EmptyView
    @inlinable func backgroundModifier<T: ViewModifier>(_ modifier: T) -> some View
    {
        self.background (
            EmptyView()
                .modifier(modifier)
        )
    }

}
