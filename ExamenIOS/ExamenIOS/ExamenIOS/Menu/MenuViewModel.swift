import SwiftUI

class MenuViewModel: ObservableObject {
    @Published var showProfile = false
    @Published var showFavorites = false
    @Published var showSettings = false
    @Published var showHome = false
    @Published var isLoggedOut = false
    @Binding var isOpen: Bool
    private var session: SessionStore

    init(isOpen: Binding<Bool>, session: SessionStore) {
        self._isOpen = isOpen
        self.session = session
    }

    func toggleMenu() {
        isOpen.toggle()
    }

    func logout() {
        session.signOut()
        isLoggedOut = true
    }

    var menuItems: [MenuItem] {
        [
            MenuItem(icon: "house.fill", text: "Home") {
                if self.session.currentView != .home {
                    self.session.currentView = .home
                    self.showHome = true
                } else {
                    self.isOpen = false
                }
            },
            MenuItem(icon: "person.fill", text: "Perfil") {
                self.showProfile = true
            },
            MenuItem(icon: "bookmark.fill", text: "Favoritos") {
                if self.session.currentView != .favorites {
                    self.session.currentView = .favorites
                    self.showFavorites = true
                } else {
                    self.isOpen = false
                }
            },
            MenuItem(icon: "gearshape.fill", text: "Ajustes") {
                if self.session.currentView != .settings {
                    self.session.currentView = .settings
                    self.showSettings = true
                } else {
                    self.isOpen = false
                }
            },
            MenuItem(icon: "arrowshape.turn.up.left.fill", text: "Logout") {
                self.logout()
            }
        ]
    }
}

