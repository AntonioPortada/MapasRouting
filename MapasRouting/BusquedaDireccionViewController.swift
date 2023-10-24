//
//  BusquedaDireccionViewController.swift
//  MapasRouting
//
//  Created by Antonio Portada on 28/09/23.
//

import UIKit
import MapKit

class BusquedaDireccionViewController: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var txtDireccionABuscar: UITextField!
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtDireccionABuscar.delegate = self
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func buscarDireccion() {
        //eliminar pines anteriores
        self.map.removeAnnotations(self.map.annotations)
        
        let geocoder = CLGeocoder()
        
        if let direccion = txtDireccionABuscar.text {
            geocoder.geocodeAddressString(direccion) { lugares, error in
                if error != nil {
                    self.showAlertOk(title: "Atención", message: "Error al encontrar dirección")
                }
                
                if let lugar = lugares?.first {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = lugar.location!.coordinate
                    annotation.title = direccion
                    annotation.subtitle = "\(lugar.location?.coordinate.latitude)  \(lugar.location?.coordinate.longitude)"
                    
                    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
                    
                    self.map.setRegion(region, animated: true)
                    self.map.addAnnotation(annotation)
                    self.map.showsUserLocation = true
                }
            }
        }
    }
}

extension BusquedaDireccionViewController: UITextFieldDelegate {
    
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

