# import asyncio
# import websockets
# import motor.motor_asyncio
import argparse
# from pymongo.errors import ConnectionFailure

# MESSAGE_TO_GODOT = "get data"
# PORT = 8000
# ADDRESS = "localhost"
# MONGO_DETAILS = "mongodb://localhost:27017"

# client = motor.motor_asyncio.AsyncIOMotorClient(MONGO_DETAILS)

# async def check_mongodb_connection():
#     try:
#         # Ping the MongoDB server
#         await client.admin.command('ping')
#         print("Successfully connected to MongoDB.")
#         return True
#     except ConnectionFailure:
#         print("Failed to connect to MongoDB. Please ensure MongoDB is running.")
#         return False

# async def train_model(data, collection):
#     print(f"training started on data: {data}")
#     await asyncio.sleep(3)  # Simulated training time
#     await collection.insert_one({"data": data})
#     print("\tfinished training and data inserted into MongoDB")

# async def run(websocket, path, collection):
#     await websocket.send(MESSAGE_TO_GODOT)

#     try:
#         async for message in websocket:
#             send_task = asyncio.create_task(train_model(message, collection))
#             await websocket.send(MESSAGE_TO_GODOT)  # Send a message back to the client
#             await send_task
#     except websockets.exceptions.ConnectionClosed:
#         print("Connection to client was closed")

# async def main():
#     is_mongodb_connected = await check_mongodb_connection()
#     if not is_mongodb_connected:
#         return  # Exit if MongoDB is not running

#     DATABASE_NAME = "your_database"
#     COLLECTION_NAME = "your_collection"
#     db = client[DATABASE_NAME]
#     collection = db[COLLECTION_NAME]

#     async with websockets.serve(lambda ws, path: run(ws, path, collection), ADDRESS, PORT):
#         print(f"WebSocket server started at ws://{ADDRESS}:{PORT}. Waiting for clients...")
#         await asyncio.Future()  # Run forever


def parse_args():
    parser = argparse.ArgumentParser(description='This program is used to put images from a websocket into a MongoDB database.')
    parser.add_argument('-d', '--display', action='store_false', help='Open a window with received images.')
    subparsers = parser.add_subparsers(dest='image location', required=True, description='Where to write the images. ')
    to_nothing = subparsers.add_parser('to-nothing') 
    to_mongo = subparsers.add_parser('to-mongo')
    to_file = subparsers.add_parser('to-file')
    
    # parser.add_argument('-m', '--mode', choices=['pose', 'viewport', 'occlusion'], default='', type=str, help='Choose which type of data to generate.')
    # parser.add_argument('-n', '--data-points', help='Number of data points', default='', type=str)
    return parser.parse_args()  

if __name__ == "__main__":
    args = parse_args()
    # asyncio.run(main())
