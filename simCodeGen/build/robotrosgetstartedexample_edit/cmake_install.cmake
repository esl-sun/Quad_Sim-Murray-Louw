# Install script for directory: /home/murray/Masters/Developer/MATLAB/Quad_Sim_Murray/simCodeGen/src/robotrosgetstartedexample_edit

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/murray/Masters/Developer/MATLAB/Quad_Sim_Murray/simCodeGen/install")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/usr/bin/objdump")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "/home/murray/Masters/Developer/MATLAB/Quad_Sim_Murray/simCodeGen/build/robotrosgetstartedexample_edit/catkin_generated/installspace/robotrosgetstartedexample_edit.pc")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/robotrosgetstartedexample_edit/cmake" TYPE FILE FILES
    "/home/murray/Masters/Developer/MATLAB/Quad_Sim_Murray/simCodeGen/build/robotrosgetstartedexample_edit/catkin_generated/installspace/robotrosgetstartedexample_editConfig.cmake"
    "/home/murray/Masters/Developer/MATLAB/Quad_Sim_Murray/simCodeGen/build/robotrosgetstartedexample_edit/catkin_generated/installspace/robotrosgetstartedexample_editConfig-version.cmake"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/robotrosgetstartedexample_edit" TYPE FILE FILES "/home/murray/Masters/Developer/MATLAB/Quad_Sim_Murray/simCodeGen/src/robotrosgetstartedexample_edit/package.xml")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/robotrosgetstartedexample_edit" TYPE EXECUTABLE FILES "/home/murray/Masters/Developer/MATLAB/Quad_Sim_Murray/simCodeGen/devel/lib/robotrosgetstartedexample_edit/robotROSGetStartedExample_edit")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/robotrosgetstartedexample_edit/robotROSGetStartedExample_edit" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/robotrosgetstartedexample_edit/robotROSGetStartedExample_edit")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/usr/bin/strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/robotrosgetstartedexample_edit/robotROSGetStartedExample_edit")
    endif()
  endif()
endif()

