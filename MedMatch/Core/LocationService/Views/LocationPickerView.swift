import SwiftUI
import MapKit
import Combine

// Modelo de resultado de búsqueda de ubicación
struct LocationResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let mapItem: MKMapItem
    
    var formattedAddress: String {
        return subtitle.isEmpty ? title : "\(title), \(subtitle)"
    }
}

class LocationSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [LocationResult] = []
    @Published var isSearching = false
    @Published var recentLocations: [String] = []
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var completerDelegate: SearchCompleterDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupCompleter()
        
        // Cargar ubicaciones recientes desde UserDefaults
        if let savedLocations = UserDefaults.standard.stringArray(forKey: "recentLocations") {
            recentLocations = savedLocations
        }
        
        // Configurar el observador de texto
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchTerm in
                guard let self = self else { return }
                
                if searchTerm.isEmpty {
                    self.searchResults = []
                    self.isSearching = false
                    return
                }
                
                self.isSearching = true
                print("Buscando: \(searchTerm)")
                self.searchCompleter.queryFragment = searchTerm
            }
            .store(in: &cancellables)
    }
    
    // CORRECCIÓN: Configuración completa del completer
    private func setupCompleter() {
        searchCompleter.resultTypes = .address
        
        // Crear y mantener una referencia fuerte al delegado
        completerDelegate = SearchCompleterDelegate()
        completerDelegate?.onUpdate = { [weak self] completer in
            self?.handleCompleterResults(completer)
        }
        completerDelegate?.onError = { [weak self] error in
            print("Error en el completer: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self?.isSearching = false
            }
        }
        
        searchCompleter.delegate = completerDelegate
        
        // Configurar región por defecto para mejorar resultados
        searchCompleter.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
        )
    }
    
    private func handleCompleterResults(_ completer: MKLocalSearchCompleter) {
        print("Resultados recibidos: \(completer.results.count)")
        let items = completer.results.map { result in
            return LocationResult(
                title: result.title,
                subtitle: result.subtitle,
                mapItem: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D()))
            )
        }
        
        DispatchQueue.main.async {
            self.searchResults = items
            self.isSearching = false
        }
    }
    
    func getFullLocation(for result: LocationResult, completion: @escaping (LocationResult?) -> Void) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "\(result.title) \(result.subtitle)"
        
        // Configurar región global para mejor búsqueda
        searchRequest.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
        )
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let error = error {
                print("Error en búsqueda: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let response = response, let firstMapItem = response.mapItems.first else {
                print("No se encontraron resultados de mapas")
                completion(nil)
                return
            }
            
            let updatedResult = LocationResult(
                title: result.title,
                subtitle: result.subtitle,
                mapItem: firstMapItem
            )
            
            completion(updatedResult)
        }
    }
    
    func saveToRecents(location: String) {
        // Remover si ya existe
        recentLocations.removeAll { $0 == location }
        
        // Añadir al principio
        recentLocations.insert(location, at: 0)
        
        // Mantener solo las 5 más recientes
        if recentLocations.count > 5 {
            recentLocations = Array(recentLocations.prefix(5))
        }
        
        // Guardar en UserDefaults
        UserDefaults.standard.set(recentLocations, forKey: "recentLocations")
    }
    
    // Función para pruebas manuales
    func performManualSearch(text: String) {
        print("Búsqueda manual: \(text)")
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let error = error {
                print("Error en búsqueda manual: \(error)")
                return
            }
            
            if let response = response {
                print("Resultados manuales encontrados: \(response.mapItems.count)")
                
                // Crear resultados manualmente si el completer no funciona
                if !response.mapItems.isEmpty {
                    let items = response.mapItems.map { mapItem in
                        return LocationResult(
                            title: mapItem.name ?? "Ubicación",
                            subtitle: mapItem.placemark.title ?? "",
                            mapItem: mapItem
                        )
                    }
                    
                    DispatchQueue.main.async {
                        self.searchResults = items
                        self.isSearching = false
                    }
                }
            }
        }
    }
}

// Delegado explícito para MKLocalSearchCompleter (necesario para TestFlight)
class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    var onUpdate: ((MKLocalSearchCompleter) -> Void)?
    var onError: ((Error) -> Void)?
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        print("Completer actualizó resultados: \(completer.results.count)")
        onUpdate?(completer)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error en completer: \(error.localizedDescription)")
        onError?(error)
    }
}

// MARK: - Renombrado de LocationManager a LocationPickerManager
class LocationPickerManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isRequestingLocation = false
    @Published var currentLocation: CLLocation?
    @Published var locationString: String = "Ubicación actual"
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocation() {
        isRequestingLocation = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        // CORRECCIÓN PARA TESTFLIGHT: Agregar timeout para evitar que la solicitud se bloquee
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            if self?.isRequestingLocation == true {
                self?.isRequestingLocation = false
                // Considerar mostrar algún mensaje de error al usuario aquí
            }
        }
    }
    
    func cancelLocationRequest() {
        locationManager.stopUpdatingLocation()
        isRequestingLocation = false
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            isRequestingLocation = false
            currentLocation = location
            
            // Geocodificación inversa para obtener la dirección
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                if let placemark = placemarks?.first {
                    let address = [
                        placemark.name,
                        placemark.locality,
                        placemark.administrativeArea
                    ].compactMap { $0 }.joined(separator: ", ")
                    
                    self?.locationString = address.isEmpty ? "Ubicación actual" : address
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error del administrador de ubicación: \(error.localizedDescription)")
        isRequestingLocation = false
    }
}

struct LocationPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = LocationSearchViewModel()
    @StateObject private var locationManager = LocationPickerManager()
    let onSelectLocation: (String, CLLocation?) -> Void
    
    @State private var isProcessingAction = false
    @State private var showMapPreview = false
    @State private var selectedLocation: LocationResult?
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var showFallbackSearch = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Cabecera
                    ZStack {
                        Text("Seleccionar Ubicación")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Button(action: {
                                if !isProcessingAction {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    // Campo de búsqueda
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        TextField("Buscar ubicación", text: $viewModel.searchText)
                            .autocorrectionDisabled()
                            .onSubmit {
                                if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                                    // Realizar búsqueda alternativa si no hay resultados
                                    viewModel.performManualSearch(text: viewModel.searchText)
                                } else if !viewModel.searchResults.isEmpty {
                                    selectSearchResult(viewModel.searchResults[0])
                                }
                            }
                            .padding(.vertical, 12)
                        
                        if !viewModel.searchText.isEmpty {
                            Button(action: {
                                viewModel.searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                            }
                        } else if viewModel.isSearching {
                            ProgressView()
                                .padding(.horizontal, 8)
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    
                    // Botón de búsqueda alternativa si la normal no funciona
                    if showFallbackSearch && !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.performManualSearch(text: viewModel.searchText)
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Buscar manualmente")
                                    .font(.subheadline)
                            }
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                        }
                        .padding(.bottom, 8)
                    }
                    
                    if showMapPreview && selectedCoordinate != nil {
                        // Vista previa del mapa cuando se selecciona una ubicación
                        MapPreview(coordinate: selectedCoordinate!, name: selectedLocation?.title ?? "Ubicación Seleccionada")
                            .frame(height: 180)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    }
                    
                    // Resultados de búsqueda o opciones de ubicación reciente/actual
                    VStack(spacing: 0) {
                        if !viewModel.searchText.isEmpty {
                            // Resultados de búsqueda
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Resultados de Búsqueda")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                
                                if viewModel.isSearching {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    }
                                    .padding()
                                } else if viewModel.searchResults.isEmpty {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Text("No se encontraron resultados")
                                                .foregroundColor(.gray)
                                                .padding()
                                            Spacer()
                                        }
                                        
                                        // Mostrar botón de búsqueda alternativa después de un tiempo
                                        Button(action: {
                                            viewModel.performManualSearch(text: viewModel.searchText)
                                        }) {
                                            Text("Intentar otra búsqueda")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 16)
                                                .background(Color.blue.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                        .padding(.bottom, 16)
                                    }
                                    .onAppear {
                                        // Activar botón de búsqueda alternativa después de 2 segundos sin resultados
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            showFallbackSearch = true
                                        }
                                    }
                                    .onDisappear {
                                        showFallbackSearch = false
                                    }
                                } else {
                                    ScrollView {
                                        LazyVStack(spacing: 0) {
                                            ForEach(viewModel.searchResults) { result in
                                                Button(action: {
                                                    selectSearchResult(result)
                                                }) {
                                                    HStack {
                                                        Image(systemName: "mappin.circle.fill")
                                                            .font(.system(size: 22))
                                                            .foregroundColor(.blue)
                                                            .padding(.trailing, 8)
                                                        
                                                        VStack(alignment: .leading, spacing: 4) {
                                                            Text(result.title)
                                                                .foregroundColor(.primary)
                                                                .font(.system(size: 16))
                                                            
                                                            if !result.subtitle.isEmpty {
                                                                Text(result.subtitle)
                                                                    .font(.system(size: 14))
                                                                    .foregroundColor(.gray)
                                                            }
                                                        }
                                                        
                                                        Spacer()
                                                    }
                                                    .padding(.vertical, 12)
                                                    .padding(.horizontal)
                                                    .background(Color.white)
                                                }
                                                
                                                Divider()
                                                    .padding(.leading, 56)
                                            }
                                        }
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        } else {
                            // Opción de ubicación actual
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Ubicación Actual")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                
                                Button(action: {
                                    useCurrentLocation()
                                }) {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(Color.blue.opacity(0.1))
                                                .frame(width: 36, height: 36)
                                            
                                            Image(systemName: "location.fill")
                                                .foregroundColor(.blue)
                                        }
                                        
                                        Text("Usar ubicación actual")
                                            .foregroundColor(.primary)
                                            .padding(.leading, 8)
                                        
                                        Spacer()
                                        
                                        if locationManager.isRequestingLocation {
                                            ProgressView()
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                                    .padding(.horizontal)
                                }
                                .disabled(isProcessingAction || locationManager.isRequestingLocation)
                            }
                            
                            // Ubicaciones recientes
                            if !viewModel.recentLocations.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Ubicaciones Recientes")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                        .padding(.top, 16)
                                        .padding(.bottom, 8)
                                    
                                    VStack(spacing: 0) {
                                        ForEach(viewModel.recentLocations, id: \.self) { location in
                                            Button(action: {
                                                selectRecentLocation(location)
                                            }) {
                                                HStack {
                                                    ZStack {
                                                        Circle()
                                                            .fill(Color.gray.opacity(0.1))
                                                            .frame(width: 36, height: 36)
                                                        
                                                        Image(systemName: "clock.arrow.circlepath")
                                                            .foregroundColor(.gray)
                                                    }
                                                    
                                                    Text(location)
                                                        .foregroundColor(.primary)
                                                        .padding(.leading, 8)
                                                        .lineLimit(1)
                                                    
                                                    Spacer()
                                                }
                                                .padding(.vertical, 12)
                                                .padding(.horizontal)
                                                .background(Color.white)
                                            }
                                            
                                            Divider()
                                                .padding(.leading, 60)
                                        }
                                    }
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    // Botón de confirmar cuando se selecciona una ubicación
                    if selectedLocation != nil || selectedCoordinate != nil {
                        Button(action: {
                            confirmSelection()
                        }) {
                            Text("Confirmar Ubicación")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                                .padding(.horizontal)
                                .padding(.bottom, 16)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onReceive(locationManager.$authorizationStatus) { status in
                handleLocationAuthorizationChange(status)
            }
            .onDisappear {
                locationManager.cancelLocationRequest()
            }
            .onAppear {
                // No es necesario llamar a setupCompleterDelegate() ya que ahora se configura en el init
            }
        }
    }
    
    // MARK: - Métodos de Acción
    
    private func selectSearchResult(_ result: LocationResult) {
        guard !isProcessingAction else { return }
        isProcessingAction = true
        
        // Mostrar un indicador de carga
        selectedLocation = result
        
        // Obtener los detalles completos de la ubicación
        viewModel.getFullLocation(for: result) { updatedResult in
            if let updatedResult = updatedResult {
                let placemark = updatedResult.mapItem.placemark
                
                DispatchQueue.main.async {
                    self.selectedLocation = updatedResult
                    self.selectedCoordinate = placemark.coordinate
                    self.showMapPreview = true
                    self.viewModel.saveToRecents(location: updatedResult.formattedAddress)
                    self.isProcessingAction = false
                }
            } else {
                DispatchQueue.main.async {
                    // Alternativa si no pudimos obtener coordenadas
                    self.showMapPreview = false
                    self.isProcessingAction = false
                }
            }
        }
    }
    
    private func selectRecentLocation(_ location: String) {
        viewModel.searchText = location
        // Esto activará la búsqueda y mostrará resultados
    }
    
    private func useCurrentLocation() {
        guard !isProcessingAction else { return }
        isProcessingAction = true
        
        locationManager.requestLocation()
        
        Task {
            if locationManager.authorizationStatus == .notDetermined {
                // Esperar la respuesta de autorización en el controlador didChangeAuthorization
            } else if locationManager.authorizationStatus == .authorizedWhenInUse ||
                      locationManager.authorizationStatus == .authorizedAlways {
                
                // Esperar actualización de ubicación
                for _ in 0..<10 { // Intentar por hasta 5 segundos
                    if let location = locationManager.currentLocation {
                        await MainActor.run {
                            // Tenemos una ubicación, usarla
                            selectedCoordinate = location.coordinate
                            showMapPreview = true
                            
                            // Obtener placemark para la ubicación actual
                            let geocoder = CLGeocoder()
                            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                                if let placemark = placemarks?.first {
                                    let address = [
                                        placemark.thoroughfare,
                                        placemark.locality,
                                        placemark.administrativeArea,
                                        placemark.postalCode,
                                        placemark.country
                                    ].compactMap { $0 }.joined(separator: ", ")
                                    
                                    viewModel.saveToRecents(location: address)
                                } else {
                                    viewModel.saveToRecents(location: "Ubicación Actual")
                                }
                                
                                isProcessingAction = false
                            }
                        }
                        return
                    }
                    
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 segundo
                }
                
                // Si llegamos aquí, agotamos el tiempo de espera para la ubicación
                await MainActor.run {
                    isProcessingAction = false
                }
            } else {
                // Autorización denegada
                await MainActor.run {
                    isProcessingAction = false
                }
            }
        }
    }
    
    private func confirmSelection() {
        if let selectedLocation = selectedLocation {
            let locationString = selectedLocation.formattedAddress
            
            // Verificar si tenemos coordenadas para pasar también
            if let coordinate = selectedCoordinate {
                let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                onSelectLocation(locationString, location)
            } else {
                onSelectLocation(locationString, nil)
            }
        } else if let coordinate = selectedCoordinate {
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            onSelectLocation("Ubicación Seleccionada", location)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func handleLocationAuthorizationChange(_ status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse || status == .authorizedAlways) &&
           locationManager.isRequestingLocation && !isProcessingAction {
            
            // Permisos de ubicación recién concedidos, continuar con la obtención de la ubicación actual
            useCurrentLocation()
        }
    }
}

// MARK: - Vistas de Soporte

struct MapPreview: View {
    let coordinate: CLLocationCoordinate2D
    let name: String
    
    @State private var region: MKCoordinateRegion
    
    init(coordinate: CLLocationCoordinate2D, name: String) {
        self.coordinate = coordinate
        self.name = name
        
        // Inicializar la región con la coordenada
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [MapAnnotation(coordinate: coordinate)]) { item in
            MapMarker(coordinate: item.coordinate, tint: .blue)
        }
        .overlay(
            Text(name)
                .font(.caption)
                .padding(8)
                .background(Color.white.opacity(0.9))
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .padding(12),
            alignment: .bottom
        )
    }
}

struct MapAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
