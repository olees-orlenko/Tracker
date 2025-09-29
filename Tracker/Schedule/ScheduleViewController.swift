import UIKit

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    // MARK: - Properties
    
    var switchButton: [Int : Bool] = [:]
    var selectedDays: [Week] = []
    var onScheduleSelected: (([Week]) -> Void)?
    
    // MARK: - UI Elements
    
    private var tableView = UITableView()
    private let doneButton = UIButton()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupDoneButton()
        setupConstraints()
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        tableView.tableFooterView = UIView()
        view.backgroundColor = .white
        navigationItem.title = NSLocalizedString("schedule_title", comment: "Title for the Schedule view")
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
        tableView.register(ScheduleTableViewCell.self, forCellReuseIdentifier: ScheduleTableViewCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }
    
    private func setupDoneButton() {
        doneButton.setTitle(NSLocalizedString("done_button_title", comment: "Title for the Done button"), for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = UIColor(resource: .black)
        doneButton.layer.cornerRadius = 16
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneButton)
    }
    
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
        onScheduleSelected?(selectedDays)
        delegate?.didUpdateSchedule(selectedDays: selectedDays)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Week.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseIdentifier, for: indexPath) as? ScheduleTableViewCell else {
            return UITableViewCell()
        }
        let day = Week.allCases[indexPath.row]
        cell.contentView.backgroundColor = UIColor(resource: .background).withAlphaComponent(0.3)
        let backgroundColor = UIColor(resource: .background).withAlphaComponent(0.3)
        cell.backgroundColor = backgroundColor
        cell.contentView.backgroundColor = .clear
        cell.textLabel?.text = day.localizedString
        cell.daySwitch.isOn = selectedDays.contains(day)
        cell.daySwitch.tag = indexPath.row
        cell.daySwitch.removeTarget(nil, action: nil, for: .allEvents)
        cell.daySwitch.addTarget(self, action: #selector(switchButton(_:)), for: .valueChanged)
        if indexPath.row == Week.allCases.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    // MARK: - Switch Action
    
    @objc private func switchButton(_ sender: UISwitch) {
        let day = Week.allCases[sender.tag]
        if sender.isOn {
            if !selectedDays.contains(day) {
                selectedDays.append(day)
            }
        } else {
            selectedDays.removeAll { $0 == day }
        }
    }
}
