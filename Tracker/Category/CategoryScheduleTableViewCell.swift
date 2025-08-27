import UIKit

class CategoryScheduleTableViewCell: UITableViewCell {
    weak var delegate: CategoryCellDelegate?
    static let reuseIdentifier = "CategoryScheduleTableViewCell"
    
    // MARK: - UI Elements
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    //    private let selectedDaysLabel = UILabel()
    //    let selectedCategoryLabel = UILabel()
    
    // MARK: - Initializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTitleLabel()
        setupSubtitleLabel()
        setupConstraints()
        //        setupSelectedDaysLabel()
        //        setupSelectedCategoryLabel()
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
    //    private func setupSelectedDaysLabel() {
    //        selectedDaysLabel.textColor = UIColor(resource: .gray)
    //        selectedDaysLabel.font = .systemFont(ofSize: 17, weight: .regular)
    //        selectedDaysLabel.translatesAutoresizingMaskIntoConstraints = false
    //        contentView.addSubview(selectedDaysLabel)
    //    }
    //
    //    private func setupSelectedCategoryLabel(){
    //        selectedCategoryLabel.textColor = UIColor(resource: .gray)
    //        selectedCategoryLabel.font = .systemFont(ofSize: 17, weight: .regular)
    //        selectedCategoryLabel.translatesAutoresizingMaskIntoConstraints = false
    //        contentView.addSubview(selectedCategoryLabel)
    //    }
    
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
            //            selectedDaysLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            //            selectedDaysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            //            selectedDaysLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            //            selectedDaysLabel.heightAnchor.constraint(equalToConstant: 22),
            //            selectedCategoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            //            selectedCategoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            //            selectedCategoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            //            selectedCategoryLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(title: String, subtitle: String?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
//        subtitleLabel.isHidden = subtitle == nil
        subtitleLabel.isHidden = (subtitle == nil || subtitle?.isEmpty == true)
    }
    //    func configure(title: String, selectedDaysText: String?) {
    //            titleLabel.text = title
    //            selectedDaysLabel.text = selectedDaysText
    //            selectedDaysLabel.isHidden = selectedDaysText == nil
    //        }
    //
    //    func configureCategory(title: String, selectedCategoryText: String?) {
    //        titleLabel.text = title
    //        selectedCategoryLabel.text = selectedCategoryText
    //        selectedCategoryLabel.isHidden = selectedCategoryText == nil
    //    }
}
