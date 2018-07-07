//
//  StatusBitfieldTableCellView.swift
//  Aria2D
//
//  Created by xjbeta on 2017/8/11.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Cocoa

class StatusBitfieldTableCellView: NSTableCellView {
	@IBOutlet var bitfieldCollectionView: NSCollectionView!
	
    var test = "123456789abcdef"
    
	var bitfield = "" {
		didSet {
//            self.bitfieldCollectionView.reloadData()
		}
	}

	override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
}


extension StatusBitfieldTableCellView: NSCollectionViewDelegate, NSCollectionViewDataSource {
    
	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
//        return bitfield.characters.count
        if section == 0 {
            return 45
        }
        
        return 0
	}
    
    
	
	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        let item = bitfieldCollectionView.makeItem(withIdentifier: .statusCollectionViewItem, for: indexPath)
        if let item = item as? StatusCollectionViewItem {
            if indexPath.item < 10 {
                item.setItem("\(indexPath.item)")
            } else {
                item.setItem("0")
            }
        }

        return item
//        let item = bitfieldCollectionView.makeItem(withIdentifier: .statusCollectionViewItem, for: indexPath)
//
//        if let item = item as? StatusCollectionViewItem {
//            if indexPath.item < 10 {
//                item.setItem("\(indexPath.item)")
//            } else {
//                item.setItem("0")
//            }
//
//
//            return item
//        }
//        return item
	}
	
	
}
