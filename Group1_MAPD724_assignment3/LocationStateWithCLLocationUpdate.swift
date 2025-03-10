//
//  LocationStateWithCLLocationUpdate.swift
//  Group1_MAPD724_assignment3
//
//  Created by Rickie Au on 10/3/2025.
//
import SwiftUI
import CoreLocation


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
