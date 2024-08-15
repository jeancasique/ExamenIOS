import SwiftUI
import Kingfisher

struct MenuView: View {
    @Binding var isOpen: Bool
    @State private var showProfile = false
    @State private var showFavorites = false
    @State private var showSettings = false
    @State private var showHome = false
    @State private var isLoggedOut = false

    @EnvironmentObject var session: SessionStore

    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .center) {
                    profileImageSection

                    Text(session.userData.firstName.isEmpty ? "Hola, usuario!" : "Hola \(session.userData.firstName)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text("UX/UI Designer")
                        .foregroundColor(.gray)
                }
                .padding(.top, 30)
                .padding(.horizontal, 50)
                .padding(.bottom, 10)

                Divider()

                Group {
                    MenuItem(icon: "house.fill", text: "Home") {
                        if session.currentView != .home {
                            session.currentView = .home
                            self.showHome = true
                        } else {
                            self.isOpen = false // Ocultar el menú si ya estamos en Home
                        }
                    }
                    MenuItem(icon: "person.fill", text: "Perfil") {
                        self.showProfile = true
                    }
                    MenuItem(icon: "bookmark.fill", text: "Favoritos") {
                        if session.currentView != .favorites {
                            session.currentView = .favorites
                            self.showFavorites = true
                        } else {
                            self.isOpen = false // Ocultar el menú si ya estamos en Favoritos
                        }
                    }
                    MenuItem(icon: "gearshape.fill", text: "Ajustes") {
                        if session.currentView != .settings {
                            session.currentView = .settings
                            self.showSettings = true
                        } else {
                            self.isOpen = false // Ocultar el menú si ya estamos en Ajustes
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                Divider()

                MenuItem(icon: "arrowshape.turn.up.left.fill", text: "Logout") {
                    logout()
                }
                .padding(.bottom, 40)
                .padding(.horizontal)
            }
            .background(Color(UIColor.systemBackground))
            .frame(width: UIScreen.main.bounds.width * 0.7)
            .shadow(radius: 20)
        }
        .fullScreenCover(isPresented: $showHome) {
            NavigationView {
                MoviesView()
                    .environmentObject(session)
                    .navigationBarBackButtonHidden(false)
                    .onDisappear {
                        self.showHome = false
                    }
            }
        }
        .fullScreenCover(isPresented: $showProfile) {
            NavigationView {
                PerfilView()
                    .environmentObject(session)
                    .navigationBarBackButtonHidden(false)
                    .onDisappear {
                        self.showProfile = false
                    }
            }
        }
        .fullScreenCover(isPresented: $showFavorites) {
            NavigationView {
                FavoritesMovies()
                    .environmentObject(session)
                    .navigationBarBackButtonHidden(false)
                    .onDisappear {
                        self.showFavorites = false
                    }
            }
        }
        .fullScreenCover(isPresented: $showSettings) {
            NavigationView {
                Ajustes()
                    .environmentObject(session)
                    .navigationBarBackButtonHidden(false)
                    .onDisappear {
                        self.showSettings = false
                    }
            }
        }
        .fullScreenCover(isPresented: $isLoggedOut) {
            LoginView()
                .environmentObject(session)
        }
        .onTapGesture {
            if isOpen {
                isOpen.toggle()
            }
        }
    }

    var profileImageSection: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 140, height: 140)
                .shadow(radius: 10)

            if let profileImage = session.userData.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .clipShape(Circle())
                    .frame(width: 130, height: 130)
            } else if let urlString = session.userData.profileImageURL, let url = URL(string: urlString) {
                KFImage(url)
                    .resizable()
                    .placeholder {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 130, height: 130)
                            .foregroundColor(.white)
                    }
                    .cancelOnDisappear(true)
                    .clipShape(Circle())
                    .frame(width: 130, height: 130)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
        }
    }

    func logout() {
        session.signOut()
        self.isLoggedOut = true
    }
}

