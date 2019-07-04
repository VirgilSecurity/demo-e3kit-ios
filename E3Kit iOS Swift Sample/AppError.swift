//
//  AppError.swift
//  E3Kit iOS Swift Sample
//
//  Created by Matheus Cardoso on 6/26/19.
//  Copyright © 2019 cardoso. All rights reserved.
//

import Foundation

enum AppError: Error {
    case gettingJwtFailed
    case gettingChannelsListFailed
    case notAuthenticated
    case eThreeNotInitialized
    case invalidUrl
    case messagingNotInitialized
    case invalidResponse
}
