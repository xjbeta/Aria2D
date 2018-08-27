//
//  Aria2Methods.swift
//  Aria2D
//
//  Created by xjbeta on 2018/8/18.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa

struct Aria2Method {
    static let addUri = "aria2.addUri"
    static let addTorrent = "aria2.addTorrent"
    static let getPeers = "aria2.getPeers"
    static let addMetalink = "aria2.addMetalink"
    static let remove = "aria2.remove"
    static let pause = "aria2.pause"
    static let forcePause = "aria2.forcePause"
    static let pauseAll = "aria2.pauseAll"
    static let forcePauseAll = "aria2.forcePauseAll"
    static let unpause = "aria2.unpause"
    static let unpauseAll = "aria2.unpauseAll"
    static let forceRemove = "aria2.forceRemove"
    static let changePosition = "aria2.changePosition"
    static let tellStatus = "aria2.tellStatus"
    static let getUris = "aria2.getUris"
    static let getFiles = "aria2.getFiles"
    static let getServers = "aria2.getServers"
    static let tellActive = "aria2.tellActive"
    static let tellWaiting = "aria2.tellWaiting"
    static let tellStopped = "aria2.tellStopped"
    static let getOption = "aria2.getOption"
    static let changeUri = "aria2.changeUri"
    static let changeOption = "aria2.changeOption"
    static let getGlobalOption = "aria2.getGlobalOption"
    static let changeGlobalOption = "aria2.changeGlobalOption"
    static let purgeDownloadResult = "aria2.purgeDownloadResult"
    static let removeDownloadResult = "aria2.removeDownloadResult"
    static let getVersion = "aria2.getVersion"
    static let getSessionInfo = "aria2.getSessionInfo"
    static let shutdown = "aria2.shutdown"
    static let forceShutdown = "aria2.forceShutdown"
    static let getGlobalStat = "aria2.getGlobalStat"
    static let saveSession = "aria2.saveSession"
    static let multicall = "system.multicall"
    static let listMethods = "system.listMethods"
    static let listNotifications = "system.listNotifications"
}
