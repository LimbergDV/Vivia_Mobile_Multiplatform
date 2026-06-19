//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import device_info_plus
import google_sign_in_ios
import local_auth_darwin
import package_info_plus
import passkeys_darwin
import shared_preferences_foundation
import ua_client_hints

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  DeviceInfoPlusMacosPlugin.register(with: registry.registrar(forPlugin: "DeviceInfoPlusMacosPlugin"))
  FLTGoogleSignInPlugin.register(with: registry.registrar(forPlugin: "FLTGoogleSignInPlugin"))
  LocalAuthPlugin.register(with: registry.registrar(forPlugin: "LocalAuthPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  PasskeysPlugin.register(with: registry.registrar(forPlugin: "PasskeysPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  UAClientHintsPlugin.register(with: registry.registrar(forPlugin: "UAClientHintsPlugin"))
}
