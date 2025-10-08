import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    weak var delegate: TrackerCellDelegate?
    static let reuseIdentifier = "TrackerCollectionViewCell"
    
    // MARK: - UI Elements
    
    private let cardView = UIView()
    private let counterLabel = UILabel()
    private let addButton = UIButton()
    private let textLabel = UILabel()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    
    // MARK: - Private Properties
    
    private var trackerID: UUID?
    private var trackerName: String?
    private var indexPath: IndexPath?
    private var categoryTitle: String?
    private var completedDays: Int = 0
    private var currentDate: Date = Date()
    private var isFutureDate: Bool = false
    private var color: UIColor?
    private let colors = Colors()
    private var isCompleted: Bool = false
    private var trackerEmoji: String?
    private var trackerSchedule: [Week]?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCardView()
        setupInteraction()
        setupCounterLabel()
        setupEmojiLabel()
        setupTextLabel()
        setuptTitleLabel()
        setupAddButton()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI Elements
    
    private func setupCardView() {
        cardView.backgroundColor = UIColor(resource: .green)
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
    }
    
    private func setupInteraction() {
        let interaction = UIContextMenuInteraction(delegate: self)
        cardView.addInteraction(interaction)
    }
    
    private func setupTextLabel() {
        textLabel.text = "Поливать растения"
        textLabel.numberOfLines = 0
        titleLabel.contentMode = .bottom
        textLabel.textColor = UIColor(resource: .white)
        textLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(textLabel)
    }
    
    private func setupEmojiLabel() {
        emojiLabel.text = "😪"
        emojiLabel.textColor = UIColor(resource: .dark)
        emojiLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.layer.masksToBounds = true
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(emojiLabel)
    }
    
    private func setupCounterLabel() {
        counterLabel.text = "0 дней"
        counterLabel.textColor = colors.trackerTintColor()
        counterLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        counterLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(counterLabel)
    }
    
    private func setuptTitleLabel() {
        titleLabel.text = "Домашний уют"
        titleLabel.textColor = colors.trackerTintColor()
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        titleLabel.contentMode = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
    }
    
    private func setupAddButton() {
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        let checkmarkImage = UIImage(systemName: "checkmark")
        addButton.setImage(checkmarkImage, for: .selected)
        addButton.tintColor = colors.createButtonEnabledTextColor()
        addButton.backgroundColor = UIColor(resource: .green)
        addButton.layer.cornerRadius = 16
        addButton.clipsToBounds = true
        addButton.contentMode = .scaleAspectFit
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        contentView.addSubview(addButton)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 18),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            cardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            addButton.heightAnchor.constraint(equalToConstant: 34),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            counterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            counterLabel.heightAnchor.constraint(equalToConstant: 18),
            counterLabel.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            counterLabel.trailingAnchor.constraint(lessThanOrEqualTo: addButton.leadingAnchor, constant: -8),
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            textLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            textLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
        ])
    }
    
    // MARK: - Actions
    
    @objc func addButtonTapped() {
        guard let trackerID = trackerID, let indexPath = indexPath, let color = self.color else {
            return
        }
        if isFutureDate {
            return
        }
        let newIsCompleted = !addButton.isSelected
        if newIsCompleted {
            completedDays += 1
            delegate?.didTapCompleteButton(trackerId: trackerID, at: indexPath)
        } else {
            completedDays -= 1
            delegate?.didTapUnCompleteButton(trackerId: trackerID, at: indexPath)
        }
        updateCounterLabelText(completedDays: completedDays)
        updateAddButtonView(isCompleted: newIsCompleted, color: color)
        addButton.isSelected = newIsCompleted
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        indexPath = nil
        trackerID = nil
        isCompleted = false
    }
    
    // MARK: - Configuration
    
    func configure(isCompleted: Bool, trackerID: UUID, trackerName: String, indexPath: IndexPath, categoryTitle: String, completedDays: Int, currentDate: Date, color: UIColor, emoji: String) {
        self.trackerID = trackerID
        self.textLabel.text = trackerName
        self.indexPath = indexPath
        self.isCompleted = isCompleted
        self.categoryTitle = categoryTitle
        self.completedDays = completedDays
        self.currentDate = currentDate
        self.emojiLabel.text = emoji
        self.cardView.backgroundColor = color
        self.addButton.backgroundColor = color
        self.color = color
        isFutureDate = currentDate > Date()
        updateCounterLabelText(completedDays: completedDays)
        updateAddButtonView(isCompleted: isCompleted, color: color)
        addButton.isSelected = isCompleted
        titleLabel.isHidden = indexPath.row != 0
        titleLabel.text = categoryTitle
        if isFutureDate {
            addButton.isEnabled = false
            addButton.backgroundColor = .gray
        } else {
            addButton.isEnabled = true
        }
    }
    
    // MARK: - Update UI
    
    private func updateAddButtonView(isCompleted: Bool, color: UIColor) {
        addButton.isSelected = isCompleted
        let image = isCompleted ? UIImage(named: "Plus") : UIImage(systemName: "plus")
        addButton.setImage(image, for: .normal)
        addButton.tintColor = colors.createButtonEnabledTextColor()
        if isFutureDate {
            addButton.backgroundColor = UIColor.gray
        } else {
            addButton.backgroundColor = isCompleted ? color.withAlphaComponent(0.3) : color
        }
    }
    
    private func setCategoryTitle(_ title: String) {
        if self.categoryTitle == nil {
            self.categoryTitle = title
            titleLabel.text = title
        }
    }
    
    private func updateCounterLabelText(completedDays: Int) {
        let days = completedDays % 100
        let localizedString: String
        if (11...14).contains(days) {
            localizedString = NSLocalizedString("days_plural", comment: "")
        } else {
            switch days % 10 {
            case 1:
                localizedString = NSLocalizedString("day_singular", comment: "")
            case 2...4:
                localizedString = NSLocalizedString("days_few", comment: "")
            default:
                localizedString = NSLocalizedString("days_plural", comment: "")
            }
        }
        counterLabel.text = "\(completedDays) \(localizedString)"
    }
}

extension TrackerCollectionViewCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        print("contextMenuInteraction called for cell: indexPath=\(String(describing: indexPath)), trackerID=\(String(describing: trackerID)), isCompleted=\(String(describing: isCompleted))")
        guard let indexPath = indexPath,
              let trackerID = trackerID else {
            return nil
        }
        let completed = self.isCompleted ?? false
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            guard let self = self else { return nil }
            let edit = UIAction(title: NSLocalizedString("editTracker_title", comment: "")) { _ in
                guard let trackerID = self.trackerID,
                      let indexPath = self.indexPath else {
                    return
                }
                self.delegate?.didTapEditButton(trackerId: trackerID, at: indexPath)
            }
            let delete = UIAction(title: NSLocalizedString("deleteTracker_title", comment: ""),
                                  image: nil,
                                  attributes: .destructive) { _ in
                let tracker = Tracker(id: trackerID, name: "", color: .clear, emoji: "", schedule: [])
                self.delegate?.didTapDeleteButton(tracker: tracker)
            }
            return UIMenu(title: "", children: [edit, delete])
        }
    }
}
