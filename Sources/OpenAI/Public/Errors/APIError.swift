//
//  APIError.swift
//
//
//  Created by Sergii Kryvoblotskyi on 02/04/2023.
//

import Foundation

public enum OpenAIError: Error {
    case emptyData
}

public struct APIError: Error, Decodable, Equatable {
    public let error: String?
    public let message: String
    public let type: String
    public let param: String?
    public let code: String?
  
    public init(message: String, error: String?, type: String, param: String?, code: String?) {
    self.message = message
    self.type = type
    self.param = param
    self.code = code
    self.error = error
  }
  
  enum CodingKeys: CodingKey {
    case error
    case message
    case type
    case param
    case code
  }
  
  public init(from decoder: Decoder) throws {
    // First try to decode as simple string error
    if let container = try? decoder.singleValueContainer(),
       let errorString = try? container.decode(String.self) {
        self.message = errorString
        self.type = "error"
        self.error = errorString
        self.param = nil
        self.code = nil
        return
    }
    
    // If that fails, try the regular format
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    // message can be String or [String]
    if let string = try? container.decode(String.self, forKey: .message) {
      self.message = string
    } else if let array = try? container.decode([String].self, forKey: .message) {
      self.message = array.joined(separator: "\n")
    } else {
      throw DecodingError.typeMismatch(String.self, .init(codingPath: [CodingKeys.message], debugDescription: "message: expected String or [String]"))
    }
    
    self.type = try container.decode(String.self, forKey: .type)
    self.error = try container.decodeIfPresent(String.self, forKey: .error)
    self.param = try container.decodeIfPresent(String.self, forKey: .param)
    self.code = try container.decodeIfPresent(String.self, forKey: .code)
  }
}

extension APIError: LocalizedError {
    
    public var errorDescription: String? {
        return message
    }
}

public struct APIErrorResponse: Error, Decodable, Equatable {
    public let error: APIError
}

extension APIErrorResponse: LocalizedError {
    
    public var errorDescription: String? {
        return error.errorDescription
    }
}
