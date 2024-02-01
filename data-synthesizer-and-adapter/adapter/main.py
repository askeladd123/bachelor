import asyncio
import websockets

MESSAGE_TO_GODOT = "get data"
PORT = 8000
ADDRESS = "localhost"

async def train_model(data): 
    print(f"training started on data: {data}")
    await asyncio.sleep(3)
    print("\tfinished training")

async def run(websocket, path):
    await websocket.send(MESSAGE_TO_GODOT)

    try:
        async for message in websocket:
            send_task = asyncio.create_task(train_model(message))
            await websocket.send(MESSAGE_TO_GODOT)
            await send_task
    except websockets.exceptions.ConnectionClosed:
        print("connection to client was closed")

def main():
    start_server = websockets.serve(run, ADDRESS, PORT)

    try:
        asyncio.get_event_loop().run_until_complete(start_server)
        asyncio.get_event_loop().run_forever()
    except KeyboardInterrupt:
        print("keyboard interrupt: shutting down server")
    finally:
        asyncio.get_event_loop().close()

if __name__ == "__main__":
    main()
