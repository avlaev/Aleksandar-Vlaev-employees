import Foundation

class EmployeesStatsPresenter {
    
    // MARK: Variables
    private weak var view: EmployeesStatsView?
    var guessDateFormat: Bool = true
 
    func viewDidLoad(view: EmployeesStatsView) {
        self.view = view
    }
    
    func onFilePicked(url: URL) {
        view?.setLoadingAnimationVisibility(true)
        Task.init {
            if let content = readInputFile(url) {
                let entries = parseContent(content)
                let result = calculateCollaborationStats(entries: entries)
                showResult(result)
            } else {
                showResult([])
            }
        }
    }
    
    private func showResult(_ result: [CollaborationResult]) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.displayCollaborationResult(result)
        }
    }
    
    private func calculateCollaborationStats(entries: [WorkEntry]) -> [CollaborationResult] {
        // Map between project ids and list with collaboration results. It is a list in cases when multiple pairs of employees have equal collaboration period
        var collaborationStats: [String: [CollaborationResult]] = [:]
        
        for entryA in entries {
            for entryB in entries {
                if entryA == entryB || entryA.projectId != entryB.projectId || entryA.empId == entryB.empId {
                    continue
                }
                let days = entryA.calculateCollaborationPeriod(other: entryB) // calculates the number of days during which the two employees worked on the project together
                if days > 0 {
                    var list: [CollaborationResult] = collaborationStats[entryA.projectId] ?? []
                    if let elem = list.first {
                        if elem.totalDaysOfCollaboration < days {
                            list.removeAll() // new longest collaboration is found
                        } else if elem.totalDaysOfCollaboration > days {
                            continue
                        }
                    }
                    let newItem = CollaborationResult(entryA: entryA, entryB: entryB, totalDaysOfCollaboration: days)
                    if !(list.contains(where: { res in
                        (res.entryA == newItem.entryA && res.entryB == newItem.entryB) ||
                        (res.entryA == newItem.entryB && res.entryB == newItem.entryA)
                    })) {
                        list.append(newItem)
                    }
                    
                    collaborationStats[entryA.projectId] = list
                }
            }
        }
        // Now collaborationStats holds a mapping between project ids and max colaboration results between employees. Next step is to sort the list so we get the pairs of employees with most collaboration days
        let sortedList = collaborationStats.values.sorted { resArray1, resArray2 in
            if let res1 = resArray1.first, let res2 = resArray2.first { // check first element is enough. If there are others they will have the same value for totalDaysOfCollaboration
                return res1.totalDaysOfCollaboration > res2.totalDaysOfCollaboration
            }
            return false
        }
        // Filter to leave only the top results
        let max = sortedList.first?.first?.totalDaysOfCollaboration
        let filteredList = sortedList.filter { list in
            if let elem = list.first {
                return max == elem.totalDaysOfCollaboration
            }
            return false
        }
        // Flatten the list and return to view
        var resultList: [CollaborationResult] = []
        filteredList.forEach { lst in
            resultList.append(contentsOf: lst)
        }
        return resultList
    }
    
    /*
        Parses and validates each entry in the CSV. Invalid entries are excluded from the result
     */
    private func parseContent(_ content: String) -> [WorkEntry] {
        var entries: [WorkEntry] = []
        
        let lines = content.components(separatedBy: "\n")
        for line in lines {
            let elems = line.components(separatedBy: ",")
            if elems.count == 4 {
                let empId = elems[0]
                let projId = elems[1]
                if let startDate = parseDate(elems[2]), let endDate = parseDate(elems[3]), !empId.isEmpty, !projId.isEmpty {
                    if startDate.compare(endDate) == .orderedDescending {
                        log("End date cannot be before start date for line \(line)")
                    } else {
                        entries.append(WorkEntry(empId: empId, projectId: projId, dateFrom: startDate, dateTo: endDate))
                    }
                } else {
                    log("Invalid entry data for line \(line)")
                }
            } else {
                log("Invalid entry format for line \(line)")
            }
            
        }
        
        return entries
    }
    
    private func parseDate(_ str: String) -> Date? {
        if str.lowercased() == "null" {
            return Date()
        }
        if guessDateFormat {
            return findDate(dateString: str)
        }
        return dateFrom(str: str)
    }
    
    private func dateFrom(str: String) -> Date? {
        let dateFormatter = DateFormatter()
        
        // Put all supported formats here
        let formats = ["yyyy-MM-dd", "yyyy-MM-dd HH:mm:ss", "dd.MM.yyyy"]
        
        for format in formats {
            dateFormatter.dateFormat = format
            if let date = dateFormatter.date(from: str) {
                return date
            }
        }
        
        return nil
    }
    
    private func findDate(dateString: String) -> Date? {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
            let matches = detector.matches(in: dateString, options: [], range: NSRange(location: 0, length: dateString.utf16.count))
            
            if let match = matches.first, let date = match.date {
                return date
            }
        } catch {
            print("Error creating NSDataDetector: \(error)")
        }
        
        return nil // Failed to parse
    }
    
    private func readInputFile(_ url: URL) -> String? {
        do {
            let data = try Data(contentsOf: url)
            if let string = String(data: data, encoding: .utf8) {
                return string
            }
        } catch {
            log("Error while reading file: \(error)")
        }
        return nil
    }
    
    private func log(_ msg: String) {
        print("[EmployeesStats] \(msg)")
    }
}

protocol EmployeesStatsView: AnyObject {
    func setLoadingAnimationVisibility(_ visible: Bool)
    func displayCollaborationResult(_ result: [CollaborationResult])
}
