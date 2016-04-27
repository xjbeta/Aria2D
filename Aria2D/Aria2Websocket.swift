//
//  Aria2Websocket.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/10.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa
import Starscream


class Aria2Websocket: NSObject {
    var onConnect: (() -> Void)?
    var onDisconnect: ((NSError?) -> Void)?
    var onData: ((NSData) -> Void)?
    
    
    static let sharedInstance = Aria2Websocket()

    private let socket = WebSocket(url: NSURL(string: "ws://localhost:23337/jsonrpc")!)
    
    
    private override init() {
        socket.queue = dispatch_queue_create("com.xjbeta.starscream.Aria2D", nil)
    }
    
    
    let websocketNotificationHandle = WebsocketNotificationHandle()

    func setWebSocketNotifications() {
        
        socket.onConnect = {
            BackgroundTask.sharedInstance.sendAction({
                Aria2cAPI.sharedInstance.tellStatus()
            })
            self.onConnect?()
        }
        socket.onDisconnect = { error in
            print("websocket is disconnected: \(error?.localizedDescription)")
            self.onDisconnect?(error)
            DataAPI.sharedInstance.resetData()
        }
        //websocketDidReceiveMessage
        socket.onText = { text in
            self.websocketNotificationHandle.handle(text)
        }
        //websocketDidReceiveData
        socket.onData = { data in
            print("got some data: \(data.length)")
            self.onData?(data)
        }
        

    }
    
    




    func isConnected() -> Bool {
        return socket.isConnected
    }
    
    
    
    func connect() {
        socket.connect()
    }
    

    
    
    func writeData(data: NSData) {
        socket.writeData(data)
    }
    
    


}
