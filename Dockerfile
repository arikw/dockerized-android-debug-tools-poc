FROM debian:9-slim

# This docker image is based on the following sources:
# https://github.com/random-robbie/frida-docker/blob/master/Dockerfile
# https://stackoverflow.com/a/51122958

# Set Env
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV ANDROID_HOME=/opt
ENV PATH=$ANDROID_HOME/platform-tools:$PATH

# Update OS
RUN apt-get update && apt-get upgrade -y

# Install various linux packages
RUN apt-get install -y unzip bash git nano gcc-multilib \
    lib32stdc++ zlib1g-dev lib32z1-dev python3 python3-dev \
    python3-pip git autotools-dev automake net-tools

# Install Objection & Frida
RUN pip3 install colorama prompt-toolkit pygments objection

# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=863199
RUN mkdir -p /usr/share/man/man1

# Install OpenJDK-8
RUN apt-get install -y openjdk-8-jdk ant && \
    apt-get clean;

# Fix certificate issues
RUN apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# Install APK Tool
RUN apt install -y curl apktool

# Install adb 
RUN mkdir -pm 0750 ~/.android $ANDROID_HOME 
RUN curl -fsSL https://dl.google.com/android/repository/platform-tools-latest-linux.zip -o /tmp/adb.zip
RUN unzip /tmp/adb.zip -d $ANDROID_HOME 

WORKDIR /root/

LABEL \
  org.opencontainers.image.authors="Arik Weizman" \
  org.opencontainers.image.description="Dockerized Android debugging tools: Android Debug Bridge (adb), Objection, and Frida" \
  org.opencontainers.image.licenses="MIT" \
  org.opencontainers.image.source="https://github.com/arikw/docker-compose-webhook" \
  org.opencontainers.image.title="Dockerized Android Debugging Tools"

ENTRYPOINT ["bash"]