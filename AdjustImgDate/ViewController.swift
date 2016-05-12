//
//  ViewController.swift
//  AdjustImgDate
//
//  Created by ChenYi-Hung on 2016/4/27.
//  Copyright © 2016年 ChenYi-Hung. All rights reserved.
//

import Cocoa

class sFileData {
    var fileName: String
    var creationDate: String
    var creationDateExif: String
    var need2Modified: Bool
    init (fileName: String, creationDate: String, creationDateExif: String, bModified: Bool) {
        self.fileName = fileName;
        self.creationDate = creationDate;
        self.creationDateExif = creationDateExif;
        self.need2Modified = bModified;
    }
 }

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var m_tableView: NSTableView!
    
    var m_objectArray:NSMutableArray! = NSMutableArray();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //m_objectArray.addObject(sFileData(fileName: "1.jpg", creationDate: "1987/10/10", creationDateExif: "1988/10/10"))
        //m_objectArray.addObject(sFileData(fileName: "2.jpg", creationDate: "2087/10/10", creationDateExif: "1995/10/10"))
        //m_objectArray.addObject(sFileData(fileName: "3.jpg", creationDate: "2387/10/10", creationDateExif: "2000/10/10"))
        
        
        m_tableView.reloadData();
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // delegate
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String = ""
        var cellId: String = ""
        let object = m_objectArray[row] as! sFileData
        
        if (tableColumn == m_tableView.tableColumns[0]) {
            cellId = "cellFileName"
            text = object.fileName
        } else if (tableColumn == m_tableView.tableColumns[1]) {
            cellId = "cellCreationDate"
            text = object.creationDate
        } else if (tableColumn == m_tableView.tableColumns[2]) {
            cellId = "cellCreationDateExif"
            text = object.creationDateExif
        }
        
        //print("?? row: \(row) cellId: \(cellId)");
        
        if let cell = m_tableView.makeViewWithIdentifier(cellId, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text;
            return cell;
        }
        
        
        return nil;
    }

    // data source
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        print("## \(m_objectArray.count)");
        return m_objectArray.count;
    }
    
    
    
    @IBAction func openDocument(sender: AnyObject?) {
        
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles      = false
        openPanel.canChooseFiles        = false
        openPanel.canChooseDirectories  = true
        
        //self.
        
        let dd = openPanel.runModal();
        
        if (dd == NSModalResponseOK) {
            print("select path: \(openPanel.URL)");
            if (openPanel.URL != nil) {
                let path = openPanel.URL;
                print("##: \(path)");
                
                let path2 = path!.path!;
                
                let fileDatas = getImageFileFromSelectdDir(path2);
                
                if (fileDatas?.count > 0) {
                    m_objectArray.removeAllObjects()
                    for fileData in fileDatas! {
                        m_objectArray.addObject(fileData)
                    }
                }
                
                m_tableView.reloadData();
                
            }
        }
    }
    
    func executeShell(launchPath: String, arguments: [String] = []) {
        let output = shell(launchPath, arguments: arguments)
        
        if (output != nil) {
            print(output)
        }
    }
    
    func shell(launchPath: String, arguments: [String] = []) -> String? {
        let task = NSTask()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data,
                                       encoding:  NSUTF8StringEncoding)
        
        return output as! String
    }
    
    
    func getImageFileFromSelectdDir(pathOfFolder: String) -> [sFileData]? {
        let fileManager = NSFileManager.defaultManager();
        let contents:[String];
        let folderURL = NSURL.fileURLWithPath(pathOfFolder);
        
        do {
            contents = try fileManager.contentsOfDirectoryAtPath(/*mCurrFolder.stringValue*/ pathOfFolder);
            
            // TODO: using .contentsOfDirectoryAtURL to re-implement this value
            let folderCntx = try fileManager.contentsOfDirectoryAtURL(folderURL, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles);
            
            let files = (folderCntx.map(){$0.lastPathComponent})
            var cnt = 0;
            var sameCnt = 0;
            var diffCnt = 0;
            var noExifCnt = 0;
            var bNeedModified = false;
            
            cnt = 0;
            var fileData = [sFileData] ();
            for URLS in folderCntx {
                let pathStr:String = URLS.relativePath!;
                let ext:String = URLS.pathExtension!;
                let fileName: String? = URLS.lastPathComponent;
                
                if (ext.lowercaseString == "jpg") {
                    print("[\(cnt)]:\(pathStr)\t\(fileName)");
                    cnt++;
                    
                    let fileAttr = try NSFileManager.defaultManager().attributesOfItemAtPath(pathStr);
                    let creationDate = fileAttr[NSFileCreationDate] as? NSDate;
                    let modificationDate = fileAttr[NSFileModificationDate]
                    
                    
                    let imageSrc: AnyObject? = CGImageSourceCreateWithURL(URLS, nil);
                    
                    let imgSrc = CGImageSourceCreateWithURL(URLS, nil);
                    let imgProps: NSDictionary? = CGImageSourceCopyPropertiesAtIndex(imgSrc!, 0, nil)
                    

                    if (imgProps == nil) {
                        print("\(pathStr) is not invalid image type!!");
                        // skip invalid image
                        
                    } else {
                        let imgExif = imgProps?.valueForKey(kCGImagePropertyExifDictionary as String);
                        let imgTm = imgExif?.valueForKey(kCGImagePropertyExifDateTimeOriginal as String);
                        
                        //print("!!!!!\(imgExif), \n\(imgTm), \(object_getClass(imgTm))");
                    
                        let dateFormatter = NSDateFormatter()
                        //dateFormatter.dateStyle = .MediumStyle
                        dateFormatter.dateFormat="yyyy:MM:dd' 'HH::mm:ss"
                        
                        let creationDateStr = dateFormatter.stringFromDate(creationDate!);
                        //print("[File] creation date \(creationDateStr)")
                        
                        var exifDateStr = "";
                        if (imgTm != nil) {
                            exifDateStr = imgTm as! String;
                            //print("[Exif] creation date \(str)\n")
                            
                            if (exifDateStr != creationDateStr) {
                                print("[File] creation date \(creationDateStr)")
                                print("[Exif] creation date \(exifDateStr)")
                                print("??? different date time\n")
                                diffCnt++
                                bNeedModified = true;
                                
                                var dateFormatter = NSDateFormatter()
                                dateFormatter.dateFormat = "yyyy:MM:dd' 'HH::mm::ss"
                                var exifDateStrExt = dateFormatter.dateFromString(exifDateStr)
                                
                                
                                dateFormatter.dateFormat = "MM/dd/yyyy' 'HH::mm::ss"
                                exifDateStr = dateFormatter.stringFromDate(exifDateStrExt!)
                                /*executeShell("/usr/bin/SetFile", arguments: ["-d", "'\(exifDateStr)'", "\(pathStr)"])*/
                                executeShell("/usr/bin/SetFile", arguments: ["-d", "\(exifDateStr)", "\(pathStr)"])
                                
                            } else {
                                print("$$$ same date time\n")
                                sameCnt++
                            }
                        } else {
                            noExifCnt++;
                            print("@@@<<< no exif");
                        }
                        
                        
                        
                        
                        
                        let s: sFileData = sFileData(fileName: fileName!, creationDate: creationDateStr, creationDateExif: exifDateStr, bModified: bNeedModified);
                        
                        //print("\(s)")
                        fileData.append(s);
                    }
                } else {
                    // skip not jpg
                    continue;
                }

            }
            
            
            print("same date cnt: \(sameCnt)")
            print("diff date cnt: \(diffCnt)")
            print("no exif   cnt: \(noExifCnt)")
            return fileData;
        } catch let error as NSError {
            print (error.localizedDescription);
            return nil;
        }
    }
    
}

