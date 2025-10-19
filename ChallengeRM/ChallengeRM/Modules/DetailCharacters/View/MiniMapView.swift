//
//  MiniMapView.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
import MapKit
import SwiftUI

struct MiniMapView: View {
    @StateObject var viewModel: DetailCharacterVM
    @State private var showFullScreen = false

    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, annotationItems: [PinModel(id: 0, coordinate: viewModel.pinLocation)]) { pin in
                MapPin(coordinate: pin.coordinate, tint: .red) 
            }
            .frame(width: 150, height: 150)
            .cornerRadius(12)
            .shadow(radius: 4)
            .fullScreenCover(isPresented: $showFullScreen) {
                ZStack(alignment: .topTrailing) {
                    Map(coordinateRegion: $viewModel.region, annotationItems: [PinModel(id: 0, coordinate: viewModel.pinLocation)]) { pin in
                        MapPin(coordinate: pin.coordinate, tint: .red)
                    }
                    .ignoresSafeArea()
                    
                    Button(action: {
                        showFullScreen = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .padding()
                    }
                }
            }
            
            Rectangle()
                .foregroundColor(.clear)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        showFullScreen.toggle()
                    }
                }
        }
    }
}
