#include "include/flutter_serial/flutter_serial_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_serial_plugin.h"

void FlutterSerialPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_serial::FlutterSerialPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
