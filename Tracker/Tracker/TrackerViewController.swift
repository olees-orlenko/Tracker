import UIKit

final class TrackerViewController: UIViewController, AddTrackerViewControllerDelegate, TrackerCellDelegate {
    
    // MARK: - UI Elements
    
    private let textLabel = UILabel()
    private let cellIdentifier = "cell"
    private var imageView = UIImageView()
    private var searchField: UISearchController?
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: - Properties
    
    var currentDate = Date()
    var categories: [TrackerCategory] = []
    
    // MARK: - Private Properties
    
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = [] {
        didSet {
            collectionView.reloadData()
            updateImageView()
        }
    }
    var filteredTrackers: [Tracker] = [] {
        didSet {
            updateImageView()
            collectionView.reloadData()
        }
    }
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        setupView()
        setupCollectionView()
        setupTrackerButton()
        setupTitle()
        setupSearchField()
        setupImageView()
        setupTextLabel()
        setupDatePicker()
        setupConstraints()
        updateImageView()
        collectionView.reloadData()
    }
    
    // MARK: - Setup UI Elements
    
    private func setupView() {
        view.backgroundColor = UIColor(resource: .white)
        view.contentMode = .scaleToFill
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCollectionViewCell")
        view.addSubview(collectionView)
    }
    
    private func setupDatePicker() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
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
    
    private func setupTrackerButton(){
        let trackerButtonImage = UIImage(named: "add_tracker")
        let addTrackerButton = UIBarButtonItem(image: trackerButtonImage, style: .plain, target: self, action: #selector(addTrackerButtonTapped))
        addTrackerButton.tintColor = .black
        navigationItem.leftBarButtonItem = addTrackerButton
    }
    
    private func setupTitle(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Трекеры"
    }
    
    private func setupSearchField() {
        searchField = UISearchController(searchResultsController: nil)
        searchField?.searchBar.placeholder = "Поиск"
        searchField?.searchBar.searchTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        searchField?.searchBar.searchTextField.textColor = UIColor(resource: .gray)
        navigationItem.searchController = searchField
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 147),
            textLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    // MARK: - Actions
    
    @objc private func addTrackerButtonTapped() {
        let addTrackerViewController = AddTrackerViewController()
        addTrackerViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: addTrackerViewController)
        present(navigationController, animated: true)
        filterTrackersForSelectedDate(currentDate)
        collectionView.reloadData()
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        self.currentDate = selectedDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
        filterTrackersForSelectedDate(selectedDate)
    }
    
    // MARK: - TrackerCellDelegate
    
    func didTapCompleteButton(trackerId: UUID, at indexPath: IndexPath) {
        if currentDate <= Date() {
            addTrackerRecord(trackerId: trackerId, date: currentDate)
            collectionView.reloadData()
        }
    }
    
    func didTapUnCompleteButton(trackerId: UUID, at indexPath: IndexPath) {
        self.removeTrackerRecord(trackerId: trackerId, date: self.currentDate)
        collectionView.reloadData()
    }
    
    // MARK: - Data
    
    private func updateImageView() {
        imageView.isHidden = !filteredTrackers.isEmpty
        textLabel.isHidden = !filteredTrackers.isEmpty
    }
    
    func addNewTracker(tracker newTracker: Tracker, title categoryTitle: String) {
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
        print(updatedCategories)
        updateImageView()
        collectionView.reloadData()
    }
    
    func addTrackerRecord(trackerId: UUID, date: Date) {
        let newRecord = TrackerRecord(trackerId: trackerId, date: date)
        completedTrackers.append(newRecord)
    }
    
    func removeTrackerRecord(trackerId: UUID, date: Date) {
        completedTrackers.removeAll { record in
            record.trackerId == trackerId && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }
    
    func completeTracker(trackerId: UUID, date: Date) {
        let existingRecord = completedTrackers.first { record in
            record.trackerId == trackerId && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
        if existingRecord != nil {
            removeTrackerRecord(trackerId: trackerId, date: date)
        } else {
            addTrackerRecord(trackerId: trackerId, date: date)
        }
    }
    
    private func filterTrackersForSelectedDate(_ date: Date) {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        guard let selectedWeekDay = Week(calendarWeekday: dayOfWeek) else {
            self.filteredTrackers = []
            self.visibleCategories = []
            return
        }
        var newVisibleCategories: [TrackerCategory] = []
        var newFilteredTrackers: [Tracker] = []
        for category in categories {
            let filteredTrackersInCategory = category.trackers.filter { tracker in
                return tracker.schedule.contains(selectedWeekDay)
            }
            if !filteredTrackersInCategory.isEmpty {
                let newCategory = TrackerCategory(title: category.title, trackers:
                                                    filteredTrackersInCategory)
                newVisibleCategories.append(newCategory)
                newFilteredTrackers.append(contentsOf: filteredTrackersInCategory)
            }
        }
        self.filteredTrackers = newFilteredTrackers
        self.visibleCategories = newVisibleCategories
    }
}

// MARK: - CollectionView Delegate and DataSource

extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.row]
        let completedDays = completedTrackers.filter { completedTracker in
            return completedTracker.trackerId == tracker.id
        }.count
        let isCompleted = completedTrackers.contains { completedTracker in
            return completedTracker.trackerId == tracker.id && completedTracker.date == currentDate
        }
        cell.configure(isCompleted: isCompleted, trackerID: tracker.id, trackerName: tracker.name, indexPath: indexPath, categoryTitle: category.title, completedDays: completedDays, currentDate: currentDate)
        cell.delegate = self
        return cell
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInsets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let itemSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: indexPath.section)
        let numberOfColumns: CGFloat = 2
        let totalPadding = sectionInsets.left + sectionInsets.right
        let spacingBetweenCells = itemSpacing * (numberOfColumns - 1)
        let availableWidth = collectionView.bounds.width - totalPadding - spacingBetweenCells
        let cellWidth = availableWidth / numberOfColumns
        let cellHeight: CGFloat = 178
        return CGSize(width: floor(cellWidth), height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 16, bottom: 0, right: 16)
    }
}
