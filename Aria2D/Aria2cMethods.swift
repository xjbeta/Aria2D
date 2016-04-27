//
//  Aria2cMethods.swift
//  Aria2D
//
//  Created by xjbeta on 16/2/12.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class Aria2cMethods: NSObject {
    
    /*
    
    https://aria2.github.io/manual/en/html/aria2c.html#methods
    
    addUri
    addTorrent
    addMetalink
    remove
    forceRemove
    pause
    pauseAll
    forcePause
    forcePauseAll
    unpause
    unpauseAll
    tellStatus
    getUris
    getFiles
    getPeers
    getServers
    tellActive
    tellWaiting
    tellStopped
    changePosition
    changeUri
    getOption
    changeOption
    getGlobalOption
    changeGlobalOption
    getGlobalStat //获取全局状态
    purgeDownloadResult //清除全部完成／错误／移除的下载
    removeDownloadResult //清除 某个 完成／错误／移除的下载
    getVersion //返回 版本号，启用的方法
    getSessionInfo //返回 sessionID
    shutdown //关闭Aria2
    forceShutdown //强制退出
    saveSession //保存当前 session
    */
    
    

    
    
    private struct CustomMethods {
        let tellStatus = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2tellStatus\", \"method\":\"system.multicall\",\"params\":[[{\"methodName\":\"aria2.tellActive\"},{\"methodName\":\"aria2.tellWaiting\",\"params\":[0,1000]},{\"methodName\":\"aria2.tellStopped\",\"params\":[0,1000]}]]}"
        
        let tellUpdate = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2tellUpdate\", \"method\":\"aria2.tellActive\",\"params\":[[\"gid\",\"completedLength\",\"totalLength\",\"downloadSpeed\"]]}"
        
        let shutdown  = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2shutdown\", \"method\":\"aria2.shutdown\"}"
        
        
        let pauseAll = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2pauseAll\", \"method\":\"aria2.pauseAll\"}"
        let unPauseAll = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2unpauseAll\", \"method\":\"aria2.unpauseAll\"}"
        
        
    }
    
    
    private let methods = CustomMethods()
    
    
    
    func tellStatus() {
        WriteToWebsocket(methods.tellStatus)
    }
    
    func tellActiveSec() {
        WriteToWebsocket(methods.tellUpdate)
    }
    
    func shutdown() {
        WriteToWebsocket(methods.shutdown)
    }
    
    
    
    
    func addUri(uri: String) {
        let addUri = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2addUri\", \"method\":\"aria2.addUri\",\"params\":[[\"\(uri)\"]]}"
        
        
        WriteToWebsocket(addUri)
    }
    
    
    func addTorrent(path: String) {
        let addTorrent = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2addTorrent\", \"method\":\"aria2.addTorrent\",\"params\":[\"\(path)\", [], {\"show-files\":\"true\"}]}"
        WriteToWebsocket(addTorrent)
    }
    
    
    
    func pause(gid: GID) {
        let pause = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2pause\", \"method\":\"aria2.pause\",\"params\":[\"\(gid)\", [\"\(gid)\"]]}"
        WriteToWebsocket(pause)

    }
    
    
    func unpause(gid: GID) {
        let unpause = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2unpause\", \"method\":\"aria2.unpause\",\"params\":[\"\(gid)\"]}"
        WriteToWebsocket(unpause)
        
    }
    
    
    func forcePause(gid: String) {
        let forcePause = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2pause\", \"method\":\"aria2.forcePause\",\"params\":[\"\(gid)\"]}"
        WriteToWebsocket(forcePause)
        
    }
    
    
    func removeDownloadResult(gid: String) {
        let removeDownloadResult = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2removeDownloadResult\", \"method\":\"aria2.removeDownloadResult\",\"params\":[\"\(gid)\"]}"
        WriteToWebsocket(removeDownloadResult)
    }
    
    
    func remove(gid: String) {
        let remove = "{\"jsonrpc\": \"2.0\", \"id\": \"aria2remove\", \"method\":\"aria2.forceRemove\",\"params\":[\"\(gid)\"]}"
        WriteToWebsocket(remove)
    }
    
    
    
    func pauseAll() {
        WriteToWebsocket(methods.pauseAll)
    }
    
    func unPauseAll() {
        WriteToWebsocket(methods.unPauseAll)
    }


}



private extension Aria2cMethods {
    
    
    func WriteToWebsocket(str: String) {
        let data: NSData = str.dataUsingEncoding(NSUTF8StringEncoding)!
        Aria2Websocket.sharedInstance.writeData(data)
        
    }
    
    
}
