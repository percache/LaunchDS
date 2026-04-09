//
//  CreditsPerson.swift
//  Antoine
//
//  Created by Serena on 04/02/2023.
//

import Foundation

struct CreditsPerson: Codable, Hashable {
    // Note: If you ever want to add someone new to credits, do so here
    static let allContributors: [CreditsPerson] = [
        CreditsPerson(name: "percache", role: "Developer, maintainer",
                      pfpURL: "https://github.com/percache.png",
                      socialLink: "https://github.com/percache"),
        CreditsPerson(name: "Serena", role: "Original Antoine developer",
                      pfpURL: "https://github.com/SerenaKit.png",
                      socialLink: "https://twitter.com/CoreSerena"),
        CreditsPerson(name: "seo (ds-kexploit-fun)", role: "DarkSword exploit",
                      pfpURL: "https://github.com/seoapps.png",
                      socialLink: "https://github.com/seoapps"),
        CreditsPerson(name: "rooootdev", role: "lara / sandbox escape",
                      pfpURL: "https://github.com/rooootdev.png",
                      socialLink: "https://github.com/rooootdev"),
        CreditsPerson(name: "opa334", role: "kexploit_opa334",
                      pfpURL: "https://github.com/opa334.png",
                      socialLink: "https://github.com/opa334"),
    ]

    let name: String
    let role: String
    let pfpURL: URL
    let socialLink: URL
}
