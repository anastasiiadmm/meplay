import UIKit
import Flutter
import GoogleCast
// import YandexMobileMetrica
// import Firebase


// let YMApiKey = ""


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, GCKLoggerDelegate {
  // flutter_video_cast
  let kReceiverAppID = kGCKDefaultMediaReceiverApplicationID
  let kDebugLoggingEnabled = true

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // flutter default
    GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    // flutter_video_cast
    let criteria = GCKDiscoveryCriteria(applicationID: kReceiverAppID)
    let options = GCKCastOptions(discoveryCriteria: criteria)
    GCKCastContext.setSharedInstanceWith(options)
    GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
    GCKLogger.sharedInstance().delegate = self

    // Yandex Metrica
    // let configuration = YMMYandexMetricaConfiguration.init(apiKey: YMApiKey)
    // YMMYandexMetrica.activate(with: configuration!)

    // Firebase
    // FirebaseApp.configure()

    // iOS default
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
