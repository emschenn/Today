import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import workmanager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
   
      func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    application.registerForRemoteNotifications()

    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
                // Registry in this case is the FlutterEngine that is created in Workmanager's
                // performFetchWithCompletionHandler or BGAppRefreshTask.
                // This will make other plugins available during a background operation.
                GeneratedPluginRegistrant.register(with: registry)
            }
    
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
  //   Auth.auth().setAPNSToken(deviceToken, type: .prod)
  // }

  // override func application(_ application: UIApplication,
  //   didReceiveRemoteNotification notification: [AnyHashable : Any],
  //   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
  //   if Auth.auth().canHandleNotification(notification) {
  //     completionHandler(.noData)
  //     return
  //   }
  // }

  // override func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
  //   if Auth.auth().canHandle(url) {
  //     return true
  //   }
  //   return false;
  // }
   override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Pass device token to auth
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
        
        // Pass device token to messaging
        Messaging.messaging().apnsToken = deviceToken
        
        return super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    // https://firebase.google.com/docs/auth/ios/phone-auth#appendix:-using-phone-sign-in-without-swizzling
    // https://firebase.google.com/docs/cloud-messaging/ios/receive#handle-swizzle
    override func application(_ application: UIApplication,
                              didReceiveRemoteNotification notification: [AnyHashable : Any],
                              fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle the message for firebase auth phone verification
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        
        // Handle it for firebase messaging analytics
        if ((notification["gcm.message_id"]) != nil) {
            Messaging.messaging().appDidReceiveMessage(notification)
        }
        
        return super.application(application, didReceiveRemoteNotification: notification, fetchCompletionHandler: completionHandler)
    }
    
    // https://firebase.google.com/docs/auth/ios/phone-auth#appendix:-using-phone-sign-in-without-swizzling
    override func application(_ application: UIApplication, open url: URL,
                              options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        // Handle auth reCAPTCHA when silent push notifications aren't available
        if Auth.auth().canHandle(url) {
            return true
        }
        
        return super.application(application, open: url, options: options)
    }
  
}
