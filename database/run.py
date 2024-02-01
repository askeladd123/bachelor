import subprocess
import sys

def run_command(command):
    try:
        output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT)
        return output.decode('utf-8')
    except subprocess.CalledProcessError as e:
        print("Error executing command:", e.output.decode('utf-8'))
        sys.exit(1)

def main():
    container_name = "my-mongo"
    port = "27017"

    # Check if the container already exists
    existing_containers = run_command(f"docker ps -a --format '{{{{.Names}}}}'")
    if container_name in existing_containers:
        print(f"Container '{container_name}' already exists. Starting the container...")
        run_command(f"docker start {container_name}")
    else:
        print(f"Creating and starting container '{container_name}'...")
        run_command(f"docker run --name {container_name} -v my-mongo-data:/data/db -p {port}:{port} -d mongo")

    print("MongoDB container is up and running.")

if __name__ == "__main__":
    main()
