//
//  Aria2Option.swift
//  Aria2D
//
//  Created by xjbeta on 2017/3/28.
//  Copyright © 2017年 xjbeta. All rights reserved.
//

import Foundation

struct Aria2Option: RawRepresentable, Hashable, Codable {
	typealias RawValue = String
	
	var rawValue: RawValue
	var hashValue: Int {
		get {
			return self.rawValue.hashValue
		}
	}
	
	var valueType: ValueType
	var preferencesType: PreferencesType
	
	init(_ string: String, valueType: ValueType, type: PreferencesType) {
		self.rawValue = string
		switch valueType {
		case .boolType:
			self.valueType = .bool(bool: [.true🤣, .false😂])
		default:
			self.valueType = valueType
		}
		self.preferencesType = type
	}
	
	enum ValueType {
		case string(str: String)
		case bool(bool: [constants])
		case boolType
		
		case number(min: Int, max: Int)
		case unitNumber(min: UnitNumber, max: UnitNumber)
		case parameter(p: [constants])
		
		
		case hostPort
		
		case floatNumber(min: Float, max: Float)
		
		
		case httpProxy
		
		case localFilePath
		
		case optimizeConcurrentDownloads
		// value: true | false | A:B
		
		case integerRange(min: Int, max: Int)
		// "6881-6999"  !selectFile
		
		
	}
	
	// 40
	enum constants: String {
		case true🤣 = "true"
		case false😂 = "false"
		case default😅 = "default"
		case none = "none"
		case mem = "mem"
		case all = "all"
		case full = "full"
		case hide = "hide"
		case geom = "geom"
		case prealloc = "prealloc"
		case falloc = "falloc"
		case trunc = "trunc"
		case debug = "debug"
		case info = "info"
		case notice = "notice"
		case warn = "warn"
		case error = "error"
		case inorder = "inorder"
		case random = "random"
		case feedback = "feedback"
		case adaptive = "adaptive"
		case libuv = "libuv"
		case epoll = "epoll"
		case kqueue = "kqueue"
		case port = "port"
		case poll = "poll"
		case select = "select"
		case binary = "binary"
		case ascii = "ascii"
		case get = "get"
		case tunnel = "tunnel"
		case plain = "plain"
		case arc4 = "arc4"
		case http = "http"
		case https = "https"
		case ftp = "ftp"
		case sslv3 = "SSLv3"
		case tlsv1 = "TLSv1"
		case tlsv11 = "TLSv1.1"
		case tlsv12 = "TLSv1.2"
	}
	
	
    enum PreferencesType: Int {
		case general
		case ftpRelated
		case httpRelated
		case proxyRelated
		case bitTorrentRelated
		case metalinkRelated
		case other
        case none
        
        func raw() -> String {
            switch self {
            case .general: return "general"
            case .ftpRelated: return "ftpRelated"
            case .httpRelated: return "httpRelated"
            case .proxyRelated: return "proxyRelated"
            case .bitTorrentRelated: return "bitTorrentRelated"
            case .metalinkRelated: return "metalinkRelated"
            case .other: return "other"
            case .none: return "none"
            }
        }
	}
	
	// 213
	init(rawValue: RawValue) {
		switch rawValue {
		case "all-proxy": self = .allProxy
		case "all-proxy-passwd": self = .allProxyPasswd
		case "all-proxy-user": self = .allProxyUser
		case "allow-overwrite": self = .allowOverwrite
		case "allow-piece-length-change": self = .allowPieceLengthChange
		case "always-resume": self = .alwaysResume
		case "async-dns": self = .asyncDns
		case "async-dns-server": self = .asyncDnsServer
		case "auto-file-renaming": self = .autoFileRenaming
		case "auto-save-interval": self = .autoSaveInterval
		case "bt-detach-seed-only": self = .btDetachSeedOnly
		case "bt-enable-hook-after-hash-check": self = .btEnableHookAfterHashCheck
		case "bt-enable-lpd": self = .btEnableLpd
		case "bt-exclude-tracker": self = .btExcludeTracker
		case "bt-external-ip": self = .btExternalIp
		case "bt-force-encryption": self = .btForceEncryption
		case "bt-hash-check-seed": self = .btHashCheckSeed
		case "bt-keep-alive-interval": self = .btKeepAliveInterval
        case "bt-load-saved-metadata": self = .btLoadSavedMetadata
		case "bt-lpd-interface": self = .btLpdInterface
		case "bt-max-open-files": self = .btMaxOpenFiles
		case "bt-max-peers": self = .btMaxPeers
		case "bt-metadata-only": self = .btMetadataOnly
		case "bt-min-crypto-level": self = .btMinCryptoLevel
		case "bt-prioritize-piece": self = .btPrioritizePiece
		case "bt-remove-unselected-file": self = .btRemoveUnselectedFile
		case "bt-request-peer-speed-limit": self = .btRequestPeerSpeedLimit
		case "bt-request-timeout": self = .btRequestTimeout
		case "bt-require-crypto": self = .btRequireCrypto
		case "bt-save-metadata": self = .btSaveMetadata
		case "bt-seed-unverified": self = .btSeedUnverified
		case "bt-timeout": self = .btTimeout
		case "bt-stop-timeout": self = .btStopTimeout
		case "bt-tracker": self = .btTracker
		case "bt-tracker-connect-timeout": self = .btTrackerConnectTimeout
		case "bt-tracker-interval": self = .btTrackerInterval
		case "bt-tracker-timeout": self = .btTrackerTimeout
		case "ca-certificate": self = .caCertificate
		case "certificate": self = .certificate
		case "check-certificate": self = .checkCertificate
		case "check-integrity": self = .checkIntegrity
		case "checksum": self = .checksum
		case "conditional-get": self = .conditionalGet
		case "conf-path": self = .confPath
		case "connect-timeout": self = .connectTimeout
		case "console-log-level": self = .consoleLogLevel
		case "content-disposition-default-utf8": self = .contentDispositionDefaultUtf8
		case "continue": self = .continue🤣
		case "daemon": self = .daemon
		case "deferred-input": self = .deferredInput
		case "dht-entry-point": self = .dhtEntryPoint
		case "dht-entry-point6": self = .dhtEntryPoint6
		case "dht-entry-point-host": self = .dhtEntryPointHost
		case "dht-entry-point-host6": self = .dhtEntryPointHost6
		case "dht-entry-point-port": self = .dhtEntryPointPort
		case "dht-entry-point-port6": self = .dhtEntryPointPort6
		case "dht-file-path": self = .dhtFilePath
		case "dht-file-path6": self = .dhtFilePath6
		case "dht-listen-addr": self = .dhtListenAddr
		case "dht-listen-addr6": self = .dhtListenAddr6
		case "dht-listen-port": self = .dhtListenPort
		case "dht-message-timeout": self = .dhtMessageTimeout
		case "dir": self = .dir
		case "disable-ipv6": self = .disableIpv6
		case "disk-cache": self = .diskCache
		case "dns-timeout": self = .dnsTimeout
		case "download-result": self = .downloadResult
		case "dry-run": self = .dryRun
		case "dscp": self = .dscp
		case "enable-async-dns6": self = .enableAsyncDns6
		case "enable-color": self = .enableColor
		case "enable-dht": self = .enableDht
		case "enable-dht6": self = .enableDht6
		case "enable-http-keep-alive": self = .enableHttpKeepAlive
		case "enable-http-pipelining": self = .enableHttpPipelining
		case "enable-mmap": self = .enableMmap
		case "enable-peer-exchange": self = .enablePeerExchange
		case "enable-rpc": self = .enableRpc
		case "event-poll": self = .eventPoll
		case "file-allocation": self = .fileAllocation
		case "follow-metalink": self = .followMetalink
		case "follow-torrent": self = .followTorrent
		case "force-save": self = .forceSave
		case "force-sequential": self = .forceSequential
		case "ftp-passwd": self = .ftpPasswd
		case "ftp-pasv": self = .ftpPasv
		case "ftp-proxy": self = .ftpProxy
		case "ftp-proxy-passwd": self = .ftpProxyPasswd
		case "ftp-proxy-user": self = .ftpProxyUser
		case "ftp-reuse-connection": self = .ftpReuseConnection
		case "ftp-type": self = .ftpType
		case "ftp-user": self = .ftpUser
		case "gid": self = .gid
		case "hash-check-only": self = .hashCheckOnly
		case "header": self = .header
		case "help": self = .help
		case "http-accept-gzip": self = .httpAcceptGzip
		case "http-auth-challenge": self = .httpAuthChallenge
		case "http-no-cache": self = .httpNoCache
		case "http-passwd": self = .httpPasswd
		case "http-proxy": self = .httpProxy
		case "http-proxy-passwd": self = .httpProxyPasswd
		case "http-proxy-user": self = .httpProxyUser
		case "http-user": self = .httpUser
		case "https-proxy": self = .httpsProxy
		case "https-proxy-passwd": self = .httpsProxyPasswd
		case "https-proxy-user": self = .httpsProxyUser
		case "human-readable": self = .humanReadable
		case "index-out": self = .indexOut
		case "input-file": self = .inputFile
		case "interface": self = .interface
		case "keep-unfinished-download-result": self = .keepUnfinishedDownloadResult
		case "listen-port": self = .listenPort
		case "load-cookies": self = .loadCookies
		case "log": self = .log
		case "log-level": self = .logLevel
		case "lowest-speed-limit": self = .lowestSpeedLimit
		case "max-concurrent-downloads": self = .maxConcurrentDownloads
		case "max-connection-per-server": self = .maxConnectionPerServer
		case "max-download-limit": self = .maxDownloadLimit
		case "max-download-result": self = .maxDownloadResult
		case "max-downloads": self = .maxDownloads
		case "max-file-not-found": self = .maxFileNotFound
		case "max-http-pipelining": self = .maxHttpPipelining
		case "max-mmap-limit": self = .maxMmapLimit
		case "max-overall-download-limit": self = .maxOverallDownloadLimit
		case "max-overall-upload-limit": self = .maxOverallUploadLimit
		case "max-resume-failure-tries": self = .maxResumeFailureTries
		case "max-tries": self = .maxTries
		case "max-upload-limit": self = .maxUploadLimit
		case "metalink-base-uri": self = .metalinkBaseUri
		case "metalink-enable-unique-protocol": self = .metalinkEnableUniqueProtocol
		case "metalink-file": self = .metalinkFile
		case "metalink-language": self = .metalinkLanguage
		case "metalink-location": self = .metalinkLocation
		case "metalink-os": self = .metalinkOs
		case "metalink-preferred-protocol": self = .metalinkPreferredProtocol
		case "metalink-version": self = .metalinkVersion
		case "min-split-size": self = .minSplitSize
		case "min-tls-version": self = .minTlsVersion
		case "multiple-interface": self = .multipleInterface
		case "netrc-path": self = .netrcPath
		case "no-conf": self = .noConf
		case "no-file-allocation-limit": self = .noFileAllocationLimit
		case "no-netrc": self = .noNetrc
		case "no-proxy": self = .noProxy
		case "on-bt-download-complete": self = .onBtDownloadComplete
		case "on-download-complete": self = .onDownloadComplete
		case "on-download-error": self = .onDownloadError
		case "on-download-pause": self = .onDownloadPause
		case "on-download-start": self = .onDownloadStart
		case "on-download-stop": self = .onDownloadStop
		case "optimize-concurrent-downloads": self = .optimizeConcurrentDownloads
		case "optimize-concurrent-downloads-coeffA": self = .optimizeConcurrentDownloadsCoeffA
		case "optimize-concurrent-downloads-coeffB": self = .optimizeConcurrentDownloadsCoeffB
		case "out": self = .out
		case "parameterized-uri": self = .parameterizedUri
		case "pause": self = .pause
		case "pause-metadata": self = .pauseMetadata
        case "peer-agent": self = .peerAgent
		case "peer-connection-timeout": self = .peerConnectionTimeout
		case "peer-id-prefix": self = .peerIdPrefix
		case "piece-length": self = .pieceLength
		case "private-key": self = .privateKey
		case "proxy-method": self = .proxyMethod
		case "quiet": self = .quiet
		case "realtime-chunk-checksum": self = .realtimeChunkChecksum
		case "referer": self = .referer
		case "remote-time": self = .remoteTime
		case "remove-control-file": self = .removeControlFile
		case "retry-wait": self = .retryWait
		case "reuse-uri": self = .reuseUri
		case "rlimit-nofile": self = .rlimitNofile
		case "rpc-allow-origin-all": self = .rpcAllowOriginAll
		case "rpc-certificate": self = .rpcCertificate
		case "rpc-listen-all": self = .rpcListenAll
		case "rpc-listen-port": self = .rpcListenPort
		case "rpc-max-request-size": self = .rpcMaxRequestSize
		case "rpc-passwd": self = .rpcPasswd
		case "rpc-private-key": self = .rpcPrivateKey
		case "rpc-save-upload-metadata": self = .rpcSaveUploadMetadata
		case "rpc-secret": self = .rpcSecret
		case "rpc-secure": self = .rpcSecure
		case "rpc-user": self = .rpcUser
		case "save-cookies": self = .saveCookies
		case "save-not-found": self = .saveNotFound
		case "save-session": self = .saveSession
		case "save-session-interval": self = .saveSessionInterval
		case "seed-ratio": self = .seedRatio
		case "seed-time": self = .seedTime
		case "select-file": self = .selectFile
		case "select-least-used-host": self = .selectLeastUsedHost
		case "server-stat-if": self = .serverStatIf
		case "server-stat-of": self = .serverStatOf
		case "server-stat-timeout": self = .serverStatTimeout
		case "show-console-readout": self = .showConsoleReadout
		case "show-files": self = .showFiles
		case "socket-recv-buffer-size": self = .socketRecvBufferSize
		case "split": self = .split
		case "ssh-host-key-md": self = .sshHostKeyMd
		case "startup-idle-time": self = .startupIdleTime
		case "stderr": self = .stderr
		case "stop": self = .stop
		case "stop-with-process": self = .stopWithProcess
		case "stream-piece-selector": self = .streamPieceSelector
		case "summary-interval": self = .summaryInterval
		case "timeout": self = .timeout
		case "torrent-file": self = .torrentFile
		case "truncate-console-readout": self = .truncateConsoleReadout
		case "uri-selector": self = .uriSelector
		case "use-head": self = .useHead
		case "user-agent": self = .userAgent
		case "version": self = .version
		default:
			self.rawValue = rawValue
			self.valueType = .string(str: "")
			self.preferencesType = .other
		}
	}
	
	static let allProxy = Aria2Option("all-proxy", valueType: .httpProxy, type: .proxyRelated)
	static let allProxyPasswd = Aria2Option("all-proxy-passwd", valueType: .string(str: "PASSWD"), type: .proxyRelated)
	static let allProxyUser = Aria2Option("all-proxy-user", valueType: .string(str: "USER"), type: .proxyRelated)
	static let allowOverwrite = Aria2Option("allow-overwrite", valueType: .boolType, type: .general)
	static let allowPieceLengthChange = Aria2Option("allow-piece-length-change", valueType: .boolType, type: .general)
	static let alwaysResume = Aria2Option("always-resume", valueType: .boolType, type: .general)
	static let asyncDns = Aria2Option("async-dns", valueType: .boolType, type: .general)
	static let asyncDnsServer = Aria2Option("async-dns-server", valueType: .string(str: "string"), type: .general)
	static let autoFileRenaming = Aria2Option("auto-file-renaming", valueType: .boolType, type: .general)
	static let autoSaveInterval = Aria2Option("auto-save-interval", valueType: .number(min: 0, max: 600), type: .general)
	static let btDetachSeedOnly = Aria2Option("bt-detach-seed-only", valueType: .boolType, type: .bitTorrentRelated)
	static let btEnableHookAfterHashCheck = Aria2Option("bt-enable-hook-after-hash-check", valueType: .boolType, type: .bitTorrentRelated)
	static let btEnableLpd = Aria2Option("bt-enable-lpd", valueType: .boolType, type: .bitTorrentRelated)
	static let btExcludeTracker = Aria2Option("bt-exclude-tracker", valueType: .string(str: "URIS"), type: .bitTorrentRelated)
	static let btExternalIp = Aria2Option("bt-external-ip", valueType: .string(str: "a numeric IP address"), type: .bitTorrentRelated)
	static let btForceEncryption = Aria2Option("bt-force-encryption", valueType: .boolType, type: .bitTorrentRelated)
	static let btHashCheckSeed = Aria2Option("bt-hash-check-seed", valueType: .boolType, type: .bitTorrentRelated)
	static let btKeepAliveInterval = Aria2Option("bt-keep-alive-interval", valueType: .number(min: 1, max: 120), type: .bitTorrentRelated)
    static let btLoadSavedMetadata = Aria2Option("bt-load-saved-metadata", valueType: .boolType, type: .bitTorrentRelated)
	static let btLpdInterface = Aria2Option("bt-lpd-interface", valueType: .string(str: "Possible Values: interface, IP address"), type: .bitTorrentRelated)
	static let btMaxOpenFiles = Aria2Option("bt-max-open-files", valueType: .number(min: 1, max: -1), type: .bitTorrentRelated)
	static let btMaxPeers = Aria2Option("bt-max-peers", valueType: .number(min: 0, max: -1), type: .bitTorrentRelated)
	static let btMetadataOnly = Aria2Option("bt-metadata-only", valueType: .boolType, type: .bitTorrentRelated)
	static let btMinCryptoLevel = Aria2Option("bt-min-crypto-level", valueType: .parameter(p: [.plain, .arc4]), type: .bitTorrentRelated)
	static let btPrioritizePiece = Aria2Option("bt-prioritize-piece", valueType: .string(str: "head[=<SIZE>],tail[=<SIZE>]"), type: .bitTorrentRelated) /* PrioritizePieceOptionHandler */
	static let btRemoveUnselectedFile = Aria2Option("bt-remove-unselected-file", valueType: .boolType, type: .bitTorrentRelated)
	static let btRequestPeerSpeedLimit = Aria2Option("bt-request-peer-speed-limit", valueType: .unitNumber(min: UnitNumber(0), max: UnitNumber(0)), type: .bitTorrentRelated)
	static let btRequestTimeout = Aria2Option("bt-request-timeout", valueType: .number(min: 1, max: 600), type: .bitTorrentRelated)
	static let btRequireCrypto = Aria2Option("bt-require-crypto", valueType: .boolType, type: .bitTorrentRelated)
	static let btSaveMetadata = Aria2Option("bt-save-metadata", valueType: .boolType, type: .bitTorrentRelated)
	static let btSeedUnverified = Aria2Option("bt-seed-unverified", valueType: .boolType, type: .bitTorrentRelated)
	static let btTimeout = Aria2Option("bt-timeout", valueType: .number(min: 1, max: 600), type: .bitTorrentRelated)
	static let btStopTimeout = Aria2Option("bt-stop-timeout", valueType: .number(min: 0, max: -1), type: .bitTorrentRelated)
	static let btTracker = Aria2Option("bt-tracker", valueType: .string(str: "SEC"), type: .bitTorrentRelated)
	static let btTrackerConnectTimeout = Aria2Option("bt-tracker-connect-timeout", valueType: .number(min: 1, max: 600), type: .bitTorrentRelated)
	static let btTrackerInterval = Aria2Option("bt-tracker-interval", valueType: .number(min: 0, max: -1), type: .bitTorrentRelated)
	static let btTrackerTimeout = Aria2Option("bt-tracker-timeout", valueType: .number(min: 1, max: 600), type: .bitTorrentRelated)
	static let caCertificate = Aria2Option("ca-certificate", valueType: .localFilePath, type: .httpRelated)
	static let certificate = Aria2Option("certificate", valueType: .string(str: "string that your file system recognizes as a file name."), type: .httpRelated)
	static let checkCertificate = Aria2Option("check-certificate", valueType: .boolType, type: .httpRelated)
	static let checkIntegrity = Aria2Option("check-integrity", valueType: .boolType, type: .general)
	static let checksum = Aria2Option("checksum", valueType: .string(str: "hashType=digest"), type: .general) /* ChecksumOptionHandler */
	
	
	static let conditionalGet = Aria2Option("conditional-get", valueType: .boolType, type: .general)
	static let confPath = Aria2Option("conf-path", valueType: .string(str: "PATH"), type: .general)
	static let connectTimeout = Aria2Option("connect-timeout", valueType: .number(min: 1, max: 600), type: .general)
	static let consoleLogLevel = Aria2Option("console-log-level", valueType: .parameter(p: [.debug, .info, .notice, .warn, .error]), type: .general)
	static let contentDispositionDefaultUtf8 = Aria2Option("content-disposition-default-utf8", valueType: .boolType, type: .httpRelated)
	static let continue🤣 = Aria2Option("continue", valueType: .boolType, type: .general)
	static let daemon = Aria2Option("daemon", valueType: .boolType, type: .general)
	static let deferredInput = Aria2Option("deferred-input", valueType: .boolType, type: .general)
	static let dhtEntryPoint = Aria2Option("dht-entry-point", valueType: .hostPort, type: .bitTorrentRelated)
	static let dhtEntryPoint6 = Aria2Option("dht-entry-point6", valueType: .hostPort, type: .bitTorrentRelated)
	static let dhtEntryPointHost = Aria2Option("dht-entry-point-host", valueType: .hostPort, type: .bitTorrentRelated)
	static let dhtEntryPointHost6 = Aria2Option("dht-entry-point-host6", valueType: .hostPort, type: .bitTorrentRelated)
	static let dhtEntryPointPort = Aria2Option("dht-entry-point-port", valueType: .hostPort, type: .bitTorrentRelated)
	static let dhtEntryPointPort6 = Aria2Option("dht-entry-point-port6", valueType: .hostPort, type: .bitTorrentRelated)
	static let dhtFilePath = Aria2Option("dht-file-path", valueType: .localFilePath, type: .bitTorrentRelated)
	static let dhtFilePath6 = Aria2Option("dht-file-path6", valueType: .localFilePath, type: .bitTorrentRelated)
	static let dhtListenAddr = Aria2Option("dht-listen-addr", valueType: .string(str: "ADDR"), type: .bitTorrentRelated)
	static let dhtListenAddr6 = Aria2Option("dht-listen-addr6", valueType: .string(str: "ADDR"), type: .bitTorrentRelated)
	static let dhtListenPort = Aria2Option("dht-listen-port", valueType: .integerRange(min: 1024, max: Int(UINT16_MAX)), type: .bitTorrentRelated)
	static let dhtMessageTimeout = Aria2Option("dht-message-timeout", valueType: .number(min: 1, max: 60), type: .bitTorrentRelated)
	static let dir = Aria2Option("dir", valueType: .localFilePath, type: .general)
	static let disableIpv6 = Aria2Option("disable-ipv6", valueType: .boolType, type: .general)
	static let diskCache = Aria2Option("disk-cache", valueType: .unitNumber(min: UnitNumber("16M"), max: UnitNumber(0)), type: .general)
	static let dnsTimeout = Aria2Option("dns-timeout", valueType: .number(min: 1, max: 60), type: .general)
	static let downloadResult = Aria2Option("download-result", valueType: .parameter(p: [.default😅, .full, .hide]), type: .general)
	static let dryRun = Aria2Option("dry-run", valueType: .boolType, type: .general)
	static let dscp = Aria2Option("dscp", valueType: .number(min: 0, max: -1), type: .general)
	static let enableAsyncDns6 = Aria2Option("enable-async-dns6", valueType: .boolType, type: .general)
	static let enableColor = Aria2Option("enable-color", valueType: .boolType, type: .general)
	static let enableDht = Aria2Option("enable-dht", valueType: .boolType, type: .bitTorrentRelated)
	static let enableDht6 = Aria2Option("enable-dht6", valueType: .boolType, type: .bitTorrentRelated)
	static let enableHttpKeepAlive = Aria2Option("enable-http-keep-alive", valueType: .boolType, type: .httpRelated)
	static let enableHttpPipelining = Aria2Option("enable-http-pipelining", valueType: .boolType, type: .httpRelated)
	static let enableMmap = Aria2Option("enable-mmap", valueType: .boolType, type: .general)
	static let enablePeerExchange = Aria2Option("enable-peer-exchange", valueType: .boolType, type: .bitTorrentRelated)
	static let enableRpc = Aria2Option("enable-rpc", valueType: .boolType, type: .general)
	static let eventPoll = Aria2Option("event-poll", valueType: .parameter(p: [.epoll, .select]), type: .general)
	static let fileAllocation = Aria2Option("file-allocation", valueType: .parameter(p: [.prealloc, .falloc, .none]), type: .general)
	static let followMetalink = Aria2Option("follow-metalink", valueType: .parameter(p: [.true🤣, .false😂, .mem]), type: .metalinkRelated)
	static let followTorrent = Aria2Option("follow-torrent", valueType: .parameter(p: [.true🤣, .false😂, .mem]), type: .bitTorrentRelated)
	static let forceSave = Aria2Option("force-save", valueType: .boolType, type: .general)
	static let forceSequential = Aria2Option("force-sequential", valueType: .boolType, type: .general)
	static let ftpPasswd = Aria2Option("ftp-passwd", valueType: .string(str: "PASSWD"), type: .ftpRelated)
	static let ftpPasv = Aria2Option("ftp-pasv", valueType: .boolType, type: .ftpRelated)
	static let ftpProxy = Aria2Option("ftp-proxy", valueType: .httpProxy, type: .proxyRelated)
	static let ftpProxyPasswd = Aria2Option("ftp-proxy-passwd", valueType: .string(str: "PASSWD"), type: .proxyRelated)
	static let ftpProxyUser = Aria2Option("ftp-proxy-user", valueType: .string(str: "USER"), type: .proxyRelated)
	static let ftpReuseConnection = Aria2Option("ftp-reuse-connection", valueType: .boolType, type: .ftpRelated)
	static let ftpType = Aria2Option("ftp-type", valueType: .parameter(p: [.binary, .ascii]), type: .ftpRelated)
	static let ftpUser = Aria2Option("ftp-user", valueType: .string(str: "USER"), type: .ftpRelated)
	static let gid = Aria2Option("gid", valueType: .string(str: "GID"), type: .general)
	static let hashCheckOnly = Aria2Option("hash-check-only", valueType: .boolType, type: .general)
	static let header = Aria2Option("header", valueType: .string(str: "Header"), type: .httpRelated) /* CumulativeOptionHandler */
	static let help = Aria2Option("help", valueType: .string(str: "HELP"), type: .other)
	static let httpAcceptGzip = Aria2Option("http-accept-gzip", valueType: .boolType, type: .httpRelated)
	static let httpAuthChallenge = Aria2Option("http-auth-challenge", valueType: .boolType, type: .httpRelated)
	static let httpNoCache = Aria2Option("http-no-cache", valueType: .boolType, type: .httpRelated)
	static let httpPasswd = Aria2Option("http-passwd", valueType: .string(str: "PASSWD"), type: .httpRelated)
	static let httpProxy = Aria2Option("http-proxy", valueType: .httpProxy, type: .proxyRelated)
	static let httpProxyPasswd = Aria2Option("http-proxy-passwd", valueType: .string(str: "PASSWD"), type: .proxyRelated)
	static let httpProxyUser = Aria2Option("http-proxy-user", valueType: .string(str: "USER"), type: .proxyRelated)
	static let httpUser = Aria2Option("http-user", valueType: .string(str: "USER"), type: .httpRelated)
	static let httpsProxy = Aria2Option("https-proxy", valueType: .httpProxy, type: .proxyRelated)
	static let httpsProxyPasswd = Aria2Option("https-proxy-passwd", valueType: .string(str: "PASSWD"), type: .proxyRelated)
	static let httpsProxyUser = Aria2Option("https-proxy-user", valueType: .string(str: "USER"), type: .proxyRelated)
	static let humanReadable = Aria2Option("human-readable", valueType: .boolType, type: .general)
	static let indexOut = Aria2Option("index-out", valueType: .string(str: "1*digit '=' a string that your file system recognizes as a file name."), type: .bitTorrentRelated) /* IndexOutOptionHandler */
	static let inputFile = Aria2Option("input-file", valueType: .localFilePath, type: .general)
	static let interface = Aria2Option("interface", valueType: .string(str: "interface, IP address, hostname"), type: .general)
	static let keepUnfinishedDownloadResult = Aria2Option("keep-unfinished-download-result", valueType: .boolType, type: .general)
	static let listenPort = Aria2Option("listen-port", valueType: .integerRange(min: 1024, max: Int(UINT16_MAX)), type: .bitTorrentRelated)
	static let loadCookies = Aria2Option("load-cookies", valueType: .localFilePath, type: .httpRelated)
	static let log = Aria2Option("log", valueType: .localFilePath, type: .general)
	static let logLevel = Aria2Option("log-level", valueType: .parameter(p: [.debug, .info, .notice, .warn, .error]), type: .general)
	static let lowestSpeedLimit = Aria2Option("lowest-speed-limit", valueType: .unitNumber(min: UnitNumber(0), max: UnitNumber(0)), type: .general)
	static let maxConcurrentDownloads = Aria2Option("max-concurrent-downloads", valueType: .number(min: 1, max: -1), type: .general)
	static let maxConnectionPerServer = Aria2Option("max-connection-per-server", valueType: .number(min: 1, max: 16), type: .general)
	static let maxDownloadLimit = Aria2Option("max-download-limit", valueType: .unitNumber(min: UnitNumber(0), max: UnitNumber(0)), type: .general)
	static let maxDownloadResult = Aria2Option("max-download-result", valueType: .number(min: 1, max: -1), type: .general)
	static let maxDownloads = Aria2Option("max-downloads", valueType: .number(min: 1, max: -1), type: .general)
	static let maxFileNotFound = Aria2Option("max-file-not-found", valueType: .number(min: 0, max: -1), type: .general)
	static let maxHttpPipelining = Aria2Option("max-http-pipelining", valueType: .number(min: 1, max: 8), type: .httpRelated)
	static let maxMmapLimit = Aria2Option("max-mmap-limit", valueType: .unitNumber(min: UnitNumber(0), max: UnitNumber(0)), type: .general)
	static let maxOverallDownloadLimit = Aria2Option("max-overall-download-limit", valueType: .unitNumber(min: UnitNumber(0), max: UnitNumber(0)), type: .general)
	static let maxOverallUploadLimit = Aria2Option("max-overall-upload-limit", valueType: .unitNumber(min: UnitNumber(0), max: UnitNumber(0)), type: .bitTorrentRelated)
	static let maxResumeFailureTries = Aria2Option("max-resume-failure-tries", valueType: .number(min: 0, max: -1), type: .general)
	static let maxTries = Aria2Option("max-tries", valueType: .number(min: 0, max: -1), type: .general)
	static let maxUploadLimit = Aria2Option("max-upload-limit", valueType: .unitNumber(min: UnitNumber(0), max: UnitNumber(0)), type: .bitTorrentRelated)
	static let metalinkBaseUri = Aria2Option("metalink-base-uri", valueType: .string(str: "URL"), type: .metalinkRelated)
	static let metalinkEnableUniqueProtocol = Aria2Option("metalink-enable-unique-protocol", valueType: .boolType, type: .metalinkRelated)
	static let metalinkFile = Aria2Option("metalink-file", valueType: .localFilePath, type: .metalinkRelated)
	static let metalinkLanguage = Aria2Option("metalink-language", valueType: .string(str: "LANGUAGE"), type: .metalinkRelated)
	static let metalinkLocation = Aria2Option("metalink-location", valueType: .string(str: "LOCATION"), type: .metalinkRelated)
	static let metalinkOs = Aria2Option("metalink-os", valueType: .string(str: "OS"), type: .metalinkRelated)
	static let metalinkPreferredProtocol = Aria2Option("metalink-preferred-protocol", valueType: .parameter(p: [.http, .https, .ftp, .none]), type: .metalinkRelated)
	static let metalinkVersion = Aria2Option("metalink-version", valueType: .string(str: "VERSION"), type: .metalinkRelated)
	static let minSplitSize = Aria2Option("min-split-size", valueType: .unitNumber(min: UnitNumber("1M"), max: UnitNumber("1G")), type: .general)
	static let minTlsVersion = Aria2Option("min-tls-version", valueType: .parameter(p: [.sslv3, .tlsv1, .tlsv11, .tlsv12]), type: .general)
	static let multipleInterface = Aria2Option("multiple-interface", valueType: .string(str: "interface, IP address, hostname"), type: .general)
	static let netrcPath = Aria2Option("netrc-path", valueType: .localFilePath, type: .general)
	static let noConf = Aria2Option("no-conf", valueType: .boolType, type: .general)
	static let noFileAllocationLimit = Aria2Option("no-file-allocation-limit", valueType: .unitNumber(min: UnitNumber(0), max: UnitNumber(0)), type: .general)
	static let noNetrc = Aria2Option("no-netrc", valueType: .boolType, type: .general)
	static let noProxy = Aria2Option("no-proxy", valueType: .string(str: "HOSTNAME,DOMAIN,NETWORK/CIDR"), type: .proxyRelated) /* "HOSTNAME,DOMAIN,NETWORK/CIDR" */
	static let onBtDownloadComplete = Aria2Option("on-bt-download-complete", valueType: .localFilePath, type: .bitTorrentRelated)
	static let onDownloadComplete = Aria2Option("on-download-complete", valueType: .localFilePath, type: .general)
	static let onDownloadError = Aria2Option("on-download-error", valueType: .localFilePath, type: .general)
	static let onDownloadPause = Aria2Option("on-download-pause", valueType: .localFilePath, type: .general)
	static let onDownloadStart = Aria2Option("on-download-start", valueType: .localFilePath, type: .general)
	static let onDownloadStop = Aria2Option("on-download-stop", valueType: .localFilePath, type: .general)
	static let optimizeConcurrentDownloads = Aria2Option("optimize-concurrent-downloads", valueType: .optimizeConcurrentDownloads, type: .general)
	static let optimizeConcurrentDownloadsCoeffA = Aria2Option("optimize-concurrent-downloads-coeffA", valueType: .optimizeConcurrentDownloads, type: .general)
	static let optimizeConcurrentDownloadsCoeffB = Aria2Option("optimize-concurrent-downloads-coeffB", valueType: .optimizeConcurrentDownloads, type: .general)
	static let out = Aria2Option("out", valueType: .localFilePath, type: .general)
	static let parameterizedUri = Aria2Option("parameterized-uri", valueType: .boolType, type: .general)
	static let pause = Aria2Option("pause", valueType: .boolType, type: .general)
	static let pauseMetadata = Aria2Option("pause-metadata", valueType: .boolType, type: .general)
    static let peerAgent = Aria2Option("peer-agent", valueType: .string(str: "PEER_AGENT"), type: .bitTorrentRelated)
	static let peerConnectionTimeout = Aria2Option("peer-connection-timeout", valueType: .number(min: 1, max: 600), type: .bitTorrentRelated)
	static let peerIdPrefix = Aria2Option("peer-id-prefix", valueType: .string(str: "a string, less than or equals to 20 bytes length"), type: .bitTorrentRelated)
	static let pieceLength = Aria2Option("piece-length", valueType: .unitNumber(min: UnitNumber("1M"), max: UnitNumber("1G")), type: .general)
	static let privateKey = Aria2Option("private-key", valueType: .localFilePath, type: .httpRelated)
	static let proxyMethod = Aria2Option("proxy-method", valueType: .parameter(p: [.get, .tunnel]), type: .proxyRelated)
	
	static let quiet = Aria2Option("quiet", valueType: .boolType, type: .general)
	static let realtimeChunkChecksum = Aria2Option("realtime-chunk-checksum", valueType: .boolType, type: .general)
	static let referer = Aria2Option("referer", valueType: .string(str: "REFERER"), type: .general)
	static let remoteTime = Aria2Option("remote-time", valueType: .boolType, type: .general)
	static let removeControlFile = Aria2Option("remove-control-file", valueType: .boolType, type: .general)
	static let retryWait = Aria2Option("retry-wait", valueType: .number(min: 0, max: 600), type: .general)
	static let reuseUri = Aria2Option("reuse-uri", valueType: .boolType, type: .general)
	static let rlimitNofile = Aria2Option("rlimit-nofile", valueType: .number(min: 1, max: -1), type: .general)
	static let rpcAllowOriginAll = Aria2Option("rpc-allow-origin-all", valueType: .boolType, type: .general)
	static let rpcCertificate = Aria2Option("rpc-certificate", valueType: .localFilePath, type: .general)
	static let rpcListenAll = Aria2Option("rpc-listen-all", valueType: .boolType, type: .general)
	static let rpcListenPort = Aria2Option("rpc-listen-port", valueType: .number(min: 1024, max: Int(UINT16_MAX)), type: .general)
	static let rpcMaxRequestSize = Aria2Option("rpc-max-request-size", valueType: .unitNumber(min: UnitNumber(0), max: UnitNumber(0)), type: .general)
	static let rpcPasswd = Aria2Option("rpc-passwd", valueType: .string(str: "PASSWD"), type: .general)
	static let rpcPrivateKey = Aria2Option("rpc-private-key", valueType: .localFilePath, type: .general)
	static let rpcSaveUploadMetadata = Aria2Option("rpc-save-upload-metadata", valueType: .boolType, type: .general)
	static let rpcSecret = Aria2Option("rpc-secret", valueType: .string(str: "TOKEN"), type: .general)
	static let rpcSecure = Aria2Option("rpc-secure", valueType: .boolType, type: .general)
	static let rpcUser = Aria2Option("rpc-user", valueType: .string(str: "Migrate to --rpc-secret option as soon as possible."), type: .general)
	static let saveCookies = Aria2Option("save-cookies", valueType: .localFilePath, type: .httpRelated)
	static let saveNotFound = Aria2Option("save-not-found", valueType: .boolType, type: .general)
	static let saveSession = Aria2Option("save-session", valueType: .localFilePath, type: .general)
	static let saveSessionInterval = Aria2Option("save-session-interval", valueType: .number(min: 0, max: -1), type: .general)
	static let seedRatio = Aria2Option("seed-ratio", valueType: .floatNumber(min: 1.0, max: -1), type: .bitTorrentRelated)
	static let seedTime = Aria2Option("seed-time", valueType: .number(min: 1, max: 1024), type: .bitTorrentRelated)
	static let selectFile = Aria2Option("select-file", valueType: .integerRange(min: 1, max: 1024), type: .bitTorrentRelated)
	static let selectLeastUsedHost = Aria2Option("select-least-used-host", valueType: .boolType, type: .general)
	static let serverStatIf = Aria2Option("server-stat-if", valueType: .localFilePath, type: .general)
	static let serverStatOf = Aria2Option("server-stat-of", valueType: .localFilePath, type: .general)
	static let serverStatTimeout = Aria2Option("server-stat-timeout", valueType: .number(min: 0, max: Int(INT_MAX)), type: .general)
	
	static let showConsoleReadout = Aria2Option("show-console-readout", valueType: .boolType, type: .general)
	static let showFiles = Aria2Option("show-files", valueType: .boolType, type: .bitTorrentRelated)
	static let socketRecvBufferSize = Aria2Option("socket-recv-buffer-size", valueType: .unitNumber(min: UnitNumber(0), max: UnitNumber("16M")), type: .general)
	static let split = Aria2Option("split", valueType: .number(min: 1, max: -1), type: .general)
	static let sshHostKeyMd = Aria2Option("ssh-host-key-md", valueType: .string(str: "hashType=digest"), type: .ftpRelated) /* ChecksumOptionHandler */
	static let startupIdleTime = Aria2Option("startup-idle-time", valueType: .number(min: 1, max: 60), type: .general)
	static let stderr = Aria2Option("stderr", valueType: .boolType, type: .general)
	static let stop = Aria2Option("stop", valueType: .number(min: 0, max: Int(INT_MAX)), type: .general)
	static let stopWithProcess = Aria2Option("stop-with-process", valueType: .number(min: 0, max: -1), type: .general)
	static let streamPieceSelector = Aria2Option("stream-piece-selector", valueType: .parameter(p: [.default😅, .inorder]), type: .general)
	static let summaryInterval = Aria2Option("summary-interval", valueType: .number(min: 0, max: Int(INT_MAX)), type: .general)
	static let timeout = Aria2Option("timeout", valueType: .number(min: 1, max: 600), type: .general)
	static let torrentFile = Aria2Option("torrent-file", valueType: .localFilePath, type: .bitTorrentRelated)
	static let truncateConsoleReadout = Aria2Option("truncate-console-readout", valueType: .boolType, type: .general)
	static let uriSelector = Aria2Option("uri-selector", valueType: .parameter(p: [.inorder, .feedback, .adaptive]), type: .general)
	static let useHead = Aria2Option("use-head", valueType: .boolType, type: .httpRelated)
	static let userAgent = Aria2Option("user-agent", valueType: .string(str: "USER_AGENT"), type: .httpRelated)
	static let version = Aria2Option("version", valueType: .string(str: "VERSION"), type: .other)
	
}


struct UnitNumber {
	typealias RawValue = UInt64
	var rawValue: RawValue
	enum unit: UInt64 {
		case K = 1024
		case M = 1048576
		case G = 1073741824
	}
	
	init(_ int: Int) {
		rawValue = UInt64(int)
	}
	init(_ string: String) {
        let intStr = string.dropLast()
		if let int = UInt64(string) {
			if int > UINT64_MAX {
				rawValue = UINT64_MAX
			} else {
				rawValue = int
			}
		} else if let int = UInt64(intStr),
			let last = string.last {
			var value: UInt64 = 0
			switch last {
			case "K", "k":
				value = unit.K.rawValue
			case "M", "m":
				value = unit.M.rawValue
			case "G", "g":
				value = unit.G.rawValue
			default:
				value = 0
			}
			value = value == 0 ? 1 : value
			if int > UINT64_MAX / value {
				rawValue = UINT64_MAX
			} else {
				rawValue = int * value
			}
		} else {
			rawValue = 0
		}
	}
	var stringValue: String {
		get {
			switch rawValue {
			case 0..<unit.K.rawValue:
				return "\(rawValue)"
			case unit.K.rawValue..<unit.M.rawValue:
				return "\(rawValue/unit.K.rawValue)K"
			case unit.M.rawValue..<unit.G.rawValue:
				return "\(rawValue/unit.M.rawValue)M"
			case unit.G.rawValue..<UINT64_MAX:
				return "\(rawValue/unit.G.rawValue)G"
			default:
				return ""
			}
		}
	}
}
