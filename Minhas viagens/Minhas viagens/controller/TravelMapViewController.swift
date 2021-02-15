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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
    }
    private func initLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
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

