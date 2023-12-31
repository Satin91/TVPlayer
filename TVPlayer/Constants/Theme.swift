//
//  Theme.swift
//  TVPlayer
//
//  Created by Артур Кулик on 21.12.2023.
//

import UIKit

enum Theme {
    enum Colors {
        static let accent = UIColor(named: "accent")
        static let transparentGray = UIColor(named: "transparentGray")
        static let transparentWhite = UIColor(named: "transparentWhite")
        static let gray = UIColor(named: "gray")
        static let darkGray = UIColor(named: "darkGray")
        static let lightGray = UIColor(named: "lightGray")
        static let divider = UIColor(named: "divider")
        static let mint = UIColor(named: "mint")
        static let contextDivider = UIColor(named: "contextDivider")
        static let textFieldBG = UIColor(named: "textFieldBG")
    }
    
    enum Images {
        static var star: UIImage { UIImage(named: "star") ?? UIImage() }
        static var search: UIImage { UIImage(named: "search") ?? UIImage() }
        static var arrowLeft: UIImage { UIImage(named: "arrowLeft") ?? UIImage() }
        static var settings: UIImage { UIImage(named: "settings") ?? UIImage() }
        static var play: UIImage { UIImage(named: "play") ?? UIImage() }
        static var pause: UIImage { UIImage(named: "pause") ?? UIImage() }
    }
}
