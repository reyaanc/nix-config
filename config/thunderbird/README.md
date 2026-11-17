# Thunderbird theme

A Gmail-style dark theme for Thunderbird 158 on macOS. It is tuned for a window at half or quarter screen width.

## Files

| File | Applies to |
|---|---|
| `user.js` | Prefs. Thunderbird reapplies them on every launch, so changing one of these settings in the app only lasts until the next restart. |
| `chrome/userChrome.css` | Thunderbird's own windows: toolbar, tabs, folder pane, message list, stock message view, menus, status bar. |
| `chrome/userContent.css` | Web-style pages inside Thunderbird. Here it's limited to the Thunderbird Conversations add-on's reading pane. |

`~/.config/thunderbird` is a symlink into this repo. The profile `~/Library/Thunderbird/Profiles/5tv85n2t.default-release` symlinks `user.js` and `chrome/` back to it.

Changes only load at startup. Quit with Cmd+Q and reopen; closing the window isn't enough.

Every selector and variable was checked against Thunderbird 158.0.1's built-in CSS (`omni.ja`) and the Conversations 4.3.16 add-on.

## user.js

| Pref | Value | Effect |
|---|---|---|
| `toolkit.legacyUserProfileCustomizations.stylesheets` | `true` | Makes Thunderbird load `userChrome.css` and `userContent.css`. Nothing else works without it. |
| `mail.threadpane.listview` | `0` | Card view in the message list. `1` is the multi-column table, which is unusable at narrow widths. |
| `mail.threadpane.cardsview.rowcount` | `3` | Three lines per card: sender and date, subject, then star and icons. `2` is the compact option; it was tried and dropped as too cramped. |
| `mail.addressDisplayFormat` | `2` | The list shows "Scotia InfoAlerts" instead of "Scotia InfoAlerts <infoalerts@…>". `0` is the full form and `1` is email only. The reading-pane header still shows the full address, so spoofed senders are still visible. |
| `mail.tabs.tabMinWidth` | `50` | Tabs can shrink to 50px (the default is 100) before the tab strip starts scrolling. 50 is the lowest value Thunderbird accepts. |
| `mail.uifontsize` | `14` | Interface text size in px. `0` means the macOS default, 13px. Card heights follow it automatically. Allowed range: 9–30. |
| `widget.macos.titlebar-blend-mode.behind-window` | `true` | Lets the title bar blend with the desktop behind the window. Same setting as the Firefox config. |
| `calendar.alarms.show` | `false` | No pop-up window for event reminders. Slack already sends them. |
| `calendar.alarms.playsound` | `false` | No reminder sound either. |

## userChrome.css

### Palette

All colours come from Gmail's dark theme. Most are applied by overriding Thunderbird's own `--layout-*` variables, so everything that uses them changes at once.

| Role | Colour |
|---|---|
| Window frame: toolbar, sidebars, tab strip | `#131314` |
| Content area: message list, reading pane | `#1e1f20` |
| Raised surfaces: search bar, buttons, menus | `#282a2c` |
| Hover | `#37393b` |
| Borders | `#444746` |
| Primary / secondary / muted text | `#e3e3e3` / `#c4c7c5` / `#8e918f` |
| Selection (folders, messages, active space) | `#004a77` background, `#c2e7ff` text |
| Accent: unread dot, active tab | `#a8c7fa` |

### Global

- **Borders and corners.** `--button-border-color: transparent` and `--button-border-radius: 18px` make most buttons borderless and rounded.
- **Search bar.** It's a 24px-radius pill with no border on `#282a2c`.
- **Sharper text.** `-moz-osx-font-smoothing: grayscale` turns off macOS's thickening of light-on-dark text, which made small text blur. If text looks too thin, delete this one line.

### Transparency

- **Blur.** The window frame shows a blurred desktop behind it, the same macOS vibrancy as `~/.config/firefox` (`appearance: -moz-sidebar` on `#messengerWindow`).
- **Tint.** The toolbar, spaces rail and status bar are `rgba(19, 19, 20, 0.6)` over the blur. The tab strip is transparent, so the toolbar tint shows through it.
- **Content stays solid.** The folder pane, message list and reading pane are opaque so text stays readable.
- **Adjusting.** Change the `0.6` alpha to make it more or less see-through. To turn it off, delete the `#messengerWindow` rule.

### Tabs

- **Strip.** The tab strip is transparent, with a thin line along the bottom.
- **Selected tab.** No raised box. Its label turns `#a8c7fa`, and Thunderbird's own tab indicator moves to the bottom as a 3px underline.
- **Unselected tabs.** Labels are solid `#c4c7c5`; Thunderbird draws them at 70% opacity, which looked washed out.
- **Narrow tabs.** A tab squeezed to 80px or less hides its label and shows only its icon. Hovering still shows the name.
  - The selected tab never goes below 120px, so its name stays readable.
  - Tradeoff: two folder tabs squeezed to icons look the same until you hover. To turn this off, delete the `@container (max-width: 80px)` block.

### Spaces rail (left icon bar)

- **Background.** The translucent frame tint; Thunderbird's faint gradient is gone.
- **Active space.** Shows as a blue circle. This comes from the global button radius and the selection colour; no separate rule.

### Folder pane

- **Rows.** Folder rows are rounded on the right, like Gmail's sidebar.
- **Selected folder.** Bold and blue.
- **Unread counts.** Plain text instead of a badge, at full size (Thunderbird shrinks them to 85%).
- **Unified Folders shows only Inbox.** Drafts, Templates, Sent and the other unified folders are hidden; expanding Inbox still lists each account's inbox. Those folders are still reachable under All Folders. To bring them back, delete the `li[data-mode="smart"]` rule.
- **Folder icons on demand.** Icons are hidden and appear on hover and on the selected folder. They keep their space, so text doesn't shift.
- **Section headers.** "Unified Folders", "All Folders" and the other mode names are 1rem, medium weight, grey. Thunderbird uses 1.1rem semibold.

### Message list header

- **Quick Filter.** When the message list is narrower than 999px, the Quick Filter button shows only its icon. It works the same, with the same tooltip. That frees room for the folder name ("Important") to show in full.
- This copies how Thunderbird already collapses its own buttons at that width.

### Message list (cards)

- **Layout.** The cards lose their rounded borders and gaps and become full-width rows with a 1px `#2d2f31` divider, like Gmail's mobile list.
- **Text.** Sender and date are full size (Thunderbird uses 95%). The date is fully opaque (Thunderbird uses 85%). These were the main source of the "trippy" small text.
- **Read vs unread.**
  - Read: grey `#c4c7c5`, normal weight.
  - Unread: white, bold sender and subject, and a `#a8c7fa` dot instead of Thunderbird's green one.
  - New messages: the "new" sparkle and the new-subject colour use the same accent.
- **Hover.** Unselected rows lighten to `#282a2c`.
- **Selection.** Solid `#004a77` with `#c2e7ff` text. It stays that colour on hover and after you click into the reading pane; Thunderbird normally fades it to grey in both cases.

### Stock message view

This is the built-in reader. You see it when a message opens in its own tab or window, or if Conversations is disabled.

- **One surface.** The header, notification bar and attachment bar share the `#1e1f20` background, and the line between header and notifications is gone. Header and email read as one surface.
- **Spacing.** The header has 16px side margins and 8px between rows. The email body has an 8px side margin so it lines up with the header.
- **Subject.** About 21px, regular weight. It only applies when Thunderbird's own "Large subject" header option is on, which is the default.
- **Labels.** "To" and the sender address are solid instead of 70–90% opacity.
- **Buttons.**
  - Reply, Forward and the other header buttons are borderless, 32px tall and rounded.
  - Split buttons such as Reply All and Save All lose the borders on their inner halves too.
  - The More button stays highlighted while its menu is open.
  - In icons-only mode (⋮ More → Customize… → Button style "Icons") they become 36px circles. That mode also stops the buttons wrapping to two rows at narrow widths.
- **Star.** Gets a round hover highlight.
- **Remote-content bar.** Grey `#282a2c` instead of yellow, lined up with the 16px margin. Its "Preferences" button is a pill.

### Menus and popups

- **Colours.** Right-click menus and popups use `#282a2c` with a `#444746` border instead of Thunderbird's navy.
- **Hover.** Item highlight stays the native macOS accent so keyboard navigation keeps a high-contrast highlight.

### Status bar

- **Ghost text.** Removed the light-theme text shadow that drew a faint copy of "Today Pane" and the status text 1px below.
- **Colour.** Text is a slightly quieter `#c4c7c5`.

## userContent.css (Conversations reading pane)

When you select a message, the reading pane is drawn by the Thunderbird Conversations add-on (`gconversation@xulforum.org`), not by Thunderbird. It runs as a web-style page, which `userChrome.css` can't reach.

Every rule is wrapped in `@-moz-document url-prefix("chrome://conversations/content/experiment-api/stub.html")`. Without that wrapper, generic class names like `.message` and `.subject` would also match inside emails and web pages.

- **Font.** Conversations used Helvetica while the rest of Thunderbird uses SF. It now uses `system-ui`, so the typeface matches.
- **Colours.**
  - Background `#1e1f20`, text `#e3e3e3`.
  - Secondary text (snippets, sender email, the reply / (i) / ⋮ icons) is `#c4c7c5` instead of `#999` / `#b6b6b6`.
- **Subject strip.** No shadow, same background as the messages. The subject is about 22px at regular weight instead of 16px bold.
- **Action icons.** The seven icons in the subject strip are 36px circles with a hover fill.
- **Messages.**
  - The bordered, rounded, inset card is gone. Messages sit flush, separated by a thin line, with 16px side padding.
  - Keyboard focus shows a 3px blue bar on the left. Mouse clicks show nothing.
- **Sender email.** Full size instead of 85%.

Two things not to mistake for this theme:
- **The black block in some emails is the email itself.** Conversations' dark mode inverts white emails to black. The droplet icon in the subject strip turns that off per message.
- **Some parts may not change.** The subject, the action buttons and the sender email are inside the add-on's own components. If those three don't change after a restart, the rules can't reach them there. The rest of the file still applies.

## Out of scope

These can't be done with CSS or prefs:
- **Sender avatars and preview snippets in cards.** Cards don't contain an avatar element or any preview text.
- **Tag pill colours.** They're inside a part of the card that CSS can't reach.
- **Shorter dates for older messages.** `mail.ui.display.dateformat.thisweek` might show "Sun 11:53 p.m." for the past week. The value `4` is unconfirmed, so it isn't set.
- **Email background matching the header.** `browser.display.background_color.dark` would make plain-text mail sit on `#1e1f20`. It also changes the background of unstyled web pages and the compose window, so it isn't set.

## Check it works

Quit with Cmd+Q, reopen, and run Thunderbird at half-screen width.

1. **Message list.**
   - Cards have three lines and no borders between them.
   - The sender shows the name only.
   - Unread rows are white and bold with a blue dot; read rows are grey.
   - The date is as crisp as the subject.
2. **Selection.** Click a message. Its row turns solid blue and stays blue when you hover it or click into the reading pane.
3. **Reading pane (Conversations).** There's no framed card, the subject is large and regular weight, and the strip icons are round with a hover fill.
4. **Stock view.** Double-click a message so it opens in a tab.
   - Header and body are one surface.
   - "To" and the sender address are solid.
   - Reply All has no inner borders.
   - The More button stays highlighted while its menu is open.
5. **Tabs.** Open five or more tabs.
   - The strip doesn't scroll.
   - Inactive tabs become icon-only.
   - The active tab has a blue label and underline.
6. **Status bar.** "Today Pane" has no ghost copy underneath.
7. **Menus.** A right-click menu is grey with a lighter grey border, not navy.
8. **Text size.** Interface text is one step larger than before.
9. **Transparency.** Drag the window over a bright part of the wallpaper. The toolbar, tabs, left rail and status bar show it blurred; the panes don't.