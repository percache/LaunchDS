//
//  AlderisStub.swift
//  AntoineDS
//
//  Stub for Alderis color picker (not needed on iOS 14+)
//  We use UIColorPickerViewController instead
//

import UIKit

// Alderis stubs for compatibility
class ColorPickerConfiguration {
    var color: UIColor
    init(color: UIColor) {
        self.color = color
    }
}

protocol ColorPickerDelegate: AnyObject {
    func colorPicker(_ colorPicker: ColorPickerViewController, didAccept color: UIColor)
}

class ColorPickerViewController: UIViewController {
    weak var delegate: ColorPickerDelegate?
    var configuration: ColorPickerConfiguration
    
    init(configuration: ColorPickerConfiguration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // On iOS < 14, just present a simple alert
        // This is a stub - real Alderis would show a color picker
    }
}
