import tempfile
from pathlib import Path
import shutil

import prefect
from prefect_shell import shell_run_command

from cat12_models import models

from .. import utils


@prefect.task
async def run(image: Path, out: Path) -> None:
    # if the output already exists, we don't want this to run again.
    if not (out / image.name).exists():
        standalone = utils.get_standalone_script()
        batch = utils.get_batch()
        with tempfile.TemporaryDirectory() as tmpdir:
            tmpimg = shutil.copy2(image, tmpdir)
            cmd = f"{standalone} -b {batch} {tmpimg}"
            await shell_run_command.fn(command=cmd)
            # validate
            shutil.copytree(tmpdir, out, dirs_exist_ok=True)
            models.CATResult.from_root(Path(tmpdir), Path(tmpimg))


@prefect.flow
def cat_flow(images: frozenset[Path], out: Path) -> None:
    for image in images:
        run.submit(image, out=out)
