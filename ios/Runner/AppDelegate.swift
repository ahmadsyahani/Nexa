import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate

    WorkmanagerPlugin.registerTask(
      withIdentifier: "backgroundNotifTask"
    )
    WorkmanagerPlugin.registerTask(
      withIdentifier: "dev.fluttercommunity.workmanager.iOSBackgroundAppRefresh"
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
