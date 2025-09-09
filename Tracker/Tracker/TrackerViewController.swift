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
    var trackers: [Tracker] = []
    
    // MARK: - Private Properties
    
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = [] {
        didSet {
            collectionView.reloadData()
            updateImageView()
        }
    }
    private var filteredTrackers: [Tracker] = [] {
        didSet {
            updateImageView()
            collectionView.reloadData()
        }
    }
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
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
        filterTrackersForSelectedDate(currentDate)
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
        let category: TrackerCategoryCoreData
        do {
            if let existingCategory = try trackerCategoryStore.fetchCategory(withTitle: categoryTitle) {
                category = existingCategory
            } else {
                category = try trackerCategoryStore.createCategory(title: categoryTitle)
            }
        } catch {
            print("Ошибка при получении или создании категории: \(error)")
            return
        }
        do {
            try trackerStore.createTracker(newTracker, category: category)
        } catch {
            print("Ошибка при создании трекера: \(error)")
            return
        }
        updateImageView()
        collectionView.reloadData()
    }
    
    func addTrackerRecord(trackerId: UUID, date: Date) {
        do {
            try trackerRecordStore.createRecord(trackerId: trackerId, date: date)
        } catch {
            print("Ошибка при создании записи трекера по Id \(trackerId) на дату \(date): \(error)")
        }
    }
    
    func removeTrackerRecord(trackerId: UUID, date: Date) {
        do {
            try trackerRecordStore.deleteRecord(trackerId: trackerId, date: date)
        } catch {
            print("Ошибка при удалении записи трекера по Id \(trackerId) на дату \(date): \(error)")
        }
    }
    
    func completeTracker(trackerId: UUID, date: Date) {
        if trackerRecordStore.isTrackerCompleted(trackerId: trackerId, onDate: date) {
            removeTrackerRecord(trackerId: trackerId, date: date)
        } else {
            addTrackerRecord(trackerId: trackerId, date: date)
        }
    }
    
    private func filterTrackersForSelectedDate(_ date: Date) {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        guard let selectedWeekDay = Week(calendarWeekday: dayOfWeek) else {
            self.visibleCategories = []
            return
        }
        let fetchRequest = trackerStore.fetchedResultsController.fetchRequest
        fetchRequest.predicate = NSPredicate(format: "schedule & %d != 0", 1 << selectedWeekDay.bitValue)
        do {
            try trackerStore.fetchedResultsController.performFetch()
            updateVisibleCategories()
        } catch {
            print("Ошибка получения трекера по предикату: \(error)")
        }
    }
    
    private func updateVisibleCategories() {
        var newVisibleCategories: [TrackerCategory] = []
        var newFilteredTrackers: [Tracker] = []
        guard let fetchedObjects = trackerStore.fetchedResultsController.fetchedObjects else {
            self.visibleCategories = []
            self.filteredTrackers = []
            return
        }
        let groupedByCategories = Dictionary(grouping: fetchedObjects) { (trackerCoreData) -> String in
            return trackerCoreData.category?.title ?? "Без категории"
        }
        for (categoryTitle, trackerCoreDataArray) in groupedByCategories.sorted(by: { $0.key < $1.key }) {
            let trackersForCategory: [Tracker] = trackerCoreDataArray.compactMap { trackerCoreData in
                try? trackerStore.tracker(from: trackerCoreData)
            }
            if !trackersForCategory.isEmpty {
                let category = TrackerCategory(title: categoryTitle, trackers: trackersForCategory)
                newVisibleCategories.append(category)
                newFilteredTrackers.append(contentsOf: trackersForCategory)
            }
        }
        self.visibleCategories = newVisibleCategories
        self.filteredTrackers = newFilteredTrackers
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
        let completedDays = (try? trackerRecordStore.fetchCompletedDates(forTrackerId: tracker.id).count) ?? 0
        let isCompleted = (try? trackerRecordStore.isTrackerCompleted(trackerId: tracker.id, onDate: currentDate)) ?? false
        cell.configure(isCompleted: isCompleted, trackerID: tracker.id, trackerName: tracker.name, indexPath: indexPath, categoryTitle: category.title, completedDays: completedDays, currentDate: currentDate, color: tracker.color, emoji: tracker.emoji)
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

extension TrackerViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore, didUpdate update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates {
            if !update.insertedIndexesSection.isEmpty {
                collectionView.insertSections(update.insertedIndexesSection)
            }
            if !update.deletedIndexesSection.isEmpty {
                collectionView.deleteSections(update.deletedIndexesSection)
            }
            if !update.insertedIndexPath.isEmpty {
                collectionView.insertItems(at: update.insertedIndexPath)
            }
            if !update.deletedIndexPath.isEmpty {
                collectionView.deleteItems(at: update.deletedIndexPath)
            }
            if !update.movedIndexPath.isEmpty {
                for move in update.movedIndexPath {
                    collectionView.moveItem(at: move.0, to: move.1)
                }
            }
        } completion: { _ in
            self.updateVisibleCategories()
        }
    }
}

extension TrackerViewController: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidUpdateRecords(_ store: TrackerRecordStore) {
        collectionView.reloadData()
    }
}
