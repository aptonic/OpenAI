//
//  Model.swift
//
//
//  Created by Aled Samuel on 08/04/2023.
//

import Foundation

/// The model object matching the specified ID.
public struct ModelResult: Codable, Equatable {
    public let id: String
    public let created: TimeInterval?
    public let object: String?
    public let ownedBy: String?
    public let displayName: String?
    public let supportsVision: Bool?  // Optional property

    enum CodingKeys: String, CodingKey {
        case id, created, object, ownedBy = "owned_by", displayName = "display_name", modelSpec = "model_spec"
    }
    
    enum ModelSpecCodingKeys: String, CodingKey {
        case capabilities
    }
    
    enum CapabilitiesCodingKeys: String, CodingKey {
        case supportsVision
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        created = try? container.decode(TimeInterval.self, forKey: .created)
        object = try? container.decode(String.self, forKey: .object)
        ownedBy = try? container.decode(String.self, forKey: .ownedBy)
        displayName = try? container.decode(String.self, forKey: .displayName)
        
        if let modelSpecContainer = try? container.nestedContainer(keyedBy: ModelSpecCodingKeys.self, forKey: .modelSpec),
           let capabilitiesContainer = try? modelSpecContainer.nestedContainer(keyedBy: CapabilitiesCodingKeys.self, forKey: .capabilities) {
            supportsVision = try? capabilitiesContainer.decode(Bool.self, forKey: .supportsVision)
        } else {
            supportsVision = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(created, forKey: .created)
        try container.encode(object, forKey: .object)
        try container.encode(ownedBy, forKey: .ownedBy)
        try container.encode(displayName, forKey: .displayName)
        
        if let supportsVision = supportsVision {
            var modelSpecContainer = container.nestedContainer(keyedBy: ModelSpecCodingKeys.self, forKey: .modelSpec)
            var capabilitiesContainer = modelSpecContainer.nestedContainer(keyedBy: CapabilitiesCodingKeys.self, forKey: .capabilities)
            try capabilitiesContainer.encode(supportsVision, forKey: .supportsVision)
        }
    }
}
