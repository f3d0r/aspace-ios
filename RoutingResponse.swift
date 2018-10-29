// To parse the JSON, add this file to your project and do:
//
//   let routingResponse = try? newJSONDecoder().decode(RoutingResponse.self, from: jsonData)
//
// To parse values from Alamofire responses:
//
//   Alamofire.request(url).responseRoutingResponse { response in
//     if let routingResponse = response.result.value {
//       ...
//     }
//   }

import Foundation
import Alamofire

class RoutingResponse: Codable {
    let resInfo: RoutingResInfo?
    let resContent: RoutingResContent?
    
    enum CodingKeys: String, CodingKey {
        case resInfo = "res_info"
        case resContent = "res_content"
    }
    
    init(resInfo: RoutingResInfo?, resContent: RoutingResContent?) {
        self.resInfo = resInfo
        self.resContent = resContent
    }
}

class RoutingResContent: Codable {
    let routes: [[RoutingResContentRoute]]?
    let sessionID: Int?
    
    enum CodingKeys: String, CodingKey {
        case routes = "routes"
        case sessionID = "session_id"
    }
    
    init(routes: [[RoutingResContentRoute]]?, sessionID: Int?) {
        self.routes = routes
        self.sessionID = sessionID
    }
}

class RoutingResContentRoute: Codable {
    let name: String?
    let prettyName: String?
    let origin: RoutingDest?
    let dest: RoutingDest?
    let directions: RoutingDirections?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case prettyName = "pretty_name"
        case origin = "origin"
        case dest = "dest"
        case directions = "directions"
    }
    
    init(name: String?, prettyName: String?, origin: RoutingDest?, dest: RoutingDest?, directions: RoutingDirections?) {
        self.name = name
        self.prettyName = prettyName
        self.origin = origin
        self.dest = dest
        self.directions = directions
    }
}

class RoutingDest: Codable {
    let meta: RoutingMeta?
    let lng: Double?
    let lat: Double?
    
    enum CodingKeys: String, CodingKey {
        case meta = "meta"
        case lng = "lng"
        case lat = "lat"
    }
    
    init(meta: RoutingMeta?, lng: Double?, lat: Double?) {
        self.meta = meta
        self.lng = lng
        self.lat = lat
    }
}

class RoutingMeta: Codable {
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
    let batteryLevel: Double?
    
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
    
    init(id: String?, distance: Double?, parkingPrice: Double?, type: String?, drivingTime: Double?, name: String?, paymentProcess: String?, address: String?, paymentTypes: String?, facilities: String?, company: String?, region: String?, bikesAvailable: Int?, batteryLevel: Double?) {
        self.id = id
        self.distance = distance
        self.parkingPrice = parkingPrice
        self.type = type
        self.drivingTime = drivingTime
        self.name = name
        self.paymentProcess = paymentProcess
        self.address = address
        self.paymentTypes = paymentTypes
        self.facilities = facilities
        self.company = company
        self.region = region
        self.bikesAvailable = bikesAvailable
        self.batteryLevel = batteryLevel
    }
}

class RoutingDirections: Codable {
    let code: String?
    let waypoints: [RoutingWaypoint]?
    let routes: [RoutingDirectionsRoute]?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case waypoints = "waypoints"
        case routes = "routes"
    }
    
    init(code: String?, waypoints: [RoutingWaypoint]?, routes: [RoutingDirectionsRoute]?) {
        self.code = code
        self.waypoints = waypoints
        self.routes = routes
    }
}

class RoutingDirectionsRoute: Codable {
    let legs: [RoutingLeg]?
    let weightName: String?
    let geometry: RoutingGeometry?
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
    
    init(legs: [RoutingLeg]?, weightName: String?, geometry: RoutingGeometry?, weight: Double?, distance: Double?, duration: Double?) {
        self.legs = legs
        self.weightName = weightName
        self.geometry = geometry
        self.weight = weight
        self.distance = distance
        self.duration = duration
    }
}

class RoutingGeometry: Codable {
    let coordinates: [[Double]]?
    let type: RoutingType?
    
    enum CodingKeys: String, CodingKey {
        case coordinates = "coordinates"
        case type = "type"
    }
    
    init(coordinates: [[Double]]?, type: RoutingType?) {
        self.coordinates = coordinates
        self.type = type
    }
}

enum RoutingType: String, Codable {
    case lineString = "LineString"
}

class RoutingLeg: Codable {
    let steps: [RoutingStep]?
    let weight: Double?
    let distance: Double?
    let annotation: RoutingAnnotation?
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
    
    init(steps: [RoutingStep]?, weight: Double?, distance: Double?, annotation: RoutingAnnotation?, summary: String?, duration: Double?) {
        self.steps = steps
        self.weight = weight
        self.distance = distance
        self.annotation = annotation
        self.summary = summary
        self.duration = duration
    }
}

class RoutingAnnotation: Codable {
    let speed: [Double]?
    let metadata: RoutingMetadata?
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
    
    init(speed: [Double]?, metadata: RoutingMetadata?, nodes: [Int]?, duration: [Double]?, distance: [Double]?, weight: [Double]?, datasources: [Int]?) {
        self.speed = speed
        self.metadata = metadata
        self.nodes = nodes
        self.duration = duration
        self.distance = distance
        self.weight = weight
        self.datasources = datasources
    }
}

class RoutingMetadata: Codable {
    let datasourceNames: [String]?
    
    enum CodingKeys: String, CodingKey {
        case datasourceNames = "datasource_names"
    }
    
    init(datasourceNames: [String]?) {
        self.datasourceNames = datasourceNames
    }
}

class RoutingStep: Codable {
    let intersections: [RoutingIntersection]?
    let drivingSide: RoutingDrivingSide?
    let geometry: RoutingGeometry?
    let duration: Double?
    let distance: Double?
    let name: String?
    let weight: Double?
    let mode: RoutingMode?
    let maneuver: RoutingManeuver?
    let instruction: String?
    let ref: String?
    let destinations: String?
    
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
        case ref = "ref"
        case destinations = "destinations"
    }
    
    init(intersections: [RoutingIntersection]?, drivingSide: RoutingDrivingSide?, geometry: RoutingGeometry?, duration: Double?, distance: Double?, name: String?, weight: Double?, mode: RoutingMode?, maneuver: RoutingManeuver?, instruction: String?, ref: String?, destinations: String?) {
        self.intersections = intersections
        self.drivingSide = drivingSide
        self.geometry = geometry
        self.duration = duration
        self.distance = distance
        self.name = name
        self.weight = weight
        self.mode = mode
        self.maneuver = maneuver
        self.instruction = instruction
        self.ref = ref
        self.destinations = destinations
    }
}

enum RoutingDrivingSide: String, Codable {
    case drivingSideLeft = "left"
    case drivingSideRight = "right"
    case none = "none"
    case slightLeft = "slight left"
    case slightRight = "slight right"
    case straight = "straight"
}

class RoutingIntersection: Codable {
    let out: Int?
    let entry: [Bool]?
    let location: [Double]?
    let bearings: [Int]?
    let intersectionIn: Int?
    let classes: [RoutingClass]?
    let lanes: [RoutingLane]?
    
    enum CodingKeys: String, CodingKey {
        case out = "out"
        case entry = "entry"
        case location = "location"
        case bearings = "bearings"
        case intersectionIn = "in"
        case classes = "classes"
        case lanes = "lanes"
    }
    
    init(out: Int?, entry: [Bool]?, location: [Double]?, bearings: [Int]?, intersectionIn: Int?, classes: [RoutingClass]?, lanes: [RoutingLane]?) {
        self.out = out
        self.entry = entry
        self.location = location
        self.bearings = bearings
        self.intersectionIn = intersectionIn
        self.classes = classes
        self.lanes = lanes
    }
}

enum RoutingClass: String, Codable {
    case motorway = "motorway"
    case tunnel = "tunnel"
}

class RoutingLane: Codable {
    let valid: Bool?
    let indications: [RoutingDrivingSide]?
    
    enum CodingKeys: String, CodingKey {
        case valid = "valid"
        case indications = "indications"
    }
    
    init(valid: Bool?, indications: [RoutingDrivingSide]?) {
        self.valid = valid
        self.indications = indications
    }
}

class RoutingManeuver: Codable {
    let bearingAfter: Int?
    let bearingBefore: Int?
    let type: String?
    let location: [Double]?
    let modifier: RoutingDrivingSide?
    
    enum CodingKeys: String, CodingKey {
        case bearingAfter = "bearing_after"
        case bearingBefore = "bearing_before"
        case type = "type"
        case location = "location"
        case modifier = "modifier"
    }
    
    init(bearingAfter: Int?, bearingBefore: Int?, type: String?, location: [Double]?, modifier: RoutingDrivingSide?) {
        self.bearingAfter = bearingAfter
        self.bearingBefore = bearingBefore
        self.type = type
        self.location = location
        self.modifier = modifier
    }
}

enum RoutingMode: String, Codable {
    case driving = "driving"
}

class RoutingWaypoint: Codable {
    let hint: String?
    let location: [Double]?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case hint = "hint"
        case location = "location"
        case name = "name"
    }
    
    init(hint: String?, location: [Double]?, name: String?) {
        self.hint = hint
        self.location = location
        self.name = name
    }
}

class RoutingResInfo: Codable {
    let code: Int?
    let codeInfo: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case codeInfo = "code_info"
    }
    
    init(code: Int?, codeInfo: String?) {
        self.code = code
        self.codeInfo = codeInfo
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
    func responseRoutingResponse(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<RoutingResponse>) -> Void) -> Self {
        return responseDecodable(queue: queue, completionHandler: completionHandler)
    }
}
