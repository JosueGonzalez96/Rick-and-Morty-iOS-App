//
//  ImageAsyncDownload.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
import SwiftUI

struct ImageAsyncDownload: View {
    let url: String
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .cornerRadius(12)
            case .failure:
                Image(systemName: "xmark.octagon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.red)
            @unknown default:
                EmptyView()
            }
        }
    }
}
