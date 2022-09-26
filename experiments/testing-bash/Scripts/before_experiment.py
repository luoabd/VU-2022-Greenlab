from AndroidRunner.Device import Device
import os

# noinspection PyUnusedLocal
def main(device: Device, *args: tuple, **kwargs: dict):
    print('Trying to unlock device')
    os.system("adb shell input keyevent 82;sleep 1;adb shell input keyevent 82")
