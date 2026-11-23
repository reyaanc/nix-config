#include <AudioToolbox/AudioServices.h>
#include <CoreAudio/CoreAudio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char** argv) {
  bool mute = argc == 2 && strcmp(argv[1], "mute") == 0;
  bool step = argc == 3 && strcmp(argv[1], "step") == 0;
  if (!mute && !step) {
    printf("Usage: %s mute | step <percent>\n", argv[0]);
    exit(1);
  }

  AudioDeviceID device = 0;
  UInt32 size = sizeof device;
  AudioObjectPropertyAddress default_device = {
    kAudioHardwarePropertyDefaultOutputDevice,
    kAudioObjectPropertyScopeGlobal,
    kAudioObjectPropertyElementMain
  };
  AudioObjectGetPropertyData(kAudioObjectSystemObject, &default_device, 0, NULL, &size, &device);

  if (mute) {
    AudioObjectPropertyAddress address = {
      kAudioDevicePropertyMute,
      kAudioDevicePropertyScopeOutput,
      kAudioObjectPropertyElementMain
    };
    UInt32 muted = 0;
    size = sizeof muted;
    AudioObjectGetPropertyData(device, &address, 0, NULL, &size, &muted);
    muted = !muted;
    AudioObjectSetPropertyData(device, &address, 0, NULL, sizeof muted, &muted);
    return 0;
  }

  AudioObjectPropertyAddress address = {
    kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
    kAudioDevicePropertyScopeOutput,
    kAudioObjectPropertyElementMain
  };
  Float32 volume = 0;
  size = sizeof volume;
  AudioObjectGetPropertyData(device, &address, 0, NULL, &size, &volume);
  volume += atof(argv[2]) / 100;
  volume = volume < 0 ? 0 : volume > 1 ? 1 : volume;
  AudioObjectSetPropertyData(device, &address, 0, NULL, sizeof volume, &volume);
  return 0;
}
