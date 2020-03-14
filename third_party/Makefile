apps=boost
apps+=opencv
apps+=cscope
apps+=global
apps+=libpcap
apps+=emacs
apps+=qt
apps+=OpenCC
apps+=openssl
apps+=jwt-cpp
apps+=ninja
apps+=ycmd
apps+=spacemacs
apps+=libjson
apps+=protobuf
apps+=libxml2
apps+=libpng
apps+=libbmp
apps+=ninja
apps+=apt-file
apps+=libcurl
apps+=libdash

all: apps

libdash: .libdash

libcurl: .libcurl

libpcap: .libpcap

apt-file: .apt-file

ninja: .ninja

libbmp: .libbmp

libpng: .libpng

libxml2: .libxml2

boost: .boost

libjson: .libjson

opencv: .opencv

cscope: .cscope

OpenCC: .OpenCC

emacs: .emacs

ycmd: .ycmd

spacemacs: global cscope emacs .spacemacs

global: .global

ninja: .ninja

protobuf: .protobuf

qt: .qt

jwt-cpp: openssl .jwt-cpp

openssl: .openssl

.boost:
	sudo apt-get install build-essential cmake git
	tar zxf boost_1_59_0.tar.gz
	sudo mkdir -p /usr/local/boost/1.59.0
	cd boost_1_59_0; \
	./bootstrap.sh --prefix=/usr/local/boost/1.59.0; \
	./b2 -j 4; \
	sudo ./b2 install;
	touch $@

.opencv:
	sudo apt-get install build-essential cmake git
	sudo apt-get install libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
	sudo apt-get install python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev
	mkdir opencv/release
	sudo mkdir -p /usr/local/opencv/2.8
	cd release; \
	cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX:PATH=/usr/local/opencv/2.8 ..; \
	make j -4; \
	sudo make install;
	touch $@

.cscope:
	if [ ! -e cscope-15.8b.tar.gz ]; \
	then \
		wget https://nchc.dl.sourceforge.net/project/cscope/cscope/15.8b/cscope-15.8b.tar.gz; \
	fi;
	tar zxf cscope-15.8b.tar.gz
	sudo mkdir -p /usr/local/cscope/15.8b
	cd cscope-15.8b; \
	./configure --prefix=/usr/local/cscope/15.8b; \
	make -j 4; \
	sudo make install;
	echo "export PATH=/usr/local/cscope/15.8b/bin:\$$PATH" >> ~/.bashrc
	touch $@

.OpenCC:
	git clone https://github.com/BYVoid/OpenCC.git
	mkdir OpenCC/release
	sudo mkdir -p /usr/local/OpenCC
	cd OpenCC/release; \
	cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local/OpenCC ..; \
	make -j 4; \
	sudo make install;
	echo "export PATH=/usr/local/OpenCC/bin:\$$PATH" >> ~/.bashrc
	touch $@

.ycmd:
	sudo apt-get install build-essential cmake python-dev git
	git clone https://github.com/Valloric/ycmd.git
	cd ycmd; \
	git submodule update --init --recursive; \
	./build.py --clang-completer;
	touch $@

# start emacs to complete the installation, view the steps from https://sulfredlee.blogspot.com/2018/06/spacemacs-as-c-ide.html
.spacemacs:
	git clone https://github.com/syl20bnr/spacemacs.git ~/.emacs.d
	sudo apt-get install meld
	source ~/.bashrc
	emacs --insecure
	meld ../other/VIMConfig/spacemacs ~/.spacemacs # update the config

.global:
	sudo apt-get install libncurses5-dev
	if [ ! -e global-6.6.2.tar.gz ]; \
	then \
		wget https://ftp.gnu.org/pub/gnu/global/global-6.6.2.tar.gz; \
	fi;
	tar zxf global-6.6.2.tar.gz
	sudo mkdir -p /usr/local/global/6.6.2
	cd global-6.6.2; \
	./configure --prefix=/usr/local/global/6.6.2; \
	make -j 4; \
	sudo make install;
	echo "export PATH=/usr/local/global/6.6.2/bin:\$$PATH" >> ~/.bashrc
	touch $@

# If you fail when sudo apt-get build-dep emacs24, you may install it by aptitude
# sudo apt-get install aptitude
# sudo aptitude build-dep emacs24
.emacs:
	if [ ! -e emacs-26.3.tar.gz ]; \
	then \
		wget https://ftp.gnu.org/gnu/emacs/emacs-26.3.tar.gz; \
	fi;
	tar zxf emacs-26.3.tar.gz
	sudo apt-get build-dep emacs25
	sudo mkdir -p /usr/local/emacs/26.3
	cd emacs-26.3; \
	./configure --prefix=/usr/local/emacs/26.3; \
	make -j 4; \
	sudo make install;
	echo "export PATH=/usr/local/emacs/26.3/bin:\$$PATH" >> ~/.bashrc
	touch $@

.ninja:
	git clone https://github.com/ninja-build/ninja.git
	cd ninja; \
	./configure.py --bootstrap; \
	sudo cp ninja /usr/bin;
	touch $@

.libpcap:
	sudo apt-get install flex bison
	wget http://www.tcpdump.org/release/libpcap-1.8.1.tar.gz
	tar zxf libpcap-1.8.1.tar.gz
	sudo mkdir -p /usr/local/libpcap/1.8.1
	cd libpcap-1.8.1; \
	./configure --prefix=/usr/local/libpcap/1.8.1; \
	make -j 4; \
	sudo make install;
	touch $@

.qt:
	sudo mkdir -p /usr/local/Qt/5.6.2
	sudo qt-opensource-linux-x64-5.6.2.run # follow GUI
	touch $@

.openssl:
	sudo apt-get install build-essential cmake git
	git clone https://github.com/openssl/openssl.git
	sudo mkdir -p /usr/local/openssl/1.1
	cd openssl; \
	./config --prefix=/usr/local/openssl/1.1; \
	make -j 4; \
	sudo make install;
	touch $@

.jwt-cpp:
	sudo apt-get install build-essential cmake git
	git clone https://github.com/pokowaka/jwt-cpp.git
	mkdir jwt-cpp/release
	sudo mkdir -p /usr/local/jwt-cpp
	cd jwt-cpp/release; \
	cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX:PATH=/usr/local/jwt-cpp\
				-D OPENSSL_INCLUDE_DIRS:PATH=/usr/local/openssl/1.1/include\
				-D OPENSSL_LIBRARY_DIRS:PATH=/usr/local/openssl/1.1/lib\
				-D OPENSSL_LIBRARIES:STRING="/usr/local/openssl/1.1/lib/libcrypto.so.1.1;/usr/local/openssl/1.1/lib/libssl.so.1.1"\
				..; \
	make -j 4; \
	sudo make install;
	touch $@

.libjson:
	git clone https://github.com/vincenthz/libjson.git
	sudo mkdir -p /usr/local/libjson/1.0.0/bin
	sudo mkdir -p /usr/local/libjson/1.0.0/lib
	sudo mkdir -p /usr/local/libjson/1.0.0/include
	cd libjson; \
	make -j 4; \
	sudo cp jsonlint /usr/local/libjson/1.0.0/bin; \
	sudo cp libjson.a libjson.so* /usr/local/libjson/1.0.0/lib; \
	sudo cp json.h /usr/local/libjson/1.0.0/include;
	touch $@

.protobuf:
	git clone https://github.com/google/protobuf.git
	sudo mkdir -p /usr/local/protobuf/3.6.0
	cd protobuf; \
	./autogen.sh; \
	./configure --prefix=/usr/local/protobuf/3.6.0; \
	make -j 8; \
	sudo make install;
	touch $@

.libxml2:
	wget ftp://xmlsoft.org/libxml2/libxml2-2.9.8.tar.gz
	tar zxf libxml2-2.9.8.tar.gz
	sudo mkdir -p /usr/local/libxml2/2.9.8
	cd libxml2-2.9.8; \
	./configure --prefix=/usr/local/libxml2/2.9.8; \
	make -j 8; \
	sudo make install;
	touch $@

.libpng:
	tar zxf libpng-1.6.35.tar.gz
	sudo mkdir -p /usr/local/libpng/1.6.35
	cd libpng-1.6.35; \
	./configure --prefix=/usr/local/libpng/1.6.35; \
	make -j 8; \
	sudo make install;
	touch $@

.libbmp:
	tar zxf libbmp-0.1.3.tar.gz
	sudo mkdir -p /usr/local/libbmp/0.1.3
	cd libbmp-0.1.3; \
	./configure --prefix=/usr/local/libbmp/0.1.3; \
	make -j 8; \
	sudo make install;
	touch $@

.ninja:
	git clone https://github.com/ninja-build/ninja.git
	cd ninja; \
	./configure.py --bootstrap; \
	sudo cp ninja /usr/bin;

# usage: after update, you can search your file by apt-file search "gl.h"
.apt-file:
	sudo apt-get install apt-file
	apt-file update

.libcurl:
	wget https://curl.haxx.se/download/curl-7.63.0.tar.gz
	sudo mkdir -p /usr/local/libcurl/7.63.0
	tar zxf curl-7.63.0.tar.gz
	cd curl-7.63.0; \
	./configure --prefix=/usr/local/libcurl/7.63.0; \
	make -j 8; \
	sudo make install;
	touch $@

.libdash:
	sudo apt-get install libxml2-dev libcurl4-openssl-dev
	git clone https://github.com/bitmovin/libdash.git
	sudo mkdir -p /usr/local/libdash/master/bin
	sudo mkdir -p /usr/local/libdash/master/include
	sudo mkdir -p /usr/local/libdash/master/lib
	cd libdash/libdash; \
	mkdir build; \
	cd build; \
	cmake .. -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local/libdash/master; \
	ninja;
	cd libdash/libdash; \
	sudo cp libdash/include/* /usr/local/libdash/master/include; \
	sudo cp build/bin/libdash_networkpart_test /usr/local/libdash/master/bin; \
	sudo cp build/bin/libdash.so /usr/local/libdash/master/lib;
