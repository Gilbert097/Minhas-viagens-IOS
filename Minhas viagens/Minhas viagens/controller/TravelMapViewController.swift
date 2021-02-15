//
//  ViewController.swift
//  Minhas viagens
//
//  Created by Gilberto Silva on 15/02/21.
//

import UIKit
import MapKit

class TravelMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    private var locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        registerMapLongPressGesture()
    }
    
    private func initLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func registerMapLongPressGesture() {
        let mapLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.onMapLongPress(gesture:)))
        mapView.addGestureRecognizer(mapLongPressGesture)
    }
    
    @objc func onMapLongPress(gesture: UIGestureRecognizer){
        switch gesture.state {
        case .possible:
            print("gesture possible")
        case .began:
            print("gesture began")
            onMapGestureBegan(gesture)
        case .changed:
            print("gesture changed")
        case .ended:
            print("gesture ended")
        case .cancelled:
            print("gesture cancelled")
        case .failed:
            print("gesture failed")
        @unknown default:
            print("Error gesture state nil")
        }
    }
    
    private func onMapGestureBegan(_ gesture: UIGestureRecognizer) {
        let pointSelected = gesture.location(in: self.mapView)
        let coordinate = self.mapView.convert(pointSelected ,toCoordinateFrom: self.mapView)
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        findAddressByLocation(location){ address in
            self.applyPointAnnotationByAddress(coordinate, address)
        }
    }
    
    private func applyPointAnnotationByAddress(_ location: CLLocationCoordinate2D, _ address: Address?) {
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate.latitude = location.latitude
        pointAnnotation.coordinate.longitude = location.longitude
        if let addressReceived = address {
            if(!addressReceived.name.isEmpty){
                pointAnnotation.title = addressReceived.name
                pointAnnotation.subtitle = addressReceived.getShortAddress()
            }else{
                pointAnnotation.title = addressReceived.getShortAddress()
                pointAnnotation.subtitle = ""
            }
        }
        
        self.mapView.addAnnotation(pointAnnotation)
    }
    
    private func findAddressByLocation(_ location: CLLocation, completion: @escaping (Address?)-> (Void)) {
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil {
                
                if let placemarksRecived = placemarks,
                   let placemarkFirst = placemarksRecived.first {
                    let address =  Address(name: placemarkFirst.name ?? "",
                                           thoroughfare: placemarkFirst.thoroughfare ?? "",
                                           subThoroughfare: placemarkFirst.subThoroughfare ?? "",
                                           locality: placemarkFirst.locality ?? "",
                                           subLocality: placemarkFirst.subLocality ?? "",
                                           postalCode: placemarkFirst.postalCode ?? "",
                                           country: placemarkFirst.country ?? "",
                                           administrativeArea: placemarkFirst.administrativeArea ?? "",
                                           subAdministrativeArea: placemarkFirst.subAdministrativeArea ?? "")
                    completion(address)
                }else{
                    completion(nil)
                }
            }else{
                completion(nil)
                print("Error: \(String(describing: error))")
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        let status =  manager.authorizationStatus
        switch status {
        case .notDetermined:
            print("Status: notDetermined")
        case .restricted:
            print("Status: restricted")
        case .denied:
            print("Status: denied")
            showAlertRequestPermissionLocation()
        case .authorizedAlways:
            print("Status: authorizedAlways")
        case .authorizedWhenInUse:
            print("Status: authorizedWhenInUse")
            locationManager.startUpdatingLocation()
        @unknown default:
            print("Status: nil")
        }
    }
    
    
    private func showAlertRequestPermissionLocation() {
        let alertController = UIAlertController(title: "Permissão de localização",
                                                message: "Necessário permissão para à sua localização!",
                                                preferredStyle: .actionSheet)
        addAlertActions(alertController)
        present(alertController, animated: true, completion: nil)
    }
    
    private func addAlertActions(_ alertController: UIAlertController) {
        let configurationAction = UIAlertAction(title: "Abrir configurações",
                                                style: .default) { (action) in
            
            if let bundleId = Bundle.main.bundleIdentifier,
               let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)"),
               UIApplication.shared.canOpenURL(url)
            {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        
        alertController.addAction(configurationAction)
        alertController.addAction(cancelAction)
    }
    
    
    
    
}

