import UIKit

final class OnboardingTrackerViewController: UIViewController {
    
    // MARK: - UI Elements
    
    private let imageView = UIImageView()
    private let label = UILabel()
    
    // MARK: - Private Properties
    
    private let imageName: String
    private let labelText: String
    
    // MARK: - Initializers
    
    init(imageName: String, labelText: String) {
        self.imageName = imageName
        self.labelText = labelText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        setupLabel()
        setupConstraints()
    }
    
    // MARK: - Setup UI Elements

    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: imageName)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
    }
    
    private func setupLabel() {
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor(resource: .black)
        label.text = labelText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -304),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 432),
        ])
    }
}
