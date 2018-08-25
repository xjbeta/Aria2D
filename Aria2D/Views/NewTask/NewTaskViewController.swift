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
        
		if !torrentTask, downloadUrlTextField.stringValue != "" {
            Aria2.shared.addUri(downloadUrlTextField.stringValue, options: options)
		} else if torrentTask, torrentData != "" {
			Aria2.shared.addTorrent(torrentData, options: options)
		}
		dismiss(self)
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
    
    var torrentTask = false
    var fileURL: URL? = nil {
        didSet {
            if let url = fileURL {
                self.setTorrentPath(url)
                self.urlManager(true)
            }
        }
    }
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
        
        if let url = fileURL {
            setTorrentPath(url)
            urlManager(true)
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
        switch option.valueType {
        case .bool:
            return 21
        case .parameter:
            return 22
        case .number(min: _, max: _), .floatNumber(min: _, max: _):
            return 28
        default:
            if let view = tableView.makeView(withIdentifier: .aria2TextOptionCellView, owner: nil) as? Aria2TextOptionCellView {
                view.bounds.size.width = tableView.bounds.size.width
                view.valueTextField.stringValue = allowAria2Options[option] ?? ""
                view.layoutSubtreeIfNeeded()
                view.autoResize()
                return view.frame.height
            } else {
                return 28
            }
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var identifier: NSUserInterfaceItemIdentifier? = nil
        
        let option = allowOptions.filter({
            $0.preferencesType == optionsType
        })[row]
        switch option.valueType {
        case .bool:
            identifier = .aria2BoolOptionCellView
        case .parameter:
            identifier = .aria2ParameterOptionCellView
        case .number(min: _, max: _), .floatNumber(min: _, max: _):
            identifier = .aria2NumberOptionTextView
        default:
            identifier = .aria2TextOptionCellView
        }
        if let identifier = identifier {
            switch identifier {
            case .aria2BoolOptionCellView:
                if let view = tableView.makeView(withIdentifier: identifier, owner: nil) as? Aria2BoolOptionCellView {
                    view.textField?.stringValue = option.rawValue
                    
//                    view.textField?.toolTip = "fsadfsdghdfgsdsalbfhkjbadlhf"
                    view.checkButton.state = allowAria2Options[option] == "true" ? .on : .off
                    view.option = option
                    view.delegate = self
                    return view
                }
            case .aria2ParameterOptionCellView:
                if let view = tableView.makeView(withIdentifier: identifier, owner: nil) as? Aria2ParameterOptionCellView {
                    view.textField?.stringValue = option.rawValue
//                    view.textField?.toolTip = "fsadfsdghdfgsdsalbfhkjbadlhf"
                    switch option.valueType {
                    case .parameter(p: let p):
                        view.comboBox.removeAllItems()
                        view.comboBox.addItems(withObjectValues: p.map({ $0.rawValue }))
                        view.comboBox.selectItem(withObjectValue: allowAria2Options[option])
                    default:break
                    }
                    view.option = option
                    view.delegate = self
                    return view
                }
            case .aria2TextOptionCellView:
                if let view = tableView.makeView(withIdentifier: identifier, owner: nil) as? Aria2TextOptionCellView {
                    view.textField?.stringValue = option.rawValue
                    
//                    view.textField?.toolTip = "fsadfsdghdfgsdsalbfhkjbadlhf"
                    view.valueTextField.placeholderString = option.toolTisString()
                    switch option.valueType {
                    case .unitNumber(min: _, max: _):
                        view.unitNumberValue = UnitNumber(allowAria2Options[option] ?? "")
                        view.valueTextField?.stringValue = view.unitNumberValue.stringValue
                        
                    default:
                        view.valueTextField.stringValue = allowAria2Options[option] ?? ""
                    }
                    
                    view.option = option
                    view.delegate = self
                    return view
                }
            case .aria2NumberOptionTextView:
                if let view = tableView.makeView(withIdentifier: identifier, owner: nil) as? Aria2NumberOptionTextView {
                    view.textField?.stringValue = option.rawValue
//                    view.textField?.toolTip = "fsadfsdghdfgsdsalbfhkjbadlhf"
                    
                    view.numberTextField.placeholderString = option.toolTisString()
                    view.numberTextField.integerValue = Int(allowAria2Options[option] ?? "") ?? 0
                    switch option.valueType {
                    case .number(min: let min, max: let max):
                        view.numberFormatter.maximumFractionDigits = 0
                        view.numberFormatter.minimum = min as NSNumber
                        view.numberFormatter.maximum = max as NSNumber
                    case .floatNumber(min: let min, max: let max):
                        view.numberFormatter.maximumFractionDigits = 1
                        view.numberFormatter.minimum = min as NSNumber
                        view.numberFormatter.maximum = max as NSNumber
                        break
                    default:
                        break
                    }
                    view.option = option
                    view.delegate = self
                    return view
                }
            default:
                break
            }
        }
        return nil
    }
}

extension NewTaskViewController: Aria2OptionValueDelegate {
    func resizeTableView(_ height: CGFloat, for option: Aria2Option) {
        let options = allowOptions.filter({
            $0.preferencesType == optionsType
        })
        if let row = options.firstIndex(of: option) {
            optionsTableView.noteHeightOfRows(withIndexesChanged: IndexSet(integer: row))
        }
    }
    
    func aria2OptionValueDidChanged(_ value: String, for option: Aria2Option) {
        allowAria2Options[option] = value
    }
    
}
