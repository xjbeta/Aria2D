//
//  NewTaskViewController.swift
//  Aria2D
//
//  Created by xjbeta on 2016/9/29.
//  Copyright © 2016年 xjbeta. All rights reserved.
//

import Cocoa

class NewTaskViewController: NSViewController {
    let allowOptions: [Aria2Option] = [.allProxy,
                                       .allProxyPasswd,
                                       .allProxyUser,
                                       .allowOverwrite,
                                       .allowPieceLengthChange,
                                       .alwaysResume,
                                       .asyncDns,
                                       .autoFileRenaming,
                                       .btEnableHookAfterHashCheck,
                                       .btEnableLpd,
                                       .btExcludeTracker,
                                       .btExternalIp,
                                       .btForceEncryption,
                                       .btHashCheckSeed,
                                       .btLoadSavedMetadata,
                                       .btMaxPeers,
                                       .btMetadataOnly,
                                       .btMinCryptoLevel,
                                       .btPrioritizePiece,
                                       .btRemoveUnselectedFile,
                                       .btRequestPeerSpeedLimit,
                                       .btRequireCrypto,
                                       .btSaveMetadata,
                                       .btSeedUnverified,
                                       .btStopTimeout,
                                       .btTracker,
                                       .btTrackerConnectTimeout,
                                       .btTrackerInterval,
                                       .btTrackerTimeout,
                                       .checkIntegrity,
                                       .checksum,
                                       .conditionalGet,
                                       .connectTimeout,
                                       .contentDispositionDefaultUtf8,
                                       .continue🤣,
                                       .dir,
                                       .dryRun,
                                       .enableHttpKeepAlive,
                                       .enableHttpPipelining,
                                       .enableMmap,
                                       .enablePeerExchange,
                                       .fileAllocation,
                                       .followMetalink,
                                       .followTorrent,
                                       .forceSave,
                                       .ftpPasswd,
                                       .ftpPasv,
                                       .ftpProxy,
                                       .ftpProxyPasswd,
                                       .ftpProxyUser,
                                       .ftpReuseConnection,
                                       .ftpType,
                                       .ftpUser,
                                       .gid,
                                       .hashCheckOnly,
                                       .header,
                                       .httpAcceptGzip,
                                       .httpAuthChallenge,
                                       .httpNoCache,
                                       .httpPasswd,
                                       .httpProxy,
                                       .httpProxyPasswd,
                                       .httpProxyUser,
                                       .httpUser,
                                       .httpsProxy,
                                       .httpsProxyPasswd,
                                       .httpsProxyUser,
                                       .indexOut,
                                       .lowestSpeedLimit,
                                       .maxConnectionPerServer,
                                       .maxDownloadLimit,
                                       .maxFileNotFound,
                                       .maxMmapLimit,
                                       .maxResumeFailureTries,
                                       .maxTries,
                                       .maxUploadLimit,
                                       .metalinkBaseUri,
                                       .metalinkEnableUniqueProtocol,
                                       .metalinkLanguage,
                                       .metalinkLocation,
                                       .metalinkOs,
                                       .metalinkPreferredProtocol,
                                       .metalinkVersion,
                                       .minSplitSize,
                                       .noFileAllocationLimit,
                                       .noNetrc,
                                       .noProxy,
                                       .out,
                                       .parameterizedUri,
                                       .pause,
                                       .pauseMetadata,
                                       .pieceLength,
                                       .proxyMethod,
                                       .realtimeChunkChecksum,
                                       .referer,
                                       .remoteTime,
                                       .removeControlFile,
                                       .retryWait,
                                       .reuseUri,
                                       .rpcSaveUploadMetadata,
                                       .seedRatio,
                                       .seedTime,
                                       .selectFile,
                                       .split,
                                       .sshHostKeyMd,
                                       .streamPieceSelector,
                                       .timeout,
                                       .uriSelector,
                                       .useHead,
                                       .userAgent]

    var allowAria2Options: [Aria2Option: String] = [:]
    
	@IBAction func selectTorrent(_ sender: Any) {
		selectTorrentFile()
	}

	@IBAction func download(_ sender: Any) {
        let options = allowAria2Options.reduce([String: String]()) { result, dic in
            var re = result
            re[dic.key.rawValue] = dic.value
            return re
        }
        
        if let _ = fileURL, torrentData != "" {
            Aria2.shared.addTorrent(torrentData, options: options)
            dismiss(self)
        } else if downloadUrlTextField.stringValue != "" {
            Aria2.shared.addUri(downloadUrlTextField.stringValue, options: options)
            dismiss(self)
        }
        
	}
	
	@IBOutlet var showOptionsButton: NSButton!
	@IBAction func showOptions(_ sender: Any) {
		let show = showOptionsButton.state == .on
        optionsGridRow.isHidden = !show
        optionsTypeGridView.isHidden = !show
        downloadButton.keyEquivalent = show ? "" : "\r"
	}
	
	@IBOutlet var downloadUrlTextField: DownloadUrlTextField!
	@IBOutlet var torrentFileInfoButton: NSButton!
    @IBOutlet weak var downloadButton: NSButton!
    
    @IBOutlet weak var optionsGridRow: NSGridRow!
    @IBOutlet weak var optionsManagerGridRow: NSGridRow!
    @IBOutlet weak var optionsTypeGridView: NSGridRow!
    @IBOutlet weak var downloadInfoGridRow: NSGridRow!
    
    @IBOutlet weak var optionsTableView: NSTableView!
    @IBOutlet weak var optionsSegmentControl: NSSegmentedControl!
    @IBAction func changeOptionsType(_ sender: Any) {
        optionsTableView.reloadData()
    }
    
    var optionsType: Aria2Option.PreferencesType {
        get {
            switch optionsSegmentControl.selectedSegment {
            case 0: return .general
            case 1: return .ftpRelated
            case 2: return .httpRelated
            case 3: return .proxyRelated
            case 4: return .bitTorrentRelated
            case 5: return .metalinkRelated
            case 6: return .other
            default: return .none
            }
        }
    }
    
    var preparedInfo = [String: String]()
    var fileURL: URL?
    
    var torrentData: String {
        get {
            do {
                if let url = fileURL {
                    return try Data(contentsOf: url).base64EncodedString()
                }
            } catch { }
            return ""
        }
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // remove the other options
        optionsSegmentControl.segmentCount = 6
        
		// init optionsView
        optionsGridRow.isHidden = true
        optionsTypeGridView.isHidden = true
        optionsManagerGridRow.isHidden = true
        downloadButton.keyEquivalent = "\r"
        
        Aria2.shared.getGlobalOption() {
            let options = Aria2Websocket.shared.aria2GlobalOption
            options.forEach {
                if self.allowOptions.contains($0.key) {
                    self.allowAria2Options[$0.key] = $0.value
                    DispatchQueue.main.async {
                        self.optionsTableView.reloadData()
                    }
                }
            }
        }
        
        
        if let file = preparedInfo["file"] {
            fileURL = URL(fileURLWithPath: file)
            setTorrentPath(URL(fileURLWithPath: file))
            urlManager(true)
        } else if let url = preparedInfo["url"] {
            downloadUrlTextField.stringValue = url
            urlManager(false)
        } else {
            urlManager(false)
        }
    }
	
    lazy var openPanel = NSOpenPanel()
    
	func selectTorrentFile() {
		openPanel.canChooseFiles = true
		openPanel.allowedFileTypes = ["torrent"]
		openPanel.allowsMultipleSelection = false
		if let window = view.window {
			openPanel.beginSheetModal(for: window) { result in
                if result == .OK, let path = self.openPanel.url {
                    self.fileURL = path
				}
			}
		}
	}
	
	func urlManager(_ isTorrent: Bool) {
        downloadUrlTextField.isHidden = isTorrent
        torrentFileInfoButton.isHidden = !isTorrent
        downloadInfoGridRow.height = isTorrent ? 17 : 70
	}
	
	func setTorrentPath(_ url: URL) {
		DispatchQueue.main.async {
			let image = NSWorkspace.shared.icon(forFileType: url.pathExtension)
			image.size = NSSize(width: 17, height: 17)
			self.torrentFileInfoButton.image = image
			self.torrentFileInfoButton.title = url.lastPathComponent
		}
	}
    
}

extension NewTaskViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return allowOptions.filter({
            $0.preferencesType == optionsType
        }).count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let option = allowOptions.filter({
            $0.preferencesType == optionsType
        })[row]
        let textFiled = NSTextFieldCell()
        textFiled.font = NSFont.systemFont(ofSize: 13)
        
        textFiled.stringValue = option.rawValue
        var heights: [CGFloat] = [24]
        heights.append(textFiled.cellSize(forBounds: NSRect(x: 0, y: 0, width: 180, height: 80)).height + 7)
        switch option.valueType {
        case .bool, .parameter, .number, .floatNumber:
            break
        default:
            textFiled.stringValue = allowAria2Options[option] ?? ""
            let width = tableView.bounds.size.width - 180 - 24 - tableView.intercellSpacing.width
            heights.append(textFiled.cellSize(forBounds: NSRect(x: 0, y: 0, width: width, height: 400)).height + 10)
        }
        return heights.max() ?? 24
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let option = allowOptions.filter({
            $0.preferencesType == optionsType
        })[row]
        if let view = tableView.makeView(withIdentifier: .aria2OptionCellView, owner: nil) as? Aria2OptionCellView {
            view.initValue(option: option, value: allowAria2Options[option] ?? "")
            view.delegate = self
            return view
        }
        return nil
    }
}

extension NewTaskViewController: Aria2OptionValueDelegate {
    func aria2OptionValueDidChanged(_ value: String, for option: Aria2Option) {
        allowAria2Options[option] = value
    }
    
    func resizeTableView(for option: Aria2Option) {
        let options = allowOptions.filter({
            $0.preferencesType == optionsType
        })
        if let row = options.firstIndex(of: option) {
            optionsTableView.noteHeightOfRows(withIndexesChanged: IndexSet(integer: row))
        }
    }
    
}
