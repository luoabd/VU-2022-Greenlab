from collections import OrderedDict
import logging
import os
from pathlib import Path
import re
from AndroidRunner.Plugins.Profiler import Profiler
from AndroidRunner import util

class Network(Profiler):

    # noinspection PyUnusedLocal
    def __init__(self, config, paths):
        self.logger = logging.getLogger(self.__class__.__name__)
        pass

    def dependencies(self):
        """Returns list of needed app dependencies,like com.quicinc.trepn, [] if none"""
        return []

    def load(self, device):
        """Load (and start) the profiler process on the device"""
        pass

    def start_profiling(self, device, **kwargs):
        """Start the profiling process"""
        script = str((Path(__file__).parent.readlink().parent.parent / 'utils' / 'get_network_usage.sh').absolute())
        os.system(f"{script} > {self.output_dir}/stats_before.txt")

    def stop_profiling(self, device, **kwargs):
        """Stop the profiling process"""
        pass

    def collect_results(self, device):
        """Collect the data and clean up extra files on the device, save data in location set by 'set_output' """
        script = str((Path(__file__).parent.readlink().parent.parent / 'utils' / 'get_network_usage.sh').absolute())
        os.system(f"{script} > {self.output_dir}/stats_after.txt")
        self.compute_diff()
        os.remove(os.path.join(self.output_dir, 'stats_before.txt'))
        os.remove(os.path.join(self.output_dir, 'stats_after.txt'))

    def compute_diff(self):
        # Parse Xt stats
        tx_a = 0
        rx_a = 0
        with open(os.path.join(self.output_dir, 'stats_after.txt'), 'r') as f:
            rx_a = int(f.readline().strip('\n'))
            tx_a = int(f.readline().strip('\n'))
        tx_b = 0
        rx_b = 0
        with open(os.path.join(self.output_dir, 'stats_before.txt'), 'r') as f:
            rx_b = int(f.readline().strip('\n'))
            tx_b = int(f.readline().strip('\n'))
        if not os.path.exists(os.path.join(self.output_dir, 'network.csv')):
            os.system(f'echo "rx,tx" > {os.path.join(self.output_dir, "network.csv")}')
        os.system(f'echo "{ rx_a - rx_b },{ tx_a - tx_b }" >> {self.output_dir}/network.csv')

    def unload(self, device):
        """Stop the profiler, removing configuration files on device"""
        pass

    def set_output(self, output_dir):
        """Set the output directory before the start_profiling is called"""
        self.output_dir = output_dir

    def aggregate_subject(self):
        """Aggregate the data at the end of a subject, collect data and save data to location set by 'set output' """
        filename = os.path.join(self.output_dir, 'Aggregated.csv')
        rx_mean = 0
        tx_mean = 0
        count = 0
        with open(os.path.join(self.output_dir, 'network.csv'), 'r') as f:
            f.readline()
            for line in f:
                rx, tx = line.strip().split(',')
                rx_mean += int(rx)
                tx_mean += int(tx)
                count += 1
        rx_mean /= count
        tx_mean /= count
        with open(filename, 'w') as f:
            f.write(f'rx,tx\n')
            f.write(f'{rx_mean},{tx_mean}\n')
        

    def aggregate_end(self, data_dir, output_file):
        """Aggregate the data at the end of the experiment.
         Data located in file structure inside data_dir. Save aggregated data to output_file
        """
        rows = []
        def add_row(filename):
            with open(filename, 'r') as f:
                f.readline()
                rx, tx = f.readline().strip().split(',')
                row.update({'rx': rx, 'tx': tx})
            rows.append(row.copy())

        for device in util.list_subdir(data_dir):
            row = OrderedDict({'device': device})
            device_dir = os.path.join(data_dir, device)
            for subject in util.list_subdir(device_dir):
                row.update({'subject': subject})
                print(f'Aggregating network for {device} {subject}')
                subject_dir = os.path.join(device_dir, subject)
                if os.path.isdir(os.path.join(subject_dir, 'network')):
                    add_row(os.path.join(subject_dir, 'network', 'Aggregated.csv'))
                else:
                    for browser in util.list_subdir(subject_dir):
                        row.update({'browser': browser})
                        browser_dir = os.path.join(subject_dir, browser)
                        if os.path.isdir(os.path.join(browser_dir, 'network')):
                            add_row(os.path.join(browser_dir, 'network', 'Aggregated.csv'))
        util.write_to_file(output_file, rows)
