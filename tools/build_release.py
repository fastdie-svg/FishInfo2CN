#!/usr/bin/env python3
"""Build the distributable zip for FishInfo2CN.

Produces a zip whose single top-level entry is the addon folder `FishInfo2CN/`,
so that extracting it into `World of Warcraft/Interface/AddOns/` yields a
correctly laid out addon. Build metadata (timestamps, permissions) is
normalised so the archive is byte-for-byte reproducible.
"""

import os
import zipfile

SRC_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))  # addon root
OUT_DIR = os.path.join(SRC_DIR, "dist")
OUT_NAME = "FishInfo2CN-V10-release.zip"
ADDON_DIR = "FishInfo2CN"          # top-level folder inside the zip
FIXED_DATE = (2026, 10, 10, 0, 0, 0)  # release date, not build time

FILES = [
    "FishInfo2CN.toc",
    "FishInfo2.xml",
    "FishInfo2.lua",
    "Bindings.xml",
    "Localization.lua",
    "README.md",
    "LICENSE",
    "NOTICE",
]


def main() -> None:
    missing = [f for f in FILES if not os.path.isfile(os.path.join(SRC_DIR, f))]
    if missing:
        raise SystemExit("missing source files: " + ", ".join(missing))

    os.makedirs(OUT_DIR, exist_ok=True)
    out_path = os.path.join(OUT_DIR, OUT_NAME)

    with zipfile.ZipFile(out_path, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for name in FILES:
            src = os.path.join(SRC_DIR, name)
            info = zipfile.ZipInfo(f"{ADDON_DIR}/{name}", date_time=FIXED_DATE)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o644 << 16
            with open(src, "rb") as fh:
                zf.writestr(info, fh.read())

    print(f"wrote {out_path}")
    print(f"entries={len(FILES)} size={os.path.getsize(out_path)}")


if __name__ == "__main__":
    main()
