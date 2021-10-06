include(heppy_find_python)

find_package(SWIG REQUIRED)
if (SWIG_FOUND)
    include(${SWIG_USE_FILE})
    # message(STATUS "Python_EXECUTABLE: ${Python_EXECUTABLE}")
    # message(STATUS "Python_INCLUDE_DIRS: ${Python_INCLUDE_DIRS}")
    # message(STATUS "Python_NumPy_INCLUDE_DIRS: ${Python_NumPy_INCLUDE_DIRS}")
    # message(STATUS "Python_LIBRARIES: ${Python_LIBRARIES}")
    include_directories(${Python_INCLUDE_DIRS})
    include_directories(${Python_NumPy_INCLUDE_DIRS})
    message(STATUS "${Green}SWIG ver. ${SWIG_VERSION} found.${ColourReset}")
  else(SWIG_FOUND)
    message(FATAL_ERROR "${Red}SWIG not found while it is the key package here...${ColourReset}")
endif(SWIG_FOUND)

include(ProcessorCount)
ProcessorCount(NCPU)

find_package(FastJet 3.0 REQUIRED)
if (NOT FASTJET_FOUND)
  message(STATUS "${Yellow}Hint: build FJ with ${CMAKE_CURRENT_SOURCE_DIR}/fastjet/build.sh ${ColourReset}")
  message(SEND_ERROR "${Red}FASTJET not found.${ColourReset}")
endif(NOT FASTJET_FOUND)

find_package(LHAPDF6 QUIET)

find_package(HepMC QUIET COMPONENTS HepMC)

find_package(HepMC3 QUIET COMPONENTS HepMC)
if (HEPMC3_FOUND)
  if (${HEPMC3_VERSION_MINOR} GREATER "0")
    # message( STATUS "HEPMC3 minor version ${HEPMC3_VERSION_MINOR} > 0 - adding HEPMC3 definition")
    add_definitions(-DHEPMC31)
  endif()
  if (${HEPMC3_VERSION} VERSION_GREATER "3.0")
    # message( STATUS "HEPMC3 version ${HEPMC3_VERSION} > 3.0 - adding HEPMC3 definition")
    add_definitions(-DHEPMC31)
  endif()
endif(HEPMC3_FOUND)

find_package(ROOT4HEPPY)

find_package(Pythia8)

find_package(RooUnfold)
