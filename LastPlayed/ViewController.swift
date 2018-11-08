import UIKit
import MediaPlayer

func checkForMusicLibraryAccess(andThen f:(()->())? = nil) {
    let status = MPMediaLibrary.authorizationStatus()
    switch status {
    case .authorized:
        f?()
    case .notDetermined:
        MPMediaLibrary.requestAuthorization() { status in
            if status == .authorized {
                DispatchQueue.main.async {
                	f?()
				}
            }
        }
    case .restricted:
        // do nothing
        break
    case .denied:
        // do nothing, or beg the user to authorize us in Settings
        break
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var simpleTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLastPlayed()
    }
    
    func loadLastPlayed () {
        checkForMusicLibraryAccess {
            let start: TimeInterval = Date().timeIntervalSince1970
            let songsQuery = MPMediaQuery.songs()
            let songsArray = songsQuery.items
            let sorter = NSSortDescriptor(key: MPMediaItemPropertyLastPlayedDate, ascending: false)
            let sortedSongsArray = (songsArray as NSArray?)?.sortedArray(using: [sorter]).prefix(upTo: 50)
            let finish: TimeInterval = Date().timeIntervalSince1970
            print("Execution took \(finish - start) seconds.")

            for song: MPMediaItem in Array(sortedSongsArray!) as? [MPMediaItem] ?? [] {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let lastPlayedDate = dateFormatter.string(from: song.lastPlayedDate ?? Date.init())
                let logLine = "\(song.artist ?? ""): \(song.title ?? "") (\(lastPlayedDate))"
                print(logLine)
                self.simpleTextView.text = self.simpleTextView.text + "\(logLine)\n"
            }
        }
    }
}
