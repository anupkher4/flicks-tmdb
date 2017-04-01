//
//  ErrorView.swift
//  Flicks
//
//  Created by Anup Kher on 3/31/17.
//  Copyright © 2017 codepath. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    var errorLabel: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        errorLabel.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
    }
    
    func setupLabel() {
        errorLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 30))
        errorLabel.textColor = UIColor.white
        errorLabel.text = "Network Error"
        
        addSubview(errorLabel)
    }

}
