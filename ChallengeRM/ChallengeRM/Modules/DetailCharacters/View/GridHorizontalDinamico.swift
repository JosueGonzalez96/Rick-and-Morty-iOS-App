//
//  GridHorizontalDinamico.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
import SwiftUI
internal import Combine
struct GridHorizontalDinamico: View {
    let rows = [GridItem(.fixed(150))]
    @ObservedObject var viewModel: DetailCharacterVM

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 16) {
                ForEach(viewModel.episodes) { episode in
                    VStack {
                        Image("placeholder")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .cornerRadius(10)
                        Text(episode.name)
                            .font(.caption)
                    }
                    .frame(width: 140)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}
