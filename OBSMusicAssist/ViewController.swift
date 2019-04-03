//
//  ViewController.swift
//  OBSMusicAssist
//
//  Created by Maxwell Hubbard on 3/30/19.
//  Copyright © 2019 Maxwell Hubbard. All rights reserved.
//

import Cocoa
import CoreFoundation

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}

extension NSImageView {
    
    func downloadedFrom(url: URL, imageScaling mode: NSImageScaling = NSImageScaling.scaleProportionallyUpOrDown, complete: @escaping (Bool) -> Void) {
        imageScaling = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = NSImage(data: data)
                
                else { return }
            DispatchQueue.main.async() {
                self.image = image
                complete(true)
            }
            }.resume()
    }
    func downloadedFrom(link: String, imageScaling mode: NSImageScaling = NSImageScaling.scaleProportionallyUpOrDown, complete: @escaping (Bool) -> Void) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, imageScaling: mode, complete: complete)
    }
}

class ViewController: NSViewController {
    
    
    @IBOutlet weak var albumArtImage: NSImageView!
    @IBOutlet weak var songLabel: NSTextField!
    @IBOutlet weak var artistLabel: NSTextField!
    @IBOutlet weak var albumLabel: NSTextField!
    @IBOutlet weak var songPath: NSTextField!
    @IBOutlet weak var artistPath: NSTextField!
    @IBOutlet weak var coverPath: NSTextField!
    var testImage: NSImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        testImage = NSImageView()
        
        try? FileManager.default.createDirectory(at: getDocumentsDirectory().appendingPathComponent("OBSMusicAssist"), withIntermediateDirectories: true, attributes: nil)
        
        songPath.stringValue = getDocumentsDirectory().appendingPathComponent("OBSMusicAssist").appendingPathComponent("song.txt").absoluteString
        
        artistPath.stringValue = getDocumentsDirectory().appendingPathComponent("OBSMusicAssist", isDirectory: true).appendingPathComponent("album.txt").absoluteString
        
        coverPath.stringValue = getDocumentsDirectory().appendingPathComponent("OBSMusicAssist", isDirectory: true).appendingPathComponent("cover.png").absoluteString
        
        let dnc = DistributedNotificationCenter.default()
        dnc.addObserver(self, selector:#selector(updateTrackInfo),
                        name:NSNotification.Name(rawValue:"com.apple.iTunes.playerInfo"), object:nil)
        
        let appDelegate = NSApp.delegate as! AppDelegate
        
        if appDelegate.iTunesBridge.isRunning { self.updateTrackInfo() }
        
    }
    
    @objc func updateTrackInfo() {
        let appDelegate = NSApp.delegate as! AppDelegate
        if let trackInfo = appDelegate.iTunesBridge.trackInfo {
            
            songLabel.stringValue = trackInfo["trackName"] as! String
            artistLabel.stringValue = trackInfo["trackArtist"] as! String
            albumLabel.stringValue = trackInfo["trackAlbum"] as! String
            
            let string = songLabel.stringValue + " - " + artistLabel.stringValue
            
            
            do {
                try string.write(to: URL(string: songPath.stringValue)!, atomically: true, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("Error: fileURL failed to write: \n\(error)" )
                
            }
            
            do {
                try albumLabel.stringValue.write(to: URL(string: artistPath.stringValue)!, atomically: true, encoding: String.Encoding.utf8)
            } catch {
            }
            
            if !albumLabel.stringValue.isEmpty && albumLabel.stringValue != " " {
                parseData(searchTerm: songLabel.stringValue + " " + (trackInfo["trackAlbum"] as! String))
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func changeSongPath(_ sender: Any) {
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(string: songPath.stringValue)!
        
        panel.beginSheetModal(for: window) { (result) in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                
                if panel.urls[0].hasDirectoryPath {
                    self.songPath.stringValue = panel.urls[0].absoluteString + "song.txt"
                    print(self.songPath.stringValue)
                } else {
                    if panel.urls[0].pathExtension != "txt" {
                        self.songPath.stringValue = panel.urls[0].absoluteString + ".txt"
                    } else {
                        self.songPath.stringValue = panel.urls[0].absoluteString
                    }
                }
                self.updateTrackInfo()
            }
        }
    }
    
    @IBAction func changeAlbumPath(_ sender: Any) {
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(string: artistPath.stringValue)!
        
        panel.beginSheetModal(for: window) { (result) in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                if panel.urls[0].hasDirectoryPath {
                    self.artistPath.stringValue = panel.urls[0].absoluteString + "album.txt"
                } else {
                    if panel.urls[0].pathExtension != "txt" {
                        self.artistPath.stringValue = panel.urls[0].absoluteString + ".txt"
                    } else {
                        self.artistPath.stringValue = panel.urls[0].absoluteString
                    }
                }
                self.updateTrackInfo()
            }
        }
        
    }
    
    @IBAction func changeCoverPath(_ sender: Any) {
        guard let window = view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(string: coverPath.stringValue)!
        
        panel.beginSheetModal(for: window) { (result) in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                if panel.urls[0].hasDirectoryPath {
                    self.coverPath.stringValue = panel.urls[0].absoluteString + "cover.png"
                } else {
                    if panel.urls[0].pathExtension != "png" {
                        self.coverPath.stringValue = panel.urls[0].absoluteString + ".png"
                    } else {
                        self.coverPath.stringValue = panel.urls[0].absoluteString
                    }
                }
                self.updateTrackInfo()
            }
        }
    }
    
    func parseData(searchTerm: String) {
        let itunesSearchTerm = searchTerm.replacingOccurrences(of: " ", with: "%20", options: .caseInsensitive, range: nil)
        let urlString = "https://itunes.apple.com/search?term=" + itunesSearchTerm
        let url = URL(string: removeSpecial(text: urlString))!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
                
            else {
                    if let fetchedDict = try? JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as? [String:Any],
                        let fetchedArray = fetchedDict ["results"] as? [[String:Any]] {
                    
                        print(fetchedArray)
                        
                        if fetchedArray[0]["artworkUrl100"] != nil {
                            DispatchQueue.main.async {
                                let ur = (fetchedArray[0]["artworkUrl100"] as! String).replacingOccurrences(of: "100x100bb", with: "200x200bb")
                                self.albumArtImage!.downloadedFrom(url: URL(string: ur)!, complete: {(done) in
                                    
                                })
                                
                                self.testImage!.downloadedFrom(url: URL(string: ur.replacingOccurrences(of: "200x200bb", with: "500x500bb"))!, complete: {(done) in
                                    
                                    let image = self.testImage.image!
                                    image.pngWrite(to: URL(string: self.coverPath.stringValue)!)
                                })
                            }
                            
                        }
                    }
                }
            }.resume()
    }
    
    func removeSpecial(text: String) -> String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+%-=().!_:/?&$#@[]")
        return text.filter {okayChars.contains($0) }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.homeDirectoryForCurrentUser
        return paths
    }
}

