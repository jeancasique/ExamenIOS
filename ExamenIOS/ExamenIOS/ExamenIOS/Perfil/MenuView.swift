import SwiftUI

struct MenuView: View {
    @Binding var isOpen: Bool // Binding para controlar si el menú está abierto
    @State private var showProfile = false
    @State private var showFavorites = false
    @State private var showSettings = false

    var body: some View {
        ZStack(alignment: .leading) {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 20) {
                // Foto de perfil y nombre de usuario
                VStack(alignment: .center) {
                  
                        Image(systemName: "person.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            
                        
                       
                            Text("Naila Stefenson")
                            .font(.title2)
                            .fontWeight(.bold)
                            
                            
                            Text("UX/UI Designer")
                                .foregroundColor(.gray)
                  
                 
                    .padding(.bottom, 10)
                }
                .padding(.top, 30)
                .padding(.horizontal, 50)

                Divider()

                // Opciones del menú
                Group {
                    MenuItem(icon: "person.fill", text: "Perfil") {
                        self.showProfile = true
                    }
                    MenuItem(icon: "heart.fill", text: "Favoritos") {
                        self.showFavorites = true
                    }
                    MenuItem(icon: "gearshape.fill", text: "Ajustes") {
                        self.showSettings = true
                    }
                }
                .padding(.horizontal)

                Spacer()

                Divider()

                // Opción de logout
                MenuItem(icon: "arrowshape.turn.up.left.fill", text: "Logout") {
                    // Acción de logout
                }
                .padding(.bottom, 40)
                .padding(.horizontal)
            }
            .background(Color.white)
            .frame(width: UIScreen.main.bounds.width * 0.7) // 70% del ancho de la pantalla
            .shadow(radius: 20)
        }
        .fullScreenCover(isPresented: $showProfile) {
            PerfilView()
        }
        .fullScreenCover(isPresented: $showFavorites) {
            FavoritesMovies()
        }
        .fullScreenCover(isPresented: $showSettings) {
            Ajustes()
        }
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
                    .foregroundColor(.black)
                Text(text)
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
        }
    }
}

// Custom shape for background decoration (if needed)
struct CustomShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height * 0.2))
        path.addQuadCurve(to: CGPoint(x: rect.width, y: rect.height * 0.3),
                          control: CGPoint(x: rect.width * 0.5, y: rect.height * 0.1))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

// Vista de previsualización para SwiftUI
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(isOpen: .constant(true))
    }
}

