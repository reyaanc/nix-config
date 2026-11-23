import json
import os
import re
import shlex
import subprocess
import sys

SEPARATORS = set(";&|()\n`")
REDIRECTS = set("<>&0123456789")
ASSIGNMENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*=")
DURATION = re.compile(r"\d+(\.\d+)?[smhd]?")
SHELL_C = re.compile(r"-[a-z]*c[a-z]*")
WRAPPERS = {"env", "command", "builtin", "exec", "nohup", "nice", "time", "timeout", "stdbuf", "noglob", "xargs", "caffeinate", "watch"}
WRAPPER_VALUE_OPTS = {"-u", "-s", "-k", "-n", "-I", "-P", "-L", "-d"}
SHELLS = {"sh", "bash", "zsh", "dash", "fish", "source", "."}
INTERPRETERS = {"node", "ruby", "perl"}
RISKY_TARGET = re.compile(r"(^|[:_-])(deploy|release|publish|migrate|apply|push|rollout)")
RISKY_TEXT = re.compile(
    r"\bgit\W+(?:-\S+\W+)*(?:push|commit)\b"
    r"|\b(?:terraform|tofu)\W+(?:apply|destroy)\b"
    r"|\bkubectl\W+(?:apply|delete|patch|replace)\b"
    r"|\bhelm\W+(?:install|upgrade|uninstall|rollback)\b"
    r"|\bdocker\W+push\b"
    r"|\b(?:npm|pnpm|yarn|cargo|uv)\W+publish\b"
    r"|\b(?:darwin|nixos)-rebuild\b"
)

GIT_VALUE_OPTS = {"-C", "-c", "--git-dir", "--work-tree", "--namespace", "--exec-path", "--config-env"}
GIT_BLOCKED = {"push", "commit", "add"}
GIT_CONFIG_READS = {"--get", "--get-all", "--get-regexp", "--list", "-l", "get", "list"}

GH_VALUE_OPTS = {"-R", "--repo", "--hostname", "-X", "--method", "-f", "-F", "--field", "--raw-field", "-H", "--header", "-q", "--jq", "--input", "-t", "--template", "-L", "--limit", "--json", "-s", "--state"}
GH_LOCAL = {"auth", "browse", "search", "status", "help", "completion", "config", "extension", "alias"}
GH_READ = {"view", "list", "diff", "checks", "status", "download", "checkout", "clone", "watch"}
GH_FIELDS = {"-f", "-F", "--field", "--raw-field"}

TERRAFORM_BLOCKED = {"apply", "destroy", "import", "taint", "untaint", "force-unlock"}
TERRAFORM_STATE_BLOCKED = {"rm", "mv", "push", "replace-provider"}

KUBECTL_VALUE_OPTS = {"-n", "--namespace", "--context", "--kubeconfig", "--cluster", "--user", "-l", "--selector", "-o", "--output", "-c", "--container", "-f", "--filename", "--as", "-s", "--server", "--token", "--since", "--tail", "-L"}
KUBECTL_READ = {"get", "describe", "logs", "diff", "explain", "api-resources", "api-versions", "version", "cluster-info", "top", "config", "auth", "events", "wait", "port-forward", "proxy", "kustomize", "completion", "plugin", "exec"}

HELM_VALUE_OPTS = {"-n", "--namespace", "--kube-context", "--kubeconfig"}
HELM_BLOCKED = {"install", "upgrade", "uninstall", "delete", "del", "un", "rollback", "push"}

AWS_VALUE_OPTS = {"--profile", "--region", "--output", "--endpoint-url", "--query", "--color", "--ca-bundle", "--cli-read-timeout", "--cli-connect-timeout", "--cli-binary-format"}
AWS_LOCAL = {"configure", "help", "sso"}
AWS_READ = re.compile(r"(describe|list|get|head|scan|query|filter|lookup|search|tail|wait|help|validate|estimate|preview|simulate|test|batch-get|select|download|presign|ls|assume-role|decode|update-kubeconfig)\b")

DOCKER_VALUE_OPTS = {"--context", "-c", "-H", "--host", "--config", "-f", "--file", "-t", "--tag"}
JS_VALUE_OPTS = {"--registry", "--prefix", "-w", "--workspace", "-C", "--dir", "--filter", "--cwd"}
JS_BLOCKED = {"publish", "unpublish", "deprecate"}
CARGO_VALUE_OPTS = {"--manifest-path", "-p", "--package", "-Z", "--config", "-C", "--target"}
UV_VALUE_OPTS = {"--directory", "--project", "--python", "-p", "--with", "--index", "--extra-index-url", "--package", "--extra", "--group", "--env-file", "--from"}
MAKE_VALUE_OPTS = {"-C", "-f", "--file", "--directory", "-j", "-I", "--justfile", "-d"}
ACTIVATION = {"switch", "activate", "boot", "test"}


class Blocked(Exception):
    pass


def positionals(args, value_opts=frozenset()):
    out = []
    it = iter(args)
    for arg in it:
        if arg == "--":
            out.extend(it)
        elif arg.startswith("-"):
            if arg in value_opts:
                next(it, None)
        else:
            out.append(arg)
    return out


def after_options(args, value_opts=frozenset()):
    i = 0
    while i < len(args) and args[i].startswith("-"):
        i += 2 if args[i] in value_opts else 1
    return args[i:]


def simple_commands(command):
    lex = shlex.shlex(command, posix=True, punctuation_chars=";&|()<>\n`")
    lex.whitespace = " \t\r"
    lex.whitespace_split = True
    lex.commenters = ""
    current, skip = [], False
    for token in lex:
        if token and set(token) <= SEPARATORS:
            if current:
                yield current
            current = []
        elif token and set(token) <= REDIRECTS and set(token) & set("<>"):
            skip = True
        elif skip:
            skip = False
        else:
            current.append(token)
    if current:
        yield current


def scan(path, cwd):
    if not path:
        return
    try:
        with open(os.path.join(cwd, os.path.expanduser(path)), "rb") as f:
            content = f.read(1_000_000)
    except OSError:
        return
    if b"\0" not in content[:1024] and RISKY_TEXT.search(content.decode(errors="ignore")):
        raise Blocked(f"{path} contains a change-applying command")


def check(command, cwd, depth=0):
    if depth > 5:
        raise Blocked("command nests too deeply to inspect")
    try:
        commands = list(simple_commands(command))
    except ValueError:
        if RISKY_TEXT.search(command):
            raise Blocked("unparseable command mentioning a change-applying tool")
        return
    for argv in commands:
        check_argv(argv, cwd, depth)


def check_argv(argv, cwd, depth):
    while argv:
        if ASSIGNMENT.match(argv[0]):
            argv = argv[1:]
        elif os.path.basename(argv[0]) in WRAPPERS:
            argv = after_options(argv[1:], WRAPPER_VALUE_OPTS)
            if argv and DURATION.fullmatch(argv[0]):
                argv = argv[1:]
        else:
            break
    if not argv:
        return
    path, args = argv[0], argv[1:]
    name = os.path.basename(path)

    if name == "sudo":
        raise Blocked("sudo")
    if name == "eval":
        return check(" ".join(args), cwd, depth + 1)
    if name in SHELLS:
        flag = next((i for i, a in enumerate(args) if SHELL_C.fullmatch(a)), None)
        if flag is not None:
            return check(args[flag + 1], cwd, depth + 1) if flag + 1 < len(args) else None
        script = next((a for a in args if not a.startswith("-")), None)
        if script is None:
            raise Blocked("piping commands into a shell")
        return scan(script, cwd)
    if name.startswith("python") or name in INTERPRETERS:
        if "-m" in args:
            return check_argv(args[args.index("-m") + 1:], cwd, depth)
        for flag in ("-c", "-e"):
            if flag in args and args.index(flag) + 1 < len(args):
                if RISKY_TEXT.search(args[args.index(flag) + 1]):
                    raise Blocked(f"inline {name} code running a change-applying command")
                return
        return scan(next((a for a in args if not a.startswith("-")), None), cwd)
    if name in RULES:
        return RULES[name](args, cwd, depth)
    if "/" in path:
        scan(path, cwd)


def git(args, cwd, depth):
    for i, arg in enumerate(args[:-1]):
        if arg == "-c" and args[i + 1].startswith("alias."):
            raise Blocked("defining a git alias inline")
    pos = positionals(args, GIT_VALUE_OPTS)
    if not pos:
        return
    sub = pos[0]
    if sub in GIT_BLOCKED:
        raise Blocked(f"git {sub}")
    if sub == "config":
        if any(a.startswith("alias.") for a in pos[1:]) and not GIT_CONFIG_READS & set(args):
            raise Blocked("defining a git alias")
        return
    alias = subprocess.run(
        ["git", "config", "--get", f"alias.{sub}"], cwd=cwd, capture_output=True, text=True, timeout=5
    ).stdout.strip()
    if alias:
        check(alias[1:] if alias.startswith("!") else f"git {alias}", cwd, depth + 1)


def gh(args, cwd, depth):
    pos = positionals(args, GH_VALUE_OPTS)
    if not pos or pos[0] in GH_LOCAL:
        return
    if pos[0] == "api":
        return gh_api(args, pos)
    if len(pos) > 1 and pos[1] not in GH_READ:
        raise Blocked(f"gh {pos[0]} {pos[1]}")


def gh_api(args, pos):
    method, fields = None, []
    for i, arg in enumerate(args):
        value = args[i + 1] if i + 1 < len(args) else ""
        if arg in ("-X", "--method"):
            method = value
        elif arg.startswith("--method="):
            method = arg.split("=", 1)[1]
        elif arg.startswith("-X") and len(arg) > 2:
            method = arg[2:]
        elif arg in GH_FIELDS or arg == "--input":
            fields.append(value)
    if method and method.upper() != "GET":
        raise Blocked(f"gh api -X {method}")
    if method is None and fields:
        if pos[1:2] == ["graphql"] and not any("mutation" in f for f in fields):
            return
        raise Blocked("gh api with fields, which defaults to POST")


def terraform(args, cwd, depth):
    sub, second = (positionals(args) + ["", ""])[:2]
    if sub in TERRAFORM_BLOCKED or (sub == "state" and second in TERRAFORM_STATE_BLOCKED) or (sub == "workspace" and second == "delete"):
        raise Blocked(f"terraform {sub} {second}".strip())


def kubectl(args, cwd, depth):
    sub, second = (positionals(args, KUBECTL_VALUE_OPTS) + ["", ""])[:2]
    if sub and sub not in KUBECTL_READ and not (sub == "rollout" and second in {"status", "history"}):
        raise Blocked(f"kubectl {sub}")


def helm(args, cwd, depth):
    pos = positionals(args, HELM_VALUE_OPTS)
    if pos and pos[0] in HELM_BLOCKED:
        raise Blocked(f"helm {pos[0]}")


def aws(args, cwd, depth):
    pos = positionals(args, AWS_VALUE_OPTS)
    if len(pos) < 2 or pos[0] in AWS_LOCAL:
        return
    service, op = pos[:2]
    if service == "s3" and op in {"cp", "sync"}:
        if pos[-1].startswith("s3://"):
            raise Blocked(f"aws s3 {op} to S3")
    elif not AWS_READ.match(op):
        raise Blocked(f"aws {service} {op}")


def aws_vault(args, cwd, depth):
    if "exec" not in args:
        return
    rest = args[args.index("exec") + 1:]
    if "--" in rest:
        return check_argv(rest[rest.index("--") + 1:], cwd, depth)
    check_argv(after_options(rest)[1:], cwd, depth)


def docker(args, cwd, depth):
    if "push" in positionals(args, DOCKER_VALUE_OPTS)[:2] or "--push" in args:
        raise Blocked("docker push")


def js(args, cwd, depth, runs_scripts_directly=False):
    pos = positionals(args, JS_VALUE_OPTS)
    if not pos:
        return
    if JS_BLOCKED & set(pos[:2]) or pos[:2] == ["dist-tag", "add"]:
        raise Blocked(f"publishing a package ({' '.join(pos[:2])})")
    script = pos[1] if pos[0] in {"run", "run-script"} and len(pos) > 1 else pos[0] if runs_scripts_directly else ""
    if RISKY_TARGET.search(script):
        raise Blocked(f"running the {script} script")
    if pos[0] in {"exec", "dlx", "x"}:
        check_argv(after_options(args[args.index(pos[0]) + 1:]), cwd, depth)


def cargo(args, cwd, depth):
    pos = [p for p in positionals(args, CARGO_VALUE_OPTS) if not p.startswith("+")]
    if pos and pos[0] in {"publish", "yank", "owner"}:
        raise Blocked(f"cargo {pos[0]}")


def uv(args, cwd, depth):
    pos = positionals(args, UV_VALUE_OPTS)
    if not pos:
        return
    if pos[0] == "publish":
        raise Blocked("uv publish")
    if pos[0] == "run":
        check_argv(after_options(args[args.index("run") + 1:], UV_VALUE_OPTS), cwd, depth)
    if pos[:2] == ["tool", "run"]:
        check_argv(after_options(args[args.index("run") + 1:], UV_VALUE_OPTS), cwd, depth)


def nix(args, cwd, depth):
    for flag in ("-c", "--command"):
        if flag in args:
            return check_argv(args[args.index(flag) + 1:], cwd, depth)
    if positionals(args)[:1] == ["copy"] or {"switch", "activate"} & set(args):
        raise Blocked("nix copy or activating a configuration")


def nix_shell(args, cwd, depth):
    for flag in ("--run", "--command"):
        if flag in args and args.index(flag) + 1 < len(args):
            check(args[args.index(flag) + 1], cwd, depth + 1)


def rebuild(args, cwd, depth):
    if ACTIVATION & set(args):
        raise Blocked("activating a system configuration")


def activate(args, cwd, depth):
    raise Blocked("activating a configuration")


def make(args, cwd, depth):
    for target in positionals(args, MAKE_VALUE_OPTS):
        if "=" not in target and RISKY_TARGET.search(target):
            raise Blocked(f"the {target} target")


def direnv(args, cwd, depth):
    if args[:1] == ["exec"]:
        check_argv(args[2:], cwd, depth)


def twine(args, cwd, depth):
    if "upload" in args:
        raise Blocked("twine upload")


RULES = {
    "git": git,
    "gh": gh,
    "terraform": terraform,
    "tofu": terraform,
    "kubectl": kubectl,
    "helm": helm,
    "aws": aws,
    "aws-vault": aws_vault,
    "docker": docker,
    "npm": js,
    "pnpm": lambda a, c, d: js(a, c, d, True),
    "yarn": lambda a, c, d: js(a, c, d, True),
    "bun": lambda a, c, d: js(a, c, d, True),
    "npx": lambda a, c, d: check_argv(after_options(a), c, d),
    "bunx": lambda a, c, d: check_argv(after_options(a), c, d),
    "uvx": lambda a, c, d: check_argv(after_options(a, UV_VALUE_OPTS), c, d),
    "cargo": cargo,
    "uv": uv,
    "twine": twine,
    "nix": nix,
    "nix-shell": nix_shell,
    "darwin-rebuild": rebuild,
    "nixos-rebuild": rebuild,
    "nh": rebuild,
    "home-manager": lambda a, c, d: rebuild([x for x in a if x == "switch"], c, d),
    "activate": activate,
    "activate-user": activate,
    "make": make,
    "just": make,
    "direnv": direnv,
}


def main():
    event = json.load(sys.stdin)
    command = event.get("tool_input", {}).get("command", "")
    try:
        check(command, event.get("cwd") or os.getcwd())
    except Blocked as e:
        print(
            f"Blocked: {e}. Applying changes outside this checkout is the user's call. "
            "Don't look for another route; stop and give them the exact command to run.",
            file=sys.stderr,
        )
        sys.exit(2)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Guard hook crashed, blocking to be safe: {e!r}", file=sys.stderr)
        sys.exit(2)
