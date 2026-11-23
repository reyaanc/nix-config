import json
import re
import sys

RANK = ["none", "patch", "minor", "major"]


def load(path):
    with open(path) as f:
        return json.load(f)


def classify(old_version, new_version):
    old, new = re.findall(r"\d+", old_version), re.findall(r"\d+", new_version)
    if not old or not new or old[0] != new[0]:
        return "major"
    if old[1:2] != new[1:2]:
        return "minor"
    return "patch"


def package_changes(old, new):
    level = "none"
    rows = []
    for name in sorted(old.keys() | new.keys()):
        before, after = old.get(name), new.get(name)
        if before == after:
            continue
        kind = "minor" if before is None or after is None else classify(before, after)
        level = max(level, kind, key=RANK.index)
        rows.append(f"| {name} | {before or '-'} | {after or '-'} | {kind} |")
    return level, rows


def input_links(old_lock, new_lock):
    links = []
    for name in new_lock["nodes"]["root"]["inputs"]:
        before = old_lock["nodes"][name]["locked"]
        after = new_lock["nodes"][name]["locked"]
        if before["rev"] != after["rev"]:
            url = f"https://github.com/{after['owner']}/{after['repo']}/compare/{before['rev']}...{after['rev']}"
            links.append(f"- [{name}]({url})")
    return links


def render(level, rows, links):
    lines = [f"## Package changes: {level}", ""]
    if rows:
        lines += ["| Package | Old | New | Bump |", "|---|---|---|---|", *rows]
    else:
        lines.append("No installed package versions changed.")
    lines += ["", "## Inputs", "", *(links or ["No input revisions changed."])]
    return "\n".join(lines) + "\n"


def main():
    old, new, old_lock, new_lock = (load(path) for path in sys.argv[1:5])
    level, rows = package_changes(old, new)
    with open(sys.argv[5], "w") as f:
        f.write(render(level, rows, input_links(old_lock, new_lock)))
    print(level)


if __name__ == "__main__":
    main()
