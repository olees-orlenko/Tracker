import UIKit

final class EmojiColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "EmojiColorCollectionViewCell"
    
    // MARK: - UI Elements
    
    let label = UILabel()
    let colorView = UIView()
    
    // MARK: - Properties
    
    private var representedEmoji: String?
    private var representedColor: UIColor?
    var emojiSelectionBackgroundColor: UIColor? = nil
    
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
    }
    
    private func setupColorViewLabel() {
        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
        colorView.backgroundColor = nil
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
    
    func configure(emoji: String?, color: UIColor?) {
        representedEmoji = emoji
        representedColor = color
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = nil
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 8
        label.isHidden = true
        colorView.isHidden = true
        label.text = nil
        colorView.backgroundColor = .clear
        if let emoji = emoji {
            label.isHidden = false
            label.text = emoji
        } else if let color = color {
            colorView.isHidden = false
            colorView.backgroundColor = color
        }
        applySelection()
    }
    
    private func applySelection() {
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = nil
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 8
        if let _ = representedEmoji {
            if isSelected {
                contentView.backgroundColor = emojiSelectionBackgroundColor ?? UIColor(named: "backgroundColor") ?? UIColor.systemGray5
                contentView.layer.cornerRadius = 16
            }
        } else if let color = representedColor {
            if isSelected {
                contentView.layer.borderWidth = 3
                contentView.layer.borderColor = (color.withAlphaComponent(0.3)).cgColor
                contentView.layer.cornerRadius = 8
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            applySelection()
        }
    }
}
