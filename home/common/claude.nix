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
          "Bash(uv sync:*)"
          "Bash(uv lock:*)"
          "Bash(uv add:*)"
          "Bash(uv remove:*)"
          "Bash(uv tree:*)"
          "Bash(uv run pytest:*)"
          "Bash(uv run ruff:*)"
          "Bash(uv run pyright:*)"
          "Bash(uv run basedpyright:*)"
          "Bash(uvx ruff:*)"
          "Bash(pytest:*)"
          "Bash(ruff:*)"
          "Bash(make test)"
          "Bash(make lint)"
          "Bash(make check)"
          "Bash(make build)"
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
          "Bash(aws s3 ls:*)"
        ];
        deny = [
          "Bash(*git push*)"
          "Bash(*git -* push*)"
          "Bash(*git add*)"
          "Bash(*git -* add *)"
          "Bash(*git commit*)"
          "Bash(*git -* commit*)"
          "Bash(*gh*pr create*)"
          "Bash(*gh*pr merge*)"
          "Bash(*gh*pr close*)"
          "Bash(*gh*pr reopen*)"
          "Bash(*gh*pr ready*)"
          "Bash(*gh*pr comment*)"
          "Bash(*gh*pr review*)"
          "Bash(*gh*pr edit*)"
          "Bash(*gh*issue create*)"
          "Bash(*gh*issue comment*)"
          "Bash(*gh*issue close*)"
          "Bash(*gh*issue reopen*)"
          "Bash(*gh*issue edit*)"
          "Bash(*gh*issue delete*)"
          "Bash(*gh*release create*)"
          "Bash(*gh*release edit*)"
          "Bash(*gh*release delete*)"
          "Bash(*gh*release upload*)"
          "Bash(*gh*repo create*)"
          "Bash(*gh*repo edit*)"
          "Bash(*gh*repo delete*)"
          "Bash(*gh*repo rename*)"
          "Bash(*gh*repo archive*)"
          "Bash(*gh*repo fork*)"
          "Bash(*gh*repo sync*)"
          "Bash(*gh*workflow run*)"
          "Bash(*gh*workflow enable*)"
          "Bash(*gh*workflow disable*)"
          "Bash(*gh*run rerun*)"
          "Bash(*gh*run cancel*)"
          "Bash(*gh*run delete*)"
          "Bash(*gh*secret set*)"
          "Bash(*gh*secret delete*)"
          "Bash(*gh*variable set*)"
          "Bash(*gh*variable delete*)"
          "Bash(*gh*gist create*)"
          "Bash(*gh*gist edit*)"
          "Bash(*gh api*-*POST*)"
          "Bash(*gh api*-*PUT*)"
          "Bash(*gh api*-*PATCH*)"
          "Bash(*gh api*-*DELETE*)"
          "Bash(*gh api*mutation*)"
          "Bash(*terraform* apply)"
          "Bash(*terraform* apply *)"
          "Bash(*terraform* destroy)"
          "Bash(*terraform* destroy *)"
          "Bash(*terraform* import *)"
          "Bash(*terraform* taint *)"
          "Bash(*terraform* untaint *)"
          "Bash(*terraform* force-unlock *)"
          "Bash(*terraform* state rm *)"
          "Bash(*terraform* state mv *)"
          "Bash(*terraform* state push *)"
          "Bash(*terraform* state replace-provider *)"
          "Bash(*terraform* workspace delete *)"
          "Bash(*tofu* apply)"
          "Bash(*tofu* apply *)"
          "Bash(*tofu* destroy)"
          "Bash(*tofu* destroy *)"
          "Bash(*tofu* import *)"
          "Bash(*tofu* taint *)"
          "Bash(*tofu* untaint *)"
          "Bash(*tofu* force-unlock *)"
          "Bash(*tofu* state rm *)"
          "Bash(*tofu* state mv *)"
          "Bash(*tofu* state push *)"
          "Bash(*tofu* state replace-provider *)"
          "Bash(*tofu* workspace delete *)"
          "Bash(*kubectl* apply *)"
          "Bash(*kubectl* create *)"
          "Bash(*kubectl* delete *)"
          "Bash(*kubectl* patch *)"
          "Bash(*kubectl* edit *)"
          "Bash(*kubectl* replace *)"
          "Bash(*kubectl* scale *)"
          "Bash(*kubectl* set *)"
          "Bash(*kubectl* label *)"
          "Bash(*kubectl* annotate *)"
          "Bash(*kubectl* drain *)"
          "Bash(*kubectl* cordon *)"
          "Bash(*kubectl* uncordon *)"
          "Bash(*kubectl* taint *)"
          "Bash(*kubectl* run *)"
          "Bash(*kubectl* expose *)"
          "Bash(*kubectl* autoscale *)"
          "Bash(*kubectl* rollout restart *)"
          "Bash(*kubectl* rollout undo *)"
          "Bash(*kubectl* rollout pause *)"
          "Bash(*kubectl* rollout resume *)"
          "Bash(*helm* install *)"
          "Bash(*helm* upgrade *)"
          "Bash(*helm* uninstall *)"
          "Bash(*helm* delete *)"
          "Bash(*helm* rollback *)"
          "Bash(*helm* push *)"
          "Bash(*aws * create-*)"
          "Bash(*aws * delete-*)"
          "Bash(*aws * put-*)"
          "Bash(*aws * update-*)"
          "Bash(*aws * modify-*)"
          "Bash(*aws * terminate-*)"
          "Bash(*aws * invoke*)"
          "Bash(*aws * run-*)"
          "Bash(*aws * send-*)"
          "Bash(*aws * stop-*)"
          "Bash(*aws * reboot-*)"
          "Bash(*aws * attach-*)"
          "Bash(*aws * detach-*)"
          "Bash(*aws * associate-*)"
          "Bash(*aws * disassociate-*)"
          "Bash(*aws * authorize-*)"
          "Bash(*aws * revoke-*)"
          "Bash(*aws * add-*)"
          "Bash(*aws * remove-*)"
          "Bash(*aws * set-*)"
          "Bash(*aws * tag-*)"
          "Bash(*aws * untag-*)"
          "Bash(*aws * register-*)"
          "Bash(*aws * deregister-*)"
          "Bash(*aws * enable-*)"
          "Bash(*aws * disable-*)"
          "Bash(*aws * restore-*)"
          "Bash(*aws * copy-*)"
          "Bash(*aws * upload-*)"
          "Bash(*aws * import-*)"
          "Bash(*aws * execute-*)"
          "Bash(*aws * cancel-*)"
          "Bash(*aws * reset-*)"
          "Bash(*aws * replace-*)"
          "Bash(*aws * publish*)"
          "Bash(*aws * deploy *)"
          "Bash(*aws *s3 rm *)"
          "Bash(*aws *s3 rb *)"
          "Bash(*aws *s3 mv *)"
          "Bash(*aws *s3 mb *)"
          "Bash(*aws *s3 cp * s3://*)"
          "Bash(*aws *s3 sync * s3://*)"
          "Bash(*docker* push *)"
          "Bash(*docker*--push*)"
          "Bash(*npm publish*)"
          "Bash(*npm -* publish*)"
          "Bash(*yarn publish*)"
          "Bash(*cargo publish*)"
          "Bash(*cargo -* publish*)"
          "Bash(*cargo +* publish*)"
          "Bash(*uv publish*)"
          "Bash(*uv -* publish*)"
          "Bash(*twine upload*)"
          "Bash(*darwin-rebuild* switch*)"
          "Bash(*darwin-rebuild* activate*)"
          "Bash(*nixos-rebuild* switch*)"
          "Bash(*nixos-rebuild* boot*)"
          "Bash(*nixos-rebuild* test*)"
          "Bash(*home-manager* switch*)"
          "Bash(nh * switch*)"
          "Bash(*nix run * switch*)"
          "Bash(*result/activate*)"
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
          "Bash(sh)"
          "Bash(sh -s*)"
          "Bash(bash)"
          "Bash(bash -s*)"
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
          "Bash(git *reset --hard*)"
          "Bash(git *clean -*f*)"
          "Bash(git *checkout *-- *)"
          "Bash(git *checkout .*)"
          "Bash(git *checkout -f*)"
          "Bash(git *restore *)"
          "Bash(git *stash drop*)"
          "Bash(git *stash clear*)"
          "Bash(git *branch -d*)"
          "Bash(git *branch -D*)"
          "Bash(git *branch --delete*)"
          "Bash(git *branch -f*)"
          "Bash(git *branch --force*)"
          "Bash(*kubectl* exec *)"
          "Bash(*aws *secretsmanager get-secret-value*)"
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
          "Building, linting and testing locally: nix build/eval, cargo check/clippy/test, uv sync/lock/add, uv run pytest/ruff/pyright or a repo script, npm test, make test/lint/check/build"
        ];
        soft_deny = [
          "$defaults"
          "git push to any branch on any remote, and git commit or git add"
          "Applying infrastructure changes: terraform or tofu apply, destroy, import, taint, state mutation or workspace deletion"
          "Changing a Kubernetes cluster or Helm release"
          "Creating, modifying or deleting AWS resources, or uploading to S3"
          "Publishing packages, Helm charts or container images"
          "Creating, merging, closing, editing or commenting on GitHub PRs, issues, releases or workflow runs, changing repos, secrets, variables or gists, or writing through gh api"
          "Activating a system or home configuration: darwin-rebuild switch/activate, nixos-rebuild switch/boot/test, home-manager or nh switch, nix run ... -- switch, or result/activate"
          "Running deploy, release or production migration scripts, including make/npm/just targets that do so"
          "Running a denied command indirectly through a wrapper like uv run, nix develop -c, sh -c, or a new script, or with global flags moved before the subcommand like git -C, kubectl -n, terraform -chdir, aws --profile or gh -R"
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
