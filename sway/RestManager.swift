//
//  RestManager.swift
//  sway
//
//  Created by Vicki Chun on 10/20/15.
//  Copyright © 2015 VCH. All rights reserved.
//

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestManager: NSObject {
    static let sharedInstance = RestManager()
    
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
    
    
    func getAllRecordings(onCompletion: (tunes: [Tune]?, error: NSError?) -> Void) {
        let route = "\(baseURL)classes/Recordings"
        makeHTTPGetRequest(route, params: nil, onCompletion: { json, err in
            if err == nil {
                let resultsArray = json["results"]
                print("\(resultsArray)")
                
                var tunes = [Tune]()
                for result in resultsArray {
                    let tune : Tune = Tune(json : result.1)
                    tunes.append(tune)
                }
                onCompletion(tunes: tunes, error: nil)
            } else {
                onCompletion(tunes: nil, error: err)
            }
        })
    }
    
    func getRecording(recordingId: String, onCompletion: (tune: Tune?, error: NSError?) -> Void) {
        let route = "\(baseURL)classes/Recordings/\(recordingId)"
        makeHTTPGetRequest(route, params: nil, onCompletion: { json, err in
            if err == nil {
                let tune = Tune(json: json)
                onCompletion(tune: tune, error: nil)
            } else {
                onCompletion(tune: nil, error: err)
            }
        })
    }
    
    func postRecording(params: [String: AnyObject], onCompletion: (tune: Tune?, error: NSError?) -> Void) {
        let route = "\(baseURL)classes/Recordings"
        makeHTTPPostRequest(route, body: params) { (json, err) -> Void in
            if err == nil {
                let tune = Tune(json: json)
                onCompletion(tune: tune, error: nil)
            } else {
                onCompletion(tune: nil, error: err)
            }
        }
    }
    
}
