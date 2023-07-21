#!/usr/bin/env python3
import subprocess
import psutil
import sys
import time

def get_memory_usage(pid):
    try:
        process = psutil.Process(pid)
        return process.memory_info().rss
    except psutil.NoSuchProcess:
        return None
    
class TimeoutException(Exception):
    pass

def get_subprocess_actual_pid(subprocess_pid):
    try:
        parent = psutil.Process(subprocess_pid)
        children = parent.children(recursive=True)
        if len(children) == 0:
            return None
        return children[0].pid
    except psutil.NoSuchProcess:
        return None
    
def run_process_and_get_peak_memory(command):
    # program start time
    start_time = time.time()

    process = subprocess.Popen(command, shell=True)
    
    # actual_process_pid = get_subprocess_actual_pid(process.pid)

    # infer
    actual_process_pid = process.pid + 1

    timeout = 5  # set timeout to 5 seconds
    start_time = time.time()
    while(1):
        if(psutil.pid_exists(actual_process_pid)):
            actual_process = psutil.Process(actual_process_pid)
            break
        current_time = time.time()
        elapsed_time = current_time - start_time
        if elapsed_time >= timeout:
            print(f"PID {actual_process_pid} not exists! time out!")
            raise Exception()
    
    print(f"PID: {actual_process_pid}")

    cpu_time_start = actual_process.cpu_times()

    # peak memory
    max_memory_usage = 0

    while process.poll() is None:
        # record memory every 0.1 seconds
        memory_usage = get_memory_usage(actual_process_pid)
        if memory_usage is not None and memory_usage > max_memory_usage:
            max_memory_usage = memory_usage
        time.sleep(0.1)
        try:
            cpu_time_end = actual_process.cpu_times()
        except psutil.NoSuchProcess:
            pass

    # get peak memory in MB
    peak_memory_usage_mb = max_memory_usage / (1024 * 1024)

    # program end time
    end_time = time.time()

    if peak_memory_usage_mb > 0:
        print(f"Peak Memory Usage for Process (PID {actual_process_pid}): {peak_memory_usage_mb:.2f} MB")
    else:
        print(f"Process with PID {actual_process_pid} not found.")

    # program running time
    runtime_seconds = end_time - start_time
    # cpu time
    cpu_seconds = (cpu_time_end.user - cpu_time_start.user) + (cpu_time_end.system - cpu_time_start.system)
    print(f"Process Runtime: {runtime_seconds:.2f} seconds")
    print(f"CPU Process Runtime: {cpu_seconds:.2f} seconds")

def main():
    if len(sys.argv) < 2:
        print("Usage: ./tm [command_to_run]")
        return
    command = " ".join(sys.argv[1:])
    print(f"executing command: {command}")
    run_process_and_get_peak_memory(command)

if __name__ == "__main__":
    main()