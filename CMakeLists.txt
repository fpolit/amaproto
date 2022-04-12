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
message(DEBUG "CMAKE_BUILD_AMADB_PROTO: ${CMAKE_BUILD_AMADB_PROTO}")
message(DEBUG "CMAKE_BUILD_AMACONSOLE_PROTO: ${CMAKE_BUILD_AMACONSOLE_PROTO}")
message(DEBUG "CMAKE_BUILD_AMAPROCESSOR_PROTO: ${CMAKE_BUILD_AMAPROCESSOR_PROTO}")
message(DEBUG "CMAKE_BUILD_AMACONTROLLER_PROTO: ${CMAKE_BUILD_AMACONTROLLER_PROTO}")
message(DEBUG "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")
message(DEBUG "CMAKE_CURRENT_BINARY_DIR: ${CMAKE_CURRENT_BINARY_DIR}")

INCLUDE_DIRECTORIES(${PROTOBUF_INCLUDE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})

list(APPEND AMADB_PROTOBUF_FILES
  amadb.proto
  hash.proto
  utils.proto
  workspace.proto
)

if(CMAKE_BUILD_AMADB_PROTO)
  protobuf_generate_python(AMADB_PY_PROTO ${AMADB_PROTOBUF_FILES})
  list(APPEND AMADB_GENERATED_PY_PROTOS ${AMADB_PY_PROTO})

  message(DEBUG "AMADB_GENERATED_PY_PROTOS: ${AMADB_GENERATED_PY_PROTOS}")
  add_custom_target(amadb_pyprotos ALL
    DEPENDS ${AMADB_GENERATED_PY_PROTOS}
  )

  foreach(AMADB_PY_PROTO ${AMADB_GENERATED_PY_PROTOS})
    message(DEBUG "(loop) AMADB_PY_PROTO: ${AMADB_PY_PROTO}")
    add_custom_command(TARGET amadb_pyprotos POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy ${AMADB_PY_PROTO} ${AMADB_PY_PROTO_DESTINATION}
      COMMENT "(DEBUG) Copying python proto file ${AMADB_PY_PROTO} to ${AMADB_PY_PROTO_DESTINATION}"
    )
  endforeach()
endif()
