> changes: the pipeline was heavily modified because of time constraints. Much of this is now outdated. 

> TODO: adapter: exit gracefully: async event loop and SIGTERM
> TODO: generating less base images than masks

# bachelor
> Ask Sødal, Philip Tran

This is the code for our paper. We are making a program that generates data with a game engine, and trains a machine learning model to do instance segmentation on humans in extreme positions.

# pipeline
The pipeline consists of four components:
- data synthesizer
- data synthesizer adapter or controller
- database
- model trainer

# requirements
If you chose to run with Docker, this is handled for you. Otherwise, our pipeline uses:
- python 3.11
- godot 4.2
- mongodb database

Below you will find instructions to start the individual programs. 

## database
While the pipeline supports generating images to files, we are using a database. There are several ways to setup this, but we chose to use MongoDB 7 in a Docker container. If Docker is running, you can start the database with one of the following commands: 
- first run: `docker run --name bachelor-mongodb --publish 27017:27017 --detach mongo:7`
- following runs: `docker start bachelor-mongodb`

### persistent storage
See [docker hub](https://hub.docker.com/_/mongo) if you want to keep the data between sessions.
 
## data synthesizer
This program generates images, and sends them over a websocket to data synthesizer adapter. Start: `godot --path ./data-synthesizer-and-adapter/data-synthesizer`. 

This is an example of a json document sent over the websocket:
```json
{
  "generator version": "0.0.1", 
  "host info": {
    "cpu": "AMD Ryzen 7 4700U with Radeon Graphics", 
    "distribution": "Arch Linux", 
    "gpu": ["", ""], 
    "operating system": "Linux"
  },
  "datetime started": "2024-3-1 14:53", 
  "generator mode": "viewpoint", 
  "base image png base64": "iVBORw0KGgoAAAANSUhEUgAAA60AAAQgCAIAAACCTi0AAAAAAXNSR0IA...",
  "segmentation mask png base64": "hgAgCIfDABAkQ8GAKDIBwMAUOSDAQAo8sEAABT5YAAAinwwAABFPhgAgCIfD..."
}
```

|key                         |value                                                       |
|----------------------------|------------------------------------------------------------|
|generator version           |as we better the generation, we bump up the version         |
|operating system            |example: Windows, Linux, Mac OS                             |
|distribution                |mostly relevant on Linux                                    |
|cpu                         |hardware used                                               | 
|gpu                         |hardware used                                               |
|datetime started            |when the first image in the batch started generating        |
|generator mode              |what type of image to generate: pose, occlusion or viewpoint|
|base image png base64       |encoded image trainig data                                  |
|segmentation mask png base64|encoded image target data                                   | 
  
### about generator version
When using the generator data, you want to use the newest data with best quality. Use this field. The version will be updated like this:
- 0.0.x: minor, almost unnoticeable improvements
- 0.x.0: major, highly noticeable improvements
- x.0.0: will not be used. Maybe if we have a large, breaking change

## data synthesizer adapter
This program does multiple things:
- controls data synthesizer to commands
- takes arguments for customization
- depending on arguments, it can for instance save data to a mongodb database

Move into the folder `./data-synthesizer-and-adapter/data-synthesizer`. Use `requirements.txt` to install dependencies, for example though a virtual environment. 

Example usage: `python main.py --data-points 1000 to-file --directory ./dataset`. Note that it requires data synthesizer to be running. If you use the option `to-mongo` it also needs a database. 

> TODO: connect to remote databases
 
Use `python main.py --help` to see more documentation:
```
usage: main.py [-h] [-w MS] [-m {pose,viewpoint,occlusion}] [-n DATA_POINTS] {to-output,to-mongo,to-file} ...

This program is used to put images from a websocket into a MongoDB database. Requires other program `data synthesizer`over a websocket to work.

options:
  -h, --help            show this help message and exit
  -w MS, --wait MS      Time to pause the program between iterations, in MS milisecons.
  -m {pose,viewpoint,occlusion}, --mode {pose,viewpoint,occlusion}
                        Choose which type of data to generate.
  -n DATA_POINTS, --data-points DATA_POINTS
                        Number of image pairs to generate. Reads negative values like `-1` as infinite.

subcommands:
  Where to write the images.

  {to-output,to-mongo,to-file}
```

## model trainer
> not implemented
 
# docker
While out model trainer plans to use docker, we could not run *data synthesizer* with docker, as Godot requires a graphical environment.
