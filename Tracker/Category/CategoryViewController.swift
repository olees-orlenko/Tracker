import UIKit

final class CategoryViewController: UIViewController{
    
    weak var delegate: CategoryViewControllerDelegate?
    
    // MARK: - UI Elements
    
    private var tableView = UITableView()
    private let doneButton = UIButton()
    
    // MARK: - Properties
    
    var categories: [String] = []
    var selectedCategory: String?
    private let trackerCategoryStore: TrackerCategoryStore
    
    // MARK: - Initializers
    
    init() {
        self.trackerCategoryStore = TrackerCategoryStore()
        super.init(nibName: nil, bundle: nil)
        self.trackerCategoryStore.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupDoneButton()
        setupConstraints()
        categories = trackerCategoryStore.getCategoryTitles()
        tableView.reloadData()
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        tableView.tableFooterView = UIView()
        view.backgroundColor = .white
        navigationItem.title = "Категория"
        let title: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        navigationController?.navigationBar.titleTextAttributes = title
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryScheduleTableViewCell.self, forCellReuseIdentifier: CategoryScheduleTableViewCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setupDoneButton() {
        doneButton.setTitle("Готово", for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = UIColor(resource: .black)
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
    }
    
    // MARK: - Setup Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        if let selectedCategory = selectedCategory {
            delegate?.didUpdateCategory(selectedCategory)
        }
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return trackerCategoryStore.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerCategoryStore.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryScheduleTableViewCell.reuseIdentifier, for: indexPath) as? CategoryScheduleTableViewCell else {
            return UITableViewCell()
        }
        let categoryTitle = trackerCategoryStore.categoryTitle(at: indexPath) ?? "Неизвестная категория"
        cell.titleLabel.text = categoryTitle
        cell.subtitleLabel.text = nil
        cell.subtitleLabel.isHidden = true
        cell.accessoryType = categoryTitle == selectedCategory ? .checkmark : .none
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedCategory = trackerCategoryStore.categoryTitle(at: indexPath)
        delegate?.didUpdateCategory(selectedCategory ?? "Важное")
        tableView.reloadData()
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoryViewController: TrackerCategoryStoreDelegate {
    func trackerCategoryStore(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: update.insertedIndexPath, with: .automatic)
            tableView.deleteRows(at: update.deletedIndexPath, with: .automatic)
        } completion: { _ in
            self.categories = store.getCategoryTitles()
        }
    }
}
