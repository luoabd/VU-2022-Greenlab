from time import sleep
from AndroidRunner.Device import Device

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
    print('Playing input macro "Quit Firefox"') # Will execute for all apps (doesn't matter tho)
    firefox_cleanup(device)
