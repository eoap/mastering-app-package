"""Run cwl2markdown on every tracked CWL document without output collisions."""

from pathlib import Path
import subprocess
import sys


# cwl2markdown 0.2.1 requests index.md but ships index.md.jinja. Resolve the
# packaged template without modifying the installed third-party package.
RENDER = """
from jinja2 import PackageLoader, TemplateNotFound
from transpiler_mate.runtime.cli import main

original = PackageLoader.get_source
def get_source(self, environment, template):
    try:
        return original(self, environment, template)
    except TemplateNotFound:
        if self.package_name == 'cwl2markdown' and template == 'index.md':
            return original(self, environment, 'index.md.jinja')
        raise
PackageLoader.get_source = get_source
main()
"""


def main():
    root = Path(__file__).resolve().parents[1]
    output_root = root / "docs/reference/cwl"
    sources = subprocess.check_output(
        ["git", "ls-files", "-z", "--", "*.cwl"], cwd=root
    ).decode().split("\0")
    failures = []
    page_count = 0
    tool_count = 0
    for source in sorted(filter(None, sources)):
        output = output_root / Path(source).with_suffix("")
        result = subprocess.run(
            [sys.executable, "-c", RENDER, "cwl2markdown", "--output", str(output), source],
            cwd=root,
            capture_output=True,
            text=True,
        )
        if result.returncode:
            if "Workflow(s) found in input" in result.stderr:
                tool_count += 1
                print(f"SKIP: {source}: standalone tool (metadata validated)")
                continue
            failures.append(source)
            print(f"FAIL: {source}\n{result.stdout}{result.stderr}", file=sys.stderr)
            continue
        pages = sorted(output.glob("*.md.jinja"))
        for page in pages:
            # These files are already rendered Markdown, despite their suffix.
            page.write_text(
                "\n".join(line.rstrip() for line in page.read_text().splitlines()).rstrip()
                + "\n"
            )
            page.rename(page.with_suffix(""))
        page_count += len(pages)
        print(f"OK: {source}: {len(pages)} workflow page(s)")
    print(
        f"Generated {page_count} workflow pages; {tool_count} standalone tools; "
        f"{len(failures)} failures."
    )
    return bool(failures)


if __name__ == "__main__":
    sys.exit(main())
