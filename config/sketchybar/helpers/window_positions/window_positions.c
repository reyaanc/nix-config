#include <CoreGraphics/CoreGraphics.h>
#include <stdio.h>

int main(void) {
    CFArrayRef windows = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    for (CFIndex i = 0; i < CFArrayGetCount(windows); i++) {
        CFDictionaryRef window = CFArrayGetValueAtIndex(windows, i);
        int id, layer;
        CGRect bounds;
        CFNumberGetValue(CFDictionaryGetValue(window, kCGWindowLayer), kCFNumberIntType, &layer);
        if (layer != 0) continue;
        CFNumberGetValue(CFDictionaryGetValue(window, kCGWindowNumber), kCFNumberIntType, &id);
        CGRectMakeWithDictionaryRepresentation(CFDictionaryGetValue(window, kCGWindowBounds), &bounds);
        CGDirectDisplayID display = CGMainDisplayID();
        uint32_t count;
        CGGetDisplaysWithRect(bounds, 1, &display, &count);
        CGRect screen = CGDisplayBounds(display);
        int percent = 100 * bounds.size.width * bounds.size.height / (screen.size.width * screen.size.height);
        printf("%d|%d|%d|%d\n", id, (int)bounds.origin.x, (int)bounds.origin.y, percent);
    }
    CFRelease(windows);
}
