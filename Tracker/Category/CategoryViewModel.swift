import UIKit

protocol CategoryViewModelProtocol: AnyObject {
    
    var trackerCategoryStore: TrackerCategoryStore { get }
    var categories: [TrackerCategory] { get }
    var onCategoriesUpdate: (() -> Void)? { get set }
    var onCategorySelected: ((TrackerCategory) -> Void)? { get set }
    
    func loadCategories()
    func createCategory(title: String)
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
    
    // MARK: - Init
    
    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        trackerCategoryStore.delegate = self
    }
    
    func loadCategories() {
        print("loadCategories called")
        do {
            self.categories = try trackerCategoryStore.fetchAllCategoriesWithTrackers()
            print("loadCategories loaded: \(self.categories.count) categories")
        } catch {
            print("Ошибка загрузки категорий: \(error)")
        }
    }
    
    func createCategory(title: String) {
        print("createCategory called with title: \(title)")
        do {
            try trackerCategoryStore.createCategory(title: title)
            loadCategories()
        } catch {
            print("Не удалось создать категорию: \(error)")
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
        print("didUpdateCategories called")
        loadCategories()
        onCategoriesUpdate?()
    }
}
