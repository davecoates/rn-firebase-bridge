//
//  FirebaseBridgeError.swift
//  testapp
//
//  Created by Dave Coates on 30/09/2016.
//

enum FirebaseBridgeError: ErrorType, CustomStringConvertible {
  case UnknownQueryFunction(fnName: String)
  case AppNotFound(appName: String)
  case UserNotLoggedIn()
  case CredentialNotFound()
  
  var code: String {
    switch self {
    case UnknownQueryFunction: return "invalid_query"
    case AppNotFound: return "app_not_found"
    case UserNotLoggedIn: return "user_not_logged_in"
    case CredentialNotFound: return "credential_not_found"
    }
  }
  var description: String {
    switch self {
    case AppNotFound(let appName): return "No app with name \(appName) found"
    case UnknownQueryFunction(let fnName): return "Unknown query function '\(fnName)'"
    case UserNotLoggedIn: return "User not logged in"
    case CredentialNotFound: return "Credential not found"
    }
  }
}
