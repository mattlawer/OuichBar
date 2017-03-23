//
//  WindowController.swift
//  OuichBar
//
//  Created by mathieu on 23/03/2017.
//  Copyright © 2017 mathieu. All rights reserved.
//

import Cocoa
import AudioToolbox

fileprivate extension NSTouchBarCustomizationIdentifier {
    static let scrubberBar = NSTouchBarCustomizationIdentifier("com.TouchBarCatalog.scrubberBar")
}

fileprivate extension NSTouchBarItemIdentifier {
    static let textScrubber = NSTouchBarItemIdentifier("com.TouchBarCatalog.TouchBarItem.textScrubber")
}

class WindowController: NSWindowController {

    var ouiches = [String]()

    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.

        if let b = Bundle.main.resourcePath, let contents = try? FileManager.default.contentsOfDirectory(atPath: b) {
            ouiches = contents.filter {
                $0.hasSuffix(".mp3")
            }.map {
                $0.replacingOccurrences(of: ".mp3", with: "")
            }
        }
    }

    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .scrubberBar
        touchBar.defaultItemIdentifiers = [.textScrubber]
        touchBar.customizationAllowedItemIdentifiers = [.textScrubber]

        return touchBar
    }
}

extension WindowController: NSTouchBarDelegate {
    
    // MARK: - touch bar delegate
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {

        switch identifier {
        case NSTouchBarItemIdentifier.textScrubber:
            let scrubberItem = NSCustomTouchBarItem(identifier: identifier)

            let scrubber = NSScrubber()
            scrubber.scrubberLayout = NSScrubberFlowLayout()
            scrubber.register(NSScrubberItemView.self, forItemIdentifier: "NSScrubberItemView")
            scrubber.mode = .free
            scrubber.selectionBackgroundStyle = .outlineOverlay
            scrubber.delegate = self
            scrubber.dataSource = self

            scrubberItem.view = scrubber

            return scrubberItem
        default:
            return nil
        }
    }
}

@available(OSX 10.12.2, *)
extension WindowController: NSScrubberDelegate, NSScrubberDataSource, NSScrubberFlowLayoutDelegate {


    func numberOfItems(for scrubber: NSScrubber) -> Int {
        return ouiches.count
    }

    func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        let itemView = scrubber.makeItem(withIdentifier: "NSScrubberItemView", owner: nil)!

        let button = NSButton(frame: NSRect(origin: NSPoint(x: 1.0, y: 0.0), size: CGSize(width: itemView.bounds.width-2.0, height: itemView.bounds.height)))
        button.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        button.bezelStyle = .rounded
        //button.bezelColor = ouichColor(index)

        let attributed = NSAttributedString(string: ouiches[index].capitalized, attributes: [NSForegroundColorAttributeName: ouichColor(index), NSFontAttributeName: NSFont(name: "Lobster-Regular", size: 20)!])
        button.attributedTitle = attributed
        itemView.addSubview(button)

        return itemView
    }

    func scrubber(_ scrubber: NSScrubber, layout: NSScrubberFlowLayout, sizeForItemAt itemIndex: Int) -> NSSize {
        let string = ouiches[itemIndex].capitalized as NSString
        let size = string.size(withAttributes: [NSFontAttributeName: NSFont(name: "Lobster-Regular", size: 20)!])
        return NSSize(width: size.width+20, height: 30)
    }

    func ouichColor(_ index: Int) -> NSColor {
        switch index%16 {
        case 0:
            return NSColor(hex: "#1abffa")
        case 1:
            return NSColor(hex: "#2b5764")
        case 2:
            return NSColor(hex: "#33ae8a")
        case 3:
            return NSColor(hex: "#8b95db")
        case 4:
            return NSColor(hex: "#9a8e00")
        case 5:
            return NSColor(hex: "#a1958c")
        case 6:
            return NSColor(hex: "#a753f6")
        case 7:
            return NSColor(hex: "#a76fa8")
        case 8:
            return NSColor(hex: "#a8ea28")
        case 9:
            return NSColor(hex: "#ae2862")
        case 10:
            return NSColor(hex: "#b1f01f")
        case 11:
            return NSColor(hex: "#b80f2b")
        case 12:
            return NSColor(hex: "#d7757e")
        case 13:
            return NSColor(hex: "#e49c6d")
        case 14:
            return NSColor(hex: "#f2c436")
        case 15:
            return NSColor(hex: "#f732e7")
        default:
            return NSColor(hex: "#1abffa")
        }
    }

    func scrubber(_ scrubber: NSScrubber, didSelectItemAt index: Int) {
        print("play \(ouiches[index]).mp3")
        scrubber.selectedIndex = -1
        if let soundURL = Bundle.main.url(forResource: ouiches[index], withExtension: "mp3") {
            var mySound: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(soundURL as CFURL, &mySound)
            AudioServicesPlaySystemSound(mySound);
        }
    }
}

