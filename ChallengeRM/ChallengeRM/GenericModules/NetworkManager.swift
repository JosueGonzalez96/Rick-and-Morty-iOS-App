//
//  NetworkManager.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Network
internal import Combine

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()

    @Published var hasNetworkConnection: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.hasNetworkConnection = (path.status == .satisfied)
                print("Conexión a la red: \(self.hasNetworkConnection)")
            }
        }
        monitor.start(queue: queue)
    }
}
