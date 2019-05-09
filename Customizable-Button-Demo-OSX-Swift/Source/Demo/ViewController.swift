//  ViewController.swift

//  Customizeable-Swift-OSX-Button-Demo
//
//  A customizeable button class, written in Swift for OSX-Cocoa.
//
//  Customizable options from Interface Builder:
//
//  * Border color - highlighted and normal
//  * Fill color - highlighted and normal
//  * Text color - highlighted and normal
//  * Icon color - highlighted and normal (monochrome icons only)
//  * Glow opacity
//  * Glow radius
//  * Corner radius
//  * Hover-highlighting on/off
//
//
// To do:
//     Relative icon / button positioning is not yet
//     well or fully implemented.



import Cocoa

class ViewController: NSViewController {

    
    @IBOutlet weak var button: QXButton!
    
    @IBAction func buttonPressed(_ sender: Any) {
        print("Click!")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

