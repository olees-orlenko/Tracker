import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ScheduleTableViewCell"
    
    // MARK: - UI Elements
    
    let daySwitch = UISwitch()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupDaySwitch()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI Elements
    
    private func setupDaySwitch(){
        daySwitch.onTintColor = UIColor(resource: .blue)
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(daySwitch)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daySwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
            daySwitch.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -22)
        ])
    }
}
