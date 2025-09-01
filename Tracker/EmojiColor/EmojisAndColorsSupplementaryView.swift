import UIKit

final class EmojisAndColorsSupplementaryView: UICollectionReusableView {
    
    static let reuseIdentifier = "EmojisAndColorsSupplementaryView"
    
    // MARK: - UI Elements
    
    let titleLabel = UILabel()

    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI Elements
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        addSubview(titleLabel)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
