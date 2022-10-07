from time import sleep
from AndroidRunner.Device import Device
from pathlib import Path
import os

# Granular cleanup for web
# In Android Runner, set clear_data to False in WebExperiment.py#L86
# Instead, configure Firefox settings to clear selected data on exit
# Quit Firefox (--> Triggers cleanup)
def firefox_cleanup(device: Device):
    device.shell('monkey -p org.mozilla.firefox -c android.intent.category.LAUNCHER 1')
    sleep(1)
    device.shell('input tap 1000 2250')
    device.shell('input tap 1000 2200')

# noinspection PyUnusedLocal
def main(device: Device, *args: tuple, **kwargs: dict):
    path = ''
    with open('/tmp/android-runner_last-path', 'r') as f:
        path = f.read().strip()
    print(f'Clearing cache for run of {path}')
    if path.startswith('http://') or path.startswith('https://'):
        # print('Quit Firefox')
        # firefox_cleanup(device)
        os.system(str((Path(__file__).parent.parent.parent / 'utils' / 'clear_chrome_browser_data.sh').absolute()))
    else:
        os.system(f"{str((Path(__file__).parent.parent.parent / 'utils' / 'clear_cache.sh').absolute())} {path}")