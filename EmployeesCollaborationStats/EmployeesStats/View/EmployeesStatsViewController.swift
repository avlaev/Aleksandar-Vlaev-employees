import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class EmployeesStatsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet private weak var pickFileButton: UIButton!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var loadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var switchView: UISwitch!
    
    // MARK: Variables
    private var presenter = EmployeesStatsPresenter()
    private var result: [CollaborationResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        
        setLoadingAnimationVisibility(false)
        pickFileButton.addTarget(self, action: #selector(onPickFile), for: .touchUpInside)
        presenter.viewDidLoad(view: self)
        
        switchView.addTarget(self, action: #selector(onDateDetectionChange), for: .valueChanged)
    }
    
    @objc private func onDateDetectionChange() {
        presenter.guessDateFormat = switchView.isOn
        result.removeAll()
        tableView.reloadData()
    }
    
    @objc private func onPickFile() {
        let types = UTType.types(tag: "csv", tagClass: .filenameExtension, conformingTo: nil)
        let documentPickerController = UIDocumentPickerViewController(
                forOpeningContentTypes: types)
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }

    private func setupTableView() {
        tableView.register(UINib(nibName: CollaborationResultCell.kCellId, bundle: nil), forCellReuseIdentifier: CollaborationResultCell.kCellId)
        tableView.dataSource = self
        tableView.layoutMargins = .zero
        tableView.contentOffset = .zero
        tableView.contentInset = .zero
    }
}

extension EmployeesStatsViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let csvDocUrl = urls.first else {
            return
        }
        presenter.onFilePicked(url: csvDocUrl)
    }
    
}

extension EmployeesStatsViewController: EmployeesStatsView {
    
    func setLoadingAnimationVisibility(_ visible: Bool) {
        loadingActivityIndicatorView.isHidden = !visible
        if visible {
            loadingActivityIndicatorView.startAnimating()
        } else {
            loadingActivityIndicatorView.stopAnimating()
        }
    }
    
    func displayCollaborationResult(_ result: [CollaborationResult]) {
        self.result = result
        setLoadingAnimationVisibility(false)
        self.tableView.reloadData()
    }
}

extension EmployeesStatsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CollaborationResultCell.kCellId) as? CollaborationResultCell {
            let item = result[indexPath.row]
            cell.setup(item)
            return cell
        }
        return UITableViewCell()
    }
    
}


