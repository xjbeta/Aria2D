//
//  WaitTimer.swift
//  Aria2D
//
//  Created by xjbeta on 16/8/28.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

actor Debouncer {
    private var task: Task<Void, Never>?
    private let duration: TimeInterval
    private let operation: () async -> Void
    
    init(duration: TimeInterval, _ operation: @escaping () async -> Void) {
        self.duration = duration
        self.operation = operation
    }
    
    func debounce() {
        task?.cancel()
        task = Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await operation()
        }
    }
}
