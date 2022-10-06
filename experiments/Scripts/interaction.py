import os
from pathlib import Path
from AndroidRunner.Device import Device
from AndroidRunner.Experiment import Experiment
from typing import Dict
import time
import logging

LOGGER = logging.getLogger()

# Generally, after every action, we need to wait for the display to update.
# The time to update varies.

def tap(device: Device, x: int, y: int, sleep = 1) -> None:
    device.shell(f'input tap {x} {y}')
    time.sleep(sleep)

def write_text(device: Device, text: str, sleep = 1) -> None:
    device.shell(f'input text \'{text}\'')
    time.sleep(sleep)

def swipe(device: Device, x1: int, y1: int, x2: int, y2: int, sleep = 4, duration = 1000):
    device.shell(f'input swipe {x1} {y1} {x2} {y2} {duration}')
    time.sleep(sleep)                                                                                                                                                                                            
                                                                                                                                                                                                                 
def main(device: Device, *args, **kwargs) -> None:                                                                                                                                                               
    LOGGER.debug(args)                                                                                                                                                                                           
    LOGGER.debug(kwargs)                                                                                                                                                                                         
                                                                                                                                                                                                                 
    experiment: Experiment = args[0] # can be useful if you want to differentiate actions per subject                                                                                                            
    current_run: Dict = experiment.get_experiment()                                                                                                                                                              
    LOGGER.debug(current_run)                                                                                                                                                                                  

    path = current_run['path']
    subject = ''
    if path.startswith('http://') or path.startswith('https://'):
        subject = path.split('/')[2]
    else:
        subject = path # package name
    subject = subject.replace('.', '_')
    script=str((Path(__file__).parent / 'interactions' / f'{subject}.sh').absolute())
    print(f'Starting interaction script "{script}"')
    os.system(f'{script} &')
    try:
        time.sleep(experiment.duration)
    except:
        pass # catch Ctrl+C
    print('Stopping interaction script')
    os.system('ps -auxf | grep "{script.split("/")[-1]}' + '" | head -n 1 | awk \'{print $2}\'')
    kill_cmd = f'kill -s 9 $(ps -auxf | grep "bash[^*]*{script.split("/")[-1].split(".")[0]}' + '" | awk \'{print $2}\')'
    os.system(kill_cmd)
