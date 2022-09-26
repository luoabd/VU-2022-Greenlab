from AndroidRunner.Device import Device
from pathlib import Path
import os

# noinspection PyUnusedLocal
def main(device: Device, *args: tuple, **kwargs: dict):
    print('Trying to unlock device')
    os.system("adb shell input keyevent 82;sleep 1;adb shell input keyevent 82")
    os.system(str((Path(__file__).parent.parent.parent.parent / 'utils' / 'pre_run.sh').absolute()))
    pass
