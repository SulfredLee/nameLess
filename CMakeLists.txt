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
  set(libpcap_INCLUDE_DIR ${libpcap_ROOT}include)
  set(libpcap_LIBRARY_DIR ${libpcap_ROOT}lib)
else ()
  set(libpcap_ROOT "C:\\WpdPack\\4.1.2\\")
endif ()
if (NOT EXISTS "${libpcap_INCLUDE_DIR}/pcap.h")
  message(FATAL_ERROR "Error - ${libpcap_INCLUDE_DIR}/pcap.h not found")
  return()
endif()
if (NOT EXISTS "${libpcap_LIBRARY_DIR}/libpcap.a")
  message(FATAL_ERROR "Error - ${libpcap_LIBRARY_DIR}/libpcap.a not found")
  return()
endif()
message(STATUS "Info - libpcap include path: ${libpcap_INCLUDE_DIR}")
message(STATUS "Info - libpcap library path: ${libpcap_LIBRARY_DIR}")

# Handle libbmp libaries
message(STATUS "Info - preparing for libbmp -------------------------")
if (UNIX)
  set(libbmp_ROOT "/usr/local/libbmp/0.1.3/")
  set(libbmp_INCLUDE_DIR ${libbmp_ROOT}include)
  set(libbmp_LIBRARY_DIR ${libbmp_ROOT}lib)
else ()
endif ()
if (NOT EXISTS "${libbmp_INCLUDE_DIR}/bmpfile.h")
  message(FATAL_ERROR "Error - ${libbmp_INCLUDE_DIR}/bmpfile.h not found")
  return()
endif()
if (NOT EXISTS "${libbmp_LIBRARY_DIR}/libbmp.a")
  message(FATAL_ERROR "Error - ${libbmp_LIBRARY_DIR}/libbmp.a not found")
  return()
endif()
message(STATUS "Info - libbmp include path: ${libbmp_INCLUDE_DIR}")
message(STATUS "Info - libbmp library path: ${libbmp_LIBRARY_DIR}")

# Handle libpng libaries
message(STATUS "Info - preparing for libpng -------------------------")
if (UNIX)
  set(libpng_ROOT "/usr/local/libpng/1.6.35/")
  set(libpng_INCLUDE_DIR ${libpng_ROOT}include)
  set(libpng_LIBRARY_DIR ${libpng_ROOT}lib)
else ()
endif ()
if (NOT EXISTS "${libpng_INCLUDE_DIR}/png.h")
  message(FATAL_ERROR "Error - ${libpng_INCLUDE_DIR}/png.h not found")
  return()
endif()
if (NOT EXISTS "${libpng_LIBRARY_DIR}/libpng16.a")
  message(FATAL_ERROR "Error - ${libpng_LIBRARY_DIR}/libpng16.a not found")
  return()
endif()
message(STATUS "Info - libpng include path: ${libpng_INCLUDE_DIR}")
message(STATUS "Info - libpng library path: ${libpng_LIBRARY_DIR}")

# Handle libxml2 libaries
message(STATUS "Info - preparing for libxml2 -------------------------")
if (UNIX)
  set(libxml2_ROOT "/usr/local/libxml2/2.9.8/")
  set(libxml2_INCLUDE_DIR ${libxml2_ROOT}include/libxml2)
  set(libxml2_LIBRARY_DIR ${libxml2_ROOT}lib)
else ()
endif ()
if (NOT EXISTS "${libxml2_INCLUDE_DIR}/libxml/uri.h")
  message(FATAL_ERROR "Error - ${libxml2_INCLUDE_DIR}/uri.h not found")
  return()
endif()
if (NOT EXISTS "${libxml2_LIBRARY_DIR}/libxml2.a")
  message(FATAL_ERROR "Error - ${libxml2_LIBRARY_DIR}/libxml2.a not found")
  return()
endif()
message(STATUS "Info - libxml2 include path: ${libxml2_INCLUDE_DIR}")
message(STATUS "Info - libxml2 library path: ${libxml2_LIBRARY_DIR}")

# Handle jwt libaries
message(STATUS "Info - preparing for jwt -------------------------")
if (UNIX)
  set(libjwt_ROOT "/usr/local/jwt-cpp/")
  set(libjwt_INCLUDE_DIR ${libjwt_ROOT}include)
  set(libjwt_LIBRARY_DIR ${libjwt_ROOT}lib)
else ()
endif ()
if (NOT EXISTS "${libjwt_INCLUDE_DIR}/jwt/jwt.h")
  message(FATAL_ERROR "Error - ${libjwt_INCLUDE_DIR}/jwt/jwt.h not found")
  return()
endif()
if (NOT EXISTS "${libjwt_LIBRARY_DIR}/libjwt.a")
  message(FATAL_ERROR "Error - ${libjwt_LIBRARY_DIR}/libjwt.a not found")
  return()
endif()
message(STATUS "Info - libjwt include path: ${libjwt_INCLUDE_DIR}")
message(STATUS "Info - libjwt library path: ${libjwt_LIBRARY_DIR}")

# Handle openssl libaries
message(STATUS "Info - preparing for openssl -------------------------")
if (UNIX)
  set(libopenssl_ROOT "/usr/local/openssl/1.1/")
  set(libopenssl_INCLUDE_DIR ${libopenssl_ROOT}include)
  set(libopenssl_LIBRARY_DIR ${libopenssl_ROOT}lib)
else ()
endif ()
if (NOT EXISTS "${libopenssl_INCLUDE_DIR}/openssl/ssl.h")
  message(FATAL_ERROR "Error - ${libopenssl_INCLUDE_DIR}/openssl/ssl.h not found")
  return()
endif()
if (NOT EXISTS "${libopenssl_LIBRARY_DIR}/libssl.a")
  message(FATAL_ERROR "Error - ${libopenssl_LIBRARY_DIR}/libssl.a not found")
  return()
endif()
message(STATUS "Info - libopenssl include path: ${libopenssl_INCLUDE_DIR}")
message(STATUS "Info - libopenssl library path: ${libopenssl_LIBRARY_DIR}")

# tutorial for protobuf https://developers.google.com/protocol-buffers/docs/cpptutorial#reading-a-message
# Handle protobuf libaries
message(STATUS "Info - preparing for protobuf -------------------------")
if (UNIX)
  set(libprotobuf_ROOT "/usr/local/protobuf/3.6.0/")
  set(libprotobuf_INCLUDE_DIR ${libprotobuf_ROOT}include)
  set(libprotobuf_LIBRARY_DIR ${libprotobuf_ROOT}lib)
else ()
endif ()
if (NOT EXISTS "${libprotobuf_INCLUDE_DIR}/google/protobuf/message.h")
  message(FATAL_ERROR "Error - ${libprotobuf_INCLUDE_DIR}/google/protobuf/message.h not found")
  return()
endif()
if (NOT EXISTS "${libprotobuf_LIBRARY_DIR}/libprotobuf.a")
  message(FATAL_ERROR "Error - ${libprotobuf_LIBRARY_DIR}/libprotobuf.a not found")
  return()
endif()
message(STATUS "Info - libprotobuf include path: ${libprotobuf_INCLUDE_DIR}")
message(STATUS "Info - libprotobuf library path: ${libprotobuf_LIBRARY_DIR}")

# Handle curl libaries
message(STATUS "Info - preparing for libcurl -------------------------")
if (UNIX)
  set(libcurl_ROOT "/usr/local/libcurl/7.63.0/")
  set(libcurl_INCLUDE_DIR ${libcurl_ROOT}include)
  set(libcurl_LIBRARY_DIR ${libcurl_ROOT}lib)
else ()
endif ()
if (NOT EXISTS "${libcurl_INCLUDE_DIR}/curl/curl.h")
  message(FATAL_ERROR "Error - ${libcurl_INCLUDE_DIR}/curl/curl.h not found")
  return()
endif()
if (NOT EXISTS "${libcurl_LIBRARY_DIR}/libcurl.a")
  message(FATAL_ERROR "Error - ${libcurl_LIBRARY_DIR}/libcurl.a not found")
  return()
endif()
message(STATUS "Info - libcurl include path: ${libcurl_INCLUDE_DIR}")
message(STATUS "Info - libcurl library path: ${libcurl_LIBRARY_DIR}")

# Handle dash libaries
message(STATUS "Info - preparing for libdash -------------------------")
if (UNIX)
  set(libdash_ROOT "/usr/local/libdash/master/")
  set(libdash_INCLUDE_DIR ${libdash_ROOT}include)
  set(libdash_LIBRARY_DIR ${libdash_ROOT}lib)
else ()
endif ()
if (NOT EXISTS "${libdash_INCLUDE_DIR}/IMPD.h")
  message(FATAL_ERROR "Error - ${libdash_INCLUDE_DIR}/IMPD.h not found")
  return()
endif()
if (NOT EXISTS "${libdash_LIBRARY_DIR}/libdash.so")
  message(FATAL_ERROR "Error - ${libdash_LIBRARY_DIR}/libdash.so not found")
  return()
endif()
message(STATUS "Info - libdash include path: ${libdash_INCLUDE_DIR}")
message(STATUS "Info - libdash library path: ${libdash_LIBRARY_DIR}")

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
