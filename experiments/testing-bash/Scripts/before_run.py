from AndroidRunner.Device import Device
from pathlib import Path
import os

# noinspection PyUnusedLocal
def main(device: Device, *args: tuple, **kwargs: dict):
    os.system(str((Path(__file__).parent.parent.parent.parent / 'utils' / 'pre_run.sh').absolute()))
    pass
