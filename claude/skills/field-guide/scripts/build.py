#!/usr/bin/env python3
"""Inline a field guide's sources into one offline HTML file, then lint it.

Usage: build.py SRC_DIR OUT_FILE [--brand NAME ...] [--max-mb N]

Inlines <link rel="stylesheet" href>, <script src>, local src/href/url()
assets, and quoted 'assets/...' paths in JS as data URIs. Fails without
writing on: em dashes, misspelled brand names, external resource references,
runtime network or module loading, or size.
"""
import argparse
import base64
import mimetypes
import re
import sys
from pathlib import Path

mimetypes.add_type("font/ttf", ".ttf")
mimetypes.add_type("font/otf", ".otf")
mimetypes.add_type("font/woff", ".woff")
mimetypes.add_type("font/woff2", ".woff2")
mimetypes.add_type("image/webp", ".webp")
mimetypes.add_type("image/svg+xml", ".svg")

DATA_URI = re.compile(r"data:[\w/+.-]+;base64,[A-Za-z0-9+/=]+")


def is_local(ref):
    return not re.match(r"^(?:[a-z]+:|//|#)", ref, re.I)


def data_uri(path):
    mime = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
    return f"data:{mime};base64,{base64.b64encode(path.read_bytes()).decode()}"


def resolve(base, ref):
    path = (base / ref.split("#")[0].split("?")[0]).resolve()
    if not path.is_file():
        sys.exit(f"build: missing asset {ref} (looked in {path})")
    return path


def inline_css_urls(css, base):
    def sub(m):
        ref = m.group(2)
        return f'url("{data_uri(resolve(base, ref))}")' if is_local(ref) else m.group(0)
    return re.sub(r"""url\((['"]?)([^'")]+)\1\)""", sub, css)


def build(src):
    html = (src / "index.html").read_text()

    def stylesheet(m):
        href = m.group(1)
        if not is_local(href):
            return m.group(0)
        path = resolve(src, href)
        return f"<style>\n{inline_css_urls(path.read_text(), path.parent)}\n</style>"

    def script(m):
        if not is_local(m.group(1)):
            return m.group(0)
        js = resolve(src, m.group(1)).read_text().replace("</script", "<\\/script")
        return f"<script>\n{js}\n</script>"

    def asset(m):
        attr, ref = m.group(1), m.group(2)
        return f'{attr}="{data_uri(resolve(src, ref))}"' if is_local(ref) else m.group(0)

    html = re.sub(r"""<link\b[^>]*\brel=["']stylesheet["'][^>]*\bhref=["']([^"']+)["'][^>]*>""", stylesheet, html)
    html = re.sub(r"""<script\b[^>]*\bsrc=["']([^"']+)["'][^>]*>\s*</script>""", script, html)
    # Inline <style> blocks may reference fonts and images too.
    html = re.sub(r"<style>(.*?)</style>", lambda m: f"<style>{inline_css_urls(m.group(1), src)}</style>", html, flags=re.S)
    html = re.sub(r"""(?<![\w-])(src|href|poster)=["']([^"']+\.(?:png|jpe?g|gif|webp|svg|ico|avif))["']""", asset, html, flags=re.I)
    # Asset paths inside JS data, e.g. SHOTS = [{img: 'assets/queue.png'}].
    html = re.sub(r"""(["'`])((?:\./)?assets/[^"'`\s]+)\1""", lambda m: f"{m.group(1)}{data_uri(resolve(src, m.group(2)))}{m.group(1)}", html)
    return html


def lint(html, brands, max_mb):
    text = DATA_URI.sub("", html)
    errors = []
    for n, line in enumerate(text.splitlines(), 1):
        if "—" in line or "&mdash;" in line or "&#8212;" in line:
            errors.append(f"line {n}: em dash")
        for brand in brands:
            variant = r"[\s-]?".join(map(re.escape, brand.replace(" ", "")))
            for m in re.finditer(rf"(?<![\w/.@-]){variant}(?![\w/-]|\.\w)", line, re.I):
                if m.group(0) != brand:
                    errors.append(f"line {n}: brand spelled {m.group(0)!r}, expected {brand!r}")
    external = re.compile(
        r"""\b(?:src|srcset|poster|data)=["'](?:https?:)?//"""
        r"""|<link\b[^>]*\bhref=["'](?:https?:)?//"""
        r"""|url\(["']?(?:https?:)?//"""
        r"""|@import""", re.I)
    network = re.compile(r"""\bfetch\(|XMLHttpRequest|\bWebSocket\(|sendBeacon|\bimport\(|type=["']module["']""")
    for n, line in enumerate(text.splitlines(), 1):
        if external.search(line):
            errors.append(f"line {n}: external resource reference (must run offline from anywhere)")
        if network.search(line):
            errors.append(f"line {n}: runtime network or module loading (breaks offline and on file://)")
    size_mb = len(html.encode()) / 1_000_000
    if size_mb > max_mb:
        errors.append(f"output is {size_mb:.2f} MB, over the {max_mb} MB limit")
    return errors, size_mb


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("src", type=Path, help="directory containing index.html")
    p.add_argument("out", type=Path, help="deliverable HTML path")
    p.add_argument("--brand", action="append", default=[], help="name whose exact spelling is enforced (repeatable)")
    p.add_argument("--max-mb", type=float, default=3.0)
    args = p.parse_args()

    html = build(args.src)
    errors, size_mb = lint(html, args.brand, args.max_mb)
    if errors:
        print("build failed:\n  " + "\n  ".join(errors), file=sys.stderr)
        sys.exit(1)
    args.out.write_text(html)
    print(f"built {args.out} ({size_mb:.2f} MB)")


if __name__ == "__main__":
    main()
