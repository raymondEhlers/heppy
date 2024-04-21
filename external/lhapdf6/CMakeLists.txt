# This file is just an orchestration
cmake_minimum_required(VERSION 3.13.5)
# SWIG: use SWIG_MODULE_NAME property.
if(POLICY CMP0086)
  cmake_policy(SET CMP0086 NEW)
endif()
# target_sources: use absolute path for INTERFACE_SOURCES.
if(POLICY CMP0076)
  cmake_policy(SET CMP0076 NEW)
endif()
# SWIG: use standard target name.
if(POLICY CMP0078)
  cmake_policy(SET CMP0078 NEW)
endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../cmake")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../cmake/Modules")
include(common_heppy)
set(PROJECT_NAME heppy_external_lhapdf)
project(${PROJECT_NAME} VERSION 1.0 LANGUAGES CXX)
message(STATUS "${Green}This is ${PROJECT_NAME} ver. ${PROJECT_VERSION}${ColourReset}")

find_program(MAKE_EXE NAMES gmake nmake make)
message(STATUS "${Green}Will use ${MAKE_EXE} when needed.${ColourReset}")
find_program(CMAKE_C_COMPILER NAMES $ENV{CC} gcc PATHS ENV PATH NO_DEFAULT_PATH)
find_program(CMAKE_CXX_COMPILER NAMES $ENV{CXX} g++ PATHS ENV PATH NO_DEFAULT_PATH)

set (CMAKE_CXX_STANDARD 11)

message( STATUS "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")


include(ProcessorCount)
ProcessorCount(NCPU)

include(ExternalProject)

if (NOT LHAPDF6_VERSION)
	set(LHAPDF6_VERSION 6.2.3)
endif(NOT LHAPDF6_VERSION)

message(STATUS "LHAPDF6_VERSION ${LHAPDF6_VERSION}")

if (NOT LHAPDF6_HEPPY_PREFIX)
	set(LHAPDF6_HEPPY_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/lhapdf6-${LHAPDF6_VERSION}")
endif(NOT LHAPDF6_HEPPY_PREFIX)

message(STATUS "LHAPDF6_HEPPY_PREFIX ${LHAPDF6_HEPPY_PREFIX}")

set(LHAPDF6_CONFIGURE_COMMAND ./configure)
list(APPEND LHAPDF6_CONFIGURE_COMMAND --prefix=${LHAPDF6_HEPPY_PREFIX})

find_package(Python3 3.6 REQUIRED COMPONENTS Interpreter Development NumPy)
if (Python3_FOUND)
    get_filename_component(Python3_EXE_NAME ${Python3_EXECUTABLE} NAME)
    # If it's already just `python`, there's nothing to be done - LHAPDF should be able
    # to pick it up. Plus, we can't directly pass the base python path anymore, so we're
    # dependent on the LHAPDF logic.
    if (NOT Python3_EXE_NAME STREQUAL "python")
        # LHAPDF expects to be able to find python itself based on the executable name.
        # For many versions of python, it can find it via pythonV - eg. python3, python3.10, etc
        # Although we could just take Python3_VERSION_* (e.g. Python3_VERSION_MAJOR), we don't
        # know the level of specification that it needs. So to take care of this, we'll remove
        # `python` from string, and take what remains.
        string(REPLACE "python" "" Python3_VERSION_EXTRACTED ${Python3_EXE_NAME})

        # If it's empty, then we can fall back to setting the python major version, which is at
        # least a reasonable assumption.
        if (Python3_VERSION_EXTRACTED STREQUAL "")
            set(Python3_VERSION_EXTRACTED ${Python3_VERSION_MAJOR})
        endif (Python3_VERSION_EXTRACTED STREQUAL "")

        # We want to pass it first so it will be taken as an environment variable (based on the
        # convention of the call below)
        list(PREPEND LHAPDF6_CONFIGURE_COMMAND PYTHON_VERSION=${Python3_VERSION_EXTRACTED})
    endif (NOT Python3_EXE_NAME STREQUAL "python")
endif(Python3_FOUND)

message(STATUS "configure command: ${LHAPDF6_CONFIGURE_COMMAND}")

ExternalProject_Add(LHAPDF6
	PREFIX            ${LHAPDF6_BUILD}
	URL               https://lhapdf.hepforge.org/downloads/?f=LHAPDF-${LHAPDF6_VERSION}.tar.gz
	DOWNLOAD_DIR      ${CMAKE_CURRENT_SOURCE_DIR}/downloads
	DOWNLOAD_NAME     LHAPDF-${LHAPDF6_VERSION}.tar.gz
	# SOURCE_DIR        ${CMAKE_CURRENT_SOURCE_DIR}/build/fastjet-${LHAPDF6_VERSION}
	BUILD_IN_SOURCE   1
	INSTALL_DIR       ${LHAPDF6_BUILD}
	CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env ${LHAPDF6_CONFIGURE_COMMAND}
	BUILD_COMMAND     ${CMAKE_COMMAND} -E env ${MAKE_EXE} -j ${NCPU}
	INSTALL_COMMAND   ${CMAKE_COMMAND} -E env ${MAKE_EXE} install
	#TEST_COMMAND      ${LHAPDF6_CONFIGURE_COMMAND}/fastjet-config
	#TEST_BEFORE_INSTALL 1
	LOG_DOWNLOAD 1
	LOG_UPDATE 1
	LOG_CONFIGURE 1
	LOG_BUILD 1
	LOG_TEST 1
	LOG_INSTALL 1)
