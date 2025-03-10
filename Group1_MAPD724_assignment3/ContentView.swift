import SwiftUI
import MapKit
import CoreLocation
import CoreMotion


class LocationStateWithCLLocationUpdate: ObservableObject {
    @Published var location: CLLocation?
    
    init() {
        Task {
            let updates = CLLocationUpdate.liveUpdates()
            
            do {
                for try await update in updates {
                    if let newLocation = update.location {
                        await MainActor.run {
                            self.location = newLocation
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}



// MARK: Annotation

struct Restaurant: Identifiable, Hashable {
    let id = UUID()
    
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let name: String
    let typeOfFood: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude,
                               longitude: longitude)
    }
}

// MARK: Model

class RestaurantModel: ObservableObject {

    let bakeries = [
        Restaurant(latitude: 43.77339385427669, longitude: -79.21905327681839, name: "Tamanna cake shop", typeOfFood: "Cake"),
        Restaurant(latitude: 43.77297614187221, longitude: -79.25228481784599, name: "Country Bakery & Market", typeOfFood: "English Bakery"),
        Restaurant(latitude: 43.73025112317777, longitude:  -79.27338248235735, name: "La Bastille Boulangerie Patisserie", typeOfFood: "French Bakery"),
        Restaurant(latitude: 43.776953063602, longitude: -79.23502112548893, name: "Whisked Gluten-Free Bakery", typeOfFood: "Gluten-Free Bakery"),
        Restaurant(latitude: 43.790634728100954, longitude: -79.27641476236509, name: "Red House Bakery", typeOfFood: "Asian Bakery"),
        Restaurant(latitude: 43.79103179395124, longitude: -79.25633790081675, name: "Francesca Italian Bakery & Delicatessen", typeOfFood: "Italian Bakery"),
    ]
    
    let mexicanRestaurants = [
        
        Restaurant(latitude: 43.80953176713111, longitude: -79.22038436255853, name: "Taco Bell", typeOfFood: "Mexican Taco"),
        
        Restaurant(latitude: 43.78859261728719, longitude: -79.24218535652274, name: "El Rincón Mexican Food", typeOfFood: "Mexican"),
        
        Restaurant(latitude: 43.766820466346786, longitude: -79.22762588791556, name: "Grillies (Markham & Lawrence)", typeOfFood: "Mexican Grill"),
        
        Restaurant(latitude: 43.782698435746305, longitude: -79.29039333434538, name: "Fresh Burrito", typeOfFood: "Mexican Burrito"),
        
        Restaurant(latitude: 43.77468072390982, longitude: -79.31171355057815, name: "Grande Burrito", typeOfFood: "Mexican Burrito"),
        
        Restaurant(latitude: 43.77787051027189, longitude: -79.25158881660428, name: "Chipotle Mexican Grill", typeOfFood: "Mexican Grill"),
    ]
    
    
}

// MARK: View

struct ContentView: View {
    
    @StateObject var model = RestaurantModel()
    
    @StateObject var locationState = LocationStateWithCLLocationUpdate() // ✅ Track user location


    @State var cameraPosition = MapCameraPosition.automatic
    
    @State var selection: Restaurant?
    // anything type that is Hashable can be a selection type, Optional version of it
    // nil means no selection
    
    var body: some View {
        Map(position: $cameraPosition,
            selection: $selection) {
            ForEach(model.bakeries) { bakery in
                Marker(bakery.name,
                       systemImage: "birthday.cake.fill",
                       coordinate: bakery.coordinate)
                    .tag(bakery) // this will be the value $selection get's set to
            }
            
            ForEach(model.mexicanRestaurants) { mexicanRestaurants in
                
                // Custom Annotation for Burger King
                Annotation(
                    mexicanRestaurants.name,
                    coordinate: mexicanRestaurants.coordinate
                ) {
                    Text(verbatim: "🇲🇽")
                        .padding(2)
                        .background(Color.black.opacity(0.4), in: Circle())
                }
                .tag(mexicanRestaurants)

            }

            UserAnnotation()
        }
            .onAppear() {
              CLLocationManager().requestWhenInUseAuthorization()

            }
            .mapControls {
                MapUserLocationButton()
            }
            .onChange(of: selection) { _, newValue in
                
                
                withAnimation(.easeInOut(duration: 1)) {
                    
                    if let newValue {
                        let reg = MKCoordinateRegion(center: newValue.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                        
                        cameraPosition = .region(reg)
                    } else {
                        cameraPosition = .automatic
                    }
                }
            }
            .sheet(item: $selection) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
                    .presentationDetents([.fraction(0.25)]) // Set the sheet height to 25% of the screen
                    .interactiveDismissDisabled() // Keep the map interactive
                    .presentationBackgroundInteraction(.enabled) // Keep the map interactive
            }

            
    }
    
}

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(restaurant.name)
                .font(.title)
                .bold()
            Text("Type of Food: \(restaurant.typeOfFood)")
                .font(.subheadline)
            Text("Location: \(restaurant.coordinate.latitude), \(restaurant.coordinate.longitude)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
