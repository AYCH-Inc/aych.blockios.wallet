//
//  LocationSuggestionCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class LocationSuggestionCell: UITableViewCell {

    func configure(with suggestion: LocationSuggestion) {
        
        let titleAttributes = [NSAttributedStringKey.font: LocationSuggestionCell.titleFont(),
                               NSAttributedStringKey.foregroundColor: UIColor.black]
        let titleHighlightedAttributes = [NSAttributedStringKey.font: LocationSuggestionCell.titleFont(),
                                          NSAttributedStringKey.foregroundColor: UIColor.black]

        let subtitleAttributes = [NSAttributedStringKey.font: LocationSuggestionCell.subtitleFont(),
                                  NSAttributedStringKey.foregroundColor: UIColor.black]
        let subtitleHighlightedAttributes = [NSAttributedStringKey.font: LocationSuggestionCell.subtitleFont(),
                                             NSAttributedStringKey.foregroundColor: UIColor.black]


        let attributedTitle = NSMutableAttributedString(string: suggestion.title, attributes: titleAttributes)
        let attributedSubtitle = NSMutableAttributedString(string: suggestion.subtitle, attributes: subtitleAttributes)

        suggestion.titleHighlights.forEach({
            attributedTitle.addAttributes(titleHighlightedAttributes, range: $0)
        })

        suggestion.subtitleHighlights.forEach({
            attributedSubtitle.addAttributes(subtitleHighlightedAttributes, range: $0)
        })

        textLabel?.attributedText = attributedTitle
        detailTextLabel?.attributedText = attributedSubtitle
    }

    static func titleFont() -> UIFont {
        return UIFont(name: "Montserrat-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
    }

    static func subtitleFont() -> UIFont {
        return UIFont(name: "Montserrat-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13)
    }
}
