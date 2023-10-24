//
//  ViewController.swift
//  MapasRouting
//
//  Created by Antonio Portada on 27/09/23.
//

import UIKit
import MapKit
import CoreLocation

class MainViewController: UIViewController {

    // MARK: - IBOulet
    @IBOutlet weak var mapa: MKMapView!
    
    // MARK: - local variables
    var manager = CLLocationManager()
    var lat: Double?
    var long: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        
        manager.requestWhenInUseAuthorization()
        
        //actualiza la ubicación
        manager.startUpdatingLocation()
    }

    // MARK: - IBAction
    @IBAction func btnCoordenadas(_ sender: Any) {
        showAlertOk(title: "Atención", message: "Ubicación encontrada:\nlatitud: \(self.lat!)\nlong: \(self.long!)")
    }
    
    @IBAction func btnZoom(_ sender: Any) {
        
        guard let lat, let long else { return }
        let ubicationMap = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let spanMap = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        let regionMap = MKCoordinateRegion(center: ubicationMap, span: spanMap)
        
        mapa.setRegion(regionMap, animated: true)
        mapa.showsUserLocation = true
    }
    
    // MARK: - local methods
    func showAlertOk(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionAcept = UIAlertAction(title: "Ok", style: .default) { _ in
            //do something
        }
        
        alert.addAction(actionAcept)
        
        present(alert, animated: true)
    }
}

// MARK: - CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let ubication = locations.first?.coordinate {
            self.lat = ubication.latitude
            self.long = ubication.longitude
            
            print("coordenadas: lat - \(self.lat!) : long: \(self.long!)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error al obtener la ubicación . . .")
    }
}
