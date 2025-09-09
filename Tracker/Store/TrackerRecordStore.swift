import CoreData
import UIKit

enum TrackerRecordStoreError: Error {
    case fetchFailed(Error)
    case saveFailed(Error)
    case trackerNotFound
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidUpdateRecords(_ store: TrackerRecordStore)
}

final class TrackerRecordStore: NSObject {
    weak var delegate: TrackerRecordStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerStore = TrackerStore()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func createRecord(trackerId: UUID, date: Date) throws {
        let trackerCoreData = try trackerStore.fetchTracker(withId: trackerId)
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.trackerID = trackerId
        recordCoreData.date = date
        recordCoreData.tracker = trackerCoreData
        do {
            try context.save()
            delegate?.trackerRecordStoreDidUpdateRecords(self)
        } catch {
            throw TrackerRecordStoreError.saveFailed(error)
        }
    }
    
    func deleteRecord(trackerId: UUID, date: Date) throws {
        let trackerCoreData = try trackerStore.fetchTracker(withId: trackerId)
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        fetchRequest.predicate = NSPredicate(format: "tracker == %@ AND date >= %@ AND date < %@", trackerCoreData!, startOfDay as CVarArg, endOfDay as CVarArg)
        do {
            let records = try context.fetch(fetchRequest)
            if let recordToDelete = records.first {
                context.delete(recordToDelete)
                try context.save()
                delegate?.trackerRecordStoreDidUpdateRecords(self)
            }
        } catch {
            throw TrackerRecordStoreError.fetchFailed(error)
        }
    }
    
    func isTrackerCompleted(trackerId: UUID, onDate date: Date) -> Bool {
        guard let trackerCoreData = try? trackerStore.fetchTracker(withId: trackerId) else {
            print("Tracker not found with ID: \(trackerId)")
            return false
        }
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        fetchRequest.predicate = NSPredicate(format: "tracker == %@ AND date >= %@ AND date < %@", trackerCoreData, startOfDay as CVarArg, endOfDay as CVarArg)
        do {
            let records = try context.fetch(fetchRequest)
            return !records.isEmpty
        } catch {
            print("Failed to fetch tracker records: \(error)")
            return false
        }
    }
    
    func fetchCompletedDates(forTrackerId trackerId: UUID) throws -> [Date] {
        guard let trackerCoreData = try trackerStore.fetchTracker(withId: trackerId) else {
            throw TrackerRecordStoreError.trackerNotFound
        }
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker == %@", trackerCoreData)
        do {
            let results = try context.fetch(request)
            return results.compactMap { $0.date }
        } catch {
            throw TrackerRecordStoreError.fetchFailed(error)
        }
    }
}
