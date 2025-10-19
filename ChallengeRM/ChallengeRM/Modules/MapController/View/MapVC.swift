//
//  MapVC.swift
//  ChallengeRM
//
//  Created by Alberto Josue Gonzalez Juarez on 18/10/25.
//

import Foundation
import UIKit
import MapKit
import SDWebImage

final class MapVC: UIViewController {
    let mapView = MKMapView()
    private let showButton = UIButton(type: .system)
    private var viewModel: MapVM
    
    init(viewModel: MapVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mapa"
        setupMap()
        setupButton()
    }

    private func setupMap() {
        mapView.frame = view.bounds
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
        ])
    }

    private func setupButton() {
        showButton.setTitle("Mostrar personajes", for: .normal)
        showButton.backgroundColor = .systemBlue
        showButton.setTitleColor(.white, for: .normal)
        showButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        showButton.layer.cornerRadius = 10
        showButton.translatesAutoresizingMaskIntoConstraints = false
        showButton.addTarget(self, action: #selector(showSheet), for: .touchUpInside)

        view.addSubview(showButton)

        NSLayoutConstraint.activate([
            showButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            showButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            showButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            showButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func showSheet() {
        let sheetVC = CharactersSheetViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: sheetVC)
        sheetVC.onSelectCharacter = { [weak self] character in
            self?.centerMap(for: character)
        }

        if let sheet = sheetVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }
    
    func addCharacterAnnotation(character: CharacterRM, coordinate: CLLocationCoordinate2D) {
        mapView.removeAnnotations(mapView.annotations)
        let annotation = CharacterAnnotation(character: character, coordinate: coordinate)
        mapView.addAnnotation(annotation)
    }


    func centerMap(for character: CharacterRM) {
        let coordinate = CLLocationCoordinate2D(
            latitude: Double.random(in: -90...90),
            longitude: Double.random(in: -180...180)
        )
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30))
        mapView.setRegion(region, animated: true)
        addCharacterAnnotation(character: character, coordinate: coordinate)
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let characterAnnotation = annotation as? CharacterAnnotation else { return nil }
        
        let identifier = "CharacterPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: characterAnnotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = characterAnnotation
        }
        
        if let url = URL(string: characterAnnotation.character.image) {
            let imageView = UIImageView()
            imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder")) { image, _, _, _ in
                if let img = image {
                    annotationView?.image = self.resizeImage(image: img, targetSize: CGSize(width: 40, height: 40))
                }
            }
        }
        return annotationView
    }
}
