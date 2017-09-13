//
//  StatusViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/4/9.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class StatusViewController: NSViewController {

	@IBOutlet var outlineView: NSOutlineView!
	@IBAction func doubleAction(_ sender: Any) {
		if let item = outlineView.item(atRow: outlineView.selectedRow) {
			if outlineView(outlineView, isItemExpandable: item) {
				if outlineView.isItemExpanded(item) {
					outlineView.animator().collapseItem(item)
				} else {
					outlineView.animator().expandItem(item)
				}
			} else {
				let pasteboard = NSPasteboard.general
				pasteboard.clearContents()
				if let i = item as? DicObject, let value = i.value as? NSString {
					pasteboard.writeObjects([value])
				} else if let i = item as? ArrayObject, let value = i.value as? NSString {
					pasteboard.writeObjects([value])
				}
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	let statusViewStatusCell = "StatusViewStatusCell"
	let statusViewValueCell = "StatusViewValueCell"
	
	var result: [String: Any] = [:] {
		didSet {
			DispatchQueue.main.async {
				self.outlineView.reloadData()
			}
		}
	}
	
	
	
	struct DicObject {
		let key: String
		let value: Any
		var array: [Any]? {
			return value as? [Any]
		}
		
		var dictionary: [String: Any]? {
			return value as? [String: Any]
		}
		
		init(_ key: String, value: Any) {
			self.key = key
			self.value = value
		}
		
		
		
	}
	struct ArrayObject {
		let index: Int
		let value: Any
		
		var array: [Any]? {
			return value as? [Any]
		}
		
		var dictionary: [String: Any]? {
			return value as? [String: Any]
		}
		
		init(_ i: Int, value: Any) {
			index = i
			self.value = value
		}
	}
	

}

extension StatusViewController: NSOutlineViewDelegate, NSOutlineViewDataSource {
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let obj = item as? DicObject {
			return obj.array != nil  && obj.array?.count != 0
				|| obj.dictionary != nil && obj.dictionary?.count != 0
		} else if let obj = item as? ArrayObject {
			return obj.array != nil && obj.array?.count != 0
				|| obj.dictionary != nil && obj.dictionary?.count != 0
		}
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if let obj = item as? DicObject {
			return obj.dictionary?.count ?? obj.array?.count ?? 0
		} else if let obj = item as? ArrayObject {
			return obj.dictionary?.count ?? obj.array?.count ?? 0
		} else {
			return result.count
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		func returnObj(_ dic: [String : Any]?) -> Any {
			if let keys = dic?.keys.sorted(),
				let key = keys[safe: index] {
				return DicObject(key, value: dic?[key] ?? "")
			}
			return ""
		}

		if item == nil {
			return returnObj(result)
		} else if let obj = item as? DicObject {
			if let dicObj = obj.dictionary {
				return returnObj(dicObj)
			} else if let arrayObj = obj.array {
				return ArrayObject(index, value: arrayObj[safe: index] ?? "")
			}
		} else if let obj = item as? ArrayObject {
			if let dicObj = obj.dictionary {
				return returnObj(dicObj)
			} else if let arrayObj = obj.array {
				return ArrayObject(index, value: arrayObj[safe: index] ?? "")
			}
		}

		return ""
	}
	
	func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
		let identifier = tableColumn?.identifier.rawValue
		if identifier == statusViewStatusCell {
			if let obj = item as? DicObject {
				return obj.key
			} else if let obj = item as? ArrayObject {
				return obj.index
			}
		} else if identifier == statusViewValueCell {
			if let obj = item as? DicObject {
				if obj.key.contains("Length"),
					let str = obj.value as? String,
					let int = Int64(str) {
					return int.ByteFileFormatter()
				} else if obj.key.contains("Speed"),
					let str = obj.value as? String,
					let int = Int64(str) {
					return "\(int.ByteFileFormatter())/s"
				} else {
					return obj.value as? String
				}
			} else if let obj = item as? ArrayObject {
				return obj.array?.count ?? ""
			}
		}
		return ""
	}
	
	
	func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
		if let _ = item as? DicObject {
			return true
		} else if let _ = item as? ArrayObject {
			return true
		}
		return false
	}
	
}
