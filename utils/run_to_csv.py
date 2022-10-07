#! /usr/bin/python3

import sys
from pathlib import Path
import json

if len(sys.argv) != 2:
    print(f"Usage: {sys.argv[0]} <run dir>")
    sys.exit(1)

subjects = ['coupang', 'espn', 'linkedin', 'pinterest', 'shopee', 'soundcloud', 'spotify', 'twitch', 'weather', 'youtube'
            ]
print("subject,path,app_type,repetition,energy_consumption,network_traffic,mean_cpu_load,mean_mem_usage,mean_frame_time")
profilers = ['batterystats', 'network', 'android', 'frametimes2']

repetitions = json.loads(Path(sys.argv[1]).joinpath(
    "config.json").read_text())["repetitions"]


def get_value_batterystats(profiler_result_dir, repetition):
    result = list(profiler_result_dir.glob(f"Joule_results_*.csv"))[repetition]
    with open(result, 'r') as f:
        f.readline()
        print(f.readline().strip(), end="")


def get_value_network(profiler_result_dir, repetition):
    with open(profiler_result_dir / "network.csv", 'r') as f:
        line = f.read().strip().split('\n')[1:][repetition]
        tx, rx = line.split(',')
        vol = int(tx) + int(rx)
        print(vol, end='')


def get_value_android(profiler_result_dir, repetition):
    try:
        result = list(profiler_result_dir.glob(f"*_*.csv"))[repetition]
        cpu = []
        mem = []
        with open(result, 'r') as f:
            f.readline()
            for line in f:
                cpu.append(float(line.split(',')[1]))
                mem.append(float(line.split(',')[2]))
        print(f"{sum(cpu)/len(cpu)},{sum(mem)/len(mem)}", end='')
    except:
        print('n/a,n/a', end='')


def get_value_frametimes2(profiler_result_dir, repetition):
    result = list(profiler_result_dir.glob(f"frame_times_*.csv"))[repetition]
    frame_times = []
    with open(result, 'r') as f:
        f.readline()
        for line in f:
            frame_times.append(float(line.split(',')[2]))
    print(f"{sum(frame_times)/len(frame_times)}", end='')


def get_value(profiler_result_dir, repetition):
    profiler = profiler_result_dir.name
    try:
        if profiler == 'network':
            get_value_network(profiler_result_dir, repetition)
        elif profiler == 'batterystats':
            get_value_batterystats(profiler_result_dir, repetition)
        elif profiler == 'android':
            get_value_android(profiler_result_dir, repetition)
        elif profiler == 'frametimes2':
            get_value_frametimes2(profiler_result_dir, repetition)
        else:
            print('n/a', end='')
    except:
        print('n/a', end='')


device_dir = list(Path(sys.argv[1]).glob("data/*"))[0]
for trace_dir in device_dir.glob("*"):
    path = trace_dir.name.replace('-', '.')
    subject = [s for s in subjects if s in path][0]
    app_type = 'native'
    if path.startswith('https') or path.startswith('http'):
        path = path.replace('https', '').replace('http', '')[1:]
        app_type = 'web'
        # Change to chrome sub directory
        trace_dir = trace_dir.joinpath('chrome')
    for repetition in range(repetitions):
        print(subject, end=',')
        print(path, end=',')
        print(app_type, end=',')
        print(repetition+1, end=',')
        for i in range(len(profilers)):
            profiler = profilers[i]
            profiler_result_dir = trace_dir / profiler
            get_value(profiler_result_dir, repetition)
            if i < len(profilers) - 1:
                print(',', end='')
        print()
