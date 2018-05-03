//
//  InfoViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/8/6.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa
import RealmSwift

class InfoViewController: NSViewController {

	@IBAction func cancelButton(_ sender: Any) {
		view.window?.close()
	}
    
	@IBAction func okButton(_ sender: Any) {

        Aria2.shared.getFiles(gid) {
            if let obj = DataManager.shared.aria2Object(gid: self.gid) {
                let oldValue = obj.files.filter {
                    $0.selected
                    }.map {
                        $0.index
                }.sorted()
                var newValue: [Int] = []
                func addSelectedIndex(_ nodes: [FileNode]) {
                    nodes.forEach {
                        if $0.isLeaf {
                            if $0.selected {
                                newValue.append($0.index)
                            }
                        } else {
                            addSelectedIndex($0.children)
                        }
                    }
                }
                addSelectedIndex(self.fileNodes?.children ?? [])
                newValue = newValue.sorted()
                
                if newValue != oldValue, newValue.count > 0 {
                    let value = newValue.map {
                        "\($0)"
                        }.joined(separator: ",")

                    Aria2.shared.changeOption(self.gid,
                                              key: Aria2Option.selectFile.rawValue,
                                              value: value) { _ in }
                }
            }
            DispatchQueue.main.async {
                self.fileNodes = nil
                self.view.window?.close()
            }
        }
	}
    
	var notificationToken: NotificationToken? = nil
    var getFilesCounter = 0
    
//    let object = Aria2Object
    
	var gid = "" {
		didSet {
            initRealmObject()
		}
	}
    
    enum updateBlock {
        case name, size, status, files, announces
    }
    
    var notificationTT: NotificationToken? = nil
    
    func initRealmObject() {
        notificationToken?.invalidate()
        
        Aria2.shared.getServers(gid) {}
        Aria2.shared.getUris(gid) {}
        
        
        if let obj = DataManager.shared.aria2Object(gid: gid) {
            
            self.updateSegmentedControl(obj.bittorrent != nil)
            
            
            update(obj, block: .name)
            update(obj, block: .size)
            update(obj, block: .status)
            update(obj, block: .announces)
            
            notificationTT = obj._files.observe { _ in
                self.updateFilesOutlineView(ThreadSafeReference(to: obj))
            }
            
            notificationToken = obj.observe { objectChange in
                switch objectChange {
                case .change(let properties):
                    let propertieKeys = properties.compactMap({ Aria2Object.CodingKeys(rawValue: $0.name) })
                    
                    if propertieKeys.contains(where: [.status, .downloadSpeed, .uploadSpeed, .bittorrent].contains) {
                        switch obj.status {
                        case .active:
                            self.downloadSpeedTextField.stringValue = "⬇︎ \(obj.downloadSpeed.ByteFileFormatter())/s"
                            self.uploadSpeedTextField.stringValue = obj.bittorrent == nil ? "" : "⬆︎ \(obj.uploadSpeed.ByteFileFormatter())/s"
                        case .complete, .waiting, .paused, .error, .removed:
                            self.downloadSpeedTextField.stringValue = obj.status.string()
                            self.uploadSpeedTextField.stringValue = ""
                        }
                    }
                    
                    if propertieKeys.contains(where: [.completedLength, .totalLength].contains) {
                        self.fileSizeTextField.stringValue = "\(obj.completedLength.ByteFileFormatter()) / \(obj.totalLength.ByteFileFormatter())"
                    }
                    
                    
                    let statusProperties = properties.filter {
                        if let i = StatusObjectKey(rawValue: $0.name), self.statusList.map({ $0.key }).contains(i) {
                            return true
                        } else {
                            return false
                        }
                    }
                    statusProperties.forEach {
                        if let key = StatusObjectKey(rawValue: $0.name),
//                            "\($0.newValue)" != "\($0.oldValue)",
                            let value = $0.newValue {
                            self.statusList.update(key, newValue: value, in: self.statusTableView)
                        }
                    }

                    self.getFilesCounter += 1
                    if self.getFilesCounter == 3 {
                        if let str = self.tabView.selectedTabViewItem?.label,
                            str != "Status" {
                            self.updateTabView(with: str)
                        }
                        self.getFilesCounter = 0
                    }
                default:
                    break
                }
            }
        }
        
        
        
    }
    
    func update(_ obj: Aria2Object, block: updateBlock) {
        switch block {
        case .name:
            guard nameTextField != nil else { return }
            if obj.nameString() != nameTextField.stringValue {
                let image = obj.fileIcon()
                image.size = NSSize(width: 75, height: 75)
                DispatchQueue.main.async {
                    self.iconImageView.image = image
                    self.nameTextField.stringValue = obj.nameString()
                }
            }
        case .size:
            DispatchQueue.main.async {
                self.fileSizeTextField.stringValue = "\(obj.completedLength.ByteFileFormatter()) / \(obj.totalLength.ByteFileFormatter())"
                switch obj.status {
                case .active:
                    self.downloadSpeedTextField.stringValue = "⬇︎ \(obj.downloadSpeed.ByteFileFormatter())/s"
                    self.uploadSpeedTextField.stringValue = obj.bittorrent == nil ? "" : "⬆︎ \(obj.uploadSpeed.ByteFileFormatter())/s"
                case .complete, .waiting, .paused, .error, .removed:
                    self.downloadSpeedTextField.stringValue = obj.status.string()
                    self.uploadSpeedTextField.stringValue = ""
                }
            }
        case .status:
            if statusList.count == 0 {
                statusList.initial(obj)
            }
            DispatchQueue.main.async {
                self.statusTableView.reloadData()
            }
        case .files:
            break
//            updateFilesOutlineView()
        case .announces:
            DispatchQueue.main.async {
                self.announces = obj.bittorrent?.announceList
            }
        }
    }
    
    
    
    @IBOutlet weak var tabView: NSTabView!
    
	@IBOutlet var iconImageView: NSImageView!
	@IBOutlet var nameTextField: NSTextField!
	@IBOutlet var fileSizeTextField: NSTextField!
	@IBOutlet var downloadSpeedTextField: NSTextField!
	@IBOutlet var uploadSpeedTextField: NSTextField!
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    var segmentedControlLabels = ["Status", "Options", "Files", "Peer", "Announces"]
    
    
    func updateSegmentedControl(_ isBittorrent: Bool) {
        func initSegmentedControl() {
            self.segmentedControl.segmentCount = 3
            self.segmentedControl.setLabel("Status", forSegment: 0)
            self.segmentedControl.setLabel("Options", forSegment: 1)
            self.segmentedControl.setLabel("Files", forSegment: 2)
            
            if isBittorrent {
                self.segmentedControl.segmentCount = 5
                self.segmentedControl.setLabel("Peer", forSegment: 3)
                self.segmentedControl.setLabel("Announces", forSegment: 4)
            }
        }
        
        DispatchQueue.main.async {
            if isBittorrent {
                guard self.segmentedControl.segmentCount == 3 else {
                    initSegmentedControl()
                    return
                }
                self.segmentedControl.segmentCount = 5
                self.segmentedControl.setLabel("Peer", forSegment: 3)
                self.segmentedControl.setLabel("Announces", forSegment: 4)
            } else {
                guard self.segmentedControl.segmentCount == 5 else {
                    initSegmentedControl()
                    return
                }
                self.segmentedControl.segmentCount = 3
            }
        }
    }
    
    
    
//MARK: - Status Item
    
    @IBOutlet weak var statusTableView: NSTableView!
    var statusBitfieldTableCellView: StatusBitfieldTableCellView?
    var statusList: [StatusObject] = []

    enum statusListStatus {
        case initial, update
    }
    

    
    
//MARK: - Options Item
    
    @IBOutlet weak var optionsTableView: NSTableView!
    @IBAction func changeOption(_ sender: Any) {
        if let key = optionKeys[safe: optionsTableView.selectedRow],
            !exceptKeys.contains(key) {
            performSegue(withIdentifier: .showChangeOptionView, sender: self)
        }
    }
    var options: [Aria2Option: String] = [:] {
        didSet {
            optionKeys = options.keys.sorted(by: { $0.rawValue < $1.rawValue })
            DispatchQueue.main.async {
                self.optionsTableView.reloadData()
            }
        }
    }
    
    private var optionKeys: [Aria2Option] = []
    
    let exceptKeys: [Aria2Option] = [.dryRun,
                                     .metalinkBaseUri,
                                     .parameterizedUri,
                                     .pause,
                                     .pieceLength,
                                     .rpcSaveUploadMetadata]
    
//MARK: - Files Item
    
    @IBOutlet weak var filesOutlineView: NSOutlineView!
    
    @objc dynamic var fileNodes: FileNode?

//MARK: - Peer Item
    
    @objc dynamic var peerObjects: [Aria2Peer]?
    
//MARK: - Announces Item
    @objc dynamic var announces: [String]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBitfieldTableCellView = statusTableView.makeView(withIdentifier: .statusBitfieldTableCellView, owner: self) as? StatusBitfieldTableCellView
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        notificationToken?.invalidate()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == .showChangeOptionView {
            if let tableviewSegue = segue as? NSTableViewPopoverSegue,
                let vc = segue.destinationController as? ChangeOptionViewController {
                tableviewSegue.anchorTableView = optionsTableView
                tableviewSegue.preferredEdge = .minX
                tableviewSegue.popoverBehavior = .transient
                
                if let option = optionKeys[safe: optionsTableView.selectedRow] {
                    vc.optionValue = options[option] ?? ""
                    vc.option = option
                    vc.gid = self.gid
                    vc.changeComplete = {
                        Aria2.shared.getOption(self.gid) {
                            self.options = $0
                        }
                        Aria2.shared.updateStatus([self.gid])
                    }
                }
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
}
extension InfoViewController: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, willSelect tabViewItem: NSTabViewItem?) {
        if let str = tabViewItem?.label {
            updateTabView(with: str)
        }
    }
    
    func updateTabView(with title: String) {
        switch title {
        case "Status":
            break
//            update(block: .status)
        case "Options":
            Aria2.shared.getOption(gid) {
                self.options = $0
            }
        case "Files":
            Aria2.shared.getFiles(gid)
        case "Peer":
            guard DataManager.shared.aria2Object(gid: gid)?.status == .active else { return }
            Aria2.shared.getPeer(gid) { objs in
                DispatchQueue.main.async {
                    self.peerObjects = objs
                }
            }
        default:
            break
        }
    }
    
}

extension InfoViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == statusTableView {
            return statusList.count
        } else if tableView == optionsTableView {
            return optionKeys.count
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        if tableView == statusTableView {
            return statusList[row].height
        } else {
            return tableView.rowHeight
        }
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let title = tableColumn?.title {
            if tableView == optionsTableView {
                switch title {
                case "option":
                    return optionKeys[safe: row]?.rawValue
                case "value":
                    if let key = optionKeys[safe: row] {
                        return options[key]
                    }
                default:
                    break
                }
            }
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == statusTableView {
            switch statusList[row].key {
            case .space:
                if let view = statusTableView.makeView(withIdentifier: .statusSpaceTableCellView, owner: self) {
                    return view
                }
                
            case .bitfield:
                if let view = statusBitfieldTableCellView {
                    view.bitfield = statusList[row].value
                    return view
                }
            default:
                if let view = statusTableView.makeView(withIdentifier: .statusDicTableCellView, owner: self) as? StatusDicTableCellView {
                    view.keyTextField.stringValue = statusList[row].key.rawValue
                    view.valueTextField.stringValue = statusList[row].value
                    return view
                }
            }
        }
        return nil
    }
    
}

extension InfoViewController: NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    func updateFilesOutlineView(_ objRef: ThreadSafeReference<Aria2Object>) {
        
        DispatchQueue.global(qos: .background).async {

            let realmConfiguration = Realm.Configuration(inMemoryIdentifier: "InMemoryRealm")
            let realm = try! Realm(configuration: realmConfiguration)
            
            guard let obj = realm.resolve(objRef) else {
                return
            }
            
            if self.fileNodes == nil {
                self.fileNodes = FileNode(obj.dir, isLeaf: false)
            }
            
            let rootPathComponents = self.fileNodes!.path.pathComponents
            var groupChildrens: [FileNode] = []
            
            let filesSemaphore = DispatchSemaphore(value: 1)
            
            obj.files.map { Aria2File(value: $0) }.forEach { file in
                filesSemaphore.wait()
                guard file.path != "" else {
                    filesSemaphore.signal()
                    return
                }
                
                var pathComponents = file.path.pathComponents
                
                guard var currentNode = self.fileNodes else { return }
                
                if file.path.isChildPath(of: currentNode.path) {
                    pathComponents.removeSubrange(0 ..< rootPathComponents.count)
                }
                
                let semaphore = DispatchSemaphore(value: 1)
                
                pathComponents.forEach { _ in
                    semaphore.wait()
                    let str = pathComponents.first!
                    let group = DispatchGroup()
                    var child = currentNode.getChild(str)
                    group.enter()
                    if child == nil {
                        var path = currentNode.path
                        path.appendingPathComponent(str)
                        
                        let node = pathComponents.count != 1 ? FileNode(path, isLeaf: false) : FileNode(path, file: file, isLeaf: true)
                        
                        DispatchQueue.main.async {
                            currentNode.children.append(node)
                            if pathComponents.count != 1 {
                                groupChildrens.append(node)
                            }
                            child = currentNode.getChild(str)
                            group.leave()
                        }
                    } else if let child = child, child.isLeaf {
                        DispatchQueue.main.async {
                            child.updateData(file)
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                    
                    group.notify(queue: .global(qos: .background)) {
                        if let child = child {
                            currentNode = child
                        }
                        pathComponents.removeFirst()
                        semaphore.signal()
                        if pathComponents.count == 0 {
                            filesSemaphore.signal()
                        }
                    }
                }
            }
            
            
            // update node state
            var count = groupChildrens.map({$0.path.pathComponents.count}).max() ?? 0
            while count > rootPathComponents.count {
                groupChildrens.filter {
                    $0.path.pathComponents.count == count
                    }.forEach { child in
                        DispatchQueue.main.async {
                            child.updateStateWithChildren()
                        }
                }
                count -= 1
            }
        }
        
        
        

    }
    
    func outlineView(_ outlineView: NSOutlineView, dataCellFor tableColumn: NSTableColumn?, item: Any) -> NSCell? {
        if tableColumn?.title == "Name",
            let node = (item as? NSTreeNode)?.representedObject as? FileNode {
            let cell = NSButtonCell()
            cell.setButtonType(.switch)
            cell.allowsMixedState = !(node.children.count == 0)
            cell.title = node.title
            return cell
        }
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
        func updateState(_ tnode: NSTreeNode, state: NSControl.StateValue) {
            let fileNode = tnode.representedObject as? FileNode
            fileNode?.state = state
            if !tnode.isLeaf {
                tnode.children?.forEach {
                    updateState($0, state: state)
                }
            }
        }
        if let node = (item as? NSTreeNode)?.representedObject as? FileNode {
            if !node.isLeaf {
                let newState: NSControl.StateValue = ((object as? Int) ?? 0) == 0 ? .off : .on
                updateState(item as! NSTreeNode, state: newState)
            }
            
            var parentNode = (item as? NSTreeNode)?.parent
            while parentNode != nil {
                (parentNode?.representedObject as? FileNode)?.updateStateWithChildren()
                parentNode = parentNode?.parent
            }
        }
    }
    
}

@objc(FileNode)
class FileNode: NSObject {
    @objc dynamic let path: String
    let index: Int
    
    @objc dynamic let size: String
    @objc dynamic var progress: String
    @objc dynamic var selected: Bool
    
    @objc dynamic var title: String {
        get {
            return path.lastPathComponent
        }
    }
    
    @objc dynamic var state: NSControl.StateValue {
        didSet {
            if isLeaf {
                selected = state == .on
            }
        }
    }
    
    @objc dynamic var children: [FileNode] = []
    
    init(_ path: String, file: Aria2File? = nil, isLeaf: Bool) {
        self.path = path
        if isLeaf, let file = file {
            self.size = file.length.ByteFileFormatter()
            self.progress = file.completedLength == 0 ? "0%" : (Double(file.completedLength) / Double(file.length) * 100).percentageFormat()
            self.index = file.index
            self.state = file.selected ? .on : .off
            self.selected = file.selected
        } else {
            self.size = ""
            self.progress = ""
            self.index = -1
            self.state = .off
            self.selected = false
        }
    }
    
    func updateData(_ file: Aria2File) {
        guard file.index == index else { return }
        self.progress = file.completedLength == 0 ? "0%" : (Double(file.completedLength) / Double(file.length) * 100).percentageFormat()
    }
    
    
    @objc dynamic var isLeaf: Bool {
        get {
            return children.isEmpty
        }
    }
    
    
    func getChild(_ title: String) -> FileNode? {
        return children.filter {
            $0.title == title
            }.first
    }
    
    func updateStateWithChildren() {
        switch (children.filter({ $0.state == .on }).count,
                children.filter({ $0.state == .off }).count) {
        case (0, children.count):
            state = .off
        case (children.count, 0):
            state = .on
        default:
            state = .mixed
        }
    }
}

enum StatusObjectKey: String {
    case gid = "gid"
    case status = "status"
    case connections = "connections"
    case numPieces = "numPieces"
    case pieceLength = "pieceLength"
    case space = "space"
    case totalLength = "totalLength"
    case completedLength = "completedLength"
    case uploadLength = "uploadLength"
    case dir = "dir"
    case bitfield = "bitfield"
    case error = ""
    //        init?(raw: String) {
    //            self.init(rawValue: raw)
    //        }
}

class StatusObject {
    var key: StatusObjectKey
    var value = ""
    init(_ key: StatusObjectKey, value: String) {
        self.key = key
        self.value = value
    }
    
    var height: CGFloat {
        switch key {
        case .bitfield:
            //                let lineCount = 3
            //                return CGFloat(lineCount * (12 + 3) - 3 < 23 ? 23 : lineCount * (12 + 3) - 3)
            return 42
        case .space:
            return 10
        case .error:
            return 0
        default:
            return 21
        }
    }
    
    func update(_ value: String) {
        self.value = value
    }
}



extension Array where Element: StatusObject {
    mutating func initial(_ obj: Aria2Object) {
        self.removeAll()
        if let contents = [StatusObject(.gid, value: obj.gid),
//                           StatusObject(.bitfield, value: obj.bitfield),
                           StatusObject(.status, value: obj.status.string()),
                           StatusObject(.connections, value: "\(obj.connections)"),
                           StatusObject(.numPieces, value: obj.numPieces),
                           StatusObject(.pieceLength, value: obj.pieceLength.ByteFileFormatter()),
                           StatusObject(.space, value: ""),
                           StatusObject(.totalLength, value: obj.totalLength.ByteFileFormatter()),
                           StatusObject(.completedLength, value: obj.completedLength.ByteFileFormatter()),
                           StatusObject(.uploadLength, value: obj.uploadLength.ByteFileFormatter()),
                           StatusObject(.dir, value: obj.dir)] as? Array<Element> {
            self = contents
        }
    }
    
    func update(_ key: StatusObjectKey, newValue: Any, in tableView: NSTableView) {
        
        var value: String?
        
        switch key {
        case .gid, .dir, .bitfield, .numPieces:
            value = newValue as? String
        case .connections:
            value = "\(newValue as? Int ?? 0)"
        case .status:
            if let i = newValue as? Int {
                value = Status(rawValue: i)?.string()
            }
        case .pieceLength, .totalLength, .completedLength, .uploadLength:
            value = (newValue as? Int64)?.ByteFileFormatter()
            //                case .error:
        //                    break
        default:
            break
        }
        if let index = self.index(where: { $0.key == key }) {
            self[index].value = value ?? ""
            tableView.beginUpdates()
            tableView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: IndexSet([0]))
            tableView.endUpdates()
        }
    }
}
