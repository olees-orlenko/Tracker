import UIKit

final class TrackerViewController: UIViewController, AddTrackerViewControllerDelegate, TrackerCellDelegate {
    
    // MARK: - UI Elements
    
    private let textLabel = UILabel()
    private let cellIdentifier = "cell"
    private var imageView = UIImageView()
    private var searchField: UISearchTextField!
    private let cancelButton = UIButton(type: .system)
    private let emptyImageView = UIImageView()
    private let emptyLabel = UILabel()
    private let filtersButton = UIButton()
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    // MARK: - Properties
    
    var currentDate = Date()
    var categories: [TrackerCategory] = []
    var trackers: [Tracker] = []
    let trackerStore = TrackerStore.shared
    let trackerCategoryStore = TrackerCategoryStore.shared
    let trackerRecordStore = TrackerRecordStore.shared
    
    // MARK: - Private Properties
    
    private var visibleCategories: [TrackerCategory] = [] {
        didSet {
            updateEmptyState()
            collectionView.reloadData()
        }
    }
    private var filteredTrackers: [Tracker] = [] {
        didSet {
            updateEmptyState()
            collectionView.reloadData()
        }
    }
    private var searchFieldTrailingConstraintWhenCancelHidden: NSLayoutConstraint!
    private var searchFieldTrailingConstraintWhenCancelVisible: NSLayoutConstraint!
    private var searchText: String = "" {
        didSet {
            updateVisibleCategories()
            updateEmptyState()
        }
    }
    private var currentFilter: String? = NSLocalizedString("all_trackers", comment: "")
    private let colors = Colors()
    private let analyticsService = AnalyticsService()
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.trackerStore.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        setupView()
        setupCollectionView()
        setupTrackerButton()
        setupTitle()
        setupSearchField()
        setupCancelButton()
        setupImageView()
        setupTextLabel()
        setupEmptyImageView()
        setupEmptyLabel()
        setupDatePicker()
        setupFiltersButton()
        setupConstraints()
        try? trackerStore.fetchedResultsController.performFetch()
        updateVisibleCategories()
        let todayKey = NSLocalizedString("trackers_for_today", comment: "")
        currentFilter = todayKey
        updateFilteringForCurrentFilterAndDate()
        self.updateEmptyState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: "open", params: ["screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: "close", params: ["screen": "Main"])
    }
    
    // MARK: - Setup UI Elements
    
    private func setupView() {
        view.backgroundColor = colors.viewBackgroundColor
        view.contentMode = .scaleToFill
    }
    
    private func setupFiltersButton() {
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        filtersButton.backgroundColor = UIColor(resource: .blue)
        filtersButton.setTitle(NSLocalizedString("filtersButton_title", comment: ""), for: .normal)
        filtersButton.titleLabel?.font = .systemFont(ofSize: 17)
        filtersButton.layer.cornerRadius = 16
        filtersButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        view.addSubview(filtersButton)
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
    
    private func setupEmptyImageView() {
        emptyImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyImageView.image = UIImage(named: "error")
        emptyImageView.isHidden = true
        emptyImageView.contentMode = .scaleAspectFit
        view.addSubview(emptyImageView)
    }
    
    private func setupEmptyLabel() {
        emptyLabel.textColor = colors.trackerTintColor()
        emptyLabel.text = NSLocalizedString("no_trackers", comment: "Text indicating empty search")
        emptyLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        emptyLabel.contentMode = .center
        emptyLabel.isHidden = true
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
    }
    
    private func setupTextLabel() {
        textLabel.text = NSLocalizedString("what_to_track", comment: "Text indicating what to track")
        textLabel.textColor = colors.trackerTintColor()
        textLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        textLabel.contentMode = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textLabel)
    }
    
    private func setupTrackerButton(){
        let trackerButtonImage = UIImage(named: "add_tracker")
        let addTrackerButton = UIBarButtonItem(image: trackerButtonImage, style: .plain, target: self, action: #selector(addTrackerButtonTapped))
        addTrackerButton.tintColor = colors.trackerTintColor()
        navigationItem.leftBarButtonItem = addTrackerButton
    }
    
    private func setupTitle(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = NSLocalizedString("trackers_title", comment: "Title for the Trackers view")
    }
    
    private func setupSearchField() {
        searchField = UISearchTextField()
        searchField.placeholder = NSLocalizedString("search_placeholder", comment: "Placeholder text for the search bar")
        searchField.backgroundColor = UIColor(resource: .gray1)
        searchField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.clearButtonMode = .never
        view.addSubview(searchField)
        searchField.addTarget(self, action: #selector(searchTextFieldDidChange), for: .editingChanged)
        
    }
    
    private func setupCancelButton() {
        cancelButton.isHidden = true
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle(NSLocalizedString("cancel_button_title", comment: "Title for the Cancel button"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cancelButton.contentHorizontalAlignment = .right
        view.addSubview(cancelButton)
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchField.heightAnchor.constraint(equalToConstant: 36),
            searchField.widthAnchor.constraint(equalToConstant: 255),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cancelButton.centerYAnchor.constraint(equalTo: searchField.centerYAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cancelButton.leadingAnchor.constraint(equalTo: searchField.trailingAnchor, constant: 5),
            cancelButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 83),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 147),
            textLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        searchFieldTrailingConstraintWhenCancelHidden = searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        searchFieldTrailingConstraintWhenCancelHidden.isActive = true
        view.bringSubviewToFront(filtersButton)
        collectionView.contentInset.bottom = 82
    }
    
    // MARK: - Actions
    
    @objc private func addTrackerButtonTapped() {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "add_track"])
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
        updateFilteringForCurrentFilterAndDate()
    }
    
    @objc private func filterButtonTapped() {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "filter"])
        let viewController = FiltersViewController()
        viewController.delegate = self
        if let currentFilter {
            if currentFilter == NSLocalizedString("completed", comment: "") || currentFilter == NSLocalizedString("uncompleted", comment: ""){
                viewController.currentFilter = currentFilter
            }
        }
        self.present(viewController, animated: true, completion: nil)
    }
    
    @objc private func cancelButtonTapped() {
        searchField.text = ""
        self.searchText = ""
        searchField.resignFirstResponder()
        cancelButton.isHidden = true
        updateSearchFieldConstraints(showCancelButton: false)
    }
    
    @objc private func searchTextFieldDidChange(_ textField: UISearchTextField) {
        let currentSearchText = textField.text ?? ""
        let shouldShowCancelButton = !currentSearchText.isEmpty
        if cancelButton.isHidden == shouldShowCancelButton {
            cancelButton.isHidden = !shouldShowCancelButton
            updateSearchFieldConstraints(showCancelButton: shouldShowCancelButton)
        }
        if self.searchText != currentSearchText {
            self.searchText = currentSearchText
        }
    }
    
    // MARK: - TrackerCellDelegate
    
    func didTapCompleteButton(trackerId: UUID, at indexPath: IndexPath) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "track"])
        if currentDate <= Date() {
            addTrackerRecord(trackerId: trackerId, date: currentDate)
            updateFilteringForCurrentFilterAndDate()
        }
    }
    
    func didTapUnCompleteButton(trackerId: UUID, at indexPath: IndexPath) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "track"])
        self.removeTrackerRecord(trackerId: trackerId, date: self.currentDate)
        updateFilteringForCurrentFilterAndDate()
    }
    
    func didTapEditButton(trackerId: UUID, at indexPath: IndexPath) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "edit"])
        let tracker: Tracker
        do {
            tracker = try trackerStore.tracker(by: trackerId)
        } catch {
            print("Failed to fetch tracker for edit: \(error)")
            return
        }
        let categoryTitle = visibleCategories[indexPath.section].title
        let editCategoryViewController = AddTrackerViewController()
        editCategoryViewController.mode = .edit(tracker, categoryTitle)
        editCategoryViewController.onSave = { [weak self] updatedTracker, categoryTitle in
            guard let self = self else { return }
            do {
                try self.trackerStore.updateTracker(updatedTracker, categoryTitle: categoryTitle)
                self.updateVisibleCategories()
                DispatchQueue.main.async {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            } catch {
                print("Failed to update tracker: \(error)")
            }
        }
        let navigationController = UINavigationController(rootViewController: editCategoryViewController)
        present(navigationController, animated: true)
    }
    
    func didTapDeleteButton(tracker: Tracker) {
        analyticsService.report(event: "click", params: ["screen": "Main", "item": "delete"])
        let actionAlert: UIAlertController = {
            let alert = UIAlertController()
            alert.title = NSLocalizedString("deleteTrackerAlert", comment: "")
            return alert
        }()
        let action1 = UIAlertAction(title: NSLocalizedString("deleteTracker_title", comment: ""), style: .destructive) { [weak self] _ in
            do {
                try self?.trackerStore.deleteTracker(tracker)
                self?.collectionView.reloadData()
            } catch {
                print("Failed to delete tracker: \(error)")
            }
        }
        let action2 = UIAlertAction(title: NSLocalizedString("cancel_button_title", comment: ""), style: .cancel)
        actionAlert.addAction(action1)
        actionAlert.addAction(action2)
        present(actionAlert, animated: true)
    }
    
    // MARK: - Data
    
    private func updateEmptyState() {
        let hasAnyTrackers = (trackerStore.fetchedResultsController.fetchedObjects?.isEmpty == false)
        let hasVisibleTrackers = !visibleCategories.isEmpty && visibleCategories.contains(where: { !$0.trackers.isEmpty })
        let isSearching = !(searchField.text?.isEmpty ?? true)
        imageView.isHidden = true
        textLabel.isHidden = true
        emptyImageView.isHidden = true
        emptyLabel.isHidden = true
        if !hasAnyTrackers || (isSearching && !hasVisibleTrackers) {
            filtersButton.isHidden = true
        } else {
            filtersButton.isHidden = false
        }
        if hasVisibleTrackers {
            return
        }
        if hasAnyTrackers {
            emptyImageView.isHidden = false
            emptyLabel.isHidden = false
        } else {
            imageView.isHidden = false
            textLabel.isHidden = false
        }
    }
    
    func addNewTracker(tracker newTracker: Tracker, title categoryTitle: String) {
        let category: TrackerCategoryCoreData
        do {
            if let existingCategory = try self.trackerCategoryStore.fetchCategory(withTitle: categoryTitle) {
                category = existingCategory
            } else {
                category = try self.trackerCategoryStore.createCategory(title: categoryTitle)
            }
        } catch {
            print("Ошибка при получении или создании категории: \(error)")
            return
        }
        do {
            try self.trackerStore.createTracker(newTracker, category: category)
            try self.trackerStore.fetchedResultsController.performFetch()
        } catch {
            print("Ошибка при создании трекера: \(error)")
            return
        }
        self.updateEmptyState()
    }
    
    func updateTracker(_ tracker: Tracker, categoryTitle: String?) {
        do {
            try trackerStore.updateTracker(tracker, categoryTitle: categoryTitle)
        } catch {
            print("Ошибка при обновлении трекера: \(error)")
        }
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
    
    private func updateVisibleCategories() {
        var newVisibleCategories: [TrackerCategory] = []
        var newFilteredTrackers: [Tracker] = []
        guard let fetchedObjects = trackerStore.fetchedResultsController.fetchedObjects else {
            self.visibleCategories = []
            self.filteredTrackers = []
            updateEmptyState()
            return
        }
        let dateFilteredTrackers = fetchedObjects
        let searchFilteredTrackers = dateFilteredTrackers.filter { trackerCoreData in
            guard let trackerName = trackerCoreData.name else { return false }
            return searchText.isEmpty ? true : trackerName.lowercased().contains(searchText.lowercased())
        }
        let groupedByCategories = Dictionary(grouping: searchFilteredTrackers) { (trackerCoreData) -> String in
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
        updateEmptyState()
        print("Количество категорий после обновления visibleCategories: \(visibleCategories.count)")
    }
    
    private func filterTrackers(with searchText: String) {
        self.searchText = searchText
    }

    private func filterTrackers(_ categories: [TrackerCategory], completed: Bool) -> [TrackerCategory] {
        var filteredCategories: [TrackerCategory] = []
        for category in categories {
            let filteredTrackers = category.trackers.filter { tracker in
                let isCompleted = trackerRecordStore.isTrackerCompleted(trackerId: tracker.id, onDate: currentDate)
                return isCompleted == completed
            }
            if !filteredTrackers.isEmpty {
                filteredCategories.append(TrackerCategory(title: category.title, trackers: filteredTrackers))
            }
        }
        return filteredCategories
    }
    
    private func filterCompletedTrackers(_ categories: [TrackerCategory]) -> [TrackerCategory] {
        return filterTrackers(categories, completed: true)
    }
    
    private func filterNotCompletedTrackers(_ categories: [TrackerCategory]) -> [TrackerCategory] {
        return filterTrackers(categories, completed: false)
    }
    
    private func updateSearchFieldConstraints(showCancelButton: Bool) {
        searchFieldTrailingConstraintWhenCancelHidden.isActive = !showCancelButton
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
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
        updateVisibleCategories()
        collectionView.reloadData()
    }
}

extension TrackerViewController: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidUpdateRecords(_ store: TrackerRecordStore) {
        collectionView.reloadData()
    }
}

// MARK: - FiltersViewControllerDelegate

extension TrackerViewController: FiltersViewControllerDelegate {
    
    private func schedulePredicate(for date: Date) -> NSPredicate {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        guard let selectedWeekDay = Week(calendarWeekday: dayOfWeek) else {
            return NSPredicate(value: true)
        }
        let bit = selectedWeekDay.bitValue
        return NSPredicate(format: "schedule & %d != 0", 1 << bit)
    }
    
    private func applyFetchPredicate(_ predicate: NSPredicate?) {
        let fetchRequest = trackerStore.fetchedResultsController.fetchRequest
        fetchRequest.predicate = predicate
        do {
            try trackerStore.fetchedResultsController.performFetch()
            updateVisibleCategories()
        } catch {
            print("Ошибка получения трекеров по предикату: \(error)")
            visibleCategories = []
            filteredTrackers = []
        }
    }
    
    private func applyCompletedFilter(_ showCompleted: Bool) {
        visibleCategories = filterTrackers(visibleCategories, completed: showCompleted)
    }
    
    private func updateFilteringForCurrentFilterAndDate() {
        let allKey = NSLocalizedString("all_trackers", comment: "")
        let todayKey = NSLocalizedString("trackers_for_today", comment: "")
        let completedKey = NSLocalizedString("completed", comment: "")
        let uncompletedKey = NSLocalizedString("uncompleted", comment: "")
        var coreDataPredicate: NSPredicate? = nil
        if currentFilter != allKey {
            coreDataPredicate = schedulePredicate(for: currentDate)
        }
        applyFetchPredicate(coreDataPredicate)
        switch currentFilter {
        case completedKey:
            applyCompletedFilter(true)
        case uncompletedKey:
            applyCompletedFilter(false)
        case nil, allKey, todayKey:
            break
        default:
            break
        }
        collectionView.reloadData()
        updateEmptyState()
    }
    
    func didSelectFilter(_ filter: String) {
        currentFilter = filter
        if filter == NSLocalizedString("trackers_for_today", comment: "") {
            currentDate = Date()
        }
        updateFilteringForCurrentFilterAndDate()
        dismiss(animated: true)
    }
    
    func calendarDidSelectDate(_ date: Date) {
        dateDidChange(to: date)
    }
    
    private func dateDidChange(to newDate: Date) {
        currentDate = newDate
        updateFilteringForCurrentFilterAndDate()
    }
    
    func didDeselectFilter() {
        currentFilter = NSLocalizedString("all_trackers", comment: "")
        updateFilteringForCurrentFilterAndDate()
    }
}

extension TrackerViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        filterTrackers(with: text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
