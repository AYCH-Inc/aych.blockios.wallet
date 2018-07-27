//
//  LocationSuggestionCell.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/26/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

class LocationSuggestionCell: UITableViewCell {

    // TODO: Styling

    func configure(with suggestion: LocationSuggestion) {
        
        let titleAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17),
                               NSAttributedStringKey.foregroundColor: UIColor.black]
        let titleHighlightedAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 17),
                                          NSAttributedStringKey.foregroundColor: UIColor.black]

        let subtitleAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),
                                  NSAttributedStringKey.foregroundColor: UIColor.black]
        let subtitleHighlightedAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),
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
}
