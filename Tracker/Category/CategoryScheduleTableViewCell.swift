import UIKit

final class CategoryScheduleTableViewCell: UITableViewCell {
    weak var delegate: CategoryCellDelegate?
    static let reuseIdentifier = "CategoryScheduleTableViewCell"
    
    // MARK: - UI Elements
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTitleLabel()
        setupSubtitleLabel()
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
    
    private func setupSubtitleLabel(){
        subtitleLabel.textColor = UIColor(resource: .gray)
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 18),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(title: String, subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = (subtitle == nil || subtitle?.isEmpty == true)
    }
}
