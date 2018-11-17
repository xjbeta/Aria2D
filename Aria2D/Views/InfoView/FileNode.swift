//
//  FileNode.swift
//  Aria2D
//
//  Created by xjbeta on 2018/9/24.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Foundation

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
            self.index = Int(file.index)
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
