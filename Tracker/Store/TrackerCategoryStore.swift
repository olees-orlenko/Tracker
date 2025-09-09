import CoreData
import UIKit

enum TrackerCategoryStoreError: Error {
    case saveFailed(Error)
}

struct TrackerCategoryStoreUpdate {
    let insertedIndexPath: [IndexPath]
    let deletedIndexPath: [IndexPath]
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
    private var insertedIndexPath: [IndexPath] = []
    private var deletedIndexPath: [IndexPath] = []
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        performFetch()
        addDefaultCategories()
    }
    private func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to perform fetch for TrackerCategoryStore: \(error)")
        }
    }
    
    func createCategory(title: String) throws -> TrackerCategoryCoreData {
        if let existingCategory = try fetchCategory(withTitle: title) {
            print("Category '\(title)' already exists.")
            return existingCategory
        }
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = title
        do {
            try context.save()
            print("Category '\(title)' created and saved.")
            return categoryCoreData
        } catch {
            print("Failed to save new category: \(error)")
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
    
    func addDefaultCategories() {
        do {
            let count = fetchedResultsController.fetchedObjects?.count ?? 0
            if count == 0 {
                let defaultCategories = ["Важное", "Неважное"]
                for title in defaultCategories {
                    _ = try createCategory(title: title)
                }
                try context.save()
                try fetchedResultsController.performFetch()
                delegate?.trackerCategoryStore(self, didUpdate: TrackerCategoryStoreUpdate(insertedIndexPath: [], deletedIndexPath: []))
            }
        } catch {
            print("Failed to check if default categories exist: \(error)")
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPath = []
        deletedIndexPath = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TrackerCategoryStoreUpdate(
            insertedIndexPath: insertedIndexPath,
            deletedIndexPath: deletedIndexPath
        )
        delegate?.trackerCategoryStore(self, didUpdate: update)
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
            }
        case .move:
            break
        @unknown default:
            fatalError()
        }
    }
}
