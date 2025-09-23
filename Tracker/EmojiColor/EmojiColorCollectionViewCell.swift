import UIKit

final class EmojiColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiColorCollectionViewCell"
    
    // MARK: - UI Elements
    
    let label = UILabel()
    let colorView = UIView()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupColorViewLabel()
        setupLabel()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI Elements
    
    private func setupLabel() {
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        contentView.addSubview(colorView)
    }
    
    private func setupColorViewLabel() {
        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
        colorView.backgroundColor = nil
        label.text = nil
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorView)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}
