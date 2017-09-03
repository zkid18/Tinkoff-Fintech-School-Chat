//
//  ViewController.swift
//  Currency_Exchange
//
//  Created by Даниил on 21.02.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

   
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pickerTo: UIPickerView!
    @IBOutlet weak var pickerFrom: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let currencies = ["RUB", "EUR", "USD"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
        setDataSource()
        internetConnection()
        self.activityIndicator.hidesWhenStopped = true
        self.requestCurrentCurrencyRate()
        // Do any additional setup after loading the view.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


extension ViewController: UIPickerViewDelegate{
    
    func setDelegate() {
        self.pickerTo.delegate = self
        self.pickerFrom.delegate = self
    }
    
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


extension ViewController: UIPickerViewDataSource {
    
    func setDataSource() {
        self.pickerFrom.dataSource = self
        self.pickerTo.dataSource = self
    }
    
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

extension ViewController {
    
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

extension ViewController {
    func curreincesExeptBase() -> [String] {
        var currenciesExeptBase = currencies
        currenciesExeptBase.remove(at: pickerFrom.selectedRow(inComponent: 0))
        
        return currenciesExeptBase
    }
    
    func requestCurrentCurrencyRate() {
        
        self.activityIndicator.startAnimating()
        self.label.text = ""
        
        let baseCurrencyIndex = self.pickerFrom.selectedRow(inComponent: 0)
        let toCurrencyIndex = self.pickerTo.selectedRow(inComponent: 0)
        
        let baseCurrency = self.currencies[baseCurrencyIndex]
        let toCurrency = self.curreincesExeptBase()[toCurrencyIndex]
        
        self.retrieveCurrencyRate(baseCurrency: baseCurrency, toCurrency: toCurrency) { [weak self] (value) in
            DispatchQueue.main.async {
                if let strongSelf = self {
                    strongSelf.label.text = value
                    strongSelf.activityIndicator.stopAnimating()
                }
            }
        }

    }
}

extension ViewController {
    func internetConnection() {
        if Reachability.isConnectedToNetwork() {
            print("Internt connection is good")
        } else {
            print("Please turn on internet connection")
        }
    }
}

