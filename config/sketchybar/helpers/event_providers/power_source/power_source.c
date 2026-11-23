#include <IOKit/ps/IOPSKeys.h>
#include <IOKit/ps/IOPowerSources.h>
#include "../sketchybar.h"

static char* g_event;

static int number(CFDictionaryRef description, CFStringRef key) {
  int value = -1;
  CFNumberRef ref = CFDictionaryGetValue(description, key);
  if (ref) CFNumberGetValue(ref, kCFNumberIntType, &value);
  return value;
}

static bool flag(CFDictionaryRef description, CFStringRef key) {
  CFBooleanRef ref = CFDictionaryGetValue(description, key);
  return ref && CFBooleanGetValue(ref);
}

static void trigger(void* context) {
  CFTypeRef info = IOPSCopyPowerSourcesInfo();
  CFArrayRef sources = IOPSCopyPowerSourcesList(info);

  for (CFIndex i = 0; i < CFArrayGetCount(sources); i++) {
    CFDictionaryRef description = IOPSGetPowerSourceDescription(info, CFArrayGetValueAtIndex(sources, i));
    CFStringRef type = CFDictionaryGetValue(description, CFSTR(kIOPSTypeKey));
    if (!type || !CFEqual(type, CFSTR(kIOPSInternalBatteryType))) continue;

    CFStringRef state = CFDictionaryGetValue(description, CFSTR(kIOPSPowerSourceStateKey));
    bool ac = state && CFEqual(state, CFSTR(kIOPSACPowerValue));
    bool charging = flag(description, CFSTR(kIOPSIsChargingKey));
    int capacity = number(description, CFSTR(kIOPSCurrentCapacityKey));
    int max = number(description, CFSTR(kIOPSMaxCapacityKey));
    int remaining = number(description, charging ? CFSTR(kIOPSTimeToFullChargeKey) : CFSTR(kIOPSTimeToEmptyKey));

    char message[512];
    snprintf(message, 512, "--trigger '%s' percentage='%d' ac='%s' charging='%s' remaining='%d'",
             g_event,
             max > 0 ? capacity * 100 / max : capacity,
             ac ? "true" : "false",
             charging ? "true" : "false",
             remaining);
    sketchybar(message);
    break;
  }

  CFRelease(sources);
  CFRelease(info);
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

  CFRunLoopSourceRef source = IOPSNotificationCreateRunLoopSource(trigger, NULL);
  CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);

  trigger(NULL);
  CFRunLoopRun();
  return 0;
}
