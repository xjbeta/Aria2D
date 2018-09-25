//
//  RealmBind.swift
//  Aria2D
//
//  Created by xjbeta on 2018/9/24.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Foundation
import RealmSwift

extension Results {
    func bind(to tableView: NSTableView, animated: Bool) -> NotificationToken {
        return self.observe {
            switch $0 {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                guard animated else {
                    tableView.reloadData()
                    return
                }
                
                let lastItemCount = tableView.numberOfRows
                guard self.count == lastItemCount + insertions.count - deletions.count else {
                    tableView.reloadData()
                    return
                }
                
                tableView.beginUpdates()
                tableView.removeRows(at: IndexSet(deletions), withAnimation: .effectFade)
                tableView.insertRows(at: IndexSet(insertions), withAnimation: .effectFade)
                tableView.reloadData(forRowIndexes: IndexSet(modifications), columnIndexes: IndexSet([0]))
                tableView.endUpdates()
            case .error:
                break
            }
        }
    }
}

extension List {
    func bind(to tableView: NSTableView, animated: Bool) -> NotificationToken {
        return self.observe {
            switch $0 {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                guard animated else {
                    tableView.reloadData()
                    return
                }
                
                let lastItemCount = tableView.numberOfRows
                guard self.count == lastItemCount + insertions.count - deletions.count else {
                    tableView.reloadData()
                    return
                }
                
                tableView.beginUpdates()
                tableView.removeRows(at: IndexSet(deletions), withAnimation: .effectFade)
                tableView.insertRows(at: IndexSet(insertions), withAnimation: .effectFade)
                tableView.reloadData(forRowIndexes: IndexSet(modifications), columnIndexes: IndexSet([0]))
                tableView.endUpdates()
            case .error:
                break
            }
        }
    }
}
