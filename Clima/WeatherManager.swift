//
//  WeatherManager.swift
//  Clima
//
//  Created by Bar Elimelech on 27/01/2025.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherDataDelegate {
    func didUpdateWeather(_ weatherManager:WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let watherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=ebfc567d31b7acdec79f1e2dff01ca15&units=metric"
    var delegate: WeatherDataDelegate?
    
    func fetchWeather(cityName: String){
        let urlString = "\(watherUrl)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(lantitude: CLLocationDegrees, longitude: CLLocationDegrees){
        let urlString = "\(watherUrl)&lat=\(lantitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)// the thing that can perform the networking
            let task = session.dataTask(with: url) {(data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
    
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            return weather
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    

    
}
