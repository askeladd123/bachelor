from pymongo.errors import ConnectionFailure
import motor.motor_asyncio
import websockets
import threading
import argparse
import asyncio
import base64
import time
import json
import uuid
import os

MONGO_DETAILS = 'mongodb://localhost:27017'
MESSAGE_TO_GODOT = "get data"
ADDRESS = "localhost"
PORT = 8000
KEY_BASE_IMG = 'base image png base64'
KEY_SEG_MASK = 'segmentation mask png base64'

CMD_STOP = 0
CMD_GEN_POSE_MODE = 1
CMD_GEN_VIEWPOINT_MODE = 2
CMD_GEN_OCCLUSION_MODE = 3
adapter_commands = {CMD_STOP: 'stop', CMD_GEN_POSE_MODE: 'gen pose mode', CMD_GEN_VIEWPOINT_MODE:'gen viewpoint mode', CMD_GEN_OCCLUSION_MODE: 'gen occlusion mode'}

program_start_time = time.time()
   
def parse_args():
    parser = argparse.ArgumentParser(description='This program is used to put images from a websocket into a MongoDB database. Requires other program `data synthesizer`over a websocket to work.')
    parser.add_argument('-w', '--wait', action='store', type=float, metavar='MS', default=0.0,  help='Time to pause the program between iterations, in MS milisecons. ')  

    def to_mode(value):
        if value == 'pose':
            return CMD_GEN_POSE_MODE
        elif value == 'viewpoint':
            return CMD_GEN_VIEWPOINT_MODE
        elif value == 'occlusion':
            return CMD_GEN_OCCLUSION_MODE
        else:
            raise argparse.ArgumentTypeError(f'The value passed `{value}` is not a valid mode.')
            
    parser.add_argument('-m', '--mode', choices=['pose', 'viewpoint', 'occlusion'], default='viewpoint', type=to_mode, help='Choose which type of data to generate.')
    parser.add_argument('-n', '--data-points', help='Number of image pairs to generate. Reads negative values like `-1` as infinite.', default=-1, type=int) 
    subparsers = parser.add_subparsers(dest='image_location', required=True, description='Where to write the images. ')
    to_output = subparsers.add_parser('to-output') 
    to_output.add_argument('-b', '--hide-binary', action='store_true', help='Skips the content that are not human readable.') 
    to_mongo = subparsers.add_parser('to-mongo')
    to_file = subparsers.add_parser('to-file')

    def to_directory(path):
        if not os.path.isdir(path):
            raise argparse.ArgumentTypeError(f'The value passed `{path}` is not a valid directory.')
        return path 
    to_file.add_argument('-d', '--directory', type=to_directory, default='.',help='Folder to save images.')

    return parser.parse_args()
 
async def main():
    args = parse_args()

    if args.image_location == 'to-output':
        async def handle_data(message):
            json_data = json.loads(message)
            if args.hide_binary:
                del json_data[KEY_BASE_IMG]
                del json_data[KEY_SEG_MASK]
            print(json_data)

    elif args.image_location == 'to-file':
        async def handle_data(message): 
            json_data = json.loads(message) 
            id = uuid.uuid4()
            
            with open(os.path.join(args.directory, f'{id}-base-image.png'), 'wb') as file:
                image = base64.b64decode(json_data[KEY_BASE_IMG])
                file.write(image)

            with open(os.path.join(args.directory, f'{id}-segmentation-mask.png'), 'wb') as file:
                image = base64.b64decode(json_data[KEY_SEG_MASK])
                file.write(image)

    elif args.image_location == 'to-mongo': 
        client = motor.motor_asyncio.AsyncIOMotorClient(MONGO_DETAILS)

        DATABASE_NAME = "bachelor"
        COLLECTION_NAME = "generated dataset"
        db = client[DATABASE_NAME]
        collection = db[COLLECTION_NAME]

        try:
            await client.admin.command('ping')
            print('Successfully connected to MongoDB.')

        except ConnectionFailure:
            exit('Failed to connect to MongoDB. Please ensure MongoDB is running.')

        async def handle_data(message): 
            json_data = json.loads(message)
            json_data[KEY_BASE_IMG] = base64.b64decode(json_data[KEY_BASE_IMG])
            json_data[KEY_SEG_MASK] = base64.b64decode(json_data[KEY_SEG_MASK])
            await collection.insert_one(json_data) 

    else:
        exit('Unrecognised or unimplemented command.')

    async def run(websocket, path): 
        if args.image_location == 'to-output':
            print('Client connected. Priting received content.')

        if args.image_location == 'to-file':
            print(f'Client connected. Saving received content to folder `{args.directory}`.')

        if args.image_location == 'to-mongo':
            print('Client connected. Sending received content to MongoDB database.')

        await websocket.send(adapter_commands[args.mode])

        counter = args.data_points

        try:
            async for message in websocket:
                if counter == 0:
                    total_time = time.time() - program_start_time    
                    hours, remainder = divmod(total_time, 3600)
                    minutes, seconds = divmod(remainder, 60)

                    h = 'hour' if hours == 1 else 'hours'
                    m = 'minute' if minutes == 1 else 'minutes'
                    s = 'second' if seconds == 1 else 'seconds'
                    print(f'Finished. Generated {args.data_points} data points in {int(hours)} {h}, {int(minutes)} {m} and {int(seconds)} {s}.')  

                    print('Shutting down, sending stop command to `data synthesizer`.')
                    await websocket.send(adapter_commands[CMD_STOP]) 
                    exit()
                    
                save_task = asyncio.create_task(handle_data(message))
                await websocket.send(adapter_commands[args.mode]) 
                await save_task

                counter -= 1
                
                if 0.0 < args.wait:
                    await asyncio.sleep(args.wait) 

        except websockets.exceptions.ConnectionClosed:
            print('Connection to client was closed.')

    async with websockets.serve(lambda ws, path: run(ws, path), ADDRESS, PORT):
        print(f'WebSocket server started at ws://{ADDRESS}:{PORT}. Waiting for clients.')
        await asyncio.Future() 

if __name__ == "__main__":
    asyncio.run(main())
