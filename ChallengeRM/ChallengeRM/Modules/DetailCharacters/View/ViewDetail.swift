//
//  ViewDetail.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//
import SwiftUI

struct ViewDetail: View {
    @StateObject var viewModel: DetailCharacterVM
    var body: some View {
        
        ScrollView {
            VStack(alignment: .center, spacing: 8) {
                Spacer(minLength: 100)
                ImageAsyncDownload(url: viewModel.item.image)
                    .padding(.horizontal)
                    .padding(.top)
                    .frame(height: 200)
                Text(viewModel.item.name)
                    .font(.title)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Genero: " + viewModel.item.gender)
                            .font(.title3)
                        Text("Especie: " + viewModel.item.species)
                            .font(.title3)
                        Text("Estado: " + viewModel.item.status)
                            .font(.title3)
                    }
                  
                }
               
                HStack(spacing: 30) {
                    Text("Numero de episodios: " + "\(viewModel.item.episode.count)")
                        .font(.title)
                        .padding()
                    Button(action: {
                        viewModel.isFavorite.toggle()
                        viewModel.updateFavorite()
                    }) {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")// heart.square.fill
                            .font(.title)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
                GridHorizontalDinamico(viewModel: viewModel)
                HStack(alignment:.center, spacing: 20) {
                    VStack{
                        Text("Ubicación actual")
                            .font(.title2)
                        Text(viewModel.item.location.name)
                            .font(.body)
                        MiniMapView(viewModel: viewModel)
                    }
                    VStack{
                        Text("Ubicación origen")
                            .font(.title2)
                        Text(viewModel.item.origin.name)
                            .font(.body)
                        MiniMapView(viewModel: viewModel)
                    }
                }
            }
            .padding(.horizontal)
            .background(Color.green.opacity(0.2))
        }
    }
}
