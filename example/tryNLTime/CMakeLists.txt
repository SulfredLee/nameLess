set(targetName "tryNLTime")
get_filename_component(folderName ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE " " "_" folderName ${folderName})

file(GLOB ${folderName}_inc
  "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
file(GLOB ${folderName}_src
  "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")

include_directories(
  ${PROJECT_SOURCE_DIR}/lib/utility
  ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(${targetName} ${${folderName}_src})
# add_dependencies(${targetName} FrontEnd Utils)

target_link_libraries(${targetName}
  utility)

# Creates a folder "executables" and adds target
# project (*.vcproj) under it
set_property(TARGET ${targetName} PROPERTY FOLDER "executables")

# Adds logic to INSTALL.vcproj to copy *.exe to destination directory
install (TARGETS ${targetName} DESTINATION bin)
# install (FILES ${${folderName}_inc} DESTINATION include)
