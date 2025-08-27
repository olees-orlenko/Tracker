import UIKit

class CategoryScheduleTableViewCell: UITableViewCell {
    weak var delegate: CategoryScheduleCellDelegate?
    static let reuseIdentifier = "CategoryScheduleTableViewCell"
    
    // MARK: - Properties
    
    let titleLabel = UILabel()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTitleLabel()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI Elements
    
    private func setupTitleLabel() {
        titleLabel.textColor = UIColor(resource: .black)
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.contentMode = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 18),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28)
        ])
    }
    
    func configure(with title: String) {
            titleLabel.text = title
        }
}
