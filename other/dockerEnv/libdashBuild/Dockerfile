# This is a comment
FROM ubuntu:12.04
RUN apt-get update
RUN apt-get install -y build-essential cmake libxml2-dev libcurl4-openssl-dev python-software-properties # software-properties-common
RUN apt-add-repository ppa:ubuntu-sdk-team/ppa
RUN apt-add-repository ppa:canonical-qt5-edgers/ubuntu1204-qt5
RUN apt-get update
RUN apt-get install -y qtmultimedia5-dev qtbase5-dev libqt5widgets5 libqt5core5 libqt5gui5 libqt5multimedia5 libqt5multimediawidgets5 libqt5opengl5 libav-tools libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libavutil-dev libpostproc-dev libswscale-dev ia32-libs openjdk-6-jdk:i386 libcanberra-gtk-module libcanberra-gtk3-module
# RUN dpkg --add-architecture i386 || true