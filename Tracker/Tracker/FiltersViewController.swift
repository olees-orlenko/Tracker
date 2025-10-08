import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: String)
    func didDeselectFilter()
}

final class FiltersViewController: UIViewController {

    // MARK: - UI Elements
    
    private var titleLabel = UILabel()
    private let tableView = UITableView()
    
    // MARK: - Public Properties
    
    weak var delegate: FiltersViewControllerDelegate?
    var currentFilter: String?

    // MARK: - Private Properties

    private let color = Colors()
    private let filters = [
        NSLocalizedString("all_trackers", comment: ""),
        NSLocalizedString("trackers_for_today", comment: ""),
        NSLocalizedString("completed", comment: ""),
        NSLocalizedString("uncompleted", comment: "")
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitleLabel()
        setupTableView()
        setupView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentFilter == nil {
            currentFilter = filters.first
        }
        tableView.reloadData()
    }
    
    // MARK: - Setup UI Elements
    
    private func setupView() {
        view.backgroundColor = color.viewBackgroundColor
    }
    
    private func setupTitleLabel(){
        titleLabel.textColor = color.trackerTintColor()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.text = NSLocalizedString("filtersButton_title", comment: "")
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = true
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300),

        ])
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier, for: indexPath) as? CategoryTableViewCell else {
                return UITableViewCell()
            }
            cell.backgroundColor = UIColor(resource: .background).withAlphaComponent(0.3)
            cell.textLabel?.text = filters[indexPath.row]
            cell.textLabel?.textColor = color.trackerTintColor()
            cell.tintColor = .systemBlue
            let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
            let isLastRow = indexPath.row == numberOfRows - 1
            cell.setSeparatorHidden(isLastRow)
            if let current = currentFilter, current == filters[indexPath.row], indexPath.row != 0 {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            if currentFilter == filters[indexPath.row] {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                cell.isSelected = true
            } else {
                cell.isSelected = false
            }
            return cell
        }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let oldFilter = currentFilter
            let newFilter = filters[indexPath.row]
            currentFilter = newFilter
            var rowsToReload: [IndexPath] = [indexPath]
            if let old = oldFilter, let oldIndex = filters.firstIndex(of: old) {
                let oldIndexPath = IndexPath(row: oldIndex, section: 0)
                if oldIndexPath != indexPath {
                    rowsToReload.append(oldIndexPath)
                }
            }
            tableView.reloadRows(at: rowsToReload, with: .none)
            delegate?.didSelectFilter(newFilter)
            dismiss(animated: true, completion: nil)
        }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}
