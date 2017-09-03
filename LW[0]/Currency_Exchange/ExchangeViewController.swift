//
//  ViewController.swift
//  Currency_Exchange
//
//  Created by Даниил on 20.02.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ExchangeViewController: UIViewController {

    @IBOutlet var pickerFrom: AKPickerView!
    @IBOutlet weak var currentNumberLabel: UILabel!
    @IBOutlet weak var pickerTo: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var exchangeMapView: MKMapView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var currencies = Currency.shared.currencies
    var centers = CreateExchangeCenters.shared.exchangeCenters
    
    let locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 1000
    let currentDate = Date()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        setDataLabel()
        setupLabelInPicker()
        self.activityIndicator.hidesWhenStopped = true
        requestCurrentCurrencyRate()
        findMyLocation()
        showAnnotation()
    }
    
    
}

extension ExchangeViewController: AKPickerViewDelegate, AKPickerViewDataSource {
    
    func setDelegates() {
        self.pickerFrom.delegate = self
        self.pickerFrom.dataSource = self
    }
    
    // MARK: - AKPickerViewDataSource
    
    func numberOfItemsInPickerView(_ pickerView: AKPickerView) -> Int {
        return self.currencies.count
    }
    
    func pickerView(_ pickerView: AKPickerView, titleForItem item: Int) -> String {
        return self.currencies[item]
    }
    
    
    // MARK: - AKPickerViewDelegate
    
    func pickerView(_ pickerView: AKPickerView, didSelectItem item: Int) {        
        if pickerView === pickerTo {
            self.pickerTo.reloadAllComponents()
        }
        
        self.requestCurrentCurrencyRate()
    }
    
    func setupLabelInPicker() {
        self.pickerFrom.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
        self.pickerFrom.highlightedFont = UIFont(name: "HelveticaNeue", size: 20)!
        self.pickerFrom.textColor = UIColor.white
        self.pickerFrom.pickerViewStyle = .wheel
        self.pickerFrom.maskDisabled = false
        self.pickerFrom.reloadData()
    }
}


// MARK: - UIPickerViewDataSource

extension ExchangeViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView === pickerTo {
            return self.curreincesExeptBase().count
        }
        
        return currencies.count
    }
}

// MARK: - UIPickerViewDelegate

extension ExchangeViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView === pickerTo {
            return self.curreincesExeptBase()[row]
        }
        
        return currencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        if pickerView === pickerTo {
            self.pickerTo.reloadAllComponents()
        }
        
        self.requestCurrentCurrencyRate()
    }
    
    
}



// MARK: - Parsing

extension ExchangeViewController {
    
    func requestCurrencyRates(baseCurrency: String, parseHandler: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: "https://api.fixer.io/latest?base=" + baseCurrency) else {return}
        
        let dataTask = URLSession.shared.dataTask(with: url) { (dataRecieved, response, error) in
            parseHandler(dataRecieved, error)
        }
        
        dataTask.resume()
    }
    
    func parseCurrencyRatesResponse(data: Data?, toCurrency: String) -> String {
        var value: String = ""
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
            
            if let parsedJSON = json {
                if let rates = parsedJSON["rates"] as? Dictionary<String, Double> {
                    if let rate = rates[toCurrency] {
                        value = "\(rate)"
                    } else {
                        value = "No rate currency \(toCurrency) found"
                    }
                } else {
                    value = "No rate fields found"
                }
            } else {
                value = "No JSON value parsed"
            }
        } catch {
            value = error.localizedDescription
        }
        
        return value
    }
    
    func retrieveCurrencyRate(baseCurrency: String, toCurrency: String, completion: @escaping (String) -> Void) {
        self.requestCurrencyRates(baseCurrency: baseCurrency) { [weak self] (data, error) in
            var string = "No currenct recieved"
            
            if let currentError = error {
                string = currentError.localizedDescription
            } else {
                if let strongSelf = self {
                    string = strongSelf.parseCurrencyRatesResponse(data: data, toCurrency: toCurrency)
                }
            }
            
            completion(string)
        }
    }

}


extension ExchangeViewController {
    
    func curreincesExeptBase() -> [String] {
        var currenciesExeptBase = currencies
        currenciesExeptBase.remove(at: pickerFrom.selectedItem)
        
        return currenciesExeptBase
    }
    
    func requestCurrentCurrencyRate() {
        
        self.activityIndicator.startAnimating()
        self.currentNumberLabel.text = ""
        
        let baseCurrencyIndex = self.pickerFrom.selectedItem
        let toCurrencyIndex = self.pickerTo.selectedRow(inComponent: 0)
        
        let baseCurrency = self.currencies[baseCurrencyIndex]
        let toCurrency = self.curreincesExeptBase()[toCurrencyIndex]
        
        print(baseCurrency)
        print(toCurrency)
        
        self.retrieveCurrencyRate(baseCurrency: baseCurrency, toCurrency: toCurrency) { [weak self] (value) in
            DispatchQueue.main.async {
                if let strongSelf = self {
                    strongSelf.currentNumberLabel.text = value
                    strongSelf.activityIndicator.stopAnimating()
                }
            }
        }
        
    }

}


extension ExchangeViewController: CLLocationManagerDelegate {

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        exchangeMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            centerMapOnLocation(location: location)
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func findMyLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
    }
    
}


extension ExchangeViewController: MKMapViewDelegate {
    
    
    func showAnnotation() {
        exchangeMapView.addAnnotations(centers)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? ExchangeCenter {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.init(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
}


extension ExchangeViewController {
    func setDataLabel() {
        dateFormatter.dateStyle = .medium
        dateLabel.text = dateFormatter.string(from: currentDate)
    }
}

