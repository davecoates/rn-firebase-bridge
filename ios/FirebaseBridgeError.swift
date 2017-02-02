//
//  FirebaseBridgeError.swift
//  testapp
//
//  Created by Dave Coates on 30/09/2016.
//

enum FirebaseBridgeError: Error, CustomStringConvertible {
  case unknownQueryFunction(fnName: String)
  case appNotFound(appName: String)
  case userNotLoggedIn()
  case credentialNotFound()
  
  var code: String {
    switch self {
    case .unknownQueryFunction: return "invalid_query"
    case .appNotFound: return "app_not_found"
    case .userNotLoggedIn: return "user_not_logged_in"
    case .credentialNotFound: return "credential_not_found"
    }
  }
  var description: String {
    switch self {
    case .appNotFound(let appName): return "No app with name \(appName) found"
    case .unknownQueryFunction(let fnName): return "Unknown query function '\(fnName)'"
    case .userNotLoggedIn: return "User not logged in"
    case .credentialNotFound: return "Credential not found"
    }
  }
}
