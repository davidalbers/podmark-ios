//
//  LinkedData.swift
//  podmark
//
//  Created by David Albers on 8/18/21.
//  Copyright © 2021 David Albers. All rights reserved.
//
//  Based on https://json-ld.org
//

import Foundation

struct LinkedData: Codable {
    let name: String
    let image: String
    let partOfSeries: LinkedDataSeries
}

struct LinkedDataSeries: Codable {
    let name: String
}
