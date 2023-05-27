import UIKit

class TabBarController: UITabBarController {
    
    internal var centralButtonHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupViews()
        setupCentralButton()
    }
    
    private func setupTabBar() {
        tabBar.tintColor = .systemTeal
        tabBar.unselectedItemTintColor = .gray
    }
    
    private func setupViews() {
        let mainViewController = ViewController()
        let forecastViewController = ForecastViewController()
        
        setViewControllers([mainViewController, forecastViewController], animated: true)
        
        guard let items = tabBar.items else { return }
        
        items[0].title = "Home"
        items[1].title = "Forecast"
        
        items[0].image = UIImage(systemName: "house")
        items[1].image = UIImage(systemName: "calendar")
    }
    
    private func setupCentralButton() {
        let centralButton = UIButton(type: .system)
        centralButton.frame = CGRect(x: tabBar.center.x - 30, y: tabBar.frame.origin.y - 60, width: 60, height: 60)
        centralButton.backgroundColor = .systemTeal
        centralButton.layer.cornerRadius = 30
        centralButton.layer.shadowColor = UIColor.black.cgColor
        centralButton.layer.shadowOpacity = 0.1
        centralButton.layer.shadowOffset = CGSize(width: 4, height: 4)
        centralButton.setImage(UIImage(systemName: "plus"), for: .normal)
        centralButton.tintColor = .white
        centralButton.addTarget(self, action: #selector(centralButtonTapped), for: .touchUpInside)
        self.view.addSubview(centralButton)
    }
    
    @objc private func centralButtonTapped(_ sender: UIButton) {
        centralButtonHandler?()
        print("Central button tapped")
    }
}
