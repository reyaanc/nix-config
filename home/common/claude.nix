{ config, lib, pkgs, dotfile, ... }:
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
          "Bash(git show:*)"
          "Bash(git blame:*)"
          "Bash(ls:*)"
          "Bash(cat:*)"
          "Bash(head:*)"
          "Bash(tail:*)"
          "Bash(wc:*)"
          "Bash(diff:*)"
          "Bash(rg:*)"
          "Bash(fd:*)"
          "Bash(jq:*)"
          "Bash(find:*)"
          "Bash(mkdir:*)"
          "Bash(mv:*)"
          "Bash(uv:*)"
          "Bash(uvx:*)"
          "Bash(pytest:*)"
          "Bash(ruff:*)"
          "Bash(python:*)"
          "Bash(make:*)"
          "Bash(cargo check:*)"
          "Bash(cargo clippy:*)"
          "Bash(cargo test:*)"
          "Bash(cargo build:*)"
          "Bash(cargo fmt:*)"
          "Bash(cargo tree:*)"
          "Bash(cargo metadata:*)"
          "Bash(npm test:*)"
          "Bash(npm ls:*)"
          "Bash(nix build:*)"
          "Bash(nix eval:*)"
          "Bash(nix flake check:*)"
          "Bash(nix flake show:*)"
          "Bash(nix flake metadata:*)"
          "Bash(nix search:*)"
          "Bash(nix log:*)"
          "Bash(statix:*)"
          "Bash(gh pr view:*)"
          "Bash(gh pr list:*)"
          "Bash(gh pr diff:*)"
          "Bash(gh pr checks:*)"
          "Bash(gh run view:*)"
          "Bash(gh run list:*)"
          "Bash(gh issue view:*)"
          "Bash(gh issue list:*)"
          "Bash(gh repo view:*)"
          "Bash(docker ps:*)"
          "Bash(docker logs:*)"
          "Bash(docker images:*)"
          "Bash(docker inspect:*)"
          "Bash(kubectl get:*)"
          "Bash(kubectl describe:*)"
          "Bash(kubectl logs:*)"
          "Bash(kubectl diff:*)"
          "Bash(helm list:*)"
          "Bash(helm template:*)"
          "Bash(terraform fmt:*)"
          "Bash(terraform validate:*)"
          "Bash(terraform plan:*)"
          "Bash(terraform show:*)"
          "Bash(aws sts get-caller-identity:*)"
          "Bash(aws * describe-*)"
          "Bash(aws * list-*)"
          "Bash(aws s3 ls:*)"
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
          "Bash(gh pr close:*)"
          "Bash(gh pr comment:*)"
          "Bash(gh pr review:*)"
          "Bash(gh pr edit:*)"
          "Bash(gh issue create:*)"
          "Bash(gh issue comment:*)"
          "Bash(gh issue close:*)"
          "Bash(gh issue edit:*)"
          "Bash(gh release create:*)"
          "Bash(gh repo create:*)"
          "Bash(gh repo delete:*)"
          "Bash(gh workflow run:*)"
          "Bash(gh run rerun:*)"
          "Bash(gh secret set:*)"
          "Bash(gh variable set:*)"
          "Bash(terraform apply:*)"
          "Bash(terraform destroy:*)"
          "Bash(terraform import:*)"
          "Bash(terraform taint:*)"
          "Bash(terraform force-unlock:*)"
          "Bash(terraform state rm:*)"
          "Bash(terraform state mv:*)"
          "Bash(terraform state push:*)"
          "Bash(terraform -chdir=* apply*)"
          "Bash(terraform -chdir=* destroy*)"
          "Bash(tofu apply:*)"
          "Bash(tofu destroy:*)"
          "Bash(kubectl apply:*)"
          "Bash(kubectl create:*)"
          "Bash(kubectl delete:*)"
          "Bash(kubectl patch:*)"
          "Bash(kubectl edit:*)"
          "Bash(kubectl replace:*)"
          "Bash(kubectl scale:*)"
          "Bash(kubectl set:*)"
          "Bash(kubectl label:*)"
          "Bash(kubectl annotate:*)"
          "Bash(kubectl drain:*)"
          "Bash(kubectl cordon:*)"
          "Bash(kubectl rollout restart:*)"
          "Bash(kubectl rollout undo:*)"
          "Bash(helm install:*)"
          "Bash(helm upgrade:*)"
          "Bash(helm uninstall:*)"
          "Bash(helm rollback:*)"
          "Bash(aws * create-*)"
          "Bash(aws * delete-*)"
          "Bash(aws * put-*)"
          "Bash(aws * update-*)"
          "Bash(aws * modify-*)"
          "Bash(aws * terminate-*)"
          "Bash(aws * invoke*)"
          "Bash(aws s3 rm:*)"
          "Bash(aws s3 rb:*)"
          "Bash(aws s3 mv:*)"
          "Bash(aws s3 cp * s3://*)"
          "Bash(aws s3 sync * s3://*)"
          "Bash(docker push:*)"
          "Bash(npm publish:*)"
          "Bash(cargo publish:*)"
          "Bash(uv publish:*)"
          "Bash(darwin-rebuild switch:*)"
          "Bash(nixos-rebuild switch:*)"
          "Bash(home-manager switch:*)"
          "Bash(nh * switch*)"
          "Read(./.env)"
          "Read(./.env.*)"
          "Read(./**/.env)"
          "Read(./**/.env.*)"
          "Read(./**/*.pem)"
          "Read(./**/id_rsa*)"
          "Read(~/.aws/**)"
          "Read(~/.ssh/**)"
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
          "mcp__claude_ai_Slack__slack_add_list_comment"
          "mcp__claude_ai_Slack__slack_update_list_comment"
        ];
        ask = [
          "Bash(git reset --hard:*)"
          "Bash(git clean -fd:*)"
          "Bash(kubectl exec:*)"
          "Bash(aws secretsmanager get-secret-value:*)"
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
        "rust-analyzer-lsp@claude-plugins-official" = true;
        "pyright-lsp@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
      };
      sandbox = {
        enabled = true;
        autoAllowBashIfSandboxed = true;
        allowUnsandboxedCommands = true;
        network = {
          allowedDomains = [
            "github.com"
            "api.github.com"
            "*.githubusercontent.com"
            "pypi.org"
            "files.pythonhosted.org"
            "registry.npmjs.org"
            "crates.io"
            "index.crates.io"
            "static.crates.io"
            "cache.nixos.org"
          ];
        };
        filesystem = {
          allowWrite = [
            "~/Work/docs"
            "~/.cache/nix"
            "~/.cache/uv"
            "~/.cargo/registry"
            "~/.cargo/git"
            "~/.npm"
          ];
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
        allow = [
          "$defaults"
          "Read-only inspection of cloud and cluster state: aws describe/list/get, kubectl get/describe/logs/diff, helm template, terraform plan"
          "Building, linting and testing locally: nix build/eval, cargo check/clippy/test, uv run, npm test"
        ];
        soft_deny = [
          "$defaults"
          "git push to any branch on any remote"
          "Applying infrastructure changes: terraform or tofu apply, destroy, import, or state mutation"
          "Changing a Kubernetes cluster or Helm release"
          "Creating, modifying or deleting AWS resources, or uploading to S3"
          "Publishing packages or container images"
          "Creating, merging, closing, editing or commenting on GitHub PRs, issues, releases or workflow runs"
          "Activating a system or home configuration: darwin-rebuild, nixos-rebuild, home-manager or nh switch"
          "Running deploy, release or production migration scripts, including make/npm/just targets that do so"
          "Running a denied command indirectly through a wrapper like uv run, nix develop -c, sh -c, or a new script"
        ];
      };
    };
  };

  home.packages = with pkgs; [
    pyright
    rust-analyzer
    typescript-language-server
  ];

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
