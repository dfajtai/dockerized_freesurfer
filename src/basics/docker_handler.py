import docker
import time

class FreeSurfer:
    def __init__(self, image_name="freesurfer/freesurfer:7.4.1", source_dir="/path/to/source/directory", target_dir="/mnt",
                 license_path = "/path/to/license.txt"):
        self.image_name = image_name
        self.source_dir = source_dir
        self.target_dir = target_dir
        self.license_path = license_path
        self.container = None

    def start(self):
        # Create a Docker client
        client = docker.from_env()

        # Create a container
        self.container = client.containers.run(
            self.image_name,
            name="freesurfer_container",
            detach=True,
            volumes={
                self.source_dir: {
                    "bind": self.target_dir,
                    "mode": "rw"
                },
                self.license_path: {"bind": "/usr/local/freesurfer/.license", "mode": "ro"}
            },
            working_dir=self.target_dir,
            command="bash -c 'source /usr/local/freesurfer/SetUpFreeSurfer.sh && tail -f /dev/null'",
            # command="tail -f /dev/null",
            # command="/bin/sh -c 'while true; do sleep 1; done'",
            healthcheck=None
        )

        self.wait_for_container()
    
    
    def wait_for_container(self):
        client = docker.from_env()
        max_attempts = 10
        attempt = 0

        while attempt < max_attempts:
            try:
                container = client.containers.get(self.container.id)
                print(f"Attempt {attempt + 1}: Container status - {container.status}")

                if container.status == "running":
                    print("Container is running!")
                    self.container = container  # Update reference
                    return
                elif container.status == "exited":
                    print("Container exited unexpectedly. Check logs:")
                    print(container.logs().decode('utf-8'))
                    return
                else:
                    print("Waiting for container to start...")

            except docker.errors.NotFound:
                print("Container not found. Retrying...")

            time.sleep(1)
            attempt += 1

        print("Timeout: Container did not start within the expected time.")
    
    def stop(self):
        if self.container:
            self.container.stop()
            self.container.remove()
            print("FreeSurfer container stopped and removed.")
        else:
            print("No container running.")

    def execute_command(self, command):
        if self.container and self.container.status == 'running':
            exec_result = self.container.exec_run(
                f"bash -c 'source /usr/local/freesurfer/SetUpFreeSurfer.sh && {command}'",
                stdout=True, stderr=True
            )
            print(f"Command '{command}' executed. Output:")
            print(exec_result.output.decode('utf-8'))
            return exec_result.output.decode('utf-8')
        else:
            print("Container is not running. Please start it first.")
            return None

    def copy_result(self, source_path, destination_path):
        if self.container:
            # Copy file from container to host
            bits, stat = self.container.get_archive(source_path)
            with open(destination_path, 'wb') as f:
                for chunk in bits:
                    f.write(chunk)
            print(f"File copied from '{source_path}' to '{destination_path}'.")
        else:
            print("No container running. Please start it first.")

