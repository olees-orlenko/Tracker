import UIKit
import CoreData

enum TrackerStoreError: Error {
    case decodingErrorInvalidTracker
    case trackerNotFound
}

struct TrackerStoreUpdate {
    let insertedIndexesSection: IndexSet
    let deletedIndexesSection: IndexSet
    let insertedIndexPath: [IndexPath]
    let deletedIndexPath: [IndexPath]
    let movedIndexPath: [(IndexPath, IndexPath)]
}

protocol TrackerStoreDelegate: AnyObject {
    func store(
        _ store: TrackerStore,
        didUpdate update: TrackerStoreUpdate
    )
}

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?
    static let shared = TrackerStore()
    
    var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    private var insertedIndexesSection: IndexSet?
    private var insertedIndexPath: [IndexPath]?
    private var deletedIndexPath: [IndexPath]?
    private var deletedIndexesSection: IndexSet?
    private var movedIndexPath: [(IndexPath, IndexPath)]?
    
    private override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        self.context = appDelegate.persistentContainer.viewContext
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.title, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
            cacheName: nil
        )
        self.fetchedResultsController = controller
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            print("Failed to perform fetch for TrackerStore: \(error)")
        }
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker? {
        guard let id = trackerCoreData.id,
              let name = trackerCoreData.name,
              let colorString = trackerCoreData.color,
              let emoji = trackerCoreData.emoji else {
            throw TrackerStoreError.decodingErrorInvalidTracker
        }
        let color = uiColorMarshalling.color(from: colorString)
        let schedule = Week.changeScheduleArray(from: trackerCoreData.schedule)
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    
    func tracker(by id: UUID) throws -> Tracker {
        var result: Tracker?
        var errorResult: Error?
        context.performAndWait {
            do {
                guard let core = try fetchTracker(withId: id) else {
                    errorResult = TrackerStoreError.trackerNotFound
                    return
                }
                result = try tracker(from: core)
            } catch {
                errorResult = error
            }
        }
        if let error = errorResult { throw error }
        return result!
    }
    
    func createTracker(_ tracker: Tracker, category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = Week.changeScheduleValue(for: tracker.schedule)
        trackerCoreData.category = category
        try context.save()
    }
    
    func fetchTracker(withId id: UUID) throws -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        do {
            let trackers = try context.fetch(fetchRequest)
            return trackers.first
        } catch {
            throw error
        }
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        if let result = try context.fetch(fetchRequest).first {
            context.delete(result)
            try context.save()
        } else {
            throw TrackerStoreError.trackerNotFound
        }
    }
    
    func updateTracker(_ tracker: Tracker, categoryTitle: String?) throws {
        var thrownError: Error?
        context.performAndWait {
            do {
                let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
                fetchRequest.fetchLimit = 1
                let results = try context.fetch(fetchRequest)
                guard let core = results.first else {
                    thrownError = TrackerStoreError.trackerNotFound
                    return
                }
                core.name = tracker.name
                core.emoji = tracker.emoji
                core.color = uiColorMarshalling.hexString(from: tracker.color)
                core.schedule = Week.changeScheduleValue(for: tracker.schedule)
                if let categoryTitle {
                    let categoryCore = try fetchOrCreateCategory(withTitle: categoryTitle, in: context)
                    core.category = categoryCore
                } else {
                    core.category = nil
                }
                try context.save()
            } catch {
                thrownError = error
            }
        }
        if let e = thrownError { throw e }
    }
    
    private func fetchOrCreateCategory(withTitle title: String, in context: NSManagedObjectContext) throws -> TrackerCategoryCoreData {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        let results = try context.fetch(fetchRequest)
        if let existing = results.first {
            return existing
        }
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title
        return newCategory
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexesSection = IndexSet()
        deletedIndexesSection = IndexSet()
        insertedIndexPath = []
        deletedIndexPath = []
        movedIndexPath = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let update = TrackerStoreUpdate(
            insertedIndexesSection: insertedIndexesSection ?? IndexSet(),
            deletedIndexesSection: deletedIndexesSection ?? IndexSet(),
            insertedIndexPath: insertedIndexPath ?? [],
            deletedIndexPath: deletedIndexPath ?? [],
            movedIndexPath: movedIndexPath ?? []
        )
        delegate?.store(self, didUpdate: update)
        insertedIndexesSection = IndexSet()
        deletedIndexesSection = IndexSet()
        insertedIndexPath = []
        deletedIndexPath = []
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
                insertedIndexPath?.append(newIndexPath)
                print("insertedIndexPath: \(insertedIndexPath)")
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexPath?.append(indexPath)
            }
        case .update:
            break
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                movedIndexPath?.append((indexPath, newIndexPath))
            }
        @unknown default:
            fatalError()
        }
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            insertedIndexesSection?.insert(sectionIndex)
        case .delete:
            deletedIndexesSection?.insert(sectionIndex)
        @unknown default:
            fatalError()
        }
    }
}
