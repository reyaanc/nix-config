{ config, lib, ... }:
let
  t = config.theme;
  c = t.colors;
in
{
  programs.zed-editor = {
    enable = true;
    mutableUserSettings = true;
    extensions = [ "nix" "toml" "dockerfile" "docker-compose" "helm" "proto" "fish" "lua" "make" "sql" "git-firefly" "typst" "kanagawa-themes" ];
    userSettings = lib.mapAttrsRecursive (_: v: if lib.isList v then v else lib.mkDefault v) {
      theme = t.name;
      theme_overrides = {
        ${t.name} = {
          "background.appearance" = "blurred";
          background = "#${c.bg}d9";
          "surface.background" = "#00000000";
          "elevated_surface.background" = "#${c.bgElevated}f2";
          "panel.background" = "#00000000";
          "editor.background" = "#00000000";
          "editor.gutter.background" = "#00000000";
          "editor.active_line.background" = "#${c.fg}0a";
          "tab_bar.background" = "#00000000";
          "tab.active_background" = "#${c.fg}0f";
          "tab.inactive_background" = "#00000000";
          "toolbar.background" = "#00000000";
          "title_bar.background" = "#${c.bg}d9";
          "title_bar.inactive_background" = "#${c.bg}d9";
          "status_bar.background" = "#${c.bg}d9";
          "terminal.background" = "#00000000";
          border = "#${c.fg}14";
          "border.variant" = "#${c.fg}0d";
        };
      };
      icon_theme = {
        mode = "dark";
        light = "Zed (Default)";
        dark = "Zed (Default)";
      };
      buffer_font_family = t.font.family;
      buffer_font_size = 15;
      ui_font_size = 16;
      vim_mode = true;
      vim = {
        use_system_clipboard = "always";
      };
      vertical_scroll_margin = 10;
      use_system_path_prompts = false;
      session = {
        trust_all_worktrees = true;
      };
      agent_servers = {
        claude-acp = {
          type = "registry";
        };
      };
      telemetry = {
        diagnostics = false;
        metrics = false;
      };
      load_direnv = "direct";
      inlay_hints = {
        enabled = true;
      };
      diagnostics = {
        inline = {
          enabled = true;
        };
      };
      file_scan_exclusions = [
        "**/.git"
        "**/.svn"
        "**/.hg"
        "**/.jj"
        "**/CVS"
        "**/.DS_Store"
        "**/Thumbs.db"
        "**/.classpath"
        "**/.settings"
        "**/__pycache__"
        "**/*.pyc"
        "**/.pytest_cache"
        "**/.mypy_cache"
        "**/.ruff_cache"
        "**/.direnv"
        "**/.claude"
        "**/.venv"
        "**/*.egg-info"
        "**/.ipynb_checkpoints"
        "**/.tox"
        "**/.coverage"
        "**/htmlcov"
        "**/node_modules"
        "**/.next"
        "**/.turbo"
        "**/target"
        "**/.terraform"
        "**/.idea"
      ];
      format_on_save = "off";
      languages = {
        Rust = {
          format_on_save = "on";
        };
        Python = {
          language_servers = [ "basedpyright" "ruff" "!pyright" "!pylsp" "..." ];
          formatter = [
            {
              code_action = "source.organizeImports.ruff";
            }
            {
              code_action = "source.fixAll.ruff";
            }
            {
              language_server = {
                name = "ruff";
              };
            }
          ];
        };
      };
      lsp = {
        rust-analyzer = {
          initialization_options = {
            check = {
              command = "clippy";
            };
          };
        };
        basedpyright = {
          settings = {
            "basedpyright.analysis" = {
              typeCheckingMode = "standard";
            };
          };
        };
      };
    };
  };
}
