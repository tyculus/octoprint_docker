#Start from debian buster base image, because raspbian is based on it as well
FROM debian:buster

LABEL maintainer="docker@riepenonline.de"
LABEL description="This image contains octoprint and mjpg-streamer. To be used on a Raspberry Pi."

EXPOSE 5000/tcp



# --- ROOT ACTIONS ---
USER root

#Update and upgrade, then install [nano, procps(pkill), dependancies of octoprint] and at last install [dependancies of mjpg-streamer]
RUN apt-get update && apt-get upgrade -y && apt-get install -y nano procps python2.7-minimal python-pip python-dev python-setuptools python-virtualenv git libyaml-dev build-essential && apt-get install -y subversion libjpeg62-turbo-dev imagemagick ffmpeg libv4l-dev cmake

#Build mjpg-streamer for webcams
WORKDIR /opt
RUN git clone https://github.com/jacksonliam/mjpg-streamer.git && cd ./mjpg-streamer/mjpg-streamer-experimental && export LD_LIBRARY_PATH=. && make

#Load and build zlib
WORKDIR /opt
ADD https://www.zlib.net/zlib-1.2.11.tar.gz ./zlib-1.2.11.tar.gz
RUN gzip -d zlib-1.2.11.tar.gz && tar -xf zlib-1.2.11.tar && rm zlib-1.2.11.tar && cd zlib-1.2.11 && chmod +x configure && ./configure && make && make install

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
RUN mkdir oprint && cd /home/octoprint/oprint &&  virtualenv ./venv && . ./venv/bin/activate && pip install pip --upgrade && pip install octoprint

#Add webcam scripts and add them to the config
WORKDIR /home/octoprint
COPY --chown=octoprint:octoprint ./scripts/webcam scripts/webcamDaemon  /home/octoprint/scripts/
COPY --chown=octoprint:octoprint ./config/config.yaml /home/octoprint/.octoprint/
COPY --chown=octoprint:octoprint ./config/octopi.txt /home/octoprint/
RUN chmod +x -R /home/octoprint/scripts/



# --- ENTRYPOINT ---

#Change to normal user & groups
USER octoprint

ENTRYPOINT ["/home/octoprint/oprint/venv/bin/octoprint", "serve"]

