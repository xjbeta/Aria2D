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
    var onConnect: ((Void) -> Void)?
    var onDisconnect: ((NSError?) -> Void)?
    var onData: ((NSData) -> Void)?

    
    static let sharedInstance = Aria2Websocket()

    private let socket = WebSocket(url: NSURL(string: "ws://localhost:23337/jsonrpc")!)
    
    
    private override init() {
        socket.queue = dispatch_queue_create("com.vluxe.starscream.Aria2D", nil)
        
    }
    
    
    
    
    
    
    
    func setWebSocketNotifications() {
        
        socket.onConnect = {
            print("onConnect")
            BackgroundTask.sharedInstance.sendAction({
                Aria2cMethods.sharedInstance.TellStatus()
            })
            self.onConnect?()
        }
        //websocketDidDisconnect
        socket.onDisconnect = { error in
            print("websocket is disconnected: \(error?.localizedDescription)")
            self.onDisconnect?(error)
            
            
        }
        //websocketDidReceiveMessage
        socket.onText = { text in
            WebsocketNotificationHandle.sharedInstance.handle(text)
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
