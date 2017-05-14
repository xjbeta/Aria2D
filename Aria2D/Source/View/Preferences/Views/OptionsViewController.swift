//
//  OptionsViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2017/3/16.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa
import SwiftyJSON

class OptionsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

	@IBOutlet var optionsTableView: NSTableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

	@IBAction func changeOption(_ sender: Any) {
		if let key = optionKeys[safe: optionsTableView.selectedRow], !exceptKeys.contains(key) {
			performSegue(withIdentifier: showChangeOptionView, sender: self)
		}
	}
	
	var options: JSON = [] {
		didSet {
			DispatchQueue.main.async {
				self.optionKeys = self.options.map {
					Aria2Option(rawValue: $0.0)
				}.sorted(by: { $0.rawValue < $1.rawValue })
				self.optionsTableView.reloadData()
				self.view.window?.title = self.options[Aria2Option.out.rawValue].stringValue
			}
		}
	}
	var gid = "" 
	private var optionKeys: [Aria2Option] = []

	let exceptKeys: [Aria2Option] = [.dryRun,
	                                 .metalinkBaseUri,
	                                 .parameterizedUri,
	                                 .pause,
	                                 .pieceLength,
	                                 .rpcSaveUploadMetadata]

	
	let showChangeOptionView = "showChangeOptionView"
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		if segue.identifier == showChangeOptionView {
			if let vc = segue.destinationController as? ChangeOptionViewController {
				vc.presentViewController(vc,
				                         asPopoverRelativeTo: optionsTableView.rect(ofRow: optionsTableView.selectedRow),
				                         of: optionsTableView,
				                         preferredEdge: .minX,
				                         behavior: .transient)
				
				if let option = optionKeys[safe: optionsTableView.selectedRow] {
					vc.optionKey.stringValue = option.rawValue
					vc.optionValue = options[option.rawValue].stringValue
					vc.option = option
					vc.gid = self.gid
					vc.changeComplete = {
						Aria2.shared.getOption(self.gid) {
							self.options = $0
						}
						Aria2.shared.initData([self.gid])
					}
				}
			}
		}
	}
	
	
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return optionKeys.count
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		if let identifier = tableColumn?.identifier {
			switch identifier {
			case "OptionsTableViewOptionCell":
				return optionKeys[safe: row]?.rawValue
			case "OptionsTableViewValueCell":
				if let key = optionKeys[safe: row]?.rawValue {
					return options[key].stringValue
				}
			default:
				break
			}
		}
		return nil
	}
}
