import UIKit

final class CategoryViewController: UIViewController{
    
    weak var delegate: CategoryViewControllerDelegate?
    
    // MARK: - UI Elements
    
    private var tableView = UITableView()
    private let doneButton = UIButton()
    private var imageView = UIImageView()
    private let textLabel = UILabel()
    
    // MARK: - Properties
    
    private var selectedCategoryIndex: Int?
    private var viewModel: CategoryViewModelProtocol
    
    private var visibleCategories: [TrackerCategory] = [] {
        didSet {
            updateImageView()
        }
    }
    
    // MARK: - Initializers
    
    init(viewModel: CategoryViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        setupView()
        setupTableView()
        setupDoneButton()
        setupImageView()
        setupTextLabel()
        setupConstraints()
        tableView.reloadData()
        bindViewModel()
        viewModel.loadCategories()
        updateImageView()
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        view.backgroundColor = .white
        navigationItem.title = "Категория"
        let title: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        navigationController?.navigationBar.titleTextAttributes = title
    }
    
    private func setupTextLabel() {
        textLabel.text = "Привычки и события можно\n объединить по смыслу"
        textLabel.numberOfLines = 2
        textLabel.textColor = UIColor(resource: .black)
        textLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
    }
    
    private func setupImageView(){
        let image = UIImage(named: "image_1")
        imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(resource: .black)
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .singleLine
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
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
        doneButton.setTitle("Добавить категорию", for: .normal)
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
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -24),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 147),
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func updateImageView() {
        imageView.isHidden = !visibleCategories.isEmpty
        textLabel.isHidden = !visibleCategories.isEmpty
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        viewModel.onCategoriesUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.visibleCategories = self?.viewModel.categories ?? []
                self?.tableView.reloadData()
                self?.updateImageView()
            }
        }
        viewModel.onCategorySelected = { [weak self] category in
            self?.delegate?.didSelectCategory(category.title)
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        let addCategoryViewController = AddCategoryViewController()
        addCategoryViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: addCategoryViewController)
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryScheduleTableViewCell.reuseIdentifier, for: indexPath) as? CategoryScheduleTableViewCell else {
            return UITableViewCell()
        }
        guard indexPath.row < viewModel.categories.count else {
            return cell
        }
        let category = viewModel.categories[indexPath.row]
        cell.contentView.backgroundColor = UIColor(resource: .background).withAlphaComponent(0.3)
        let backgroundColor = UIColor(resource: .background).withAlphaComponent(0.3)
        cell.backgroundColor = backgroundColor
        cell.contentView.backgroundColor = .clear
        cell.titleLabel.text = category.title
        cell.subtitleLabel.text = nil
        cell.subtitleLabel.isHidden = true
        cell.accessoryType = (indexPath.row == selectedCategoryIndex) ? .checkmark : .none
        cell.selectionStyle = .none
        if indexPath.row == viewModel.categories.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.maskedCorners = []
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < viewModel.categories.count else {
            return
        }
        selectedCategoryIndex = indexPath.row
        viewModel.didSelectCategory(at: indexPath)
        tableView.reloadData()
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension CategoryViewController: TrackerCategoryStoreDelegate {
    func trackerCategoryStore(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: update.insertedIndexPath, with: .automatic)
            tableView.deleteRows(at: update.deletedIndexPath, with: .automatic)
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.loadCategories()
        }
    }
}

extension CategoryViewController: AddCategoryViewControllerDelegate {
    
    func didCreateCategory(_ categoryTitle: String) {
        do {
            _ = try viewModel.trackerCategoryStore.createCategory(title: categoryTitle)
            viewModel.loadCategories()
            self.tableView.reloadData()
            self.updateImageView()
        } catch {
            print("Не удалось создать категорию: \(error)")
        }
    }
}
