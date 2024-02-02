import subprocess
import os
import threading
import argparse
from time import sleep

def parse_args():
    parser = argparse.ArgumentParser(description='Generates 3d images and segmentation masks of humans. Requires running MongoDB database.')
    parser.add_argument('-m', '--mode', choices=['pose', 'viewport', 'occlusion'], default='', type=str, help='Choose which type of data to generate.')
    parser.add_argument('-n', '--data-points', help='Number of data points', default='', type=str)
    return parser.parse_args()

def run_godot_headless():
    script_dir = os.path.dirname(os.path.realpath(__file__))
    godot = os.path.join(script_dir, 'data-synthesizer')
    command = ['godot', '--headless', '--path', godot]
    subprocess.run(command, cwd=godot)

def run_adapter():
    # FIXME: run script with venv to get dependencies
    script_dir = os.path.dirname(os.path.realpath(__file__))
    adapter = os.path.join(script_dir, 'adapter', 'main.py')
    command = ['python', adapter]
    subprocess.run(command, cwd=os.path.dirname(adapter))

if __name__ == '__main__':

    # TODO: is database running?
    
    args = parse_args()
    
    adapter_thread = threading.Thread(target=run_adapter)
    godot_thread = threading.Thread(target=run_godot_headless)
    
    adapter_thread.start()
    sleep(1) 
    godot_thread.start()

    godot_thread.join()
    adapter_thread.join()

