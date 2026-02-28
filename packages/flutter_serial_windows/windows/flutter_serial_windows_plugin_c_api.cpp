#include "include/flutter_serial_windows/flutter_serial_windows_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_serial_windows_plugin.h"

void FlutterSerialWindowsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_serial_windows::FlutterSerialWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
