import UIKit
import CoreData

enum TrackerStoreError: Error {
    case decodingErrorInvalidTracker
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
    
    var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    private let context: NSManagedObjectContext
    
    private let uiColorMarshalling = UIColorMarshalling()
    private var insertedIndexesSection: IndexSet?
    private var insertedIndexPath: [IndexPath]?
    private var deletedIndexPath: [IndexPath]?
    private var deletedIndexesSection: IndexSet?
    private var movedIndexPath: [(IndexPath, IndexPath)]?
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true),
            NSSortDescriptor(keyPath: \TrackerCoreData.category?.title, ascending: false)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        self.fetchedResultsController = controller
        controller.delegate = self
        do {
            try controller.performFetch()        } catch {
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
