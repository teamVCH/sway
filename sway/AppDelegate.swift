//
//  AppDelegate.swift
//  sway
//
//  Created by Hina Sakazaki on 10/15/15.
//  Copyright © 2015 VCH. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    var sharedCache: NSURLCache?
    
    let parseCredentials = Credentials.parseCredentials
    let twitterCredentials = Credentials.twitterCredentials
    
    struct Credentials {
        static let parseCredentialsFile = "ParseCredentials"
        static let parseCredentials     = Credentials.loadFromPropertyListNamed(parseCredentialsFile)
        static let twitterCredentialsFile = "TwitterCredentials"
        static let twitterCredentials     = Credentials.loadFromPropertyListNamed(twitterCredentialsFile)
        
        let consumerKey: String
        let consumerSecret: String
        
        private static func loadFromPropertyListNamed(name: String) -> Credentials {
            let path           = NSBundle.mainBundle().pathForResource(name, ofType: "plist")!
            let dictionary     = NSDictionary(contentsOfFile: path)!
            let consumerKey    = dictionary["Key"] as! String
            let consumerSecret = dictionary["Secret"] as! String
            
            return Credentials(consumerKey: consumerKey, consumerSecret: consumerSecret)
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //set colors
        
        UINavigationBar.appearance().barTintColor = UIColor(hue: 0.6056, saturation: 0.03, brightness: 0.94, alpha: 1.0) /* #e8ebef */

        //UIColor(hue: 0.5917, saturation: 0.39, brightness: 0.58, alpha: 1.0) /* #597394 */

            
            //UIColor(hue: 0.5556, saturation: 0.18, brightness: 0.92, alpha: 1.0) /* #bfdceb */
        UITabBar.appearance().barTintColor = UIColor(hue: 0.6056, saturation: 0.03, brightness: 0.94, alpha: 1.0) /* #e8ebef */

            //UIColor(hue: 0.5917, saturation: 0.39, brightness: 0.58, alpha: 1.0) /* #597394 */

            
            //UIColor(hue: 0.5556, saturation: 0.18, brightness: 0.92, alpha: 1.0) /* #bfdceb */

        //color: http://design-seeds.com/home/entry/color-view31
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.blackColor()], forState: UIControlState.Normal)


        Parse.setApplicationId(parseCredentials.consumerKey, clientKey: parseCredentials.consumerSecret)
        PFTwitterUtils.initializeWithConsumerKey(twitterCredentials.consumerKey, consumerSecret: twitterCredentials.consumerSecret)
        
        // initialze shared cache with 2 MB mem and 100 MB disk space
        sharedCache = NSURLCache(memoryCapacity: 2 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(sharedCache!)
        
        _ = AVFoundationHelper.init(completion: { (allowed) -> () in
            if allowed {
                print("Audio recording is allowed")
            } else {
                print("Audio recording is NOT allowed")
            }
        })
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // get a URL for the saved recording in the app documents folder
    static func getDocumentsFolderUrl() -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let documentsFolderUrl: NSURL?
        do {
            documentsFolderUrl = try fileManager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
        } catch let error as NSError {
            print("Error accessing documents folder: \(error)")
            documentsFolderUrl = nil
        }
        
        return documentsFolderUrl
    }
    
    static func createTempDirectory() -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let tempDirectoryTemplate = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("sway")
        do {
            try fileManager.createDirectoryAtPath(tempDirectoryTemplate, withIntermediateDirectories: true, attributes: nil)
            return NSURL(fileURLWithPath: tempDirectoryTemplate)
        } catch let error as NSError {
            print("Error creating temp folder: \(error)")
            return nil
        }
    }
    
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.plymouthsoftware.core_data" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("sway", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("sway.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
    
}

