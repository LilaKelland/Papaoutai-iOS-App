//
//  Environment.swift
//  Papaoutai
//
//  Created by Lila Kelland on 2021-02-23.
//
//
//  Environment.swift
//
// from https://thoughtbot.com/blog/let-s-setup-your-ios-environments

import Foundation

public enum Environment {
  private static let infoDictionary: [String: Any] = {
    guard let dict = Bundle.main.infoDictionary else {
      fatalError("Plist file not found")
    }
    return dict
  }()

  static let url_string: String = {
    guard let url_string = Environment.infoDictionary["ROOT_URL"] as? String else {
      fatalError("Root URL not set in plist for this environment")
    }
//    guard let url = URL(string: rootURLstring) else {
//      fatalError("Root URL is invalid")
//    }
    return url_string
  }()
}
