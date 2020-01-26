# octoprint_docker

Allows you to build a docker container of octoprint with webcam support. Only tested on the Raspberry Pi 4, but should work on other systems. There is an example docker-compose file to get you started.

The octopi.txt files was taken from gusoft/OctoPi, the original webcam and webcamDaemon scripts are available at:  https://community.octoprint.org/t/setting-up-octoprint-on-a-raspberry-pi-running-raspbian/2337/



To build:

Enter the project's top directory and run:
docker build -t octoprint .

After that finishes:
docker-compose up -d

To stop it:
docker-compose down
