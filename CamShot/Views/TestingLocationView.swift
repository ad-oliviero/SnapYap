//
//  ContentView.swift
//  CamShot
//
//  Created by Adriano Oliviero on 16/12/25.
//

import Combine
import CoreLocation
import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack {
            if let coordinate = locationManager.lastKnownLocation {
                Text("Latitude: \(coordinate.latitude)")

                Text("Longitude: \(coordinate.longitude)")
            } else {
                Text("Unknown Location")
            }

            Button("Get location") {
                locationManager.checkLocationAuthorization()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
