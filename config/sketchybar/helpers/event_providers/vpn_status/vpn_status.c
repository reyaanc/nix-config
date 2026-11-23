#include <SystemConfiguration/SystemConfiguration.h>
#include "../sketchybar.h"

static char* g_event;

static void trigger(SCNetworkConnectionRef connection, SCNetworkConnectionStatus status, void* info) {
  char message[512];
  snprintf(message, 512, "--trigger '%s' connected='%s'",
           g_event,
           status == kSCNetworkConnectionConnected ? "true" : "false");
  sketchybar(message);
}

int main(int argc, char** argv) {
  if (argc < 3) {
    printf("Usage: %s \"<event-name>\" \"<service-id>\"\n", argv[0]);
    exit(1);
  }

  alarm(0);
  g_event = argv[1];

  char event_message[512];
  snprintf(event_message, 512, "--add event '%s'", g_event);
  sketchybar(event_message);

  CFStringRef service = CFStringCreateWithCString(NULL, argv[2], kCFStringEncodingUTF8);
  SCNetworkConnectionRef connection = SCNetworkConnectionCreateWithServiceID(NULL, service, trigger, NULL);
  SCNetworkConnectionScheduleWithRunLoop(connection, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);

  trigger(connection, SCNetworkConnectionGetStatus(connection), NULL);
  CFRunLoopRun();
  return 0;
}
