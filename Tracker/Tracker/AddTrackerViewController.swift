import UIKit

enum TrackerMode {
    case create
    case edit(Tracker, String?)
}

final class AddTrackerViewController: UIViewController, UITextFieldDelegate, ScheduleViewControllerDelegate {
    
    weak var delegate: AddTrackerViewControllerDelegate?
    private let trackerRecordStore = TrackerRecordStore()
    private let cellIdentifier = "cell"
    private let color = Colors()
    
    // MARK: - UI Elements
    
    private let nameTrackerTextField = UITextField()
    private let tableView = UITableView()
    private let cancelButton = UIButton()
    private let createButton = UIButton()
    private let textErrorLabel = UILabel()
    private var daysLabel = UILabel()
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var emojisCollectionView: UICollectionView!
    private var colorsCollectionView: UICollectionView!
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    // MARK: - Properties
    
    let sections = [
        NSLocalizedString("category_section", comment: "Title for the Category section"),
        NSLocalizedString("schedule_section", comment: "Title for the Schedule section")
    ]
    var trackerId: UUID!
    var currentDate: Date?
    private var selectedDays: [Week] = []
    private var selectedCategoryTitle: String?
    var selectedEmoji: String?
    var selectedColor: UIColor?
    var onSave: ((Tracker, String?) -> Void)?
    var mode: TrackerMode = .create {
        didSet {
            if isViewLoaded {
                configureForMode()
                setupTitle()
            }
        }
    }
    
    let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    let colors: [UIColor] = [
        .colorSelection1, .colorSelection2, .colorSelection3,
        .colorSelection4, .colorSelection5, .colorSelection6,
        .colorSelection7, .colorSelection8, .colorSelection9,
        .colorSelection10, .colorSelection11, .colorSelection12,
        .colorSelection13, .colorSelection14, .colorSelection15,
        .colorSelection16, .colorSelection17, .colorSelection18
    ]
    
    private var selectedEmojiIndex: Int?
    private var selectedColorIndex: Int?
    private var isTrackerSaved = false
    private var nameTrackerTextFieldTopConstraintToContent: NSLayoutConstraint!
    private var daysLabelTopConstraintToContent: NSLayoutConstraint!
    private var nameTrackerTextFieldTopConstraintToDaysLabel: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        setupTextErrorLabel()
        setupDaysLabel()
        setupNameTrackerTextField()
        setupTableView()
        setupCancelButton()
        setupCreateButton()
        setupEmojisCollectionView()
        setupColorsCollectionView()
        setupConstraints()
        tableView.dataSource = self
        tableView.delegate = self
        nameTrackerTextField.delegate = self
        configureForMode()
        setupTitle()
        print("mode in viewDidLoad = \(mode)")
    }
    
    // MARK: - Setup UI Elements
    
    private func setupView() {
        view.backgroundColor = color.viewBackgroundColor
    }
    
    private func setupTextErrorLabel(){
        textErrorLabel.textColor = UIColor(resource: .red)
        textErrorLabel.font = .systemFont(ofSize: 17, weight: .regular)
        textErrorLabel.text = NSLocalizedString("characters_limit_error", comment: "Error message for exceeding character limit")
        textErrorLabel.isHidden = true
        textErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textErrorLabel)
    }
    
    private func setupDaysLabel() {
        daysLabel.font = .systemFont(ofSize: 32, weight: .bold)
        daysLabel.textColor = color.trackerTintColor()
        daysLabel.text = "5 дней"
        daysLabel.textAlignment = .center
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(daysLabel)
    }
    
    private func setupTitle() {
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: color.navigationBarTintColor
        ]
        switch mode {
        case .create:
            navigationItem.title = NSLocalizedString("new_habit_title", comment: "Title for the New Habit view")
        case .edit(_, _):
            navigationItem.title = NSLocalizedString("edit_habit_title", comment: "")
        }
    }
    
    private func setupNameTrackerTextField() {
        nameTrackerTextField.placeholder = NSLocalizedString("enter_tracker_name", comment: "Placeholder text for tracker name text field")
        nameTrackerTextField.backgroundColor = UIColor(resource: .background).withAlphaComponent(0.3)
        nameTrackerTextField.layer.cornerRadius = 16
        nameTrackerTextField.layer.masksToBounds = true
        nameTrackerTextField.clearButtonMode = .whileEditing
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: nameTrackerTextField.frame.height))
        nameTrackerTextField.leftView = paddingView
        nameTrackerTextField.leftViewMode = .always
        nameTrackerTextField.returnKeyType = .done
        nameTrackerTextField.enablesReturnKeyAutomatically = true
        nameTrackerTextField.smartInsertDeleteType = .no
        nameTrackerTextField.textColor = color.trackerTintColor()
        nameTrackerTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameTrackerTextField)
    }
    
    private func setupTableView() {
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryScheduleTableViewCell.self, forCellReuseIdentifier: CategoryScheduleTableViewCell.reuseIdentifier)
        contentView.addSubview(tableView)
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle(NSLocalizedString("cancel_button_title", comment: "Title for the Cancel button"), for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.layer.borderColor = (UIColor(resource: .red)).cgColor
        cancelButton.layer.borderWidth = 1.0
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.masksToBounds = true
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cancelButton)
    }
    
    private func setupCreateButton() {
        createButton.setTitle(NSLocalizedString("create_button_title", comment: "Title for the Create button"), for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = UIColor(resource: .gray)
        createButton.backgroundColor = color.createButtonDisabledBackgroundColor()
        createButton.layer.cornerRadius = 16
        createButton.layer.masksToBounds = true
        createButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(createButton)
    }
    
    private func setupEmojisCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 18)
        emojisCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        emojisCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emojisCollectionView.delegate = self
        emojisCollectionView.dataSource = self
        emojisCollectionView.register(EmojiColorCollectionViewCell.self, forCellWithReuseIdentifier: "EmojiColorCollectionViewCell")
        emojisCollectionView.register(EmojiColorHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiColorHeaderView.reuseIdentifier)
        contentView.addSubview(emojisCollectionView)
    }
    
    private func setupColorsCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 18)
        colorsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        colorsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorsCollectionView.delegate = self
        colorsCollectionView.dataSource = self
        colorsCollectionView.register(EmojiColorCollectionViewCell.self, forCellWithReuseIdentifier: "EmojiColorCollectionViewCell")
        colorsCollectionView.register(EmojiColorHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiColorHeaderView.reuseIdentifier)
        contentView.addSubview(colorsCollectionView)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            nameTrackerTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
            
            textErrorLabel.heightAnchor.constraint(equalToConstant: 22),
            textErrorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textErrorLabel.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 8),
            
            tableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojisCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojisCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojisCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojisCollectionView.heightAnchor.constraint(equalToConstant: 222),
            
            colorsCollectionView.topAnchor.constraint(equalTo: emojisCollectionView.bottomAnchor, constant: 16),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 222),
            
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            
            contentView.bottomAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 16),
            
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            daysLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daysLabel.heightAnchor.constraint(equalToConstant: 38)
        ])
        nameTrackerTextFieldTopConstraintToContent = nameTrackerTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24)
        daysLabelTopConstraintToContent = daysLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24)
        nameTrackerTextFieldTopConstraintToDaysLabel = nameTrackerTextField.topAnchor.constraint(equalTo: daysLabel.bottomAnchor, constant: 40)
        nameTrackerTextFieldTopConstraintToContent.isActive = true
        daysLabelTopConstraintToContent.isActive = false
        nameTrackerTextFieldTopConstraintToDaysLabel.isActive = false
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard !isTrackerSaved else { return }
        guard let name = nameTrackerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            textErrorLabel.isHidden = false
            return
        }
        isTrackerSaved = true
        textErrorLabel.isHidden = true
        createButton.isEnabled = false
        let color = selectedColor ?? .colorSelection1
        let emoji = selectedEmoji ?? "🙂"
        let schedule = selectedDays
        switch mode {
        case .create:
            let newTracker = Tracker(
                id: UUID(),
                name: name,
                color: color,
                emoji: emoji,
                schedule: schedule
            )
            guard let selectedCategory = selectedCategoryTitle else {
                isTrackerSaved = false
                createButton.isEnabled = true
                textErrorLabel.isHidden = false
                return
            }
            print("addNewTracker called with tracker: \(name) and title: \(selectedCategory)")
            delegate?.addNewTracker(tracker: newTracker, title: selectedCategory)
            dismiss(animated: true, completion: nil)
        case .edit(let existing, let existingCategory):
            let updated = Tracker(id: existing.id, name: name, color: color, emoji: emoji, schedule: schedule)
            onSave?(updated, selectedCategoryTitle)
            if navigationController?.viewControllers.first == self {
                dismiss(animated: true)
            } else {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func configureForMode() {
        guard isViewLoaded else { return }
        nameTrackerTextFieldTopConstraintToContent.isActive = false
        daysLabelTopConstraintToContent.isActive = false
        nameTrackerTextFieldTopConstraintToDaysLabel.isActive = false
        switch mode {
        case .create:
            nameTrackerTextFieldTopConstraintToContent.isActive = true
            daysLabel.isHidden = true
        case .edit(let tracker, let categoryTitle):
            nameTrackerTextField.text = tracker.name
            selectedEmoji = tracker.emoji
            selectedColor = tracker.color
            selectedCategoryTitle = categoryTitle
            selectedDays = tracker.schedule
            didUpdateSchedule(selectedDays: selectedDays)
            emojisCollectionView.reloadData()
            if let index = emojis.firstIndex(of: tracker.emoji) {
                let indexPath = IndexPath(item: index, section: 0)
                DispatchQueue.main.async {
                    self.emojisCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                }
            }
            colorsCollectionView.reloadData()
            if let selectedColor,
               let colorIndex = colors.firstIndex(where: { uiColorEqual($0, selectedColor) }) {
                DispatchQueue.main.async {
                    let indexPath = IndexPath(item: colorIndex, section: 0)
                    self.colorsCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                }
            }
            let completed = (try? trackerRecordStore.fetchCompletedDates(forTrackerId: tracker.id).count) ?? 0
            updateCounterLabelText(completed)
            daysLabel.isHidden = false
            daysLabelTopConstraintToContent.isActive = true
            nameTrackerTextFieldTopConstraintToDaysLabel.isActive = true
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateCounterLabelText(_ completedDays: Int) {
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
        daysLabel.text = "\(completedDays) \(localizedString)"
    }
    
    private func uiColorEqual(_ a: UIColor, _ b: UIColor, tolerance: CGFloat = 0.001) -> Bool {
        var ra: CGFloat = 0, ga: CGFloat = 0, ba: CGFloat = 0, aa: CGFloat = 0
        var rb: CGFloat = 0, gb: CGFloat = 0, bb: CGFloat = 0, ab: CGFloat = 0
        guard a.getRed(&ra, green: &ga, blue: &ba, alpha: &aa),
              b.getRed(&rb, green: &gb, blue: &bb, alpha: &ab) else {
            return a == b
        }
        return abs(ra - rb) <= tolerance &&
        abs(ga - gb) <= tolerance &&
        abs(ba - bb) <= tolerance &&
        abs(aa - ab) <= tolerance
    }
    
    func didUpdateSchedule(selectedDays: [Week]) {
        self.selectedDays = selectedDays
        updateCreateButton()
        tableView.reloadData()
    }
    
    private func updateCreateButton() {
        let isNameValid = nameTrackerTextField.text?.isEmpty == false
        let isCategorySelected = selectedCategoryTitle != nil
        let isScheduleSelected = selectedDays.count > 0
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let allFields = isNameValid && isCategorySelected && isScheduleSelected && isEmojiSelected && isColorSelected
        if allFields {
            createButton.backgroundColor = color.createButtonEnabledBackgroundColor()
            createButton.isEnabled = true
            createButton.setTitleColor(color.createButtonEnabledTextColor(), for: .normal)
        } else {
            createButton.backgroundColor = color.createButtonDisabledBackgroundColor()
            createButton.isEnabled = false
            createButton.setTitleColor(color.createButtonDisabledTextColor(), for: .normal)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if newText.count > 38 {
            textErrorLabel.isHidden = false
            return false
        } else {
            textErrorLabel.isHidden = true
            updateCreateButton()
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTrackerTextField {
            textField.resignFirstResponder()
        }
        updateCreateButton()
        return true
    }
}

// MARK: - UITableViewDataSource

extension AddTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryScheduleTableViewCell.reuseIdentifier, for: indexPath) as? CategoryScheduleTableViewCell else {
            return UITableViewCell()
        }
        let title = sections[indexPath.row]
        var subtitle: String? = nil
        if indexPath.row == 0 {
            subtitle = selectedCategoryTitle
        } else if indexPath.row == 1 {
            if selectedDays.count == 7 {
                subtitle = NSLocalizedString("every_day", comment: "Subtitle for schedule when every day is selected")
            } else if !selectedDays.isEmpty {
                let dayAbbreviations = selectedDays.map { day in
                    switch day {
                    case .monday: return NSLocalizedString("monday_abbr", comment: "Abbreviation for Monday")
                    case .tuesday: return NSLocalizedString("tuesday_abbr", comment: "Abbreviation for Tuesday")
                    case .wednesday: return NSLocalizedString("wednesday_abbr", comment: "Abbreviation for Wednesday")
                    case .thursday: return NSLocalizedString("thursday_abbr", comment: "Abbreviation for Thursday")
                    case .friday: return NSLocalizedString("friday_abbr", comment: "Abbreviation for Friday")
                    case .saturday: return NSLocalizedString("saturday_abbr", comment: "Abbreviation for Saturday")
                    case .sunday: return NSLocalizedString("sunday_abbr", comment: "Abbreviation for Sunday")
                    }
                }
                subtitle = dayAbbreviations.joined(separator: ", ")
            }
        }
        cell.configure(title: title, subtitle: subtitle)
        cell.accessoryType = .disclosureIndicator
        cell.contentView.backgroundColor = UIColor(resource: .background).withAlphaComponent(0.3)
        let backgroundColor = UIColor(resource: .background).withAlphaComponent(0.3)
        cell.backgroundColor = backgroundColor
        cell.contentView.backgroundColor = .clear
        cell.titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        cell.titleLabel.textColor = color.trackerTintColor()
        tableView.separatorColor = .gray
        if indexPath.row == 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UITableViewDelegate

extension AddTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let categoryViewModel = CategoryViewModel(trackerCategoryStore: TrackerCategoryStore())
            let categoryViewController = CategoryViewController(viewModel: categoryViewModel)
            categoryViewController.delegate = self
            print ("Установили делегата")
            navigationController?.pushViewController(categoryViewController, animated: true)
        } else if indexPath.row == 1 {
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            scheduleViewController.selectedDays = selectedDays
            let navigationController = UINavigationController(rootViewController: scheduleViewController)
            present(navigationController, animated: true, completion: nil)
        }
    }
}

extension AddTrackerViewController: CategoryViewControllerDelegate {
    func didSelectCategory(categoryTitle: String) {
        selectedCategoryTitle = categoryTitle
        print("Selected category: \(selectedCategoryTitle ?? "None")")
        tableView.reloadData()
    }
}

extension AddTrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojisCollectionView {
            let previous = selectedEmojiIndex
            if let previous {
                let previousIndexPath = IndexPath(row: previous, section: 0)
                collectionView.deselectItem(at: previousIndexPath, animated: false)
            }
            selectedEmojiIndex = indexPath.row
            selectedEmoji = emojis[indexPath.row]
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            var paths = [indexPath]
            if let previous, previous != indexPath.row {
                paths.append(IndexPath(row: previous, section: 0))
            }
            collectionView.reloadItems(at: paths)
        } else {
            let previous = selectedColorIndex
            if let previous {
                let previousIndexPath = IndexPath(row: previous, section: 0)
                collectionView.deselectItem(at: previousIndexPath, animated: false)
            }
            selectedColorIndex = indexPath.row
            selectedColor = colors[indexPath.row]
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            var paths = [indexPath]
            if let previous, previous != indexPath.row {
                paths.append(IndexPath(row: previous, section: 0))
            }
            collectionView.reloadItems(at: paths)
        }
        updateCreateButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojisCollectionView {
            collectionView.reloadData()
        } else {
            colorsCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 19)
    }
    
}

extension AddTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojisCollectionView {
            return emojis.count
        } else if collectionView == colorsCollectionView {
            return colors.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiColorCollectionViewCell.reuseIdentifier,
            for: indexPath) as! EmojiColorCollectionViewCell
        if collectionView == emojisCollectionView {
            let emoji = emojis[indexPath.row]
            cell.configure(emoji: emoji, color: nil)
            cell.emojiSelectionBackgroundColor = UIColor(resource: .background)
            if indexPath.row == selectedEmojiIndex {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        } else {
            let color = colors[indexPath.row]
            cell.configure(emoji: nil, color: color)
            if indexPath.row == selectedColorIndex {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmojiColorHeaderView.reuseIdentifier, for: indexPath) as! EmojiColorHeaderView
            if collectionView == emojisCollectionView {
                headerView.titleLabel.textColor = color.trackerTintColor()
                headerView.titleLabel.text = "Emoji"
            } else if collectionView == colorsCollectionView {
                headerView.titleLabel.textColor = color.trackerTintColor()
                headerView.titleLabel.text = NSLocalizedString("color_header", comment: "Header text for the Colors section")            }
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }
}
