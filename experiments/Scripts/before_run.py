from AndroidRunner.Device import Device

# noinspection PyUnusedLocal
def main(device: Device, *args: tuple, **kwargs: dict):
    try:
        with open('/tmp/android-runner_last-path', 'r') as f:
            package = f.read().strip()
        if package.startswith('http://') or package.startswith('https://'):
            package='com.android.chrome'
        print(f'Closing app from last run ({package})')
        device.shell(f'am force-stop {package}')
    except:
        pass
