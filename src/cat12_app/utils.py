from pathlib import Path
from importlib import resources


def get_standalone_script() -> Path:
    out = Path()
    if (out := Path("/usr/local/bin/cat_standalone.sh")).exists():
        return out
    else:
        AssertionError("Unable to find standalone script!")
    return out


def get_batch() -> Path:
    with resources.path("cat12_app.data", "batch.m") as f:
        out = f
    return out
