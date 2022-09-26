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
        script = str((Path(__file__).parent / 'get_network_traffic_stats.sh').absolute())
        os.system(f'adb shell dumpsys netstats > {self.output_dir}/stats_before.txt')

    def stop_profiling(self, device, **kwargs):
        """Stop the profiling process"""
        pass

    def collect_results(self, device):
        """Collect the data and clean up extra files on the device, save data in location set by 'set_output' """
        script = str((Path(__file__).parent / 'get_network_traffic_stats.sh').absolute())
        os.system(f'adb shell dumpsys netstats > {self.output_dir}/stats_after.txt')

    def unload(self, device):
        """Stop the profiler, removing configuration files on device"""
        pass

    def set_output(self, output_dir):
        """Set the output directory before the start_profiling is called"""
        self.output_dir = output_dir

    def aggregate_subject(self):
        """Aggregate the data at the end of a subject, collect data and save data to location set by 'set output' """
        filename = os.path.join(self.output_dir, 'Aggregated.csv')
        # Parse Xt stats
        tx_a = 0
        rx_a = 0
        with open(os.path.join(self.output_dir, 'stats_after.txt'), 'r') as f:
            while True:
                line = f.readline()
                if not line or line.startswith('Xt stats:'):
                    break
            while True:
                line = f.readline()
                if not line or line.strip().endswith('stats:'):
                    break
                match = re.match(r'.*rb=([0-9]+).*tb=([0-9]+).*', line)
                if match is not None:
                    rx_a += int(match.group(1))
                    tx_a += int(match.group(2))
        tx_b = 0
        rx_b = 0
        with open(os.path.join(self.output_dir, 'stats_before.txt'), 'r') as f:
            while True:
                line = f.readline()
                if not line or line.startswith('Xt stats:'):
                    break
            while True:
                line = f.readline()
                if not line or line.strip().endswith('stats:'):
                    break
                match = re.match(r'.*rb=([0-9]+).*tb=([0-9]+).*', line)
                if match is not None:
                    rx_b += int(match.group(1))
                    tx_b += int(match.group(2))
        print(f'rx_a: {rx_a}, tx_a: {tx_a}, rx_b: {rx_b}, tx_b: {tx_b}')
        util.write_to_file(filename, [{'rx': rx_a - rx_b, 'tx': tx_a - tx_b}])

    def aggregate_end(self, data_dir, output_file):
        """Aggregate the data at the end of the experiment.
         Data located in file structure inside data_dir. Save aggregated data to output_file
        """
        return
        rows = self.aggregate_final(data_dir)
        util.write_to_file(output_file, rows)


    def aggregate_final(self, data_dir):
        rows = []
        return rows
        # TODO work in progress
        for device in util.list_subdir(data_dir):
            row = OrderedDict({'device': device})
            device_dir = os.path.join(data_dir, device)
            for subject in util.list_subdir(device_dir):
                row.update({'subject': subject})
                subject_dir = os.path.join(device_dir, subject)
                if os.path.isdir(os.path.join(subject_dir, 'network')):
                    row.update(self.aggregate_battery_final(os.path.join(subject_dir, 'network')))
                    rows.append(row.copy())
                else:
                    for browser in util.list_subdir(subject_dir):
                        row.update({'browser': browser})
                        browser_dir = os.path.join(subject_dir, browser)
                        if os.path.isdir(os.path.join(browser_dir, 'batterystats')):
                            row.update(self.aggregate_battery_final(os.path.join(browser_dir, 'network')))
                            rows.append(row.copy())
        return rows
