//
//  InfoViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/8/6.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class InfoViewController: NSViewController {

    @IBOutlet var objectController: NSObjectController!
    
	@IBAction func cancelButton(_ sender: Any) {
        fileEditingMode = false
		view.window?.close()
	}
    
    @IBAction func okButton(_ sender: Any) {
        Task {
            defer {
                fileNodes = nil
                fileEditingMode = false
                view.window?.close()
            }
            
            do {
                try await Aria2.shared.getFiles(gid)
                guard let files = aria2Object?.files as? [Aria2File] else { return }
                let oldValue = files.filter {
                    $0.selected
                }.map {
                    Int($0.index)
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
                addSelectedIndex(fileNodes?.children ?? [])
                newValue = newValue.sorted()
                
                if newValue != oldValue, newValue.count > 0 {
                    let value = newValue.map {
                        "\($0)"
                    }.joined(separator: ",")
                    
                    try await Aria2.shared.changeOption(gid,
                                                        key: Aria2Option.selectFile.rawValue,
                                                        value: value)
                }
            } catch {
                Log("Info ok action, failed")
            }
        }
    }
    
	var gid = "" {
		didSet {
            do {
                aria2Object = try DataManager.shared.aria2Object(gid, deep: true)
                
                updateSegmentedControl(aria2Object?.bittorrent != nil)
                
                Task {
                    try? await Aria2.shared.getServers(gid)
                    try? await Aria2.shared.getUris(gid)
                    
                    await DataManager.shared.addObserver(self, forTable: .aria2File)
                    await DataManager.shared.addObserver(self, forTable: .aria2Object)
                }
            } catch {
                Log(error)
            }
		}
	}
    
    
    @objc dynamic var aria2Object: Aria2Object?
    
    enum updateBlock {
        case name, size, status, files, announces
    }
    
    @IBOutlet weak var tabView: NSTabView!
    @IBOutlet weak var segmentedControl: NSSegmentedControl!
    
    
    enum SegmentedControls: Int {
        case status, options, files, peer, announces
    }
    
    func updateSegmentedControl(_ isBittorrent: Bool) {
        let c = isBittorrent ? 5 : 3
        segmentedControl.segmentCount = c
        
        (0..<c).forEach {
            guard let sc = SegmentedControls(rawValue: $0) else { return }
            segmentedControl.setTag($0, forSegment: $0)
            segmentedControl.setLabel(NSLocalizedString("infoViewController.segmentedControl.\($0)", comment: ""), forSegment: $0)
        }
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
            
            optionsTableView.reloadData()
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
    
    @IBOutlet var filesTreeController: NSTreeController!
    
    @objc dynamic var fileNodes: FileNode?

    var fileEditingMode = false
    
//MARK: - Peer Item
    
    @objc dynamic var peerObjects: [Aria2Peer]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filesTreeController.sortDescriptors = [NSSortDescriptor(key: "isLeaf", ascending: true),
                                               NSSortDescriptor(key: "title", ascending: true)]
        
        tabView.tabViewItems.enumerated().forEach {
            guard let sc = SegmentedControls(rawValue: $0.offset) else { return }
            $0.element.identifier = sc
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == .showChangeOptionView {
            guard let tableviewSegue = segue as? NSTableViewPopoverSegue,
                  let vc = segue.destinationController as? ChangeOptionViewController else {
                return
            }
            
            guard let option = optionKeys[safe: optionsTableView.selectedRow] else { return }
            vc.gid = gid
            vc.optionValue = options[option.option] ?? ""
            vc.option = option.option
            vc.changeComplete = {
                Task {
                    self.options = (try? await Aria2.shared.getOption(self.gid)) ?? [:]
                    
                    #warning("")
//                    try await Aria2.shared.updateStatus([self.gid])
                }
            }
            
            let selectedRow = optionsTableView.selectedRow
            guard selectedRow >= 0 else { return }
            
            (tableviewSegue.sourceController as AnyObject)
                .present(vc,
                         asPopoverRelativeTo: optionsTableView.rect(ofRow: selectedRow),
                         of: optionsTableView,
                         preferredEdge: .minX,
                         behavior: .transient)
        }
    }
    
    func updateStatusInTimer() {
        guard aria2Object?.status == Status.active.rawValue else { return }
        Task {
            guard let identifier = tabView.selectedTabViewItem?.identifier,
                  let sc = identifier as? SegmentedControls else { return }
            
            switch sc {
            case .files:
                guard !fileEditingMode else { return }
                try await Aria2.shared.getFiles(gid)
            case .peer:
                self.peerObjects = try await Aria2.shared.getPeer(gid)
            default:
                break
            }
        }
    }
    
    deinit {
//        aria2Object?.filesObserve = nil
//        aria2Object = nil
//        objectController.content = nil
    }
    
}

extension InfoViewController: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        Task {
            try? await updateTabView()
        }
    }
    
    func updateTabView() async throws {
        guard let identifier = tabView.selectedTabViewItem?.identifier,
              let sc = identifier as? SegmentedControls else { return }
        fileEditingMode = false
        switch sc {
        case .status:
            break
        case .options:
            self.options = try await Aria2.shared.getOption(gid) ?? [:]
        case .files:
            try await Aria2.shared.getFiles(gid)
            await initFileNodes()
        case .peer:
            guard aria2Object?.status == Status.active.rawValue else { return }
            self.peerObjects = try await Aria2.shared.getPeer(gid)
        default:
            break
        }
    }
    
}

extension InfoViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView {
        case optionsTableView:
            return optionKeys.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        switch tableView {
        case optionsTableView:
            return tableView.rowHeight
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        switch tableView {
        case optionsTableView:
            switch tableColumn?.identifier.rawValue {
            case "OptionTableViewValue":
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
    
    func initFileNodes() async {
        guard let obj = aria2Object else {
            return
        }
        
        let dir = obj.dir
        
        if fileNodes == nil {
            fileNodes = FileNode(dir, isLeaf: false)
        }
        var fileNodes = fileNodes!
        
        let rootPathComponents = fileNodes.path.pathComponents
        var groupChildrens: [FileNode] = []
        
        obj.files.forEach { file in
            let path = file.path
            guard path != "" else {
                return
            }
            
            var pathComponents = path.pathComponents
            if path.isChildPath(of: fileNodes.path) {
                pathComponents.removeSubrange(0 ..< rootPathComponents.count)
            }
            
            var currentNode = fileNodes
            
            pathComponents.forEach { nodeName in
                var child = currentNode.getChild(nodeName)
                if child == nil {
                    var path = currentNode.path
                    path.appendingPathComponent(nodeName)
                    
                    let node = pathComponents.count != 1 ? FileNode(path, isLeaf: false) : FileNode(path, file: file, isLeaf: true)
                    
                    currentNode.children.append(node)
                    if pathComponents.count != 1 {
                        groupChildrens.append(node)
                    }
                    child = currentNode.getChild(nodeName)
                } else if let child = child, child.isLeaf {
                    child.updateData(file)
                }
                
                if let child = child {
                    currentNode = child
                }
                pathComponents.removeFirst()
            }
        }
        updateStatus(for: groupChildrens)
        filesTreeController.content = fileNodes.children
    }
    
    func updateFileNodes() {
        guard let obj = self.aria2Object,
              self.fileNodes != nil,
              let newFiles = try? DataManager.shared.aria2Files(obj.gid) else {
            return
        }
        
        let filesDic = newFiles.reduce(into: [String: Aria2File]()) { result, file in
            result[file.id] = file
        }
        
        let rootPathComponents = self.fileNodes!.path.pathComponents
        var groupChildrens: [FileNode] = []
        var shouldUpdateSelected = false
        
        obj.files.forEach { file in
            guard let newFile = filesDic[file.id], file != newFile else { return }
            file.update(newFile)
            
            let path = file.path
            var pathComponents = path.pathComponents
            
            guard var currentNode = self.fileNodes else { return }
            
            if path.isChildPath(of: currentNode.path) {
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
                    currentNode.updateData(file)
                }
            }
        }
        
        if shouldUpdateSelected {
            self.updateStatus(for: groupChildrens)
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
                child.updateStateWithChildren()
            }
            count -= 1
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, dataCellFor tableColumn: NSTableColumn?, item: Any) -> NSCell? {
        if let last = tableColumn?.identifier.rawValue.last,
           let i = Int(String(last)),
           i == 0,
           let node = (item as? NSTreeNode)?.representedObject as? FileNode,
           let cell = tableColumn?.dataCell as? NSButtonCell {
            cell.setButtonType(.switch)
            cell.allowsMixedState = !(node.children.count == 0)
            cell.title = node.title
        }
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, byItem item: Any?) {
        fileEditingMode = true
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
        
        // Unloaded rows will not be updated
//        outlineView.reloadItem(item, reloadChildren: true)
        outlineView.reloadData()
    }
}

extension InfoViewController: DatabaseChangeObserver {
    @MainActor
    func databaseDidChange(notification: DatabaseChangeNotification) async {
        if notification.tableName == .aria2File {
            switch notification.changeType {
            case .insert(let fids), .delete(let fids):
                guard fids.contains(where: { $0.starts(with: gid) }) else { return }
                await initFileNodes()
            case .update(let fids):
                guard fids.contains(where: { $0.starts(with: gid) }) else { return }
                updateFileNodes()
            case .reload:
                await initFileNodes()
            }
        } else if notification.tableName == .aria2Object {
            switch notification.changeType {
            case .insert(let gids), .delete(let gids), .update(let gids):
                guard gids.contains(gid) else { return }
                aria2Object = try? DataManager.shared.aria2Object(gid, deep: true)
            case .reload:
                aria2Object = try? DataManager.shared.aria2Object(gid, deep: true)
            }
        }
    }
}
