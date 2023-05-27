import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let networkManager = WeatherNetworkManager()
    
    let currentLocation: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Location"
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 38, weight: .heavy)
        return label
    }()
    let currentTime: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "26 May 2023"
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 10, weight: .heavy)
        return label
    }()
    let currentTemperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 60, weight: .heavy)
        return label
    }()
    let tempDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "..."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        return label
    }()
    let tempSymbol: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(systemName: "cloud.fill")
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        img.tintColor = .gray
        return img
    }()
    let condAdvice: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textAlignment = .center
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    let tempAdvice: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.textAlignment = .left
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    var locationManager = CLLocationManager()
    var currentLoc: CLLocation?
    var stackView : UIStackView!
    var latitude : CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBarController = tabBarController as? TabBarController {
            tabBarController.centralButtonHandler = { [weak self] in
                self?.handleAddPlaceButton()
            }
        }
        
        view.backgroundColor = .systemBackground
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        setupViews()
        layoutViews()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        manager.delegate = nil
        let location = locations[0].coordinate
        latitude = location.latitude
        longitude = location.longitude
        loadDataUsingCoordinates(lat: latitude.description, lon: longitude.description)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .denied:
                showAccessDeniedAlert()
            default:
                break
            }
        }
    
    private func loadData(city: String) {
        networkManager.fetchCurrentWeather(city: city) { (weather) in
            print("Current Temperature", weather.main.temp.kelvinToCeliusConverter())
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            let stringDate = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.dt)))
            let weatherOutput = self.outputStringBasedOnTemperature(temperature: weather.main.temp.kelvinToCeliusConverter())
            let weatherConditions = self.outputStringBasedOnIDWeatherConditions(id: weather.weather[0].id)
            
            DispatchQueue.main.async {
                self.currentTemperatureLabel.text = (String(weather.main.temp.kelvinToCeliusConverter()) + "°C")
                self.currentLocation.text = "\(weather.name ?? "") , \(weather.sys.country ?? "")"
                self.tempDescription.text = weather.weather[0].description
                self.currentTime.text = stringDate
                self.tempAdvice.text = "Advice: \(weatherOutput)"
                self.condAdvice.text = weatherConditions
                self.tempSymbol.loadImageFromURL(url: "http://openweathermap.org/img/wn/\(weather.weather[0].icon)@2x.png")
                UserDefaults.standard.set("\(weather.name ?? "")", forKey: "SelectedCity")
            }
        }
    }
    
    private func loadDataUsingCoordinates(lat: String, lon: String) {
        networkManager.fetchCurrentLocationWeather(lat: lat, lon: lon) { (weather) in
            print("Current Temperature", weather.main.temp.kelvinToCeliusConverter())
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy"
            let stringDate = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.dt)))
            let weatherOutput = self.outputStringBasedOnTemperature(temperature: weather.main.temp.kelvinToCeliusConverter())
            let weatherConditions = self.outputStringBasedOnIDWeatherConditions(id: weather.weather[0].id)
            
            DispatchQueue.main.async {
                self.currentTemperatureLabel.text = (String(weather.main.temp.kelvinToCeliusConverter()) + "°C")
                self.currentLocation.text = "\(weather.name ?? "") , \(weather.sys.country ?? "")"
                self.tempDescription.text = weather.weather[0].description
                self.currentTime.text = stringDate
                self.tempAdvice.text = "Advice: \(weatherOutput)"
                self.condAdvice.text = weatherConditions
                self.tempSymbol.loadImageFromURL(url: "http://openweathermap.org/img/wn/\(weather.weather[0].icon)@2x.png")
                UserDefaults.standard.set("\(weather.name ?? "")", forKey: "SelectedCity")
            }
        }
    }
    
    func setupViews() {
        view.addSubview(currentLocation)
        view.addSubview(currentTemperatureLabel)
        view.addSubview(tempSymbol)
        view.addSubview(tempDescription)
        view.addSubview(currentTime)
        view.addSubview(tempAdvice)
        view.addSubview(condAdvice)
    }
    
    func layoutViews() {
        
        currentLocation.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        currentLocation.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18).isActive = true
        currentLocation.heightAnchor.constraint(equalToConstant: 70).isActive = true
        currentLocation.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18).isActive = true
        
        currentTime.topAnchor.constraint(equalTo: currentLocation.bottomAnchor, constant: 4).isActive = true
        currentTime.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18).isActive = true
        currentTime.heightAnchor.constraint(equalToConstant: 10).isActive = true
        currentTime.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18).isActive = true
        
        currentTemperatureLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        currentTemperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        tempSymbol.topAnchor.constraint(equalTo: currentTemperatureLabel.bottomAnchor).isActive = true
        tempSymbol.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tempSymbol.heightAnchor.constraint(equalToConstant: 90).isActive = true
        tempSymbol.widthAnchor.constraint(equalToConstant: 90).isActive = true
        
        tempDescription.topAnchor.constraint(equalTo: tempSymbol.bottomAnchor).isActive = true
        tempDescription.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tempDescription.heightAnchor.constraint(equalToConstant: 20).isActive = true
        tempDescription.widthAnchor.constraint(equalToConstant: 250).isActive = true
        
        tempAdvice.topAnchor.constraint(equalTo: tempDescription.bottomAnchor, constant: 50).isActive = true
        tempAdvice.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        
        condAdvice.topAnchor.constraint(equalTo: tempAdvice.bottomAnchor, constant: 10).isActive = true
        condAdvice.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    }
    
    private func handleAddPlaceButton() {
        let alertController = UIAlertController(title: "Add City", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "City Name"
        }
        let saveAction = UIAlertAction(title: "Add", style: .default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            print("City Name: \(String(describing: firstTextField.text))")
            guard let cityname = firstTextField.text else { return }
            self.loadData(city: cityname)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action : UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showAccessDeniedAlert() {
        let alert = UIAlertController(title: "Location Access Denied",
                                      message: "Please enable location access in Settings. When you press the Cancel button, the weather will be displayed automatically for Moscow",
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            self.loadData(city: "Moscow")
        }
        let reloadAction = UIAlertAction(title: "Reload", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(reloadAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func outputStringBasedOnTemperature(temperature: Float) -> String {
        switch temperature {
        case ..<0:
            return "Dress warmly"
        case 0..<15:
            return "Not bad, but still dress warmly"
        case 15...:
            return "Dress what you want"
        default:
            fatalError()
        }
    }
    
    private func outputStringBasedOnIDWeatherConditions(id: Int) -> String {
        
        switch id {
        case 200...232:
            return "Thunderstrorm 🌩️"
        case 300...321:
            return "Drizzle 🌧️"
        case 500...531:
            return "Rain, take an umbrella ☔️"
        case 600...622:
            return "Snow ❄️"
        case 701...781:
            return "Look out the window and decide for yourself 🙂"
        case 800:
            return "Clear sky 🤩"
        case 801...804:
            return "Clouds ☁️"
        default:
            fatalError()
        }
    }
}

