import Foundation
import UIKit

class CollaborationResultCell: UITableViewCell {
    
    // MARK: Constants
    static let kCellId = "CollaborationResultCell"
    
    // MARK: Outlets
    @IBOutlet private weak var employeeLabel2: UILabel!
    @IBOutlet private weak var employeeLabel1: UILabel!
    @IBOutlet private weak var daysOfWorkLabel: UILabel!
    @IBOutlet private weak var projectIdLabel: UILabel!
    
    func setup(_ result: CollaborationResult) {
        employeeLabel1.text = result.entryA.empId
        employeeLabel2.text = result.entryB.empId
        projectIdLabel.text = result.entryA.projectId
        daysOfWorkLabel.text = "\(result.totalDaysOfCollaboration)"
        
        self.selectionStyle = .none
        self.separatorInset = .zero
    }
    
}
