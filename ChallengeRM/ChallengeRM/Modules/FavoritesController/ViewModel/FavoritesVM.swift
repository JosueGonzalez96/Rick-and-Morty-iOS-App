//
//  FavoritesVM.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

internal import Combine
internal import CoreData
import UIKit
import LocalAuthentication

class FavoritesVM {
    enum Input {
        case refresh
        case delete(Int)
        case authenticateUser
    }
    private var context: NSManagedObjectContext
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var characters: [FavoriteCharacterModel] = []
    @Published private(set) var showAuthFailedAlert: String? = nil
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetchCharacters()
    }
    func send(_ input: Input) {
        switch input {
        case .refresh:
            refresh()
        case .delete(let index):
            delete(index: index)
        case .authenticateUser:
            authenticateUser()
        }
    }
    private func refresh() {
        characters = []
        fetchCharacters()
    }
    private func delete(index: Int) {
        let item = characters[index]
        characters.remove(at: index)
        deleteCharacterFromCoreData(id: item.id)
        
    }
    private func deleteCharacterFromCoreData(id: Int) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Character")
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let objectToDelete = results.first {
                context.delete(objectToDelete)
                try context.save()
                print("Personaje con id \(id) eliminado")
            }
        } catch {
            print("Error al borrar: \(error.localizedDescription)")
        }
    }
    private func fetchCharacters() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Character")
        fetchRequest.predicate = NSPredicate(format: "isFavorite == %d", true)

        do {
            let resultados = try context.fetch(fetchRequest)
            let characters = resultados.compactMap { objeto -> FavoriteCharacterModel? in
                guard
                    let id = objeto.value(forKey: "id") as? Int,
                    let name = objeto.value(forKey: "name") as? String,
                    let image = objeto.value(forKey: "image") as? String,
                    let url = objeto.value(forKey: "url") as? String,
                    let isFavorite = objeto.value(forKey: "isFavorite") as? Bool
                else {
                    return nil
                }
                
                return FavoriteCharacterModel(id: id, name: name, image: image, url: url, isFavorite: isFavorite)
            }
            self.characters = characters
        } catch {
            print("Error: \(error)")
            return
        }
    }
    
    private func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Accede a tus personajes favoritos"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.send(.refresh)
                    } else {
                        self?.showAuthFailedAlert = "No pudimos verificar tu identidad."
                    }
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.send(.refresh)
            }
        }
    }
}
