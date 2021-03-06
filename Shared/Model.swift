// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
// https://app.quicktype.io
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

import Foundation

import Foundation

// MARK: - LapData

typealias LapData = [Motion]

struct Motion: Codable {
    let mFrame: Int
    let mTimestamp: String
    let mCurrentLap, mSector, mLastLapTimeInMS, mSpeed: Int
    let mGear: Int
    let mEngineRPM: Int
    let mWorldposx, mWorldposy, mWorldposz: Double
    let mWorldforwarddirx, mWorldforwarddiry, mWorldforwarddirz, mWorldrightdirx: Int
    let mWorldrightdiry, mWorldrightdirz: Int
    let mYaw, mPitch, mRoll: Float
    let driver: String

    enum CodingKeys: String, CodingKey {
        case mFrame = "M_FRAME"
        case mTimestamp = "M_TIMESTAMP"
        case mCurrentLap = "M_CURRENT_LAP"
        case mSector = "M_SECTOR"
        case mLastLapTimeInMS = "M_LAST_LAP_TIME_IN_MS"
        case mSpeed = "M_SPEED"
        case mGear = "M_GEAR"
        case mEngineRPM = "M_ENGINERPM"
        case mWorldposx = "M_WORLDPOSX"
        case mWorldposy = "M_WORLDPOSY"
        case mWorldposz = "M_WORLDPOSZ"
        case mWorldforwarddirx = "M_WORLDFORWARDDIRX"
        case mWorldforwarddiry = "M_WORLDFORWARDDIRY"
        case mWorldforwarddirz = "M_WORLDFORWARDDIRZ"
        case mWorldrightdirx = "M_WORLDRIGHTDIRX"
        case mWorldrightdiry = "M_WORLDRIGHTDIRY"
        case mWorldrightdirz = "M_WORLDRIGHTDIRZ"
        case mYaw = "M_YAW"
        case mPitch = "M_PITCH"
        case mRoll = "M_ROLL"
        case driver = "DRIVER"
    }
}

// MARK: - Sessions

typealias SessionsData = [Session]

struct Session: Codable {
    let mGamehost, mSessionid: String
    let driver: String
    let laps: Int
    let sessionTime: String
    let sessionLength: Int
    
    var imageName : String{
        let number = Int.random(in:1..<3)
        if number == 1{
            return "redbullcar"
        } else{
            return "mclarencar"
        }
    }
    
    var lapsString : String{
        if laps == 1 {
            return "1 lap"
        } else {
            return "\(laps) laps"
        }
    }
    
    var sessionLengthString: String{
        let dateVar = Date.init(timeIntervalSince1970: TimeInterval(Double(sessionLength))/1000)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss.SSS"
        return dateFormatter.string(from: dateVar)
    }
    
    
    var sessionTimeMeasurement : String {
        let dateVar = Date.init(timeIntervalSince1970: TimeInterval(Double(sessionTime)!)/1000)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            return dateFormatter.string(from: dateVar)

    }

    enum CodingKeys: String, CodingKey {
        case mGamehost = "M_GAMEHOST"
        case mSessionid = "M_SESSIONID"
        case driver = "DRIVER"
        case laps = "LAPS"
        case sessionTime = "SESSION_TIME"
        case sessionLength = "SESSION_DURATION_MS"
    }
}



