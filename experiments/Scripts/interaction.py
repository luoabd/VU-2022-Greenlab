import os
from pathlib import Path
from AndroidRunner.Device import Device
from AndroidRunner.Experiment import Experiment
from typing import Dict
import time
import logging

LOGGER = logging.getLogger()                                                                                                                                                                                          
                                                                                                                                                                                                                 
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
    os.system(f'{kill_cmd} 2>/dev/null')
