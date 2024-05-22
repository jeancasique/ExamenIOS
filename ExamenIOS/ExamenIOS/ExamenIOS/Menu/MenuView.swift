import SwiftUI
import FirebaseAuth
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
                        self.showHome = true
                    }
                    MenuItem(icon: "person.fill", text: "Perfil") {
                        self.showProfile = true
                    }
                    MenuItem(icon: "bookmark.fill", text: "Favoritos") {
                        self.showFavorites = true
                    }
                    MenuItem(icon: "gearshape.fill", text: "Ajustes") {
                        self.showSettings = true
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
            }
        }
        .fullScreenCover(isPresented: $showProfile) {
            NavigationView {
                PerfilView()
                    .environmentObject(session)
                    .navigationBarBackButtonHidden(false)
            }
        }
        .fullScreenCover(isPresented: $showFavorites) {
            NavigationView {
                FavoritesMovies()
                    .environmentObject(session)
                    .navigationBarBackButtonHidden(false)
            }
        }
        .fullScreenCover(isPresented: $showSettings) {
            NavigationView {
                Ajustes()
                    .environmentObject(session)
                    .navigationBarBackButtonHidden(false)
            }
        }
        .fullScreenCover(isPresented: $isLoggedOut) {
            RootView()
                .environmentObject(session)
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

struct MenuItem: View {
    var icon: String
    var text: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.primary)
                Text(text)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding()
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(isOpen: .constant(true))
            .environmentObject(SessionStore())
    }
}

