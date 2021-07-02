import UIKit
import Flutter
import GoogleCast
//import YandexMobileMetrica
//import FBSDKCoreKit
// import Firebase


let YMApiKey = ""


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, GCKLoggerDelegate {
  // flutter_video_cast
  let kReceiverAppID = kGCKDefaultMediaReceiverApplicationID
  let kDebugLoggingEnabled = true

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // FaceBook SDK?
//    if #available(iOS 13.0, *) { } else {
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        let mainViewController = UIViewController()
//        let mainNavigationController = UINavigationController(rootViewController: mainViewController)
//        self.window!.rootViewController = mainNavigationController
//        self.window!.makeKeyAndVisible()
//    }

    // flutter default
    GeneratedPluginRegistrant.register(with: self)
    
    // flutter_video_cast
    let criteria = GCKDiscoveryCriteria(applicationID: kReceiverAppID)
    let options = GCKCastOptions(discoveryCriteria: criteria)
    GCKCastContext.setSharedInstanceWith(options)
    GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
    GCKLogger.sharedInstance().delegate = self

    // Yandex Metrica
//    let configuration = YMMYandexMetricaConfiguration.init(apiKey: YMApiKey)
//    YMMYandexMetrica.activate(with: configuration!)

    // FaceBook SDK
//    ApplicationDelegate.shared.application(
//        application,
//        didFinishLaunchingWithOptions: launchOptions
//    )

    // Firebase
    // FirebaseApp.configure()

    // iOS default
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

//  override func application(
//      _ app: UIApplication,
//      open url: URL,
//      options: [UIApplication.OpenURLOptionsKey : Any] = [:]
//  ) -> Bool {
//    // FaceBook SDK
//    ApplicationDelegate.shared.application(
//      app,
//      open: url,
//      sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
//      annotation: options[UIApplication.OpenURLOptionsKey.annotation]
//    )
//
//    return true
//  }
}
