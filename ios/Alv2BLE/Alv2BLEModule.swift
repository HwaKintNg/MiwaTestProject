//
//  Alv2BLEModule.swift
//  GentingApp
//
//  Created by Beans Group on 26/09/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

import Foundation
import UIKit
import Alv2BleService
import Realm
import RealmSwift
import CoreBluetooth
import CoreLocation

@objc(Alv2BLEModule)
class Alv2BLEModule:RCTEventEmitter, CBCentralManagerDelegate {
  
  //Recommended RF threshold
  let ALV2_RSSI:Int32 = -70
  let RDFL_RSSI:Int32 = -65
  let RECV_RSSI:Int32 = -70
  let TIMEOUT:UInt64 = 10000 // 10 seconds
  
  // Constants
  let EVENT_ALV2BLE:String = "EVENT_ALV2BLE"
  let NOTIFICATION_ALV2BLE:String = "Alv2ServiceNotification" // <- CANNOT BE CHANGED
  let NOTIFICATION_CONNECT_BLE_ALV2BLE:String = "Alv2ServiceNotificationConnectBle" // <- CANNOT BE CHANGED
  let SERIAL:String = "9271A5BF4EAC526C244AA9D3035890DA5585D6EC82136ABE82A4378E3FA708D6E1EC7AF554D3D83867410E4A38EA069E41D92CF1FC9A9640";
  
  let ERROR:String = "ERROR"
  let CODE:String = "code"
  let DATA:String = "data"
  let MSG:String = "msg"
  let KEY_FOUND:String = "KEY_FOUND"
  let KEY_IS_NULL:String = "KEY_IS_NULL"
  let ROOM_NO_IS_ZERO:String = "ROOM_NO_IS_ZERO"
  
  // Bluetooth
  let BLUETOOTH_NOT_ENABLED:String = "BLUETOOTH_NOT_ENABLED"
  let BLUETOOTH_NOT_SUPPORTED:String = "BLUETOOTH_NOT_SUPPORTED"
  let BLUEOOTH_PERMISSION_NOT_GRANTED:String = "BLUEOOTH_PERMISSION_NOT_GRANTED"
  let BLUEOOTH_PERMISSION_DENIED_FOREVER:String = "BLUEOOTH_PERMISSION_DENIED_FOREVER"

  // Location
  let LOCATION_RESTRICTED:String = "LOCATION_RESTRICTED"
  let LOCATION_NOT_ENABLED:String = "LOCATION_NOT_ENABLED"
  let LOCATION_PERMISSION_NOT_GRANTED:String = "LOCATION_PERMISSION_NOT_GRANTED"
  let LOCATION_PERMISSION_DENIED_FOREVER:String = "LOCATION_PERMISSION_DENIED_FOREVER"

  // OK code
  let ALL_CONDITIONS_OK:String = "ALL_CONDITIONS_OK"

  let CONNECTING:Int = 777
  let RECEIVING:Int = 888
  let AUTHORIZING:Int = 999
  
  // CAUTION: Alv2KeyTable, REALM REQUIRED MAIN THREAD TO ACCESS, REGARDLESS CRUD...
  var a2kt:Alv2KeyTable!// holds the room information
  var a2kList:[Alv2Key]! // array storing Alv2Key info
  var selectedKey:Alv2Key? // currently selected room key
  var alv2:Alv2Ble! // Alv2Ble service
  
  var hasListeners:Bool = false
  var isLocationOn:Bool = false
  var isLocationPermissionOk:Bool = false
  var isMiwaStarted:Bool = false
  
  var formatter:DateFormatter! = DateFormatter()
  let locationMgr:CLLocationManager = CLLocationManager()
  let centralMgr:CBCentralManager = CBCentralManager()
  var bluetoothEnabled:Bool = false
  
  override init() {
    super.init()
    
    a2kt = Alv2KeyTable() // init
    a2kList = []
    formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
    formatter.locale = Locale.init(identifier: "en_US")
    formatter.timeZone = TimeZone(abbreviation: "GMT")
    
    centralMgr.delegate = self
    
    self.startMiwa(SERIAL)
  }
  
  deinit {
    self.stopMiwa()
    self.stopObserving()
  }
  
  @objc
  override func constantsToExport() -> [AnyHashable : Any]! {
    return [
      EVENT_ALV2BLE: EVENT_ALV2BLE,
      KEY_FOUND: KEY_FOUND,
      KEY_IS_NULL: KEY_IS_NULL,
      
      BLUETOOTH_NOT_ENABLED: BLUETOOTH_NOT_ENABLED,
      BLUETOOTH_NOT_SUPPORTED: BLUETOOTH_NOT_SUPPORTED,
      BLUEOOTH_PERMISSION_NOT_GRANTED: BLUEOOTH_PERMISSION_NOT_GRANTED,
      BLUEOOTH_PERMISSION_DENIED_FOREVER: BLUEOOTH_PERMISSION_DENIED_FOREVER,

      LOCATION_RESTRICTED: LOCATION_RESTRICTED,
      LOCATION_NOT_ENABLED: LOCATION_NOT_ENABLED,
      LOCATION_PERMISSION_NOT_GRANTED: LOCATION_PERMISSION_NOT_GRANTED,
      LOCATION_PERMISSION_DENIED_FOREVER: LOCATION_PERMISSION_DENIED_FOREVER,

      ALL_CONDITIONS_OK: ALL_CONDITIONS_OK
    ];
  }
  
  @objc
  override func supportedEvents() -> [String]! {
    return [EVENT_ALV2BLE];
  }
  
  @objc
  override func startObserving() {
    self.hasListeners = true;
  }
  
  @objc
  override func stopObserving() {
    self.hasListeners = false;
  }
  
  @objc
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  @objc
  override var methodQueue: DispatchQueue! {
    return DispatchQueue.main
  }
  
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    bluetoothEnabled = (central.state == .poweredOn)
  }
  
  // Start Miwa
  @objc
  func startMiwa(_ serial:String) -> Void {
    // start Alv2ble lib
    alv2 = try! Alv2Ble(serialCode: serial)
    isMiwaStarted = true
    
    // start observer for alv2ble response
    // An observer needed to return response
    NotificationCenter.default.addObserver(self, selector: #selector(onReceiveAlv2BleResult(_:)), name: Notification.Name(NOTIFICATION_ALV2BLE), object: nil)
    
    // start observer for alv2ble connect ble response
    // An observer needed to return response
    // response to be tested
    //    NotificationCenter.default.addObserver(self, selector: #selector(onReceiveAlv2BleConnectBLEResult(_:)), name: Notification.Name(NOTIFICATION_CONNECT_BLE_ALV2BLE), object: nil)
  }
  
  // Stop Miwa
  @objc
  func stopMiwa() -> Void {
    alv2.StopService()
    isMiwaStarted = false
    
    NotificationCenter.default.removeObserver(self, name: Notification.Name(NOTIFICATION_ALV2BLE), object: nil)
    //    NotificationCenter.default.removeObserver(self, name: Notification.Name(NOTIFICATION_CONNECT_BLE_ALV2BLE), object: nil)
  }
  
  // Add key
  @objc
  func addKey(_ keyData1: String, keyData2: String, keyData3: String, keyName: String, roomNo: Int64, ci: String, co: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) -> Void {
    
    if (keyData1.count <= 0 || keyData2.count <= 0 || keyData3.count <= 0) {
      reject(ERROR, "Key Data cannot be null", nil)
      return
    } else if keyName.count <= 0 {
      reject(ERROR, "Key Name cannot be null", nil)
      return
    } else if roomNo <= 0 {
      reject(ERROR, "Key Number cannot be zero", nil)
      return
    } else if ci.count <= 0 {
      reject(ERROR, "Check-In Date cannot be null", nil)
      return
    } else if co.count <= 0 {
      reject(ERROR, "Check-Out Date cannot be null", nil)
      return
    }
    
    let basic = Utility.hexToByte(keyData1)
    let ext1 = Utility.hexToByte(keyData2)
    let ext2 = Utility.hexToByte(keyData3)
    
    let key:Alv2Key = Alv2Key(basic:basic, ext1:ext1, ext2:ext2)
    key.keyNameData = keyName
    key.roomData = roomNo
    key.ciData = formatter.date(from: ci)
    key.coData = formatter.date(from: co)
    
    let a2ktKey:Int64 = a2kt.insert(key)
    debugPrint(String(format:"key id :%d",a2ktKey))
    
    selectedKey = key;
    loadKeyData(selectedKey!.keyNameData, roomNo: selectedKey!.roomData, resolve: resolve, reject: reject)
  }
  
  // Start key data receiving process,
  // this process is async.
  @objc
  func startRecv(_ etRoom: String, resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
    sendEvent(EVENT_ALV2BLE, Constants.fromResultCode(code: CONNECTING))
    
    self.checkBluetoothAndLocationServicesV2(false, resolve, reject)
    
    if !isMiwaStarted {
      startMiwa(SERIAL)
    }
    
    if bluetoothEnabled && isLocationOn && isLocationPermissionOk {
      if etRoom.count > 0 {
        if let roomNo:Int64 = Int64(etRoom) {
          alv2.StartRecv(roomData: roomNo, rssi: RECV_RSSI, timeout: TIMEOUT)
          
          sendEvent(EVENT_ALV2BLE, Constants.fromResultCode(code: RECEIVING))
          resolve(nil)
        } else {
          print("Something wrong, roomNo false")
          reject(ERROR, ROOM_NO_IS_ZERO, nil)
        }
      } else {
        print("Something wrong, etRoom.count < 0")
        reject(ERROR, ROOM_NO_IS_ZERO, nil)
      }
    }
  }
  
  // Start key data sending process.
  // this process is async.
  @objc
  func startAuth(_ resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
    sendEvent(EVENT_ALV2BLE, Constants.fromResultCode(code: CONNECTING))
    
    self.checkBluetoothAndLocationServicesV2(false, resolve, reject)
    
    if !isMiwaStarted {
      startMiwa(SERIAL)
    }
    
    if bluetoothEnabled && isLocationOn && isLocationPermissionOk {
      if selectedKey != nil {
        alv2.StartAuth(idData: selectedKey!.idData, rssi: ALV2_RSSI, commonRssi: RDFL_RSSI, timeout: TIMEOUT)
        
        sendEvent(EVENT_ALV2BLE, Constants.fromResultCode(code: AUTHORIZING))
        resolve(nil);
      } else {
        reject(ERROR, KEY_IS_NULL, nil)
      }
    }
  }
  
  // Delete selected key data from DB.
  @objc
  func delSelectedKey(_ roomNo:Int64, resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
    if roomNo > 0 {
      a2kList = a2kt.list()
      for key in a2kList {
        if (key.roomData ==  roomNo) {
          guard a2kt.delete(key) else {
            reject(ERROR, "Room Key could not be deleted due to an unknown error", nil)
            return
          }
        }
      }
      selectedKey = nil
      resolve(nil)
    } else {
      reject(ERROR, "Room number not provided", nil)
    }
  }
  
  // Delete all key data from DB.
  @objc
  func delAllKey(_ resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
    print("delAllKey")

    a2kList = a2kt.list()
    print("count:start: ")
    print(a2kList.count)
    for key in a2kList {
      if let coDate:Date = key.coData {
        let current:Date = Date()
        if (current > coDate || current == coDate) {
          guard a2kt.delete(key) else {
            reject(ERROR, "Room Key could not be deleted due to an unknown error", nil)
            return
          }
        }
      }
    }
    selectedKey = nil
    resolve(nil)
  }
  
  @objc
  func loadKeyData(_ keyName:String, roomNo:Int64, resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
    a2kList = a2kt.list()
    var filteredKey:[Alv2Key] = []

    for key in a2kList {
      if (key.keyNameData == keyName && key.roomData == roomNo) {
        filteredKey.append(key)
      }
    }

    if (a2kList.count > 0 && filteredKey.count > 0) {
      selectedKey = filteredKey[filteredKey.count - 1]
      resolve(keyData(KEY_FOUND, msg: "", key: selectedKey!))
    } else {
      selectedKey = nil
      resolve(keyDataNil(KEY_IS_NULL, msg: KEY_IS_NULL))
    }
  }
  
  func loadKeyData() -> Void {
    a2kList = a2kt.list()
    if a2kList.count > 0 {
      selectedKey = a2kList[a2kList.count - 1]; // always get latest key
    } else {
      selectedKey = nil
    }
  }
  
  @objc
  func checkBluetoothAndLocationServicesV2(_ resolveResult:Bool, _ resolve:@escaping RCTPromiseResolveBlock,_ reject:@escaping RCTPromiseRejectBlock) -> Void {
    if centralMgr.state == .unsupported {
      resolve(BLUETOOTH_NOT_SUPPORTED)
      return
    } else if centralMgr.state == .unauthorized {
      resolve(BLUEOOTH_PERMISSION_NOT_GRANTED)
      return
    } else {
      let status = CLLocationManager.authorizationStatus()
      switch status {
      case .denied:
        // user denied purposely, prompt user to settings
        debugPrint("denied")
        isLocationPermissionOk = false
        resolve(LOCATION_PERMISSION_DENIED_FOREVER)
        return
      case .restricted:
        debugPrint("restricted")
        isLocationPermissionOk = false
        resolve(LOCATION_RESTRICTED)
        return
      case .notDetermined:
        debugPrint("notDetermined")
        isLocationPermissionOk = false
        locationMgr.requestWhenInUseAuthorization()
        resolve(LOCATION_PERMISSION_NOT_GRANTED)
        return
      case .authorizedWhenInUse:
        debugPrint("authorizedWhenInUse")
        isLocationPermissionOk = true
        bluetoothEnabled = (centralMgr.state == .poweredOn)
        isLocationOn = CLLocationManager.locationServicesEnabled()
        if !bluetoothEnabled {
          resolve(BLUETOOTH_NOT_ENABLED)
          return
        } else if !isLocationOn {
          resolve(LOCATION_NOT_ENABLED)
          return
        }
        if(resolveResult){
          resolve(ALL_CONDITIONS_OK)
          return
        }
        break
      case .authorizedAlways:
        debugPrint("authorizedAlways")
        isLocationPermissionOk = true
        bluetoothEnabled = (centralMgr.state == .poweredOn)
        isLocationOn = CLLocationManager.locationServicesEnabled()
        if !bluetoothEnabled {
          resolve(BLUETOOTH_NOT_ENABLED)
          return
        } else if !isLocationOn {
          resolve(LOCATION_NOT_ENABLED)
          return
        }
        if(resolveResult){
          resolve(ALL_CONDITIONS_OK)
          return
        }
        break
      @unknown default:
        debugPrint("unknown value")
        isLocationPermissionOk = false
        reject("ERROR","unkown permission status",nil);
        return
      }
    }
  }
  
  
  @objc
  func checkBluetoothAndLocationServices(_ resolveResult:Bool, _ resolve:@escaping RCTPromiseResolveBlock,_ reject:@escaping RCTPromiseRejectBlock) -> Void {
    isLocationOn = CLLocationManager.locationServicesEnabled()
    
    bluetoothEnabled = false
    if centralMgr.state == .unsupported {
      resolve(BLUETOOTH_NOT_SUPPORTED)
      return
    } else if centralMgr.state == .unauthorized {
      resolve(BLUEOOTH_PERMISSION_NOT_GRANTED)
      return
    } else {
      bluetoothEnabled = (centralMgr.state == .poweredOn)
      if !bluetoothEnabled {
        resolve(BLUETOOTH_NOT_ENABLED)
        return
      } else if !isLocationOn {
        resolve(LOCATION_NOT_ENABLED)
        return
      } else {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .denied:
          // user denied purposely, prompt user to settings
          debugPrint("denied")
          isLocationPermissionOk = false
          resolve(LOCATION_PERMISSION_DENIED_FOREVER)
          return
        case .restricted:
          debugPrint("restricted")
          isLocationPermissionOk = false
          resolve(LOCATION_RESTRICTED)
          return
        case .notDetermined:
          debugPrint("notDetermined")
          isLocationPermissionOk = false
          locationMgr.requestWhenInUseAuthorization()
          resolve(LOCATION_PERMISSION_NOT_GRANTED)
          return
        case .authorizedWhenInUse:
          debugPrint("authorizedWhenInUse")
          isLocationPermissionOk = true
          if(resolveResult){
            resolve(ALL_CONDITIONS_OK)
            return
          }
          break
        case .authorizedAlways:
          debugPrint("authorizedAlways")
          isLocationPermissionOk = true
          if(resolveResult){
            resolve(ALL_CONDITIONS_OK)
            return
          }
          break
        @unknown default:
          debugPrint("unknown value")
          isLocationPermissionOk = false
          reject("ERROR","unkown permission status",nil);
          return
        }
      }
    }
  }
  
  @objc
  func openLocationSetting(_ resolve:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) -> Void {
    let settingsUrl = URL(string: UIApplication.openSettingsURLString)
    
    if (settingsUrl != nil) {
      // UIApplication is main UI thread
      DispatchQueue.main.async() {
        if UIApplication.shared.canOpenURL(settingsUrl!) {
          UIApplication.shared.open(settingsUrl!, options: [:], completionHandler: nil)
          resolve(nil)
        }
      }
    }
  }
  
  /**
   * ======================================================================================================
   * HELPER HELPER HELPER HELPER HELPER HELPER HELPER HELPER HELPER HELPER HELPER HELPER HELPER HELPER
   * ======================================================================================================
   */
  func sendEvent(_ eventName:String!,_ body:Any!) -> Void {
    if hasListeners {
      sendEvent(withName: eventName, body: body)
    }
  }
  
  @objc
  func onReceiveAlv2BleResult(_ notification:Notification) -> Void {
    if let userInfo = notification.userInfo{
      print("==========onReceiveAlv2BleResult================")
      print(userInfo)
      print("==========onReceiveAlv2BleResult================")
      
      let code = userInfo["retCode"] as! UInt8
      debugPrint("onAlv2Result: "+String(format:"0x%02X",code))
      if code == 0 {
        let idData = userInfo["idData"] as! Int64
        debugPrint("onAlv2Result: "+String(format: "ResultId:%d", idData))
        if idData >= 0 {
          loadKeyData()
        }
        sendEvent(EVENT_ALV2BLE, Constants.fromResultCode(code: Int(code)))
      }else{
        sendEvent(EVENT_ALV2BLE, Constants.fromResultCode(code: Int(code)))
        showNgInfo()
      }
    }
  }
  
  // not using this function
  @objc
  func onReceiveAlv2BleConnectBLEResult(_ notification:Notification) -> Void {
    if let userInfo = notification.userInfo{
      print("+++++++++onReceiveAlv2BleConnectBLEResult+++++++++")
      print(userInfo)
      print("+++++++++onReceiveAlv2BleConnectBLEResult+++++++++")
      //
      //      let code = userInfo["retCode"] as! UInt8
      //      debugPrint("onAlv2Result: "+String(format:"0x%02X",code))
      //      if code == 0 {
      //        let idData = userInfo["idData"] as! Int64
      //        debugPrint("onAlv2Result: "+String(format: "ResultId:%d", idData))
      //        if idData > 0 {
      //          loadKeyData()
      //          self.sendEvent(eventName: EVENT_ALV2BLE, body: Constants.fromResultCode(code: Int(code)))
      //        }
      //      }else{
      //        self.sendEvent(eventName: EVENT_ALV2BLE, body: Constants.fromResultCode(code: Int(code)))
      //        showNgInfo()
      //      }
    }
  }
  
  func showNgInfo(){
    let nt:NgInfoTable = NgInfoTable()
    if let ng = nt.find(1) {
      debugPrint(String(format:"date=%@ room=%d", formatter.string(from:ng.dateData!), ng.roomData))
      debugPrint(String(format: "ERROR:0x%02X", locale: Locale(identifier: "en_US"), ng.errorData))
      debugPrint(String(format: "ID:%d", ng.idData))
      debugPrint(String(format: "LOCK_TYPE:%d", ng.roomTypeData))
      debugPrint(String(format: "ROOM:%d", ng.roomData))
      debugPrint(String(format: "SP:%d", ng.spNoData))
      debugPrint(String(format: "DATE:%d", formatter.string(from:ng.dateData!)))
      debugPrint(String(format: "BATTERY:%d", ng.batteryData))
    }else{
      debugPrint("NO NG DATA")
    }
  }
  
  func keyData(_ code:String, msg:String, key:Alv2Key) -> [String: AnyHashable?] {
    var dict = [String:AnyHashable?]() // init
    
    dict.updateValue(code, forKey: CODE)
    dict.updateValue(msg, forKey: MSG)
    dict.updateValue(keyMap(key), forKey: DATA)
    
    return dict
  }
  
  func keyDataNil(_ code:String, msg:String) -> [String: AnyHashable?] {
    var dict = [String:AnyHashable?]() // init
    
    dict.updateValue(code, forKey: CODE)
    dict.updateValue(msg, forKey: MSG)
    dict.updateValue(nil, forKey: DATA)
    
    return dict
  }
  
  func keyMap(_ key:Alv2Key) -> [String: AnyHashable?] {
    var dict = [String:AnyHashable?]() // init
    
    dict.updateValue(key.keyNameData, forKey: "getKeyName")
    dict.updateValue(key.roomData, forKey: "getRoom")
    
    let room2 = List<Int64>()
    for room:Int64 in key.room2Data ?? [] {
      room2.append(room)
    }
    
//    TODO: Check why this doesn't work
//    dict.updateValue(room2, forKey: "getRoom2")
    dict.updateValue(key.idData, forKey: "getId")
    dict.updateValue(formatter.string(from: key.ciData!), forKey: "getCheckinDate")
    dict.updateValue(formatter.string(from: key.coData!), forKey: "getCheckOutDate")
    dict.updateValue(0, forKey: "getStaffCode")
    dict.updateValue(0, forKey: "getStaffLevel")
    dict.updateValue(key.tzData, forKey: "getTz")
    dict.updateValue("", forKey: "getPos")
    
    return dict
  }
}
