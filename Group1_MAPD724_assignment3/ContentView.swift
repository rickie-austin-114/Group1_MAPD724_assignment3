//
//  ContentView.swift
//  map
//
//  Created by Rickie Au on 10/3/2025.
//

import SwiftUI
import MapKit
import CoreLocation


struct ContentView: View {
    
    @StateObject var model = RestaurantModel()
    @StateObject var locationState = LocationStateWithCLLocationUpdate()
    
    @State var cameraPosition = MapCameraPosition.automatic
    @State private var selectedRestaurant: Restaurant? // Track the selected restaurant
    @State private var isSheetPresented = false // Track whether the sheet is presented
    @State private var selectedDetent: PresentationDetent = .fraction(0.25) // Track sheet height
    
    var body: some View {
        Map(position: $cameraPosition, selection: $selectedRestaurant) {
            ForEach(model.bakeries) { bakery in
                Marker(bakery.name, systemImage: "birthday.cake.fill", coordinate: bakery.coordinate)
                    .tag(bakery)
            }
            
            ForEach(model.mexicanRestaurants) { mexicanRestaurant in
                Annotation(mexicanRestaurant.name, coordinate: mexicanRestaurant.coordinate) {
                    Text(verbatim: "🇲🇽")
                        .padding(2)
                        .background(Color.black.opacity(0.4), in: Circle())
                }
                .tag(mexicanRestaurant)
            }
            
            UserAnnotation()
        }
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
        }
        .mapControls {
            MapUserLocationButton()
        }
        .sheet(isPresented: $isSheetPresented) {
            if let selectedRestaurant {
                RestaurantDetailView(restaurant: selectedRestaurant, userLocation: locationState.location)
                    .presentationDetents([.fraction(0.25)], selection: $selectedDetent)
                    .interactiveDismissDisabled()
                    .presentationBackgroundInteraction(.enabled)
            }
        }
        .onChange(of: selectedRestaurant) { _, newValue in
            withAnimation(.easeInOut(duration: 1)) {
                if let newValue {
                    // Update the selected restaurant and present the sheet
                    selectedRestaurant = newValue
                    isSheetPresented = true
                    
                    // Update the camera position
                    let region = MKCoordinateRegion(center: newValue.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                    cameraPosition = .region(region)
                } else {
                    // Reset the sheet and camera position
                    selectedRestaurant = nil
                    isSheetPresented = false
                    cameraPosition = .automatic
                }
            }
        }
    }
}

