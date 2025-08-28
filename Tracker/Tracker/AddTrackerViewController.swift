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
    
    // MARK: - Properties
    
    let sections = ["Категория", "Расписание"]
    var categories: [String] = ["Важное", "Неважное"]
    var trackerId: UUID!
    var currentDate: Date?
    private var selectedDays: [Week] = []
    var selectedCategory: String?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTextErrorLabel()
        setupTitle()
        setupNameTrackerTextField()
        setupTableView()
        setupCancelButton()
        setupCreateButton()
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
        view.addSubview(textErrorLabel)
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
        nameTrackerTextField.textColor = UIColor(resource: .gray)
        nameTrackerTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameTrackerTextField)
    }
    
    private func setupTableView() {
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryScheduleTableViewCell.self, forCellReuseIdentifier: CategoryScheduleTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
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
        view.addSubview(cancelButton)
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
        view.addSubview(createButton)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameTrackerTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
            textErrorLabel.heightAnchor.constraint(equalToConstant: 22),
            textErrorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textErrorLabel.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 8),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            tableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let name = nameTrackerTextField.text, !name.isEmpty else {
            return
        }
        textErrorLabel.isHidden = true
        let newTracker = Tracker(id: UUID(), name: name, color: .red, emoji: "🙂", schedule: selectedDays)
        guard let selectedCategory = selectedCategory else {
            return
        }
        delegate?.addNewTracker(tracker: newTracker, title: selectedCategory)
        dismiss(animated: true, completion: nil)
    }
    
    func didUpdateSchedule(selectedDays: [Week]) {
        self.selectedDays = selectedDays
        tableView.reloadData()
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
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTrackerTextField {
            textField.resignFirstResponder()
        }
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
            subtitle = selectedCategory
        } else if indexPath.row == 1 && !selectedDays.isEmpty {
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
        cell.configure(title: title, subtitle: subtitle)
        cell.accessoryType = .disclosureIndicator
        cell.contentView.backgroundColor = UIColor(resource: .background).withAlphaComponent(0.3)
        let backgroundColor = UIColor(resource: .background).withAlphaComponent(0.3)
        cell.backgroundColor = backgroundColor
        cell.contentView.backgroundColor = .clear
        cell.titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        cell.titleLabel.textColor = UIColor.black
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
            let categoryViewController = CategoryViewController()
            categoryViewController.categories = categories
            categoryViewController.delegate = self
            categoryViewController.selectedCategory = selectedCategory
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
    func didUpdateCategory(_ categoryTitle: String) {
        self.selectedCategory = categoryTitle
        tableView.reloadData()
    }
}
