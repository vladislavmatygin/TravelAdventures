import SwiftUI

struct FirstView: View {

    @State
    var isSecondShowing = false

    @OptionalEnvironmentObject
    var navigationStorage: NavigationStorage?

    var body: some View {
        VStack {
            Text("First")
            Button {
                // True! It's can fix warning to console because .navigationStorageDestination is called outside of the TabView.
                navigationStorage?.replaceDestination(with: TabNavigation.second)
            } label: {
                Text("to Second")
            }
        }
        .padding()
        .navigationTitle("First")
    }
}
