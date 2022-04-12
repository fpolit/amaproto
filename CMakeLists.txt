cmake_minimum_required(VERSION 3.5)

project(amaproto
  VERSION 1.0.0
  DESCRIPTION "Ama-Framework protobuf definition"
  HOMEPAGE_URL https://github.com/fpolit/amaproto
)

set(PROJECT_LICENSE "GPLv3")

# options
option(CMAKE_BUILD_AMADB_PROTO  "Build amadb protobuf files" OFF)
option(CMAKE_BUILD_AMACONSOLE_PROTO  "Build amaconsole protobuf files" OFF)
option(CMAKE_BUILD_AMAPROCESSOR_PROTO  "Build amaprocessor protobuf files" OFF)
option(CMAKE_BUILD_AMACONTROLLER_PROTO  "Build amacontroller protobuf files" OFF)

# Finding dependencies
find_package(Protobuf REQUIRED)
find_package(Python3  COMPONENTS Interpreter REQUIRED)

# enviroment information
message(DEBUG "PROJECT_VERSION: ${CMAKE_PROJECT_VERSION}")
message(DEBUG "CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
message(DEBUG "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")
message(DEBUG "CMAKE_CURRENT_BINARY_DIR: ${CMAKE_CURRENT_BINARY_DIR}")
message(DEBUG "Python3_VERSION: ${Python3_VERSION}")
message(DEBUG "Python3_EXECUTABLE: ${Python3_EXECUTABLE}")

INCLUDE_DIRECTORIES(${PROTOBUF_INCLUDE_DIR})

file(GLOB ALL_PROTOBUF_FILES *.proto)
list(APPEND AMADB_PROTOBUF_FILES
  amadb.proto
  hash.proto
  utils.proto
  workspace.proto
)

foreach(PROTOBUF_FILE ${ALL_PROTOBUF_FILES})
  get_filename_component(PROTOBUF_FILE_NAME ${PROTOBUF_FILE} NAME)
  message(STATUS "(foeach loop) PROTOBUF_FILE: ${PROTOBUF_FILE}")
  if(CMAKE_BUILD_AMADB_PROTO)
    list(FIND AMADB_PROTOBUF_FILES ${PROTOBUF_FILE_NAME} _found)
    if(NOT _found EQUAL -1)
      protobuf_generate_python(PY_PROTO ${PROTOBUF_FILE})
      list(APPEND AMADB_GENERATED_PY_PROTOS ${PY_PROTO})
    endif()
  endif()
endforeach()


if(CMAKE_BUILD_AMADB_PROTO)
  message(STATUS "AMADB_GENERATED_PY_PROTOS: ${AMADB_GENERATED_PY_PROTOS}")
  add_custom_target(amadb_pyprotos ALL
    DEPENDS ${AMADB_GENERATED_PY_PROTOS}
  )
endif()
