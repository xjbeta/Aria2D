//
//  StatusViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/4/9.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa
import SwiftyJSON

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
				if let i = item as? DicObject {
					pasteboard.writeObjects([i.value.stringValue as NSString])
				} else if let i = item as? ArrayObject {
					pasteboard.writeObjects([i.value.stringValue as NSString])
				}
				
				
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	let statusViewStatusCell = "StatusViewStatusCell"
	let statusViewValueCell = "StatusViewValueCell"
	
	var json = JSON([]) {
		didSet {
			DispatchQueue.main.async {
				self.outlineView.reloadData()
			}
		}
	}
	
	
	
	struct DicObject {
		let key: String
		let value: JSON
		init(_ key: String, value: JSON) {
			self.key = key
			if key == "uris" {
				self.value = JSON(Array(Set(value.map {
					$0.1["uri"].stringValue
				})).sorted())
			} else if key == "files", value.array?.count == 1, let v = value.array?[safe: 0] {
				self.value = v
			} else if key == "announceList" {
				self.value = JSON(value.arrayValue.map {
					$0[0].stringValue
				})
			} else {
				self.value = value
			}
		}
	}
	struct ArrayObject {
		let index: Int
		let value: JSON
		init(_ i: Int, value: JSON) {
			index = i
			self.value = value
		}
	}
	

}

extension StatusViewController: NSOutlineViewDelegate, NSOutlineViewDataSource {
	
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let obj = item as? DicObject {
			return obj.value.array != nil && obj.value.array?.count != 0
				|| obj.value.dictionary != nil && obj.value.dictionary?.count != 0
		} else if let obj = item as? ArrayObject {
			return obj.value.array != nil && obj.value.array?.count != 0
				|| obj.value.dictionary != nil && obj.value.dictionary?.count != 0
		}
		return false
	}
	
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if let obj = item as? DicObject {
			return obj.value.dictionary?.count ?? obj.value.array?.count ?? 0
		} else if let obj = item as? ArrayObject {
			return obj.value.dictionary?.count ?? obj.value.array?.count ?? 0
		} else {
			return json.dictionary?.count ?? json.array?.count ?? 0
		}
	}
	
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		func returnObj(_ dic: [String : JSON]?) -> Any {
			if let keys = dic?.keys.sorted(),
				let key = keys[safe: index] {
				return DicObject(key, value: dic?[key] ?? "")
			}
			return ""
		}
		
		if item == nil {
			return returnObj(json.dictionary)
		} else if let obj = item as? DicObject {
			if let dicObj = obj.value.dictionary {
				return returnObj(dicObj)
			} else if let arrayObj = obj.value.array {
				return ArrayObject(index, value: arrayObj[safe: index] ?? "")
			}
		} else if let obj = item as? ArrayObject {
			if let dicObj = obj.value.dictionary {
				return returnObj(dicObj)
			} else if let arrayObj = obj.value.array {
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
				if obj.key.contains("Length") {
					return UnitNumber(obj.value.stringValue).stringValue
				}
				return obj.value.string
			} else if let obj = item as? ArrayObject {
				return obj.value.array?.count ?? obj.value.dictionary?.count ?? obj.value
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
