//
//  ViewCodingProtocol.swift
//  BP_viewcode
//
//  Created by Caio Soares on 08/11/22.
//

import Foundation

protocol ViewCoding: AnyObject {
    func setupView()
    func setupHierarchy()
    func setupConstraints()
}

extension ViewCoding {
    func buildLayout() {
        setupView()
        setupHierarchy()
        setupConstraints()
    }
}
