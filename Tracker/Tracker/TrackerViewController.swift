import UIKit

class TrackerViewController: UIViewController {
    
    private let textLabel = UILabel()
    private let dateLabel = UILabel()
    private let dateView = UIView()
    private var imageView = UIImageView()
    private var searchField: UISearchController!
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDateLabel()
        setupTrackerButton()
        setupTitle()
        setupSearchField()
        setupImageView()
        setupTextLabel()
        setupConstraints()
    }
    
    // MARK: - View Setup
    
    private func setupView() {
        view.backgroundColor = UIColor(resource: .white)
        view.contentMode = .scaleToFill
    }
    
    private func setupImageView(){
        let image = UIImage(named: "image_1")
        imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(resource: .black)
    }
    
    private func setupTextLabel() {
        textLabel.text = "Что будем отслеживать?"
        textLabel.textColor = UIColor(resource: .black)
        textLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        textLabel.contentMode = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
    }
    
    private func setupDateLabel(){
        dateLabel.backgroundColor = UIColor(resource: .lightgray)
        dateLabel.layer.cornerRadius = 8
        dateLabel.clipsToBounds = true
        updateDate()
        dateLabel.textColor = UIColor(resource: .black)
        dateLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        dateLabel.textAlignment = .center
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateView.translatesAutoresizingMaskIntoConstraints = false
        dateView.addSubview(dateLabel)
        let dateBarItem = UIBarButtonItem(customView: dateView)
        navigationItem.rightBarButtonItem = dateBarItem
    }
    
    func updateDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        dateLabel.text = dateFormatter.string(from: Date())
    }
    
    private func setupTrackerButton(){
        let trackerButtonImage = UIImage(named: "add_tracker")
        let addTrackerButton = UIBarButtonItem(image: trackerButtonImage, style: .plain, target: self, action: #selector(addTrackerButtonTapped))
        addTrackerButton.tintColor = .black
        let leadingSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigationItem.leftBarButtonItem = addTrackerButton
    }
    
    private func setupTitle(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Трекеры"
    }
    
    private func setupSearchField() {
        searchField = UISearchController(searchResultsController: nil)
        searchField.searchBar.placeholder = "Поиск"
        searchField.searchBar.searchTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        searchField.searchBar.searchTextField.textColor = UIColor(resource: .gray)
        navigationItem.searchController = searchField
    }
    
    @objc func addTrackerButtonTapped() {}
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            dateView.widthAnchor.constraint(equalToConstant: 77),
            dateView.heightAnchor.constraint(equalToConstant: 34),
            dateLabel.topAnchor.constraint(equalTo: dateView.topAnchor, constant: 6),
            dateLabel.bottomAnchor.constraint(equalTo: dateView.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: dateView.leadingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: dateView.trailingAnchor, constant: -12),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 147),
            textLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    func addNewTracker(newTracker: Tracker, toCategoryTitle categoryTitle: String) {
        var updatedCategories: [TrackerCategory] = []
        var foundCategory = false
        for category in categories {
            if category.title == categoryTitle {
                let updatedTrackers = category.trackers + [newTracker]
                let updatedCategory = TrackerCategory(title: category.title, trackers: updatedTrackers)
                updatedCategories.append(updatedCategory)
                foundCategory = true
            } else {
                updatedCategories.append(category)
            }
        }
        if !foundCategory {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [newTracker])
            updatedCategories.append(newCategory)
        }
        
        self.categories = updatedCategories
        print("Трекер '\(newTracker.name)' добавлен. Всего категорий: \(categories.count)")
    }
    
    func addTrackerRecord(trackerId: UUID, date: Date) {
        let newRecord = TrackerRecord(trackerId: trackerId, date: date)
        completedTrackers = completedTrackers + [newRecord]
    }
    
    func removeTrackerRecord(trackerId: UUID, date: Date) {
        completedTrackers = completedTrackers.filter { record in
            !(record.trackerId == trackerId && Calendar.current.isDate(record.date, inSameDayAs: date))
        }
    }
}
