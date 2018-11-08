cmake_minimum_required (VERSION 2.8.12)

# Maps to a solution filed (*.sln). The solution will
# have all targets (exe, lib, dll) as projects (.vcproj)
project(nameLess)

# The version number.
set (Project_VERSION_MAJOR 1)
set (Project_VERSION_MINOR 0)

# Turn on the ability to create folders to organize projects (.vcproj)
# It creates "CMakePredefinedTargets" folder by default and adds CMake
# defined projects like INSTALL.vcproj and ZERO_CHECK.vcproj
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Command to output information to the console
# Useful for displaying errors, warnings, and debugging
set(CMAKE_CXX_FLAGS "-Wall -fPIC -std=c++11")
message(STATUS "Root - cxx Flags: " ${CMAKE_CXX_FLAGS})

# Handle Preprocess Flags
if (UNIX)
  add_definitions(-DUNIX)
else ()
  add_definitions(-DWINDOWS -DWIN32 "/EHsc")
endif ()

# Handle Boost libaries
if (UNIX)
  set(Boost_INCLUDE_DIR "/usr/local/boost/1.59.0/include")
  set(Boost_LIBRARY_DIR "/usr/local/boost/1.59.0/lib")
else ()
  set(Boost_INCLUDE_DIR "C:\\boost\\1.59.0")
  set(Boost_LIBRARY_DIR "C:\\boost\\1.59.0\\lib64-msvc-12.0")
endif ()
set(Boost_USE_STATIC_LIBS   ON)
find_package(Boost 1.59.0 REQUIRED
  log
  system
  filesystem
  date_time
  log_setup
  chrono
  regex
  thread
  serialization)
message(STATUS "Info - Boost library status:")
message(STATUS "Info -     version: ${Boost_VERSION}")
message(STATUS "Info -     libraries: ${Boost_LIBRARIES}")
message(STATUS "Info -     include path: ${Boost_INCLUDE_DIR}")

# Handle QT libaries
if (UNIX)
  set(QT_ROOT "/usr/local/Qt/5.6.2/5.6/gcc_64/")
else ()
  set(QT_ROOT "C:\\Qt\\5.6.2\\5.6\\msvc2013_64\\")
endif ()
set(QT_INCLUDE_DIR "${QT_ROOT}include")
set(QT_LIBRARY_DIR "${QT_ROOT}lib")
set(CMAKE_PREFIX_PATH ${QT_ROOT})
# Handle QT libraries
find_package(Qt5 REQUIRED
  Core
  Gui
  Widgets)
message(STATUS "Info - QT library status:")
message(STATUS "Info -     version: ${Qt5Widgets_VERSION}")
message(STATUS "Info -     libraries: ${Qt5Widgets_LIBRARIES} ${Qt5Core_LIBRARIES} ${Qt5Core_QTMAIN_LIBRARIES} ${Qt5Gui_LIBRARIES}")
message(STATUS "Info -     include path: ${QT_INCLUDE_DIR}")

# Handle linux libraries
if (UNIX)
  find_package(
    Threads) # include this package to fix problem 001
else ()
endif ()
message(STATUS "Info - CMAKE_THREAD_LIBS_INIT: ${CMAKE_THREAD_LIBS_INIT}")

# Handle pcap libaries
message(STATUS "Info - preparing for pcap -------------------------")
if (UNIX)
  set(libpcap_ROOT "/usr/local/libpcap/1.8.1/")
else ()
  set(libpcap_ROOT "C:\\WpdPack\\4.1.2\\")
endif ()
find_path(libpcap_INCLUDE_DIR pcap.h
  PATHS ${libpcap_ROOT}include
  DOC "Path where pcap includes can be found")
find_library(pcap_LIBRARY NAMES pcap PATH_SUFFIXES lib64 lib
  PATHS ${libpcap_ROOT}lib
  DOC "Path where the pcap library can be found")
get_filename_component(libpcap_LIBRARY_DIR "${pcap_LIBRARY}" PATH)
if (NOT EXISTS ${libpcap_LIBRARY_DIR} AND ${libpcap_INCLUDE_DIR})
    message(FATAL_ERROR "Cannot find pcap development resourse")
    return()
endif()
message(STATUS "Info - libpcap include path: ${libpcap_INCLUDE_DIR}")
message(STATUS "Info - libpcap library path: ${libpcap_LIBRARY_DIR}")

# Handle libpng libaries
message(STATUS "Info - preparing for libpng -------------------------")
if (UNIX)
  set(libpng_ROOT "/usr/local/libpng/1.6.35/")
else ()
endif ()
set(libpng_INCLUDE_DIR ${libpng_ROOT}include)
set(libpng_LIBRARY_DIR ${libpng_ROOT}lib)
message(STATUS "Info - libpng include path: ${libpng_INCLUDE_DIR}")
message(STATUS "Info - libpng library path: ${libpng_LIBRARY_DIR}")

# Handle libxml2 libaries
message(STATUS "Info - preparing for libxml2 -------------------------")
if (UNIX)
  set(libxml2_ROOT "/usr/local/libxml2/2.9.8/")
else ()
endif ()
find_path(libxml2_INCLUDE_DIR libxml/parser.h
  PATHS ${libxml2_ROOT}include/libxml2
  DOC "Path where libxml2 includes can be found")
find_library(xml2_LIBRARY NAMES xml2 PATH_SUFFIXES lib64 lib
  PATHS ${libxml2_ROOT}lib
  DOC "Path where the libxml2 library can be found")
get_filename_component(libxml2_LIBRARY_DIR "${xml2_LIBRARY}" PATH)
if ("${libxml2_LIBRARY_DIR}" STREQUAL "" OR "${libxml2_INCLUDE_DIR}" STREQUAL "")
    message(FATAL_ERROR "Cannot find xml2 development resourse")
    return()
endif()
set(libxml2_INCLUDE_DIR ${libxml2_ROOT}include/libxml2)
set(libxml2_LIBRARY_DIR ${libxml2_ROOT}lib)
message(STATUS "Info - libxml2 include path: ${libxml2_INCLUDE_DIR}")
message(STATUS "Info - libxml2 library path: ${libxml2_LIBRARY_DIR}")

# Handle jwt libaries
message(STATUS "Info - preparing for jwt -------------------------")
if (UNIX)
  set(libjwt_ROOT "/usr/local/jwt-cpp/")
else ()
endif ()
find_path(libjwt_INCLUDE_DIR jwt/jwt.h
  PATHS ${libjwt_ROOT}include
  DOC "Path where jwt includes can be found")
find_library(jwt_LIBRARY NAMES jwt PATH_SUFFIXES lib64 lib
  PATHS ${libjwt_ROOT}lib
  DOC "Path where the jwt library can be found")
get_filename_component(libjwt_LIBRARY_DIR "${jwt_LIBRARY}" PATH)
if ("${libjwt_LIBRARY_DIR}" STREQUAL "" OR "${libjwt_INCLUDE_DIR}" STREQUAL "")
    message(FATAL_ERROR "Cannot find jwt development resourse")
    return()
endif()
message(STATUS "Info - libjwt include path: ${libjwt_INCLUDE_DIR}")
message(STATUS "Info - libjwt library path: ${libjwt_LIBRARY_DIR}")

# Handle openssl libaries
message(STATUS "Info - preparing for openssl -------------------------")
if (UNIX)
  set(libopenssl_ROOT "/usr/local/openssl/1.1/")
else ()
endif ()
find_path(libopenssl_INCLUDE_DIR openssl/ssl.h
  PATHS ${libopenssl_ROOT}include
  DOC "Path where openssl includes can be found")
find_library(openssl_LIBRARY NAMES crypto ssl PATH_SUFFIXES lib64 lib
  PATHS ${libopenssl_ROOT}lib
  DOC "Path where the openssl library can be found")
get_filename_component(libopenssl_LIBRARY_DIR "${openssl_LIBRARY}" PATH)
if ("${libopenssl_LIBRARY_DIR}" STREQUAL "" OR "${libopenssl_INCLUDE_DIR}" STREQUAL "")
    message(FATAL_ERROR "Cannot find openssl development resourse")
    return()
endif()
set(libopenssl_INCLUDE_DIR ${libopenssl_ROOT}include)
set(libopenssl_LIBRARY_DIR ${libopenssl_ROOT}lib)
message(STATUS "Info - libopenssl include path: ${libopenssl_INCLUDE_DIR}")
message(STATUS "Info - libopenssl library path: ${libopenssl_LIBRARY_DIR}")

# tutorial for protobuf https://developers.google.com/protocol-buffers/docs/cpptutorial#reading-a-message
# Handle protobuf libaries
message(STATUS "Info - preparing for protobuf -------------------------")
if (UNIX)
  set(libprotobuf_ROOT "/usr/local/protobuf/3.6.0/")
else ()
endif ()
find_path(libprotobuf_INCLUDE_DIR google/protobuf/message.h
  PATHS ${libprotobuf_ROOT}include
  DOC "Path where protobuf includes can be found")
find_library(protobuf_LIBRARY NAMES protobuf protobuf-lite protoc PATH_SUFFIXES lib64 lib
  PATHS ${libprotobuf_ROOT}lib
  DOC "Path where the protobuf library can be found")
get_filename_component(libprotobuf_LIBRARY_DIR "${protobuf_LIBRARY}" PATH)
if ("${libprotobuf_LIBRARY_DIR}" STREQUAL "" OR "${libprotobuf_INCLUDE_DIR}" STREQUAL "")
    message(FATAL_ERROR "Cannot find protobuf development resourse")
    return()
endif()
set(libprotobuf_INCLUDE_DIR ${libprotobuf_ROOT}include)
set(libprotobuf_LIBRARY_DIR ${libprotobuf_ROOT}lib)
message(STATUS "Info - libprotobuf include path: ${libprotobuf_INCLUDE_DIR}")
message(STATUS "Info - libprotobuf library path: ${libprotobuf_LIBRARY_DIR}")

# Sub-directories where more CMakeLists.txt exist
# libraries
add_subdirectory(lib)
# applications
add_subdirectory(example)
add_subdirectory(app)

# build a CPack driven installer package
include (InstallRequiredSystemLibraries)
set (CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/License.txt")
set (CPACK_PACKAGE_VERSION_MAJOR "${Project_VERSION_MAJOR}")
set (CPACK_PACKAGE_VERSION_MINOR "${Project_VERSION_MINOR}")
include (CPack)

# Problem 001
#        /usr/bin/ld: ... undefined reference to symbol 'pthread_rwlock_wrlock@@GLIBC_2.2.5'
