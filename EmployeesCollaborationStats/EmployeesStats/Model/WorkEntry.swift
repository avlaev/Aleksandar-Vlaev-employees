import Foundation

struct WorkEntry: Equatable {
    let empId: String
    let projectId: String
    let dateFrom: Date
    let dateTo: Date
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.projectId == rhs.projectId && lhs.empId == rhs.empId && lhs.dateFrom == rhs.dateFrom && lhs.dateTo == rhs.dateTo
    }
    
    func calculateCollaborationPeriod(other: WorkEntry) -> Int {
        if self.dateFrom.compare(other.dateTo) == .orderedDescending || other.dateFrom.compare(self.dateTo) == .orderedDescending {
            return 0 // no overlap
        }
        let startDate = max(self.dateFrom, other.dateFrom)
        let endDate = min(self.dateTo, other.dateTo)
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}
