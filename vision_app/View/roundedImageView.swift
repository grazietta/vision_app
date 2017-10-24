//
//  roundedImageView.swift
//  vision_app
//
//  Created by Grazietta Hof on 2017-10-15.
//  Copyright © 2017 Grazietta Hof. All rights reserved.
//

import UIKit

class roundedImageView: UIImageView {

    override func awakeFromNib() {
        self.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1) as CGColor
        self.layer.shadowRadius = 12
        self.layer.opacity = 0.75
        self.layer.cornerRadius = 15
    }

}
