//
//  Constants.swift
//  GentingApp
//
//  Created by Beans Group on 03/10/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation

struct Constants {
  
  /**
   * DIY Constants
   * Not from ALV2BLE
   * Used for reactnative
   */
  static let NULL:String = "NULL";
  static let CONNECTING:String = "Connecting"; // 777
  static let RECEIVING:String = "Receiving key"; // 888
  static let AUTHORIZING:String = "Authorizing key"; // 999
  
  /**
   * DIY Constants
   * Not from ALV2BLE
   * Used for map's key
   */
  static let CODE:String = "code";
  static let RES_CODE:String = "res_code";
  static let MSG:String = "msg";
  
  
  /**
   * ======================================================================================================
   * ======================================================================================================
   * Constants FOR ALV2BLE    Constants FOR ALV2BLE    Constants FOR ALV2BLE    Constants FOR ALV2BLE
   * ======================================================================================================
   * ======================================================================================================
   */
  
  /**
   * Common
   */
  static let SUCCESSFUL:String = "Successful";
  
  /**
   * Error code from ALV2BLE lock
   */
  static let CARD_READ_ERROR:String = "Card read error";
  static let LRC_ERROR:String = "LRC error";
  static let TIMEOUT:String = "Timeout";
  static let MISMATCH_HOTEL_CODE:String = "Mismatch hotel code";
  static let CARD_TYPE_ERROR:String = "Card type error";
  static let BATTERY_END_DETECTED:String = "Battery end detected";
  static let SERIAL_NUM_ENCODING_ERROR:String = "Serial No. encoding error"; // NOT USING
  static let LOG_ENCODING_ERROR:String = "Log encoding error";
  static let DEADBOLT_IN_USE:String = "Deadbolt in use";
  static let MLO:String = "MLO";
  static let HLO:String = "HLO";
  static let CARD_MEDIA_ERROR:String = "Card media error";
  static let SHUTOUT_CONDITION:String = "Shutout condition";
  static let MISMATCH_ROOM_NUM:String = "Mismatch room No.";
  static let MISMATCH_ROOM_RANGE:String = "Mismatch room range";
  static let MISMATCH_NON_GUEST_DOOR_FLAG:String = "Mismatch Non Guest door flag";
  static let OUT_OF_TIME_RANGE:String = "Out of time range";
  static let OUT_OF_DAY:String = "Out of day";
  static let INVALID_TIME_RANGE_0x15:String = "Invalid time range";
  static let INACTIVE_CARD:String = "Inactive card";
  static let INVALID_COMMON_DATA_USAGE:String = "Invalid common data usage";
  static let INVALID_TIME_RANGE_0x1A:String = "Invalid time range";
  static let DS_CARD_ERROR:String = "DS card error";
  static let SMS_OUT_OF_DATE_RANGE:String = "SMS out of date range";
  static let SMS_OUT_OF_TIME_RANGE:String = "SMS out of time range";
  static let SMS_OUT_OF_DAY_WEEK:String = "SMS out of day of week";
  static let SMS_INVALID_ACCESS_RIGHT:String = "SMS invalid access right";
  static let SEQUENCE_ERROR_1:String = "Sequence error (MS,SMS,EM,HLO,MLO,CL,DS,DTU)";
  static let INVALID_CARD_DATA_DATE:String = "Invalid card data (date)";
  static let INVALID_CARD_DATA_ROOM_NUM:String = "Invalid card data (Room No.)";
  static let INVALID_CARD_DATA_FREE_COMMAND:String = "Invalid card data (Free command)";
  static let SEQUENCE_ERROR_2:String = "Sequence error (GU*,MT*,ST*,GM*,OS*,PS)";
  static let MISMATCH_SPECIAL_DOOR_FLAG:String = "Mismatch special door flag";
  static let SMS_OUT_OF_ROOM_RANGE:String = "SMS out of room range";
  static let INACTIVE_CARD_OTHER_PARAMETER:String = "Inactive card (Other parameter)";
  static let UNEXPECTED_WAKEUP:String = "Unexpected wakeup"; // NOT USING
  static let RTC_ERROR:String = "RTC error";
  static let SYSTEM_RESET:String = "System Reset";
  static let RTC_FOS_FLAG_ON:String = "RTC FOS flag ON"; // NOT USING
  static let LOG_ENCODING_ARE_OVERFLOW:String = "Log encoding are overflow";
  static let ROOM_TYPE_ERROR:String = "Room type error";
  static let OVERRIDE_ERROR:String = "Override error";
  static let BATTERY_NEAR_END:String = "Battery near end";
  static let DOOR_AJAR_ON:String = "Door ajar on"; // NOT USING
  static let DOOR_AJAR_OFF:String = "Door ajar off"; // NOT USING
  static let DOOR_AJAR_ERROR:String = "Door ajar error"; // NOT USING
  static let BLE_SEND_ERROR:String = "BLE send error";
  static let BLE_RECEIVE_ERROR:String = "BLE receive error";
  static let BLE_NOTIFY_ERROR:String = "BLE notify error";
  
  /**
   * Error code for BLE encoder
   */
  static let MISMATCH_VERIFY:String = "Mismatch verify";
  
  /**
   * Error code for library
   */
//  static let NO_AUTHORIZATION_FOR_BLE_LOCATION:String = "No authorization for BLE / Location";
  
  static let TIME_OUT:String = "Time out";
  static let RECEIVE_ADVERTISE_FROM_WRONG_ROOM:String = "Receive advertise from wrong room";
  static let INSIDE_PROCESS_ERROR:String = "Inside process error";
  static let CANCEL_BY_USER:String = "Cancel by user";
  static let BLE_INACTIVE:String = "BLE inactive";
  static let OTHER_ERROR:String = "Other error";
  static let BLE_COMMUNICATION_ERROR:String = "BLE communication error"; // NOT USING

  static func fromResultCode(code: Int) -> [String:AnyHashable] {
    var dict = [String:AnyHashable]()

    dict.updateValue(code, forKey: Constants.CODE);
    dict.updateValue(String(format: "0x%02X", locale: Locale(identifier: "en_US"), code), forKey: Constants.RES_CODE);

    switch code {
    case 777:
      dict.updateValue(Constants.CONNECTING, forKey: Constants.MSG);
      break;
    case 888:
      dict.updateValue(Constants.RECEIVING, forKey: Constants.MSG);
      break;
    case 999:
      dict.updateValue(Constants.AUTHORIZING, forKey: Constants.MSG);
      break;
    case 0:
      dict.updateValue(Constants.SUCCESSFUL, forKey: Constants.MSG);
      break;
    case 1:
      dict.updateValue(Constants.CARD_READ_ERROR, forKey: Constants.MSG);
      break;
    case 3:
      dict.updateValue(Constants.LRC_ERROR, forKey: Constants.MSG);
      break;
    case 4:
      dict.updateValue(Constants.TIMEOUT, forKey: Constants.MSG);
      break;
    case 5:
      dict.updateValue(Constants.MISMATCH_HOTEL_CODE, forKey: Constants.MSG);
      break;
    case 6:
      dict.updateValue(Constants.CARD_TYPE_ERROR, forKey: Constants.MSG);
      break;
    case 7:
      dict.updateValue(Constants.BATTERY_END_DETECTED, forKey: Constants.MSG);
      break;
    case 8:
      dict.updateValue(Constants.SERIAL_NUM_ENCODING_ERROR, forKey: Constants.MSG);
      break;
    case 9:
      dict.updateValue(Constants.LOG_ENCODING_ERROR, forKey: Constants.MSG);
      break;
    case 11:
      dict.updateValue(Constants.DEADBOLT_IN_USE, forKey: Constants.MSG);
      break;
    case 12:
      dict.updateValue(Constants.MLO, forKey: Constants.MSG);
      break;
    case 13:
      dict.updateValue(Constants.HLO, forKey: Constants.MSG);
      break;
    case 14:
      dict.updateValue(Constants.CARD_TYPE_ERROR, forKey: Constants.MSG);
      break;
    case 15:
      dict.updateValue(Constants.SHUTOUT_CONDITION, forKey: Constants.MSG);
      break;
    case 16:
      dict.updateValue(Constants.MISMATCH_ROOM_NUM, forKey: Constants.MSG);
      break;
    case 17:
      dict.updateValue(Constants.MISMATCH_ROOM_RANGE, forKey: Constants.MSG);
      break;
    case 18:
      dict.updateValue(Constants.MISMATCH_NON_GUEST_DOOR_FLAG, forKey: Constants.MSG);
      break;
    case 19:
      dict.updateValue(Constants.OUT_OF_TIME_RANGE, forKey: Constants.MSG);
      break;
    case 20:
      dict.updateValue(Constants.OUT_OF_DAY, forKey: Constants.MSG);
      break;
    case 21:
      dict.updateValue(Constants.INVALID_TIME_RANGE_0x15, forKey: Constants.MSG);
      break;
    case 22:
      dict.updateValue(Constants.INACTIVE_CARD, forKey: Constants.MSG);
      break;
    case 24:
      dict.updateValue(Constants.INVALID_COMMON_DATA_USAGE, forKey: Constants.MSG);
      break;
    case 26:
      dict.updateValue(Constants.INVALID_TIME_RANGE_0x1A, forKey: Constants.MSG);
      break;
    case 27:
      dict.updateValue(Constants.DS_CARD_ERROR, forKey: Constants.MSG);
      break;
    case 32:
      dict.updateValue(Constants.SMS_OUT_OF_DATE_RANGE, forKey: Constants.MSG);
      break;
    case 33:
      dict.updateValue(Constants.SMS_OUT_OF_TIME_RANGE, forKey: Constants.MSG);
      break;
    case 34:
      dict.updateValue(Constants.SMS_OUT_OF_DAY_WEEK, forKey: Constants.MSG);
      break;
    case 35:
      dict.updateValue(Constants.SMS_INVALID_ACCESS_RIGHT, forKey: Constants.MSG);
      break;
    case 42:
      dict.updateValue(Constants.SEQUENCE_ERROR_1, forKey: Constants.MSG);
      break;
    case 43:
      dict.updateValue(Constants.INVALID_CARD_DATA_DATE, forKey: Constants.MSG);
      break;
    case 45:
      dict.updateValue(Constants.INVALID_CARD_DATA_ROOM_NUM, forKey: Constants.MSG);
      break;
    case 49:
      dict.updateValue(Constants.INVALID_CARD_DATA_FREE_COMMAND, forKey: Constants.MSG);
      break;
    case 51:
      dict.updateValue(Constants.SEQUENCE_ERROR_2, forKey: Constants.MSG);
      break;
    case 52:
      dict.updateValue(Constants.MISMATCH_SPECIAL_DOOR_FLAG, forKey: Constants.MSG);
      break;
    case 53:
      dict.updateValue(Constants.SMS_OUT_OF_ROOM_RANGE, forKey: Constants.MSG);
      break;
    case 54:
      dict.updateValue(Constants.INACTIVE_CARD_OTHER_PARAMETER, forKey: Constants.MSG);
      break;
    case 55:
      dict.updateValue(Constants.UNEXPECTED_WAKEUP, forKey: Constants.MSG);
      break;
    case 56:
      dict.updateValue(Constants.RTC_ERROR, forKey: Constants.MSG);
      break;
    case 57:
      dict.updateValue(Constants.SYSTEM_RESET, forKey: Constants.MSG);
      break;
    case 58:
      dict.updateValue(Constants.RTC_FOS_FLAG_ON, forKey: Constants.MSG);
      break;
    case 59:
      dict.updateValue(Constants.LOG_ENCODING_ARE_OVERFLOW, forKey: Constants.MSG);
      break;
    case 60:
      dict.updateValue(Constants.ROOM_TYPE_ERROR, forKey: Constants.MSG);
      break;
    case 65:
      dict.updateValue(Constants.OVERRIDE_ERROR, forKey: Constants.MSG);
      break;
    case 66:
      dict.updateValue(Constants.BATTERY_NEAR_END, forKey: Constants.MSG);
      break;
    case 67:
      dict.updateValue(Constants.DOOR_AJAR_ON, forKey: Constants.MSG);
      break;
    case 68:
      dict.updateValue(Constants.DOOR_AJAR_OFF, forKey: Constants.MSG);
      break;
    case 69:
      dict.updateValue(Constants.DOOR_AJAR_ERROR, forKey: Constants.MSG);
      break;
    case 70:
      dict.updateValue(Constants.BLE_SEND_ERROR, forKey: Constants.MSG);
      break;
    case 71:
      dict.updateValue(Constants.BLE_RECEIVE_ERROR, forKey: Constants.MSG);
      break;
    case 72:
      dict.updateValue(Constants.BLE_NOTIFY_ERROR, forKey: Constants.MSG);
      break;
    case 160:
      dict.updateValue(Constants.MISMATCH_VERIFY, forKey: Constants.MSG);
      break;
//    case 248:
//      dict.updateValue(Constants.NO_AUTHORIZATION_FOR_BLE_LOCATION, forKey: Constants.MSG);
//      break;
    case 249:
      dict.updateValue(Constants.TIME_OUT, forKey: Constants.MSG);
      break;
    case 250:
      dict.updateValue(Constants.RECEIVE_ADVERTISE_FROM_WRONG_ROOM, forKey: Constants.MSG);
      break;
    case 251:
      dict.updateValue(Constants.INSIDE_PROCESS_ERROR, forKey: Constants.MSG);
      break;
    case 252:
      dict.updateValue(Constants.CANCEL_BY_USER, forKey: Constants.MSG);
      break;
    case 253:
      dict.updateValue(Constants.BLE_INACTIVE, forKey: Constants.MSG);
      break;
    case 254:
      dict.updateValue(Constants.OTHER_ERROR, forKey: Constants.MSG);
      break;
    case 255:
      dict.updateValue(Constants.BLE_COMMUNICATION_ERROR, forKey: Constants.MSG);
      break;
    default:
      dict.updateValue(Constants.NULL, forKey: Constants.MSG);
      break;
    }
    return dict
  }
}
