//
//  Aria2ErrorCode.swift
//  Aria2D
//
//  Created by xjbeta on 2018/8/17.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa

struct Aria2ErrorCode {
    var errorInfo = ""
    var errorCode = -1
    
    init(_ code: Int) {
        errorCode = code
        switch code {
        case 0:
            errorInfo = "All downloads were successful."
        case 1:
            errorInfo = "An unknown error occurred."
        case 2:
            errorInfo = "Time out occurred."
        case 3:
            errorInfo = "A resource was not found."
        case 4:
            errorInfo = "Aria2 saw the specified number of \"resource not found\" error. See --max-file-not-found option."
        case 5:
            errorInfo = "A download aborted because download speed was too slow. See --lowest-speed-limit option."
        case 6:
            errorInfo = "Network problem occurred."
        case 7:
            errorInfo = "There were unfinished downloads. This error is only reported if all finished downloads were successful and there were unfinished downloads in a queue when aria2 exited by pressing Ctrl-C by an user or sending TERM or INT signal."
        case 8:
            errorInfo = "Remote server did not support resume when resume was required to complete download."
        case 9:
            errorInfo = "There was not enough disk space available."
        case 10:
            errorInfo = "Piece length was different from one in .aria2 control file. See --allow-piece-length-change option."
        case 11:
            errorInfo = "Aria2 was downloading same file at that moment."
        case 12:
            errorInfo = "Aria2 was downloading same info hash torrent at that moment."
        case 13:
            errorInfo = "File already existed. See --allow-overwrite option."
        case 14:
            errorInfo = "Renaming file failed. See --auto-file-renaming option."
        case 15:
            errorInfo = "Aria2 could not open existing file."
        case 16:
            errorInfo = "Aria2 could not create new file or truncate existing file."
        case 17:
            errorInfo = "File I/O error occurred."
        case 18:
            errorInfo = "Aria2 could not create directory."
        case 19:
            errorInfo = "Name resolution failed."
        case 20:
            errorInfo = "Aria2 could not parse Metalink document."
        case 21:
            errorInfo = "FTP command failed."
        case 22:
            errorInfo = "HTTP response header was bad or unexpected."
        case 23:
            errorInfo = "Too many redirects occurred."
        case 24:
            errorInfo = "HTTP authorization failed."
        case 25:
            errorInfo = "Aria2 could not parse bencoded file (usually \".torrent\" file)."
        case 26:
            errorInfo = "\".torrent\" file was corrupted or missing information that aria2 needed."
        case 27:
            errorInfo = "Magnet URI was bad."
        case 28:
            errorInfo = "Bad/unrecognized option was given or unexpected option argument was given."
        case 29:
            errorInfo = "The remote server was unable to handle the request due to a temporary overloading or maintenance."
        case 30:
            errorInfo = "Aria2 could not parse JSON-RPC request."
        case 31:
            errorInfo = "Reserved. Not used."
        case 32:
            errorInfo = "Checksum validation failed."
        default:
            errorInfo = ""
        }
    }
}


