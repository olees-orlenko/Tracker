import CoreData
import UIKit

enum TrackerCategoryStoreError: Error {
    case saveFailed(Error)
}

struct TrackerCategoryStoreUpdate {
    let insertedIndexPath: [IndexPath]
    let deletedIndexPath: [IndexPath]
    let updatedIndexPath: [IndexPath]
    let movedIndexPath: [(IndexPath, IndexPath)]
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStore(_ store: TrackerCategoryStore, didUpdate update: TrackerCategoryStoreUpdate)
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?
    
    lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    private var insertedIndexPath: [IndexPath] = []
    private var deletedIndexPath: [IndexPath] = []
    private var updatedIndexPath: [IndexPath] = []
    private var movedIndexPath: [(IndexPath, IndexPath)] = []
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let trackerStore = TrackerStore(context: context)
        self.init(context: context, trackerStore: trackerStore)
    }
    
    init(context: NSManagedObjectContext, trackerStore: TrackerStore) {
        self.context = context
        self.trackerStore = trackerStore
        super.init()
        performFetch()
    }
    
    private func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to perform fetch for TrackerCategoryStore: \(error)")
        }
    }
    
    func createCategory(title: String) throws -> TrackerCategoryCoreData {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = title
        do {
            try context.save()
            print("Категория '\(title)' создана.")
            return categoryCoreData
        } catch {
            print("Ошибка при создании категории: \(error)")
            throw TrackerCategoryStoreError.saveFailed(error)
        }
    }
    
    func fetchCategory(withTitle title: String) throws -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        do {
            let categories = try context.fetch(fetchRequest)
            return categories.first
        } catch {
            print("Failed to fetch category with title '\(title)': \(error)")
            throw error
        }
    }
    
    func fetchAllCategoriesWithTrackers() throws -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let categoryCoreDataObjects = try context.fetch(fetchRequest)
        var trackerCategories: [TrackerCategory] = []
        for categoryCoreData in categoryCoreDataObjects {
            guard let categoryTitle = categoryCoreData.title else {
                continue
            }
            let trackersForThisCategory = try fetchTrackersForCategory(categoryCoreData: categoryCoreData)
            let trackerCategory = TrackerCategory(
                title: categoryTitle,
                trackers: trackersForThisCategory
            )
            trackerCategories.append(trackerCategory)
        }
        return trackerCategories
    }
    
    private func fetchTrackersForCategory(categoryCoreData: TrackerCategoryCoreData) throws -> [Tracker] {
        guard let trackersCoreData = categoryCoreData.tracker?.allObjects as? [TrackerCoreData] else {
            return []
        }
        var trackers: [Tracker] = []
        for trackerCoreData in trackersCoreData {
            if let tracker = try trackerStore.tracker(from: trackerCoreData) {
                trackers.append(tracker)
            }
        }
        return trackers
    }
    
    func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func getCategoryTitles() -> [String] {
        return fetchedResultsController.fetchedObjects?.compactMap { $0.title } ?? []
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String? {
        return fetchedResultsController.object(at: indexPath).title
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPath = []
        deletedIndexPath = []
        updatedIndexPath = []
        movedIndexPath = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TrackerCategoryStoreUpdate(
            insertedIndexPath: insertedIndexPath,
            deletedIndexPath: deletedIndexPath,
            updatedIndexPath: updatedIndexPath,
            movedIndexPath: movedIndexPath
        )
        delegate?.trackerCategoryStore(self, didUpdate: update)
        insertedIndexPath = []
        deletedIndexPath = []
        updatedIndexPath = []
        movedIndexPath = []
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexPath.append(newIndexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexPath.append(indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                updatedIndexPath.append(indexPath)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                movedIndexPath.append((indexPath, newIndexPath))
            }
        @unknown default:
            fatalError()
        }
    }
}
