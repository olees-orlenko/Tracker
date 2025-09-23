import UIKit

final class CategoryTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CategoryTableViewCell"
    
    private var bottomSeparatorHeightConstraint: NSLayoutConstraint!
    private var pixelHeight: CGFloat { 1.5 / UIScreen.main.scale }
    
    // MARK: - UI Elements
    
    private let bottomSeparator: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .separator
        v.isOpaque = true
        return v
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(bottomSeparator)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bottomSeparator.isHidden = false
        bottomSeparator.backgroundColor = .separator
        bottomSeparatorHeightConstraint.constant = pixelHeight
    }
    
    // MARK: - Public Methods
    
    func setSeparatorHidden(_ hidden: Bool) {
        bottomSeparator.isHidden = hidden
    }
    
    func setSeparatorAppearance(color: UIColor = .separator, height: CGFloat? = nil) {
        bottomSeparator.backgroundColor = color
        bottomSeparatorHeightConstraint.constant = height ?? pixelHeight
        setNeedsLayout()
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        bottomSeparatorHeightConstraint = bottomSeparator.heightAnchor.constraint(equalToConstant: pixelHeight)
        NSLayoutConstraint.activate([
            bottomSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bottomSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bottomSeparator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomSeparatorHeightConstraint
        ])
    }
}
