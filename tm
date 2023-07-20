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
    
def get_peak_memory_usage(pid):
    # 与前面示例相同，获取峰值内存使用量的函数
    # ...
    try:
        process = psutil.Process(pid)

        # 获取进程的内存信息
        mem_info = process.memory_info()
        peak_memory = mem_info.peak_wset  # 获取峰值常驻内存使用量

        # 转换为MB单位
        peak_memory_mb = peak_memory / (1024 * 1024)

        return peak_memory_mb

    except psutil.NoSuchProcess:
        return None
    

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
    # 启动新进程并记录开始时间
    start_time = time.time()

    process = subprocess.Popen(command, shell=True)
    
    # 获取进程的PID
    # actual_process_pid = get_subprocess_actual_pid(process.pid)

    # infer
    actual_process_pid = process.pid + 1
    time.sleep(5)

    actual_process = psutil.Process(actual_process_pid)

    print(f"PID: {actual_process_pid}")

    cpu_time_start = actual_process.cpu_times()

    # 初始化最大内存使用量为0
    max_memory_usage = 0

    while process.poll() is None:
        # 每隔0.1秒获取一次内存使用情况，并记录最大值
        memory_usage = get_memory_usage(actual_process_pid)
        if memory_usage is not None and memory_usage > max_memory_usage:
            max_memory_usage = memory_usage
        time.sleep(0.1)
        try:
            cpu_time_end = actual_process.cpu_times()
        except psutil.NoSuchProcess:
            pass

    # 获取最终的峰值内存使用情况
    peak_memory_usage_mb = max_memory_usage / (1024 * 1024)

    # 记录结束时间
    end_time = time.time()

    if peak_memory_usage_mb > 0:
        print(f"Peak Memory Usage for Process (PID {actual_process_pid}): {peak_memory_usage_mb:.2f} MB")
    else:
        print(f"Process with PID {actual_process_pid} not found.")

    # 输出运行时间
    runtime_seconds = end_time - start_time
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
    # 请替换command为你要执行的实际命令
    # ...
    main()