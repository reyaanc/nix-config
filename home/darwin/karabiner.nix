{ lib, ... }:
let
  terminals = [
    "^com\\.mitchellh\\.ghostty$"
    "^so\\.pen\\.herdr-gpui$"
  ];

  remap = from: to: {
    type = "basic";
    inherit from;
    to = [ to ];
  };

  textNavigation = map ({ key, as }: remap
    { key_code = key; modifiers = { mandatory = [ "command" ]; optional = [ "shift" ]; }; }
    { key_code = key; modifiers = [ as ]; }
  ) [
    { key = "left_arrow"; as = "left_option"; }
    { key = "right_arrow"; as = "left_option"; }
    { key = "delete_or_backspace"; as = "left_option"; }
    { key = "delete_forward"; as = "left_option"; }
    { key = "tab"; as = "left_control"; }
  ];
in
{
  xdg.configFile."karabiner/karabiner.json" = {
    force = true;
    text = builtins.toJSON {
      profiles = [
        {
          name = "Default";
          selected = true;
          virtual_hid_keyboard.keyboard_type_v2 = "ansi";
          complex_modifications.rules = [
            {
              description = "Command is Super";
              manipulators = map (side: remap
                { key_code = "${side}_command"; modifiers.optional = [ "any" ]; }
                { key_code = "left_control"; modifiers = [ "left_option" "left_command" ]; }
              ) [ "left" "right" ];
            }
            {
              description = "Terminals: Ctrl+Shift+key acts as Cmd+key";
              manipulators = map (letter: remap
                { key_code = letter; modifiers.mandatory = [ "control" "shift" ]; }
                { key_code = letter; modifiers = [ "left_command" ]; }
                // {
                  conditions = [ { type = "frontmost_application_if"; bundle_identifiers = terminals; } ];
                }
              ) (lib.stringToCharacters "abcdefghijklmnopqrstuvwxyz");
            }
            {
              description = "Ctrl+arrows, Ctrl+Backspace and Ctrl+Tab behave like Linux";
              manipulators = textNavigation;
            }
            {
              description = "Ctrl is Cmd outside terminals";
              manipulators = map (side: remap
                { key_code = "${side}_control"; modifiers.optional = [ "any" ]; }
                { key_code = "left_command"; }
                // {
                  conditions = [ { type = "frontmost_application_unless"; bundle_identifiers = terminals; } ];
                }
              ) [ "left" "right" ];
            }
          ];
        }
      ];
    };
  };
}
