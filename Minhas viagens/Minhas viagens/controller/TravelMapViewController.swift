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
    var travelSelected: Travel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    private func initialize() {
        initLocationManager()
        registerMapLongPressGesture()
        loadTravels()
        validateTravelSelected()
    }
    
    private func loadTravels() {
        let travels = TravelRepository.shared.getAll()
        if !travels.isEmpty {
            travels.forEach { (travelItem) in
                self.applyPointAnnotationByAddress(travelItem.address)
            }
        }
    }
    
    private func validateTravelSelected(){
        if let travel = travelSelected{
            applyZoomRegion(latitude: travel.address.latitude, longitude: travel.address.longitude)
        } else {
            applyZoomRegion()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationLast = locations.last, travelSelected == nil {
            applyZoomRegion(latitude: locationLast.coordinate.latitude, longitude: locationLast.coordinate.longitude)
        }
    }
    
    private func applyZoomRegion(latitude: CLLocationDegrees = -19.85175198311673,
                                 longitude: CLLocationDegrees = -43.98147330120311) {
        
        let deltaLatitude: CLLocationDegrees = 0.01
        let deltaLongitude: CLLocationDegrees = 0.01
        
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let areaVisualization = MKCoordinateSpan(latitudeDelta: deltaLatitude, longitudeDelta: deltaLongitude)
        
        let region =  MKCoordinateRegion(center: location, span: areaVisualization)
        mapView.setRegion(region, animated: true)
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
        
        findAddressByLocation(coordinate){ address in
            self.validateAddress(address)
        }
    }
    
    private func validateAddress(_ address: Address?){
        if let addressReceived = address {
            AlertHelper.shared.showConfirmationMessage(viewController: self, message: "Criar viagem \(addressReceived.name)?", positiveHandler:  { _ in
                self.createTravel(addressReceived)
            },negativeHandler: nil)
        }
    }
    
    private func createTravel(_ address: Address) {
        let isSuccess = TravelRepository.shared.save(travel: Travel(address: address))
        if isSuccess {
            self.applyPointAnnotationByAddress(address)
            AlertHelper.shared.showMessage(viewController: self, message: "Viagem criada com sucesso!")
        } else {
            AlertHelper.shared.showMessage(viewController: self, message: "Error ao criar viagem!")
        }
    }
    
    fileprivate func createPointAnnotation( _ address: Address) -> MKPointAnnotation {
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate.latitude = address.latitude
        pointAnnotation.coordinate.longitude = address.longitude
        let pointDetail = address.getDetailPoint()
        pointAnnotation.title = pointDetail.title
        pointAnnotation.subtitle = pointDetail.subtitle
        return pointAnnotation
    }
    
    private func applyPointAnnotationByAddress(_ address: Address) {
        let pointAnnotation = createPointAnnotation(address)
        self.mapView.addAnnotation(pointAnnotation)
    }
    
    private func findAddressByLocation(_ coordinate: CLLocationCoordinate2D, completion: @escaping (Address?)-> (Void)) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
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
                                           subAdministrativeArea: placemarkFirst.subAdministrativeArea ?? "",
                                           latitude: coordinate.latitude,
                                           longitude: coordinate.longitude)
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
