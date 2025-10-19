//
//  DatailCharacterVM.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
private import Combine
internal import CoreData
import CoreLocation
import MapKit

final class DetailCharacterVM: ObservableObject {
    @Published private(set) var item: CharacterRM
    @Published private(set) var episodes: [EpisodeModel] = []
    @Published var isFavorite: Bool = false
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var pinLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @Published var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
    private var cancellables = Set<AnyCancellable>()
    private var context: NSManagedObjectContext
    
    init(item: CharacterRM, context: NSManagedObjectContext) {
        self.item = item
        self.context = context
        getFavorite()
        getAllEpisodes()
        let random = getRandomCoordinates()
        pinLocation = random
        region.center = random
    }
   
    private func getFavorite() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Character")
        fetchRequest.predicate = NSPredicate(format: "id == %d", item.id)
        do {
            if let resultado = try context.fetch(fetchRequest).first,
               let isFav = resultado.value(forKey: "isFavorite") as? Bool {
                isFavorite = isFav
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateFavorite() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Character")
        fetchRequest.predicate = NSPredicate(format: "id == %d", item.id)
        
        do {
            let resultados = try context.fetch(fetchRequest)
            
            if let objeto = resultados.first {
                objeto.setValue(isFavorite, forKey: "isFavorite")
                try context.save()
            } else {
                saveFavorite()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func saveFavorite() {
        let entidad = NSEntityDescription.entity(forEntityName: "Character", in: context)!
        let objeto = NSManagedObject(entity: entidad, insertInto: context)
        
        // Asignar valores a los atributos
        objeto.setValue(item.id, forKey: "id")
        objeto.setValue(item.name, forKey: "name")
        objeto.setValue(item.status, forKey: "status")
        objeto.setValue(item.species, forKey: "species")
        objeto.setValue(item.type, forKey: "type")
        objeto.setValue(item.gender, forKey: "gender")
        objeto.setValue(item.origin.name, forKey: "locationOriginName")
        objeto.setValue(item.origin.url, forKey: "locationOriginUrl")
        objeto.setValue(item.location.name, forKey: "currentLocationName")
        objeto.setValue(item.location.url, forKey: "currentLocationUrl")
        objeto.setValue(item.image, forKey: "image")
        objeto.setValue(true, forKey: "isFavorite")
        objeto.setValue(item.episode as NSArray, forKey: "episode")
        objeto.setValue(item.url, forKey: "url")
        objeto.setValue(item.created, forKey: "created")
        do {
            try context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func getAllEpisodes() {
        Task {
            do {
                let episodes = try await fetchAllEpisodes(for: item.episode)
                DispatchQueue.main.async {
                    self.episodes.removeAll()
                    self.episodes.append(contentsOf: episodes)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    private func fetchEpisode(from urlString: String) async throws -> EpisodeModel {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let episode = try JSONDecoder().decode(EpisodeModel.self, from: data)
        return episode
    }
    
    private func fetchAllEpisodes(for episodeURLs: [String]) async throws -> [EpisodeModel] {
        var episodes: [EpisodeModel] = []
        
        // Concurrencia con TaskGroup para acelerar
        try await withThrowingTaskGroup(of: EpisodeModel.self) { group in
            for url in episodeURLs {
                group.addTask {
                    try await self.fetchEpisode(from: url)
                }
            }
            
            for try await episode in group {
                episodes.append(episode)
            }
        }
        
        return episodes
    }
    private func getRandomCoordinates() -> CLLocationCoordinate2D {
        let coordinate = CLLocationCoordinate2D(
            latitude: Double.random(in: -90...90),
            longitude: Double.random(in: -180...180)
        )
        return coordinate
    }
        
}
