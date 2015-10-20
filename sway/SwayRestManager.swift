//
//  SwayRestManager.swift
//  sway
//
//  Created by Vicki Chun on 10/20/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import SwiftyJSON

typealias ServiceResponse = (JSON, NSError?) -> Void

class SwayRestManager: NSObject {
  static let sharedInstance = SwayRestManager()
  
  let baseURL = "https://api.parse.com/1/"
  
  let parseCredentials = Credentials.parseCredentials
  
  struct Credentials {
    static let parseCredentialsFile = "ParseCredentials"
    static let parseCredentials     = Credentials.loadFromPropertyListNamed(parseCredentialsFile)
    
    let consumerKey: String
    let consumerSecret: String
    let restKey: String
    
    private static func loadFromPropertyListNamed(name: String) -> Credentials {
      let path           = NSBundle.mainBundle().pathForResource(name, ofType: "plist")!
      let dictionary     = NSDictionary(contentsOfFile: path)!
      let consumerKey    = dictionary["Key"] as! String
      let consumerSecret = dictionary["Secret"] as! String
      let restKey        = dictionary["Rest"] as! String
      
      return Credentials(consumerKey: consumerKey, consumerSecret: consumerSecret, restKey: restKey)
    }
  }
  
  private func makeHTTPGetRequest(path: String, params: NSDictionary?, onCompletion: ServiceResponse) {
    let request = NSMutableURLRequest(URL: NSURL(string: path)!)
    request.addValue(parseCredentials.consumerKey, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(parseCredentials.restKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    //var params = ["Query1" : "\(searchString)"]

    if let params = params {
      do {
        let paramsJSON = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        let paramsJSONString = NSString(data: paramsJSON, encoding: NSUTF8StringEncoding)
        let whereClause = paramsJSONString?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.alphanumericCharacterSet())
        let requestURL = NSURL(string: String(format: "%@?%@%@", path, "where=", whereClause!))
        request.URL = requestURL
      } catch {
        print("error creating url with params")
      }
    }
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
      let json:JSON = JSON(data: data!)
      onCompletion(json, error)
    })
    task.resume()
  }
  
  private func makeHTTPPostRequest(path: String, body: [String: AnyObject], onCompletion: ServiceResponse) {
    let err: NSError? = nil
    let request = NSMutableURLRequest(URL: NSURL(string: path)!)
    
    // Set the method to POST
    request.HTTPMethod = "POST"
    
    do {
      // Set the POST body for the request
      request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
    } catch {
      // TODO
      print("error posting")
    }
    
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
      let json:JSON = JSON(data: data!)
      onCompletion(json, err)
    })
    task.resume()
  }
  
  
  func getAllRecordings(onCompletion: (JSON) -> Void) {
    let route = "\(baseURL)classes/Recordings"
    makeHTTPGetRequest(route, params: nil, onCompletion: { json, err in
      onCompletion(json as JSON)
    })
  }
  
  func getRecording(recordingId: String, onCompletion: (JSON) -> Void) {
    let route = "\(baseURL)classes/Recordings/\(recordingId)"
    makeHTTPGetRequest(route, params: nil, onCompletion: { json, err in
      onCompletion(json as JSON)
    })

  }
  
  func createNewRecording(params: [String: AnyObject], onCompletion: (JSON) -> Void) {
    let route = "\(baseURL)classes/Recordings"
    makeHTTPPostRequest(route, body: params) { (json, err) -> Void in
      onCompletion(json as JSON)
    }
  }
  
}