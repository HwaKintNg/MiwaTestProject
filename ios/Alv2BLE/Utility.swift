//
//  Utility.swift
//  MemberShip
//
//  Created by EADi Developer (Mobile Team) on 17/08/2017.
//  Copyright © 2017 EADI. All rights reserved.
//

import Foundation

struct Utility{

  static func byteToHex(_ byte:[UInt8]?,offSet: Int, length:Int) -> String {

    if(byte == nil || (byte!.isEmpty)){

      // since return type is set to String, "null" is used

      return "null"
    }

    var str:String = ""
    for i in 0..<length{
      str += String(format:"%02X",byte![offSet + i])
    }

    // return str once loop finishes concat
    return str

  }

  static func byteToHex(_ byte:[UInt8]?)-> String {

    if(byte == nil || (byte?.isEmpty)!){

      // since return type is set to String, "null" is used

      return "null"

    }
    return byteToHex(byte!,offSet:0,length:(byte?.count)!)

  }

  static func hexToByte(_ hexString:String) -> [UInt8]{
    let array = hexString.map {
      String($0)
    }
    let limit = hexString.count
    var hexArray:[String] = []
    var length = 2

    stride(from:0, to:limit, by:2).forEach{
      if($0+2 > limit){
        length = 1
      }
      hexArray.append(array[$0..<$0.advanced(by:length)].joined(separator: ""))
    }
    
    var data:[UInt8] = []
    for hex in hexArray{
      let hexInt = UInt8(hex,radix:16) ?? 0
      data.append(hexInt)
    }
    return data
  }
}
