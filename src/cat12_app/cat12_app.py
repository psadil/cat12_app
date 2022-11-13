from __future__ import annotations
import os
from pathlib import Path

import click

import prefect
from prefect.task_runners import SequentialTaskRunner
import prefect_dask
from dask import config

from .flows.cat import cat_flow


@prefect.flow(task_runner=SequentialTaskRunner())
def _main(
    anats: frozenset[Path] | None = None,
    output_dir: Path = Path("out"),
    n_proc: int = 1,
) -> None:

    if anats:
        cat_flow.with_options(
            task_runner=prefect_dask.DaskTaskRunner(
                cluster_kwargs={"n_workers": n_proc, "threads_per_worker": 1}
            )
        )(images=anats, out=output_dir, return_state=True)


@click.command(context_settings={"ignore_unknown_options": True})
@click.option(
    "--bids-dir",
    type=click.Path(
        exists=True, file_okay=False, dir_okay=True, resolve_path=True, path_type=Path
    ),
)
@click.option(
    "--output-dir",
    default="out",
    type=click.Path(
        exists=False, file_okay=False, dir_okay=True, resolve_path=True, path_type=Path
    ),
)
@click.option(
    "--tmpdir",
    type=click.Path(exists=True, file_okay=False, dir_okay=True, resolve_path=True),
)
@click.option("--n-proc", type=int, default=1)
def main(
    bids_dir: Path | None = None,
    output_dir: Path = Path("out"),
    tmpdir: str | None = None,
    n_proc: int = 1,
) -> None:

    # this were all used while troubleshooting. It might be worth exploring removing them
    # Though, it's also not clear that there is enough benefit to letting Dask spill memory onto
    # disk, so they are staying off for now
    # the last one would be what to try removing firstish
    config.set({"distributed.worker.memory.rebalance.measure": "managed_in_memory"})
    config.set({"distributed.worker.memory.spill": False})
    config.set({"distributed.worker.memory.target": False})
    config.set({"distributed.worker.memory.pause": False})
    config.set({"distributed.worker.memory.terminate": False})

    if tmpdir:
        os.environ["TMPDIR"] = tmpdir
    if not output_dir.exists():
        output_dir.mkdir()

    anats = frozenset(bids_dir.glob("sub*/**/anat/*T1w.nii.gz")) if bids_dir else None
    _main(anats=anats, n_proc=n_proc, output_dir=output_dir)
