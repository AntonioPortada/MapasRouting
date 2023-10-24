//
//  RutaViewController.swift
//  MapasRouting
//
//  Created by Antonio Portada on 18/10/23.
//

import UIKit
import MapKit
import CoreLocation

class RutaViewController: UIViewController {

    // MARK: - IBOulet
    @IBOutlet weak var txtLugarDestino: UITextField!
    @IBOutlet weak var map: MKMapView!
    
    // MARK: - local variables
    var manager = CLLocationManager()
    var latitud: Double?
    var longitud: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtLugarDestino.delegate = self
        map.delegate = self
        manager.delegate = self
        manager.requestLocation()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    
    func buscarDireccion() {
        
        self.map.removeAnnotations(self.map.annotations)
        self.map.removeOverlays(self.map.overlays)
        
        let geocoder = CLGeocoder()
        
        if let direccion = txtLugarDestino.text {
            geocoder .geocodeAddressString(direccion) { lugares, error in
                
                if error != nil {
                    self.showAlertOk(title: "Alerta", message: "Error al encontrar dirección")
                }
                
                if let lugar = lugares?.first {
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = lugar.location!.coordinate
                    annotation.title = direccion
                    
                    let lat = lugar.location!.coordinate.latitude
                    let long = lugar.location!.coordinate.longitude
                    annotation.subtitle = "Latitud: \(lat) - Longitud: \(long)"
                    
                    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                    
                    self.map.setRegion(region, animated: true)
                    self.map.addAnnotation(annotation)
                    self.map.showsUserLocation = true
                    
                    self.trazarRuta(coordendadasDestino: lugar.location!.coordinate)
                }
            }
        }
    }
    
    func trazarRuta(coordendadasDestino: CLLocationCoordinate2D) {
        
//        manager.startUpdatingLocation()
        
        let coorOrigen = CLLocationCoordinate2D(latitude: self.latitud ?? 0, longitude: self.longitud ?? 0)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coorOrigen
        annotation.title = "you are here"
        self.map.addAnnotation(annotation)
        
        let origenPlacemark = MKPlacemark(coordinate: coorOrigen)
        let destinoPlacemark = MKPlacemark(coordinate: coordendadasDestino)
        let origenItem = MKMapItem(placemark: origenPlacemark)
        let destinoItem = MKMapItem(placemark: destinoPlacemark)
        let solicitudRuta = MKDirections.Request()
        
        solicitudRuta.source = origenItem
        solicitudRuta.destination = destinoItem
        solicitudRuta.transportType = .automobile
        solicitudRuta.requestsAlternateRoutes = true //optional
        
        let directions = MKDirections(request: solicitudRuta)
        directions.calculate { respuesta, error in
            if error != nil {
                self.showAlertOk(title: "Atención", message: "Error al buscar la ruta.")
            }
            
            if let respuestaRuta = respuesta {
                if let defaultRute = respuestaRuta.routes.first {
                    self.map.addOverlay(defaultRute.polyline)
                    self.map.setVisibleMapRect(defaultRute.polyline.boundingMapRect, animated: true)
                }
            }
        }
    }
}

// MARK: - MKMapViewDelegate
extension RutaViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        
        return render
    }
}

// MARK: - CLLocationManagerDelegate
extension RutaViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let ubication = locations.first?.coordinate {
            self.latitud = ubication.latitude
            self.longitud = ubication.longitude
            
            print("coordenadas: lat - \(self.latitud!) : long: \(self.longitud!)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error al obtener la ubicación . . .")
        showAlertOk(title: "Atención", message: "Revisa los permisos del GPS.")
    }
}

// MARK: - UITextFieldDelegate
extension RutaViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        buscarDireccion()
        
        textField.text = ""
        textField.endEditing(true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        }
        else {
            showAlertOk(title: "Atención", message: "Necesitas escribir una dirección para buscar.")
            return false
        }
    }
}

