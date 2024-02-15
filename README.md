> TOOD: provide info about session: mostly time used
> TODO: either remove build and run scripts, orchange to bash and powershell scripts instead of python, because it is time consuming to make cross platform build scrip
> TODO: change docker image to alpine linux to dratically reduce size
> TODO: adapter: exit gracefully: async event loop and SIGTERM

# bachelor
> Ask Sødal, Philip Tran

This is the code for our paper.

# run
This system consists of two programs:
- model trainer
- data synthesizer

To run it, you need to start them in that order.

## model trainer
Located in `model-trainer` folder. Requires `python 3`. Make a virtual environment and install the dependencies found in `requirements.txt`. Run through the virtual environment.

## data synthesizer
Located in `data-synthesizer` folder. Requires `godot 4.2`. Run with `godot --headless` if you don't need a window.
