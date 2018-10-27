// To parse the JSON, add this file to your project and do:
//
//   let driveBikeResponse = try? newJSONDecoder().decode(DriveBikeResponse.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseDriveBikeResponse { response in
//     if let driveBikeResponse = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

struct DriveBikeResponse: Codable {
    let resInfo: DriveBikeResInfo?
    let resContent: DriveBikeResContent?
    
    enum CodingKeys: String, CodingKey {
        case resInfo = "res_info"
        case resContent = "res_content"
    }
}

struct DriveBikeResContent: Codable {
    let routes: [[DriveBikeResContentRoute]]?
    let sessionID: Int?
    
    enum CodingKeys: String, CodingKey {
        case routes = "routes"
        case sessionID = "session_id"
    }
}

struct DriveBikeResContentRoute: Codable {
    let name: String?
    let prettyName: String?
    let origin: DriveBikeDest?
    let dest: DriveBikeDest?
    let directions: DriveBikeDirections?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case prettyName = "pretty_name"
        case origin = "origin"
        case dest = "dest"
        case directions = "directions"
    }
}

struct DriveBikeDest: Codable {
    let lng: DriveBikeLat?
    let lat: DriveBikeLat?
    let meta: DriveBikeMeta?
    
    enum CodingKeys: String, CodingKey {
        case lng = "lng"
        case lat = "lat"
        case meta = "meta"
    }
}

enum DriveBikeLat: Codable {
    case double(Double)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(DriveBikeLat.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for DriveBikeLat"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

struct DriveBikeMeta: Codable {
    let id: String?
    let distance: Double?
    let parkingPrice: Double?
    let type: String?
    let drivingTime: Double?
    let name: String?
    let paymentProcess: String?
    let address: String?
    let paymentTypes: String?
    let facilities: String?
    let company: String?
    let region: String?
    let bikesAvailable: Int?
    let batteryLevel: JSONNull?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case distance = "distance"
        case parkingPrice = "parking_price"
        case type = "type"
        case drivingTime = "driving_time"
        case name = "name"
        case paymentProcess = "payment_process"
        case address = "address"
        case paymentTypes = "payment_types"
        case facilities = "facilities"
        case company = "company"
        case region = "region"
        case bikesAvailable = "bikes_available"
        case batteryLevel = "battery_level"
    }
}

struct DriveBikeDirections: Codable {
    let code: String?
    let waypoints: [DriveBikeWaypoint]?
    let routes: [DriveBikeDirectionsRoute]?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case waypoints = "waypoints"
        case routes = "routes"
    }
}

struct DriveBikeDirectionsRoute: Codable {
    let legs: [DriveBikeLeg]?
    let weightName: String?
    let geometry: DriveBikeGeometry?
    let weight: Double?
    let distance: Double?
    let duration: Double?
    
    enum CodingKeys: String, CodingKey {
        case legs = "legs"
        case weightName = "weight_name"
        case geometry = "geometry"
        case weight = "weight"
        case distance = "distance"
        case duration = "duration"
    }
}

struct DriveBikeGeometry: Codable {
    let coordinates: [[Double]]?
    let type: String?
    
    enum CodingKeys: String, CodingKey {
        case coordinates = "coordinates"
        case type = "type"
    }
}

struct DriveBikeLeg: Codable {
    let steps: [DriveBikeStep]?
    let weight: Double?
    let distance: Double?
    let annotation: DriveBikeAnnotation?
    let summary: String?
    let duration: Double?
    
    enum CodingKeys: String, CodingKey {
        case steps = "steps"
        case weight = "weight"
        case distance = "distance"
        case annotation = "annotation"
        case summary = "summary"
        case duration = "duration"
    }
}

struct DriveBikeAnnotation: Codable {
    let speed: [Double]?
    let metadata: DriveBikeMetadata?
    let nodes: [Int]?
    let duration: [Double]?
    let distance: [Double]?
    let weight: [Double]?
    let datasources: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case speed = "speed"
        case metadata = "metadata"
        case nodes = "nodes"
        case duration = "duration"
        case distance = "distance"
        case weight = "weight"
        case datasources = "datasources"
    }
}

struct DriveBikeMetadata: Codable {
    let datasourceNames: [String]?
    
    enum CodingKeys: String, CodingKey {
        case datasourceNames = "datasource_names"
    }
}

struct DriveBikeStep: Codable {
    let intersections: [DriveBikeIntersection]?
    let drivingSide: String?
    let geometry: DriveBikeGeometry?
    let duration: Double?
    let distance: Double?
    let name: String?
    let weight: Double?
    let mode: String?
    let maneuver: DriveBikeManeuver?
    let instruction: String?
    
    enum CodingKeys: String, CodingKey {
        case intersections = "intersections"
        case drivingSide = "driving_side"
        case geometry = "geometry"
        case duration = "duration"
        case distance = "distance"
        case name = "name"
        case weight = "weight"
        case mode = "mode"
        case maneuver = "maneuver"
        case instruction = "instruction"
    }
}

struct DriveBikeIntersection: Codable {
    let out: Int?
    let entry: [Bool]?
    let location: [Double]?
    let bearings: [Int]?
    let intersectionIn: Int?
    let lanes: [DriveBikeLane]?
    
    enum CodingKeys: String, CodingKey {
        case out = "out"
        case entry = "entry"
        case location = "location"
        case bearings = "bearings"
        case intersectionIn = "in"
        case lanes = "lanes"
    }
}

struct DriveBikeLane: Codable {
    let valid: Bool?
    let indications: [String]?
    
    enum CodingKeys: String, CodingKey {
        case valid = "valid"
        case indications = "indications"
    }
}

struct DriveBikeManeuver: Codable {
    let bearingAfter: Int?
    let location: [Double]?
    let type: String?
    let bearingBefore: Int?
    let modifier: String?
    
    enum CodingKeys: String, CodingKey {
        case bearingAfter = "bearing_after"
        case location = "location"
        case type = "type"
        case bearingBefore = "bearing_before"
        case modifier = "modifier"
    }
}

struct DriveBikeWaypoint: Codable {
    let hint: String?
    let location: [Double]?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case hint = "hint"
        case location = "location"
        case name = "name"
    }
}

struct DriveBikeResInfo: Codable {
    let code: Int?
    let codeInfo: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case codeInfo = "code_info"
    }
}

// MARK: Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - Alamofire response handlers

extension DataRequest {
    fileprivate func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer { _, response, data, error in
            guard error == nil else { return .failure(error!) }
            
            guard let data = data else {
                return .failure(AFError.responseSerializationFailed(reason: .inputDataNil))
            }
            
            return Result { try newJSONDecoder().decode(T.self, from: data) }
        }
    }
    
    @discardableResult
    fileprivate func responseDecodable<T: Decodable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        return response(queue: queue, responseSerializer: decodableResponseSerializer(), completionHandler: completionHandler)
    }
    
    @discardableResult
    func responseDriveBikeResponse(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<DriveBikeResponse>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
