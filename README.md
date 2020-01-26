# octoprint_docker

Allows you to build a docker container of octoprint with webcam support. Only tested on the Raspberry Pi 4, but should work on other systems. A reverse proxy is not included, therefore you should NOT expose this to the internet as-is. It is not possible to reboot the pi/server from within octoprint.

There is an example docker-compose file to get you started. Your printer is expected at port "/dev/ttyUSB0" and your camera as a raspberry pi camera. Your files and settings will be stored in a docker volume and are therefore persistent. It will automatically start after a reboot.

The octopi.txt files was taken from gusoft/OctoPi, the original webcam and webcamDaemon scripts are available at:  https://community.octoprint.org/t/setting-up-octoprint-on-a-raspberry-pi-running-raspbian/2337/



**To build:**
Enter the project's top directory and run:
docker build -t octoprint .

**To use it:**

- Start:
docker-compose up -d
- Stop:
docker-compose down

- Click on the "Power" button in OctoPrint's top bar, then select "Start video screen" to enable the webcam

**What's left to configure?**
- exchange "container_address" in the webcam config for your server's address/ip
- add your printer, plugins, etc.

**Problem solving**

*Webcam does not work*

- Are you using a pi camera? If not, run:
"docker exec -ti octoprint bash"
to get access to a terminal in your container (here called "octoprint"). You can then edit octopi.txt, the scripts and everything else with nano. Check wether the camera is available at "/dev/video0". If not, edit "docker-compose.yml" (see below)

*Can not find printer*

- Edit docker-compose.yml and change "/dev/ttyUSB0" to your printer's device.

*Known issues*

- "octopi.txt" does not seem to have any effect.
