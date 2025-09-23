import UIKit

final class AddTrackerViewController: UIViewController, UITextFieldDelegate, ScheduleViewControllerDelegate {
    
    weak var delegate: AddTrackerViewControllerDelegate?
    private let cellIdentifier = "cell"
    
    // MARK: - UI Elements
    
    private let nameTrackerTextField = UITextField()
    private let tableView = UITableView()
    private let cancelButton = UIButton()
    private let createButton = UIButton()
    private let textErrorLabel = UILabel()
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
    
    let sections = ["Категория", "Расписание"]
    var trackerId: UUID!
    var currentDate: Date?
    private var selectedDays: [Week] = []
    private var selectedCategoryTitle: String?
    var selectedEmoji: String?
    var selectedColor: UIColor?
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        setupTextErrorLabel()
        setupTitle()
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
    }
    
    // MARK: - Setup UI Elements
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupTextErrorLabel(){
        textErrorLabel.textColor = UIColor(resource: .red)
        textErrorLabel.font = .systemFont(ofSize: 17, weight: .regular)
        textErrorLabel.text = "Ограничение 38 символов"
        textErrorLabel.isHidden = true
        textErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textErrorLabel)
    }
    
    private func setupTitle(){
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 16, weight: .medium)]
        navigationItem.title = "Новая привычка"
    }
    
    private func setupNameTrackerTextField() {
        nameTrackerTextField.placeholder = "Введите название трекера"
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
        nameTrackerTextField.textColor = UIColor(resource: .black)
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
        cancelButton.setTitle("Отменить", for: .normal)
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
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.setTitleColor(.white, for: .normal)
        createButton.backgroundColor = UIColor(resource: .gray)
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
            
            nameTrackerTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
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
            
            contentView.bottomAnchor.constraint(equalTo: createButton.bottomAnchor, constant: 16)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard !isTrackerSaved else {
            return
        }
        isTrackerSaved = true
        guard let name = nameTrackerTextField.text, !name.isEmpty else {
            return
        }
        textErrorLabel.isHidden = true
        let newTracker = Tracker(
            id: UUID(),
            name: name,
            color: selectedColor ?? .colorSelection1,
            emoji: selectedEmoji ?? "🙂",
            schedule: selectedDays
        )
        guard let selectedCategory = selectedCategoryTitle else {
            return
        }
        print("addNewTracker called with tracker: \(name) and title: \(selectedCategoryTitle ?? "nil")")
        delegate?.addNewTracker(tracker: newTracker, title: selectedCategory)
        createButton.isEnabled = false
        dismiss(animated: true, completion: nil)
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
            createButton.backgroundColor = UIColor(resource: .black)
            createButton.isEnabled = true
        } else {
            createButton.backgroundColor = UIColor(resource: .gray)
            createButton.isEnabled = false
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
                subtitle = "Каждый день"
            } else if !selectedDays.isEmpty {
                let dayAbbreviations = selectedDays.map { day in
                    switch day {
                    case .monday: return "Пн"
                    case .tuesday: return "Вт"
                    case .wednesday: return "Ср"
                    case .thursday: return "Чт"
                    case .friday: return "Пт"
                    case .saturday: return "Сб"
                    case .sunday: return "Вс"
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
        cell.titleLabel.textColor = UIColor.black
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
            if let previousSelectedIndex = selectedEmojiIndex,
               let cell = collectionView.cellForItem(at: IndexPath(row: previousSelectedIndex, section: 0)) {
                cell.backgroundColor = .clear
            }
            let cell = collectionView.cellForItem(at: indexPath)
            cell?.layer.cornerRadius = 16
            cell?.layer.masksToBounds = true
            cell?.backgroundColor = UIColor(resource: .background)
            selectedEmojiIndex = indexPath.row
            selectedEmoji = emojis[indexPath.row]
            updateCreateButton()
        } else if collectionView == colorsCollectionView {
            if let previousSelectedIndex = selectedColorIndex,
               let cell = collectionView.cellForItem(at: IndexPath(row: previousSelectedIndex, section: 0)) {
                cell.layer.borderWidth = 0
            }
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.layer.borderColor = colors[indexPath.row].cgColor.copy(alpha: 0.3)
                cell.layer.borderWidth = 3
                cell.layer.cornerRadius = 8
                cell.layer.masksToBounds = true
            }
            selectedColorIndex = indexPath.row
            selectedColor = colors[indexPath.row]
            updateCreateButton()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiColorCollectionViewCell.reuseIdentifier, for: indexPath) as! EmojiColorCollectionViewCell
        if collectionView == emojisCollectionView {
            cell.label.text = emojis[indexPath.row]
            cell.colorView.isHidden = true
            cell.backgroundColor = .clear
        } else if collectionView == colorsCollectionView {
            cell.colorView.backgroundColor = colors[indexPath.row]
            cell.colorView.isHidden = false
            cell.label.isHidden = true
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmojiColorHeaderView.reuseIdentifier, for: indexPath) as! EmojiColorHeaderView
            if collectionView == emojisCollectionView {
                headerView.titleLabel.text = "Emoji"
            } else if collectionView == colorsCollectionView {
                headerView.titleLabel.text = "Цвет"
            }
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }
}
