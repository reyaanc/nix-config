#include <AudioToolbox/AudioServices.h>
#include <CoreAudio/CoreAudio.h>
#include <stdio.h>

static void get(AudioObjectID object, AudioObjectPropertySelector selector, AudioObjectPropertyScope scope, UInt32 size, void *out) {
    AudioObjectPropertyAddress address = {selector, scope, kAudioObjectPropertyElementMain};
    AudioObjectGetPropertyData(object, &address, 0, NULL, &size, out);
}

int main(void) {
    AudioDeviceID device = 0;
    Float32 volume = 0;
    UInt32 muted = 0, transport = 0;
    get(kAudioObjectSystemObject, kAudioHardwarePropertyDefaultOutputDevice, kAudioObjectPropertyScopeGlobal, sizeof device, &device);
    get(device, kAudioHardwareServiceDeviceProperty_VirtualMainVolume, kAudioDevicePropertyScopeOutput, sizeof volume, &volume);
    get(device, kAudioDevicePropertyMute, kAudioDevicePropertyScopeOutput, sizeof muted, &muted);
    get(device, kAudioDevicePropertyTransportType, kAudioObjectPropertyScopeGlobal, sizeof transport, &transport);
    int bluetooth = transport == kAudioDeviceTransportTypeBluetooth || transport == kAudioDeviceTransportTypeBluetoothLE;
    printf("%d %s %s\n", (int)(volume * 100 + 0.5), muted ? "true" : "false", bluetooth ? "bluetooth" : "wired");
}
