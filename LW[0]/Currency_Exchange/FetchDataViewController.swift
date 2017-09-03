//
//  FetchDataViewController.swift
//  Currency_Exchange
//
//  Created by Даниил on 21.02.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit

class FetchDataViewController: UIViewController {
    
    @IBOutlet weak var refreshButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        internetConnection()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updatePickerInfoBeforeStart() {
        self.retrieveCurrency{ [weak self] currencies in
            Currency.shared.currencies += currencies
            self?.performSegue(withIdentifier: "LoadCurrency", sender: nil)
        }
    }
    
    @IBAction func refreshData(_ sender: Any) {
        updatePickerInfoBeforeStart()
    }
    
    
    
}

extension FetchDataViewController {
    
    func parseCurrensyResponse(data: Data?) -> [String] {
        var currencies: [String] = [""]
        
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, Any>
            
            if let parsedJSON = json {
                if let rates = parsedJSON["rates"] as? Dictionary<String, Double> {
                    currencies = Array(rates.keys)
                }
            }
        } catch {
            fatalError()
        }
        
        return currencies
    }
    
    func requestCurrencyRates(parseHandler: @escaping (Data?, Error?) -> Void) {
        let url = URL(string: "https://api.fixer.io/latest")!
        
        let dataTask = URLSession.shared.dataTask(with: url) {
            (dataRecieved, response, error) in
            parseHandler(dataRecieved, error)
        }
        
        dataTask.resume()
    }
    
    func retrieveCurrency(completion: @escaping ([String]) -> Void) {
        requestCurrencyRates { [unowned self] (data, error) in
            
            if error != nil {
                fatalError()
            } else {
                DispatchQueue.main.async {
                    completion(self.parseCurrensyResponse(data: data))
                }
                
            }
        }
    }
}

extension FetchDataViewController {
    func internetConnection() {
        if Reachability.isConnectedToNetwork() {
            print("Internt connection is good")
            updatePickerInfoBeforeStart()
        } else {
            print("Please turn on internet connection")
            createAlert()
            refreshButton.isHidden = false
            refreshButton.isEnabled = true
        }
    }
    
    func createAlert() {
        
        let alertController = UIAlertController(title: "No internet connection", message: "Please try again", preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: "Cancel", style: .destructive)
        alertController.addAction(tryAgainAction)
        self.present(alertController, animated: true)
    }
}

