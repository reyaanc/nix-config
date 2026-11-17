#!/bin/sh
walls="$WALLPAPERS"
current=$(osascript -l JavaScript -e 'ObjC.import("AppKit"); $.NSWorkspace.sharedWorkspace.desktopImageURLForScreen($.NSScreen.mainScreen).path.js')
wallpaper=$(find "$walls/qiaoyan-bang" -name background.jpg | grep -vxF "$current" | sort -R | head -n 1)
case $1 in
    keep) wallpaper=$current ;;
    ?*) wallpaper="$walls/qiaoyan-bang/$1/background.jpg" ;;
esac
dir=$(dirname "$wallpaper")

osascript -l JavaScript -e '
ObjC.import("AppKit");
function run([path]) {
    const url = $.NSURL.fileURLWithPath(path);
    const screens = $.NSScreen.screens;
    for (let i = 0; i < screens.count; i++) {
        $.NSWorkspace.sharedWorkspace.setDesktopImageURLForScreenOptionsError(url, screens.objectAtIndex(i), $({}), null);
    }
}' "$wallpaper"

# Inlined because Plash's WebKit cache keeps serving an old mask.png across restarts
mask=null
[ -f "$dir/mask.png" ] && mask="\"data:image/png;base64,$(base64 -i "$dir/mask.png" | tr -d '\n')\""
widgets=$(cat "$dir/widgets.json" 2>/dev/null || echo '{}')
theme=$(cat "$dir/theme.json" 2>/dev/null || echo '{}')
# Written aside and moved into place, so a page polling mid-write never loads half a file
printf 'show({ dir: "%s", mask: %s, widgets: %s, theme: %s });\n' "${dir#"$walls"/}" "$mask" "$widgets" "$theme" > "$walls/current.js.next"
mv "$walls/current.js.next" "$walls/current.js"
printf 'changed("%s");\n' "$(date +%s)" > "$walls/version.js.next"
mv "$walls/version.js.next" "$walls/version.js"
