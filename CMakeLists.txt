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

# generate pb2_grpc (client and server python classes) to CMAKE_CURRENT_BINARY_DIR directory
function(protobuf_service_generate_python AMADB_PROTO PROTOBUF_FILES)
  set(AMADB_PROTO "" PARENT_SCOPE)

  foreach(PROTOBUF_FILE ${PROTOBUF_FILES})
    get_filename_component(PROTOBUF_FILE_PATH ${PROTOBUF_FILE} ABSOLUTE)
    get_filename_component(PROTOBUF_FILE_NAME ${PROTOBUF_FILE} NAME_WE)
    list(APPEND GENERATED_PROTO_FILES
      "${CMAKE_CURRENT_BINARY_DIR}/${PROTOBUF_FILE_NAME}_pb2.py"
      "${CMAKE_CURRENT_BINARY_DIR}/${PROTOBUF_FILE_NAME}_pb2_grpc.py")
    list(APPEND AMADB_PROTO ${GENERATED_PROTO_FILES})
    add_custom_command(OUTPUT ${GENERATED_PROTO_FILES}
      COMMAND ${Python3_EXECUTABLE} -m grpc_tools.protoc --proto_path=${CMAKE_CURRENT_SOURCE_DIR} --grpc_python_out=${CMAKE_CURRENT_BINARY_DIR} --python_out=${CMAKE_CURRENT_BINARY_DIR} ${PROTOBUF_FILE_PATH}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      COMMENT "Running python protocol buffer compiler on ${PROTOBUF_FILE}"
    )
  endforeach()
  message(DEBUG "AMADB_PROTO (inside function): ${AMADB_PROTO}")
endfunction()

list(APPEND AMADB_PROTOBUF_MESSAGES
  hash.proto
  utils.proto
  workspace.proto
)

list(APPEND AMADB_PROTOBUF_SERVICES
  amadb.proto
)

if(CMAKE_BUILD_AMADB_PROTO)
  protobuf_generate_python(AMADB_PROTO ${AMADB_PROTOBUF_MESSAGES}) # generate only message protos
  list(APPEND AMADB_GENERATED_PROTOS ${AMADB_PROTO})

  message(DEBUG "AMADB_PROTO (before call function): ${AMADB_PROTO}")
  protobuf_service_generate_python(AMADB_PROTO ${AMADB_PROTOBUF_SERVICES})
  message(DEBUG "AMADB_PROTO (outside function): ${AMADB_PROTO}")
  list(APPEND AMADB_GENERATED_PROTOS ${AMADB_PROTO})

  message(DEBUG "AMADB_GENERATED_PROTOS: ${AMADB_GENERATED_PROTOS}")

  add_custom_target(amadb_protos ALL
    DEPENDS ${AMADB_GENERATED_PROTOS}
  )
endif()
