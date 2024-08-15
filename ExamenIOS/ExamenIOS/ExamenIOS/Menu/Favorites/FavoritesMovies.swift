import SwiftUI
import FirebaseAuth

struct FavoritesMovies: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var searchText = "" // Estado para el texto de búsqueda
    @State private var isMenuOpen = false // Estado para controlar el menú
    @EnvironmentObject var session: SessionStore

    var body: some View {
        ZStack(alignment: .leading) { // Envolver el contenido en un ZStack
            NavigationView {
                ScrollView {
                    // Disposición en una cuadrícula de las tarjetas de películas
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160)), GridItem(.adaptive(minimum: 160))], spacing: 10) {
                        ForEach(viewModel.favoriteMovies, id: \.imdbID) { movie in
                            NavigationLink(destination: MovieDetailView(movieID: movie.imdbID)) {
                                MovieCard(movie: movie)
                                    .frame(width: 160, height: 240) // Ajustar tamaño de las tarjetas
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .background(Color.black)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .onChange(of: searchText) { newValue in
                    viewModel.filterMovies(searchTerm: newValue) // Filtrar películas según el término de búsqueda
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle() // Abrir/cerrar el menú
                            }
                        }) {
                            ProfileIcon(userData: session.userData, subText: "Encuentra tu película favorita") // Icono de perfil del usuario
                        }
                    }
                }
                .onAppear {
                    viewModel.loadUserData() // Cargar datos del usuario
                    viewModel.loadFavoriteMovies() // Cargar películas favoritas al aparecer la vista
                }
                .navigationBarBackButtonHidden(true) // Ocultar botón de retroceso
            }
            .navigationViewStyle(StackNavigationViewStyle()) // Asegurar el estilo de navegación para ocultar el botón de retroceso
            
            if isMenuOpen {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isMenuOpen.toggle() // Cerrar el menú al tocar fuera de él
                        }
                    }

                MenuView(isOpen: $isMenuOpen)
                    .transition(.move(edge: .leading)) // Animación de transición
            }
        }
    }
}

struct FavoritesMovies_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesMovies()
            .environmentObject(SessionStore()) // Proporcionar una instancia de SessionStore para la previsualización
    }
}

