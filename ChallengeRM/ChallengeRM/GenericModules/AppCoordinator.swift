//
//  AppCoordinator.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
import UIKit
internal import CoreData

final class AppCoordinator {
    let window: UIWindow

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        let service = APIService()
        
        let tabbarC = UITabBarController()
        
        let viewModel = ListVM(service: service)
        let rootVC = ListVC(viewModel: viewModel)
        rootVC.tabBarItem = UITabBarItem(title: "Personajes", image: UIImage(systemName: "figure.arms.open"), tag: 0)
        let navC = UINavigationController(rootViewController: rootVC)
        
        let viewModelFavorites = FavoritesVM(context: context)
        let rootFavoritesVC = FavoritesVC(viewModel: viewModelFavorites)
        rootFavoritesVC.tabBarItem = UITabBarItem(title: "Favoritos", image: UIImage(systemName: "heart"), tag: 1)
        let navCFavorites = UINavigationController(rootViewController: rootFavoritesVC)
        
        let mapViewModel = MapVM(service: service)
        let mapVC = MapVC(viewModel: mapViewModel)
        mapVC.tabBarItem = UITabBarItem(title: "Mapa", image: UIImage(systemName: "map"), tag: 2)
        let navCFMapVC = UINavigationController(rootViewController: mapVC)

        tabbarC.viewControllers = [navC, navCFavorites, navCFMapVC]
        window.rootViewController = tabbarC
        window.makeKeyAndVisible()
    }
}
