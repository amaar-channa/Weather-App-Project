//
//  ViewController.swift
//  Weather-Project
//
//  Created by Amaar Yasir Channa on 2024-07-17.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var weatherConditionImg: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var myLocationBtn: UIButton!
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        displaySampleImageForDemo()
        searchField.delegate = self
        locationManager.delegate = self
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        loadWeather(search: textField.text)
        return true
    }
    
    private func displaySampleImageForDemo() {
        let config = UIImage.SymbolConfiguration(paletteColors: [
            .blue, .yellow
        ])
        
        weatherConditionImg.preferredSymbolConfiguration = config
        weatherConditionImg.image = UIImage(systemName: "cloud.sun.fill")
    }
    
    
    @IBAction func onSearchedTapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    
    @IBAction func onLocationTapped(_ sender: Any) {
        loadWeather(search: searchField.text)
    }
    
    private func loadWeather(search: String?) {
        guard let search = search else {
            return
        }
        
        
        guard let url = getURL(query: search) else {
            print("Could not get URL")
            return
        }
        
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) { data, response, error in
            print("Network call Completed")
            
            guard error == nil else {
                print("Received error")
                return
            }
            
            guard let data = data else {
                print("No Data Found")
                return
            }
            
            if let weatherResponse = self.parseJSON(data: data) {
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                
                DispatchQueue.main.async {
                    self.locationLabel.text = weatherResponse.location.name
                    self.tempLabel.text = "\(weatherResponse.current.temp_c)C"
                }
                
                
            }
                
        }
        
        dataTask.resume()
    }
    
    private func displayLocation(latitude: Double, longitude: Double) {
        let urlString = "https://api.weatherapi.com/v1/current.json?key=f3dba11b9ebf45a18c2155521242203&q=\(latitude),\(longitude)"
        
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching weather data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            if let weatherResponse = self.parseJSON(data: data) {
                DispatchQueue.main.async {
                    self.locationLabel.text = weatherResponse.location.name
                    self.tempLabel.text = "\(weatherResponse.current.temp_c)°C"
                }
            }
        }
        
        dataTask.resume()
    }
    
    private func getURL(query: String) -> URL? {
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "f3dba11b9ebf45a18c2155521242203"
        guard let url = "\(baseURL)\(currentEndpoint)?Key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
                
        return URL(string: url)
    }
    
    private func parseJSON(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do {
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print("Error Decoding")
        }
        return weather
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got Location")
        
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("latlng: (\(latitude),\(longitude))")
           displayLocation(latitude: latitude, longitude: longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
     
}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}

struct Location: Decodable {
    let name: String
}

struct Weather: Decodable {
    let temp_c: Float
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}

class MyLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got Location")
        
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("latlng: (\(latitude),\(longitude))")
//            loadWeather(search: "(\(latitude),\(longitude))")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    

}

