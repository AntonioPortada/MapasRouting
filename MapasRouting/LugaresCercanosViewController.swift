//
//  LugaresCercanosViewController.swift
//  MapasRouting
//
//  Created by Antonio Portada on 23/10/23.
//

import UIKit
import MapKit

class LugaresCercanosViewController: UIViewController {

    // MARK: - IBOulet
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var map: MKMapView!
    
    // MARK: - local variables
    var manager = CLLocationManager()
    
    var userLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtSearch.delegate = self
        manager.delegate = self
        
        manager.requestLocation()
    }
    
    // MARK: - local methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func buscarLugares(lugar: String) {
        
        guard let userLocation = userLocation else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = lugar
        request.region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 6000, longitudinalMeters: 6000)
        
        let search = MKLocalSearch(request: request)
        search.start { lugares, error in
            
            if error != nil {
                self.showAlertOk(title: "Atención", message: "Error al encontrar lugares, intentalo nuevamente.")
            }
            
            guard let lugares else { return }
            
            for item in lugares.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                annotation.subtitle = lugar
                self.map.addAnnotation(annotation)
            }
        }
        
        let spanMap = MKCoordinateSpan(latitudeDelta: 0.09, longitudeDelta: 0.09)
        let regionMap = MKCoordinateRegion(center: userLocation.coordinate, span: spanMap)
        
        self.map.setRegion(regionMap, animated: true)
        self.map.showsUserLocation = true
    }
    
    func showAlertOk(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionAcept = UIAlertAction(title: "Ok", style: .default) { _ in
            //do something
        }
        
        alert.addAction(actionAcept)
        
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension LugaresCercanosViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // do something
        buscarLugares(lugar: txtSearch.text ?? "")
        
        txtSearch.text = ""
        textField.endEditing(true)
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        buscarLugares(lugar: txtSearch.text ?? "")
        
        textField.text = ""
        textField.endEditing(true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField.text != "" {
            return true
        }
        else {
            // do something
            textField.placeholder = "Debes escribir algo..."
            
            return false
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LugaresCercanosViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error al obtener lugares cercanos.")
    }
}
