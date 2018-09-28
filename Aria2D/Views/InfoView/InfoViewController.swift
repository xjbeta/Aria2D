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
    
    var objectNotificationToken: NotificationToken? = nil
    var fileNotificationToken: NotificationToken? = nil
    
	var gid = "" {
		didSet {
            initRealmObject()
		}
	}
    
    enum updateBlock {
        case name, size, status, files, announces
    }
    
   
    
    func initRealmObject() {
        objectNotificationToken?.invalidate()
        fileNotificationToken?.invalidate()
        
        Aria2.shared.getServers(gid) {}
        Aria2.shared.getUris(gid) {}
        
        
        if let obj = DataManager.shared.aria2Object(gid: gid) {
            
            self.updateSegmentedControl(obj.bittorrent != nil)
            
            
            update(obj, block: .name)
            update(obj, block: .size)
            update(obj, block: .status)
            update(obj, block: .announces)
            
            fileNotificationToken = obj.files.observe { objectChange in
                var reloadFileNodes = true
                switch objectChange {
                case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                    Log("deletions\(deletions), insertions\(insertions), modifications\(modifications)")
                    
                    if deletions.count == 0, insertions.count == 0 {
                        reloadFileNodes = false
                        self.updateFileNodes(modifications, ThreadSafeReference(to: obj))
                    }
                default:
                    break
                }
                
                
                if reloadFileNodes {
                    self.initFileNodes(ThreadSafeReference(to: obj))
                }
            }
            
            objectNotificationToken = obj.observe { objectChange in
                switch objectChange {
                case .change(let properties):
                    let propertieKeys = properties.filter {
                        String(describing: $0.newValue) != String(describing: $0.oldValue)
                        }.compactMap {
                            Aria2Object.CodingKeys(rawValue: $0.name)
                    }
                    
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
                    
                    // Update error in statusList
                    if let errorCode = statusProperties.filter({
                        $0.name == StatusObjectKey.errorCode.rawValue
                    }).first {
                        self.statusList.initErrorKeys("\(errorCode.newValue as? Int ?? 0)")
                    }
                    
                    // Update objects in statusList
                    statusProperties.forEach {
                        if let key = StatusObjectKey(rawValue: $0.name),
//                            "\($0.newValue)" != "\($0.oldValue)",
                            let value = $0.newValue {
                            self.statusList.update(key, newValue: value, in: self.statusTableView)
                        }
                    }
                    
                    if !propertieKeys.contains(.files) {
                        if let str = self.tabView.selectedTabViewItem?.label,
                            str == "Files" {
                            Log("getFiles")
                            Aria2.shared.getFiles(self.gid)
                        }
                    }
                case .deleted:
                    self.view.window?.close()
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
                self.announces = obj.bittorrent?.announceList.map { $0 }
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
    var segmentedControlLabels = [NSLocalizedString("infoViewController.segmentedControl.0", comment: ""),
                                  NSLocalizedString("infoViewController.segmentedControl.1", comment: ""),
                                  NSLocalizedString("infoViewController.segmentedControl.2", comment: ""),
                                  NSLocalizedString("infoViewController.segmentedControl.3", comment: ""),
                                  NSLocalizedString("infoViewController.segmentedControl.4", comment: "")]
    
    
    func updateSegmentedControl(_ isBittorrent: Bool) {
        func initSegmentedControl() {
            self.segmentedControl.segmentCount = 3
            self.segmentedControl.setLabel(segmentedControlLabels[0], forSegment: 0)
            self.segmentedControl.setLabel(segmentedControlLabels[1], forSegment: 1)
            self.segmentedControl.setLabel(segmentedControlLabels[2], forSegment: 2)
            
            if isBittorrent {
                self.segmentedControl.segmentCount = 5
                self.segmentedControl.setLabel(segmentedControlLabels[3], forSegment: 3)
                self.segmentedControl.setLabel(segmentedControlLabels[4], forSegment: 4)
            }
        }
        
        DispatchQueue.main.async {
            if isBittorrent {
                guard self.segmentedControl.segmentCount == 3 else {
                    initSegmentedControl()
                    return
                }
                self.segmentedControl.segmentCount = 5
                self.segmentedControl.setLabel(self.segmentedControlLabels[3], forSegment: 3)
                self.segmentedControl.setLabel(self.segmentedControlLabels[4], forSegment: 4)
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
            !key.isGroup,
            !exceptKeys.contains(key.option) {
            performSegue(withIdentifier: .showChangeOptionView, sender: self)
        }
    }
    var options: [Aria2Option: String] = [:] {
        didSet {
            optionKeys = []
            Array(Set(options.keys.map { $0.preferencesType }))
                .sorted(by: { $0.rawValue < $1.rawValue })
                .forEach { type in
                    // Group Item
                    optionKeys.append((isGroup: true,
                                   option: Aria2Option("", valueType: .boolType, type: type)))
                    // Options for this group
                    let keys = options.keys.filter {
                        $0.preferencesType == type
                    }.sorted(by: { $0.rawValue < $1.rawValue })
                        .map { option -> (isGroup: Bool, option: Aria2Option) in
                            return (isGroup: false, option: option)
                    }
                    optionKeys.append(contentsOf: keys)
            }
            
            DispatchQueue.main.async {
                self.optionsTableView.reloadData()
            }
        }
    }
    
    private var optionKeys: [(isGroup: Bool, option: Aria2Option)] = []
    
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
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == .showChangeOptionView {
            if let tableviewSegue = segue as? NSTableViewPopoverSegue,
                let vc = segue.destinationController as? ChangeOptionViewController {
                tableviewSegue.anchorTableView = optionsTableView
                tableviewSegue.preferredEdge = .minX
                tableviewSegue.popoverBehavior = .transient
                
                if let option = optionKeys[safe: optionsTableView.selectedRow] {
                    vc.optionValue = options[option.option] ?? ""
                    vc.option = option.option
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
        fileNotificationToken?.invalidate()
        objectNotificationToken?.invalidate()
    }
    
}
extension InfoViewController: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        updateTabView()
    }
    
    func updateTabView() {
        switch tabView.selectedTabViewItem?.label ?? "" {
        case "Status":
            break
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
        switch tableView {
        case statusTableView:
            return statusList.count
        case optionsTableView:
            return optionKeys.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        switch tableView {
        case statusTableView:
            if statusList[row].key == .errorMessage {
                let textFiled = NSTextFieldCell()
                textFiled.font = NSFont.systemFont(ofSize: 14)
                textFiled.stringValue = statusList[row].value
                
                let width = (tableView.bounds.size.width - 16 - tableView.intercellSpacing.width) * 16/25
                let height = textFiled.cellSize(forBounds: NSRect(x: 0, y: 0, width: width, height: 400)).height
                
                return height < statusList[row].height ? statusList[row].height : height
            }
            return statusList[row].height
        case optionsTableView:
            return tableView.rowHeight
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        switch tableView {
        case statusTableView:
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
        case optionsTableView:
            switch tableColumn?.title {
            case "value":
                if let view = optionsTableView.makeView(withIdentifier: .optionTableViewValue, owner: nil) as? NSTableCellView, let key = optionKeys[safe: row] {
                    view.textField?.stringValue = options[key.option] ?? ""
                    return view
                }
            default:
                if let view = optionsTableView.makeView(withIdentifier: .optionTableViewOption, owner: nil) as? NSTableCellView, let key = optionKeys[safe: row] {
                    if key.isGroup {
                        view.textField?.stringValue = key.option.preferencesType.raw()
                    } else {
                        view.textField?.stringValue = key.option.rawValue
                    }
                    return view
                }
            }
        default:
            break
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
        switch tableView {
        case optionsTableView:
            return optionKeys[row].isGroup
        default:
            return false
        }
    }
    
}

extension InfoViewController: NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    func initFileNodes(_ objRef: ThreadSafeReference<Aria2Object>) {
        
        DispatchQueue.global(qos: .background).async {

            do {
                let realm = try Realm()
                
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
                self.updateStatus(for: groupChildrens)
            } catch let error as NSError {
                fatalError("Error opening realm: \(error)")
            }
        }
    }
    
    func updateFileNodes(_ list: [Int], _ objRef: ThreadSafeReference<Aria2Object>) {
        
        DispatchQueue.global(qos: .background).async {
            do {
                let realm = try Realm()
                guard let obj = realm.resolve(objRef), self.fileNodes != nil else {
                    return
                }
                
                let rootPathComponents = self.fileNodes!.path.pathComponents
                var groupChildrens: [FileNode] = []
                var shouldUpdateSelected = false
                
                obj.files.filter {
                    list.contains($0.index - 1)
                    }.map { Aria2File(value: $0) }.forEach { file in
                        Log(file.path)
                        var pathComponents = file.path.pathComponents
                        
                        guard var currentNode = self.fileNodes else { return }
                        
                        if file.path.isChildPath(of: currentNode.path) {
                            pathComponents.removeSubrange(0 ..< rootPathComponents.count)
                        }
                        
                        while !pathComponents.isEmpty {
                            guard let title = pathComponents.first, let node = currentNode.getChild(title) else {
                                pathComponents.removeAll()
                                return
                            }
                            pathComponents.removeFirst()
                            currentNode = node
                            if pathComponents.count != 1 {
                                groupChildrens.append(node)
                            }
                            if currentNode.isLeaf {
                                let new = FileNode(currentNode.path, file: file, isLeaf: true)
                                if new.selected != currentNode.selected {
                                    shouldUpdateSelected = true
                                }
                                DispatchQueue.main.async {
                                    currentNode.updateData(file)
                                }
                            }
                        }
                }
                if shouldUpdateSelected {
                    self.updateStatus(for: groupChildrens)
                }
            } catch let error as NSError {
                fatalError("Error opening realm: \(error)")
            }
        }
    }
    
    func updateStatus(for nodes: [FileNode]) {
        // update node state
        guard let rootPathComponents = fileNodes?.path.pathComponents else { return }
        var count = nodes.map({$0.path.pathComponents.count}).max() ?? 0
        while count > rootPathComponents.count {
            nodes.filter {
                $0.path.pathComponents.count == count
                }.forEach { child in
                    DispatchQueue.main.async {
                        child.updateStateWithChildren()
                    }
            }
            count -= 1
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
    case errorCode = "errorCode"
    case errorMessage = "errorMessage"
    case none = ""
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
        case .none:
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
        if var contents = [StatusObject(.gid, value: obj.gid),
//                           StatusObject(.bitfield, value: obj.bitfield),
                           StatusObject(.status, value: obj.status.string()),
                           StatusObject(.connections, value: "\(obj.connections)"),
                           StatusObject(.numPieces, value: obj.numPieces),
                           StatusObject(.pieceLength, value: obj.pieceLength.ByteFileFormatter()),
                           StatusObject(.space, value: ""),
                           StatusObject(.totalLength, value: obj.totalLength.ByteFileFormatter()),
                           StatusObject(.completedLength, value: obj.completedLength.ByteFileFormatter()),
                           StatusObject(.uploadLength, value: obj.uploadLength.ByteFileFormatter())] as? Array<Element> {
            if obj.errorCode != 0 {
                contents.append(contentsOf: [
                    StatusObject(.space, value: ""),
                    StatusObject(.errorCode, value: "\(obj.errorCode)"),
                    StatusObject(.errorMessage, value: obj.errorMessage)] as? Array<Element> ?? [])
            }
            self = contents
        }
    }
    
    func update(_ key: StatusObjectKey, newValue: Any, in tableView: NSTableView) {
        
        var value: String?
        
        switch key {
        case .gid, .dir, .bitfield, .numPieces, .errorMessage:
            value = newValue as? String
        case .connections, .errorCode:
            value = "\(newValue as? Int ?? 0)"
        case .status:
            if let i = newValue as? Int {
                value = Status(rawValue: i)?.string()
            }
        case .pieceLength, .totalLength, .completedLength, .uploadLength:
            value = (newValue as? Int64)?.ByteFileFormatter()
//            case .errorMessage, .errorCode
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
    
    mutating func initErrorKeys(_ errorCode: String) {
        let errors: [StatusObjectKey] = [.space, .errorCode, .errorMessage]
        if errorCode == "0" {
            while errors.contains(self.last?.key ?? .none) {
                self.removeLast()
            }
        } else {
            if !self.map({ $0.key }).contains(where: errors.contains) {
                self.append(contentsOf: [
                    StatusObject(.space, value: ""),
                    StatusObject(.errorCode, value: ""),
                    StatusObject(.errorMessage, value: "")] as? Array<Element> ?? [])
            }
        }
    }
}
