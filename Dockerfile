#Start from debian buster base image, because raspbian is based on it as well
FROM debian:buster

LABEL maintainer="docker@riepenonline.de"
LABEL description="This image contains octoprint and mjpg-streamer. To be used on a Raspberry Pi."

EXPOSE 5000/tcp



# --- ROOT ACTIONS ---
USER root

#Update and upgrade
RUN apt-get update && apt-get upgrade -y
#install nano, procps(pkill) and dependancies of octoprint
RUN apt-get install -y nano procps python2.7-minimal python-pip python-dev python-setuptools python-virtualenv git libyaml-dev build-essential
#install dependancies of mjpg-streamer
RUN apt-get install -y subversion libjpeg62-turbo-dev imagemagick ffmpeg libv4l-dev cmake

#Build mjpg-streamer for webcams
WORKDIR /opt
RUN git clone https://github.com/jacksonliam/mjpg-streamer.git
WORKDIR ./mjpg-streamer/mjpg-streamer-experimental
RUN export LD_LIBRARY_PATH=. && make

#Minor cleanup at this point
RUN apt-get purge -y cmake subversion && apt-get autoremove -y && apt-get clean -y


#Create user and add to groups
RUN useradd -ms /bin/bash octoprint
#RUN groupadd -g 44 video && groupadd -g 20 dialout
RUN usermod -aG video,dialout octoprint




# --- USER ACTIONS ---
USER octoprint:octoprint

#Create octoprint directory and python environment, therein install pip and octoprint
WORKDIR /home/octoprint
RUN mkdir oprint
WORKDIR /home/octoprint/oprint
RUN virtualenv ./venv
RUN . ./venv/bin/activate && pip install pip --upgrade
RUN . ./venv/bin/activate && pip install octoprint

#Add webcam scripts and add them to the config
WORKDIR /home/octoprint
COPY --chown=octoprint:octoprint ./scripts/webcam scripts/webcamDaemon  /home/octoprint/scripts/
COPY --chown=octoprint:octoprint ./config.yaml /home/octoprint/.octoprint/
COPY --chown=octoprint:octoprint ./octopi.txt /home/octoprint
RUN chmod +x -R /home/octoprint/scripts/



# --- ENTRYPOINT ---

#Change to normal user & groups
USER octoprint

ENTRYPOINT ["/home/octoprint/oprint/venv/bin/octoprint", "serve"]

