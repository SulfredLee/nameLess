set(targetName "errorHandle")
get_filename_component(folderName ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE " " "_" folderName ${folderName})

file(GLOB ${folderName}_inc
  "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
file(GLOB ${folderName}_src
  "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")

include_directories(${PROJECT_SOURCE_DIR}/network
  ${libjwt_INCLUDE_DIR}
  ${libopenssl_INCLUDE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(${targetName} ${${folderName}_src})
# add_dependencies(${targetName} FrontEnd Utils)

target_link_libraries(${targetName}
  ${libjwt_LIBRARY_DIR}/libjwt.a
  ${libopenssl_LIBRARY_DIR}/libssl.so
  ${libopenssl_LIBRARY_DIR}/libcrypto.so)

# Creates a folder "executables" and adds target
# project (*.vcproj) under it
set_property(TARGET ${targetName} PROPERTY FOLDER "executables")

# Adds logic to INSTALL.vcproj to copy *.exe to destination directory
install (TARGETS ${targetName} DESTINATION bin)
# install (FILES ${${folderName}_inc} DESTINATION include)
