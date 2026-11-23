#include <AudioToolbox/AudioServices.h>
#include <CoreAudio/CoreAudio.h>
#include "../sketchybar.h"

static char* g_event;
static AudioDeviceID g_device;

static AudioObjectPropertyAddress g_default_device = {
  kAudioHardwarePropertyDefaultOutputDevice,
  kAudioObjectPropertyScopeGlobal,
  kAudioObjectPropertyElementMain
};

static AudioObjectPropertyAddress g_volume = {
  kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
  kAudioDevicePropertyScopeOutput,
  kAudioObjectPropertyElementMain
};

static AudioObjectPropertyAddress g_mute = {
  kAudioDevicePropertyMute,
  kAudioDevicePropertyScopeOutput,
  kAudioObjectPropertyElementMain
};

static AudioObjectPropertyAddress g_transport = {
  kAudioDevicePropertyTransportType,
  kAudioObjectPropertyScopeGlobal,
  kAudioObjectPropertyElementMain
};

static void get(AudioObjectID object, AudioObjectPropertyAddress* address, UInt32 size, void* out) {
  AudioObjectGetPropertyData(object, address, 0, NULL, &size, out);
}

static void trigger(void) {
  Float32 volume = 0;
  UInt32 muted = 0, transport = 0;
  get(g_device, &g_volume, sizeof volume, &volume);
  get(g_device, &g_mute, sizeof muted, &muted);
  get(g_device, &g_transport, sizeof transport, &transport);
  bool bluetooth = transport == kAudioDeviceTransportTypeBluetooth
                   || transport == kAudioDeviceTransportTypeBluetoothLE;

  char message[512];
  snprintf(message, 512, "--trigger '%s' volume='%d' muted='%s' transport='%s'",
           g_event,
           (int)(volume * 100 + 0.5),
           muted ? "true" : "false",
           bluetooth ? "bluetooth" : "wired");
  sketchybar(message);
}

static OSStatus property_changed(AudioObjectID object, UInt32 count, const AudioObjectPropertyAddress* addresses, void* context) {
  trigger();
  return noErr;
}

static void watch(bool add) {
  if (add) {
    AudioObjectAddPropertyListener(g_device, &g_volume, property_changed, NULL);
    AudioObjectAddPropertyListener(g_device, &g_mute, property_changed, NULL);
  } else {
    AudioObjectRemovePropertyListener(g_device, &g_volume, property_changed, NULL);
    AudioObjectRemovePropertyListener(g_device, &g_mute, property_changed, NULL);
  }
}

static OSStatus device_changed(AudioObjectID object, UInt32 count, const AudioObjectPropertyAddress* addresses, void* context) {
  watch(false);
  get(kAudioObjectSystemObject, &g_default_device, sizeof g_device, &g_device);
  watch(true);
  trigger();
  return noErr;
}

int main(int argc, char** argv) {
  if (argc < 2) {
    printf("Usage: %s \"<event-name>\"\n", argv[0]);
    exit(1);
  }

  alarm(0);
  g_event = argv[1];

  char event_message[512];
  snprintf(event_message, 512, "--add event '%s'", g_event);
  sketchybar(event_message);

  // Listeners otherwise fire on CoreAudio's own threads, which would race on the shared device and mach port.
  CFRunLoopRef run_loop = CFRunLoopGetCurrent();
  AudioObjectPropertyAddress run_loop_address = {
    kAudioHardwarePropertyRunLoop,
    kAudioObjectPropertyScopeGlobal,
    kAudioObjectPropertyElementMain
  };
  AudioObjectSetPropertyData(kAudioObjectSystemObject, &run_loop_address, 0, NULL, sizeof(CFRunLoopRef), &run_loop);

  get(kAudioObjectSystemObject, &g_default_device, sizeof g_device, &g_device);
  watch(true);
  AudioObjectAddPropertyListener(kAudioObjectSystemObject, &g_default_device, device_changed, NULL);

  trigger();
  CFRunLoopRun();
  return 0;
}
