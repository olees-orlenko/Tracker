import UIKit

protocol CategoryViewModelProtocol: AnyObject {
    
    var trackerCategoryStore: TrackerCategoryStore { get }
    var categories: [TrackerCategory] { get }
    var onCategoriesUpdate: (() -> Void)? { get set }
    var selectedCategory: TrackerCategory? { get set }
    var onCategorySelected: ((TrackerCategory) -> Void)? { get set }
    
    func loadCategories()
    func didSelectCategory(at indexPath: IndexPath)
}

final class CategoryViewModel: CategoryViewModelProtocol {
    
    // MARK: - Private Properties
    
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesUpdate?()
        }
    }
    
    // MARK: - Properties
    
    var trackerCategoryStore: TrackerCategoryStore
    var onCategoriesUpdate: (() -> Void)?
    var selectedCategory: TrackerCategory?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    var trackers: [Tracker] = []
    
    // MARK: - Initializer
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        trackerCategoryStore.delegate = self
    }
    
    func loadCategories() {
        self.categories = trackerCategoryStore.getCategoryTitles().map {
            TrackerCategory(title: $0, trackers: trackers)
        }
    }
    
    func didSelectCategory(at indexPath: IndexPath) {
        guard indexPath.row < categories.count else { return }
        selectedCategory = categories[indexPath.row]
        if let selectedCategory = selectedCategory {
            onCategorySelected?(selectedCategory)
        }
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func trackerCategoryStore(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate) {
        loadCategories()
    }
}
