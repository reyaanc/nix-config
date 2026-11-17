{ config, lib, dotfile, ... }:
let
  t = config.theme;
  c = t.colors;
  mix = a: b: p:
    lib.concatMapStrings (i:
      let
        x = lib.fromHexString (builtins.substring i 2 a);
        y = lib.fromHexString (builtins.substring i 2 b);
      in
      lib.fixedWidthString 2 "0" (lib.toLower (lib.toHexString ((x * (100 - p) + y * p) / 100)))
    ) [ 0 2 4 ];
in
{
  programs.claude-code = {
    enable = true;
    mutableSettings = true;
    context = ../../config/claude/CLAUDE.md;
    rulesDir = ../../config/claude/rules;
    settings = lib.mapAttrsRecursive (_: v: if lib.isList v then v else lib.mkDefault v) {
      "$schema" = "https://json.schemastore.org/claude-code-settings.json";
      attribution = {
        commit = "";
        pr = "";
      };
      permissions = {
        allow = [
          "Read(./**)"
          "Edit(./**)"
          "Bash(git status:*)"
          "Bash(git diff:*)"
          "Bash(git log:*)"
          "Bash(git checkout:*)"
          "Bash(git branch:*)"
          "Bash(git stash:*)"
          "Bash(git fetch:*)"
          "Bash(ls:*)"
          "Bash(cat:*)"
          "Bash(rg:*)"
          "Bash(find:*)"
          "Bash(mkdir:*)"
          "Bash(mv:*)"
          "Bash(uv:*)"
          "Bash(uvx:*)"
          "Bash(pytest:*)"
          "Bash(ruff:*)"
          "Bash(python:*)"
          "Bash(make:*)"
        ];
        deny = [
          "Bash(git push)"
          "Bash(git push:*)"
          "Bash(git -C * push *)"
          "Bash(git --git-dir* push *)"
          "Bash(git add:*)"
          "Bash(git -C * add *)"
          "Bash(git commit:*)"
          "Bash(git -C * commit *)"
          "Bash(gh pr create:*)"
          "Bash(gh pr merge:*)"
          "Bash(gh release create:*)"
          "Read(./.env)"
          "Read(./.env.*)"
          "Read(./**/.env)"
          "Read(./**/.env.*)"
          "Read(./**/*.pem)"
          "Read(./**/id_rsa*)"
          "Read(~/.aws/**)"
          "Read(~/.ssh/**)"
          "Read(~/nix-keys/**)"
          "Bash(rm -rf /:*)"
          "Bash(sudo:*)"
          "Bash(curl* | sh)"
          "Bash(curl* | bash)"
          "Bash(wget* | sh)"
          "mcp__claude_ai_Slack__slack_send_message"
          "mcp__claude_ai_Slack__slack_send_message_draft"
          "mcp__claude_ai_Slack__slack_schedule_message"
          "mcp__claude_ai_Slack__slack_add_reaction"
          "mcp__claude_ai_Slack__slack_create_canvas"
          "mcp__claude_ai_Slack__slack_update_canvas"
          "mcp__claude_ai_Slack__slack_create_list"
          "mcp__claude_ai_Slack__slack_update_list"
          "mcp__claude_ai_Slack__slack_add_list_record"
          "mcp__claude_ai_Slack__slack_update_list_record"
          "mcp__claude_ai_Slack__slack_create_conversation"
          "mcp__claude_ai_Slack__slack_get_file_upload_url"
          "mcp__claude_ai_Slack__slack_complete_file_upload"
        ];
        ask = [
          "Bash(git reset --hard:*)"
          "Bash(git clean -fd:*)"
          "Bash(docker push:*)"
          "Bash(terraform apply:*)"
          "Bash(kubectl apply:*)"
          "Bash(kubectl delete:*)"
        ];
        defaultMode = "auto";
        disableBypassPermissionsMode = "disable";
      };
      model = "opus";
      hooks = {
        SessionStart = [
          {
            matcher = "^(startup|resume|clear|compact|fork)$";
            hooks = [
              {
                type = "command";
                command = "bash '${config.home.homeDirectory}/.claude/hooks/herdr-agent-state.sh' session";
                timeout = 10;
              }
            ];
          }
        ];
      };
      statusLine = {
        type = "command";
        command = "bash ~/.claude/statusline.sh";
      };
      enabledPlugins = {
        "swift-lsp@claude-plugins-official" = true;
        "clangd-lsp@claude-plugins-official" = true;
      };
      sandbox = {
        enabled = true;
        autoAllowBashIfSandboxed = true;
        allowUnsandboxedCommands = true;
        network = {
          allowedDomains = [ "github.com" "*.githubusercontent.com" "pypi.org" "files.pythonhosted.org" ];
        };
        filesystem = {
          allowWrite = [ "~/Work/docs" ];
        };
        credentials = {
          files = [
            {
              path = "~/.aws/credentials";
              mode = "deny";
            }
            {
              path = "~/.ssh/id_rsa";
              mode = "deny";
            }
            {
              path = "~/nix-keys/reyaan.private.pem";
              mode = "deny";
            }
          ];
        };
      };
      effortLevel = "xhigh";
      modelSettings = {
        claude-opus-5-5 = {
          effortLevel = "high";
        };
      };
      theme = "custom:theme";
      autoMode = {
        allow = [ "$defaults" ];
        soft_deny = [
          "$defaults"
          "git push to any branch on any remote"
          "any write to a host, bucket, namespace, or container whose name contains 'prod' or 'production'"
        ];
        environment = [
          "### Org-wide"
          "**Organization**: VitalBio (github.com/VitalBio)"
          "**Cloud provider(s)**: AWS, on-premise"
          "**Repository visibility**: private"
          "**Internal sharing / snippet hosting**: None configured — treat public paste/gist services as outside the trust boundary"
          "**Secrets management**: None configured"
          "**Default / protected branches**: main (default); protected: main, develop, staging, releases"
          "**Source control**: VitalBio repositories and their remotes only"
          "**Sensitive data locations & audiences**: .env, .env.local and any similar credential/config files; any file holding personal data, confidential business data, credentials, or regulated material"
          "**Sensitive remote targets**: any namespace, host, or container whose name carries `prod` or `production` as a whole word or name segment; also treat protected branches and their deploy targets as sensitive"
          "**Protected IaC scopes**: IAM, RBAC, networking, quota, and node-pool resources; anything tagged `prod` or `production`"
          "### User-specific"
          "**Primary use of Claude Code**: software development (Python services)"
          "**Org-specific CLIs**: uv, uvx"
          "routine within the working directory: uv/uvx toolchain commands, pytest, ruff"
        ];
      };
    };
  };

  home.file = {
    ".claude/statusline.sh".source = dotfile "claude/statusline.sh";
    ".claude/themes/theme.json".text = builtins.toJSON {
      inherit (t) name;
      base = "dark";
      overrides = lib.mapAttrs (_: hex: "#${hex}") {
        claude = c.orange;
        claudeShimmer = mix c.orange c.fg 40;
        promptBorder = c.bgLight;
        promptBorderShimmer = c.comment;
        warning = c.yellow;
        warningShimmer = mix c.yellow c.fg 40;
        success = c.green;
        error = c.red;
        diffAdded = mix c.bg c.green 15;
        diffRemoved = mix c.bg c.red 15;
        diffAddedWord = mix c.bg c.green 30;
        diffRemovedWord = mix c.bg c.red 30;
        diffAddedDimmed = mix c.bg c.green 8;
        diffRemovedDimmed = mix c.bg c.red 8;
      };
    };
  };
}
