//
//  RestaurantDetailView.swift
//  Group1_MAPD724_assignment3
//
//  Created by Rickie Au on 10/3/2025.
//

import SwiftUI
import CoreLocation




struct RestaurantDetailView: View {
    let restaurant: Restaurant
    let userLocation: CLLocation?

    var distanceText: String {
        guard let userLocation else { return "Unknown distance" }
        
        let restaurantLocation = CLLocation(latitude: restaurant.latitude, longitude: restaurant.longitude)
        let distanceInMeters = userLocation.distance(from: restaurantLocation)
        
        let distanceInKilometers = distanceInMeters / 1000.0
        return String(format: "%.4f km away", distanceInKilometers)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(distanceText) // ✅ Show distance at the top
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.bottom, 4)
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
