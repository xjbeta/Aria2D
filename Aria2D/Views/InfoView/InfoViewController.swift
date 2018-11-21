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
    @objc var context: NSManagedObjectContext
    
    required init?(coder: NSCoder) {
        context = (NSApp.delegate as! AppDelegate).persistentContainer.viewContext
        super.init(coder: coder)
    }
    
	@IBAction func cancelButton(_ sender: Any) {
		view.window?.close()
	}
    
	@IBAction func okButton(_ sender: Any) {
        Aria2.shared.getFiles(gid) {
            if let files = self.aria2Object?.files?.allObjects as? [Aria2File] {
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
    
	var gid = "" {
		didSet {
            let fetchRequest: NSFetchRequest<Aria2Object> = Aria2Object.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "gid == %@", gid)
            aria2Object = (try? context.fetch(fetchRequest))?.first
            
            updateSegmentedControl(aria2Object?.bittorrent != nil)
            
            Aria2.shared.getServers(gid) {}
            Aria2.shared.getUris(gid) {}
            
            aria2Object?.filesObserve = { [weak self] indexs, reload in
                if reload {
                    self?.initFileNodes()
                } else {
                    self?.updateFileNodes(indexs)
                }
            }
		}
	}
    
    
    @objc dynamic var aria2Object: Aria2Object?
    
    enum updateBlock {
        case name, size, status, files, announces
    }
    
    @IBOutlet weak var tabView: NSTabView!
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
    
    @IBOutlet var filesTreeController: NSTreeController!
    
    @objc dynamic var fileNodes: FileNode?

//MARK: - Peer Item
    
    @objc dynamic var peerObjects: [Aria2Peer]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filesTreeController.sortDescriptors = [NSSortDescriptor(key: "isLeaf", ascending: true),
                                               NSSortDescriptor(key: "title", ascending: true)]
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
    
    func updateStatusInTimer() {
        guard aria2Object?.status == Status.active.rawValue else { return }
        DispatchQueue.main.async { [weak self] in
            guard let label = self?.tabView.selectedTabViewItem?.label,
                let gid = self?.gid else {
                    return
            }
            
            switch label {
            case "Files":
                Aria2.shared.getFiles(gid) {}
            case "Peer":
                Aria2.shared.getPeer(gid) { objs in
                    DispatchQueue.main.async {
                        self?.peerObjects = objs
                    }
                }
            default:
                break
            }
        }
    }
    
    deinit {
        aria2Object?.filesObserve = nil
        aria2Object = nil
        objectController.content = nil
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
            Aria2.shared.getFiles(gid) {
                self.initFileNodes()
            }
        case "Peer":
            guard aria2Object?.status == Status.active.rawValue else { return }
            Aria2.shared.getPeer(gid) { objs in
                DispatchQueue.main.async {
                    self.peerObjects = objs
                }
            }
            break
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
    
    func initFileNodes() {
        DispatchQueue.global(qos: .background).async {
            guard let obj = self.aria2Object, let dir = obj.dir else {
                return
            }

            if self.fileNodes == nil {
                self.fileNodes = FileNode(dir, isLeaf: false)
            }
            
            let rootPathComponents = self.fileNodes!.path.pathComponents
            var groupChildrens: [FileNode] = []
            
            let filesSemaphore = DispatchSemaphore(value: 1)
            
            (obj.files?.allObjects as? [Aria2File])?.forEach { file in
                filesSemaphore.wait()
                guard let path = file.path, path != "" else {
                    filesSemaphore.signal()
                    return
                }
                
                var pathComponents = path.pathComponents
                
                guard var currentNode = self.fileNodes else { return }
                
                if path.isChildPath(of: currentNode.path) {
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
            DispatchQueue.main.async {
                self.updateStatus(for: groupChildrens)
                self.filesTreeController.content = self.fileNodes?.children
            }
        }
    }
    
    func updateFileNodes(_ list: [Int]) {
        guard let obj = self.aria2Object, self.fileNodes != nil else {
            return
        }
        
        let rootPathComponents = self.fileNodes!.path.pathComponents
        var groupChildrens: [FileNode] = []
        var shouldUpdateSelected = false
        
        (obj.files?.allObjects as? [Aria2File])?.filter {
            list.contains(Int($0.index))
            }.forEach { file in
                guard let path = file.path else { return }
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
        if tableColumn?.title == "Name",
            let node = (item as? NSTreeNode)?.representedObject as? FileNode,
            let cell = tableColumn?.dataCell as? NSButtonCell {
            cell.setButtonType(.switch)
            cell.allowsMixedState = !(node.children.count == 0)
            cell.title = node.title
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
