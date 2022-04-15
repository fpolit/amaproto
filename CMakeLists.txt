cmake_minimum_required(VERSION 3.5)

project(amaproto
  VERSION 1.0.1
  DESCRIPTION "Ama-Framework protobuf definition"
  HOMEPAGE_URL https://github.com/fpolit/amaproto
)

set(PROJECT_LICENSE "GPLv3")
set(CMAKE_SHARED_MODULE_PREFIX "")
set(CMAKE_PROJECT_AMAPROTO_VERSION ${CMAKE_PROJECT_VERSION} PARENT_SCOPE) # amaproto version to parent cmakes files

option(CMAKE_BUILD_TESTS  "Build protobuf tests" OFF)
option(CMAKE_COMPILER_WALL "Warning all" ON)

if(${CMAKE_COMPILER_WALL})
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")
endif()

# protobuf options
option(CMAKE_BUILD_AMADB_PY_PROTO  "Build amadb python protobuf files" OFF)
option(CMAKE_BUILD_AMADB_CXX_PROTO  "Build amadb c++ protobuf files" OFF)
option(CMAKE_BUILD_AMACONTROLLER_PY_PROTO  "Build amacontroller python protobuf files" OFF)
option(CMAKE_BUILD_AMACONTROLLER_CXX_PROTO  "Build amacontroller c++ protobuf files" OFF)
option(CMAKE_BUILD_AMAPROCESSOR_PROTO  "Build amaprocessor protobuf files" OFF )# CXX protobuf files

# Finding dependencies
find_package(Protobuf REQUIRED)
find_package(Python3  COMPONENTS Interpreter REQUIRED)

# enviroment information
message(DEBUG "PROJECT_AMAPROTO_VERSION: ${PROJECT_AMAPROTO_VERSION}")
message(DEBUG "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")
message(DEBUG "CMAKE_CURRENT_BINARY_DIR: ${CMAKE_CURRENT_BINARY_DIR}")
message(DEBUG "Python_VERSION: ${Python_VERSION}")
message(DEBUG "CMAKE_BUILD_AMADB_PY_PROTO: ${CMAKE_BUILD_AMADB_PY_PROTO}")
message(DEBUG "CMAKE_BUILD_AMADB_CXX_PROTO: ${CMAKE_BUILD_AMADB_CXX_PROTO}")
message(DEBUG "CMAKE_BUILD_AMACONTROLLER_PY_PROTO: ${CMAKE_BUILD_AMACONTROLLER_PY_PROTO}")
message(DEBUG "CMAKE_BUILD_AMACONTROLLER_CXX_PROTO: ${CMAKE_BUILD_AMACONTROLLER_CXX_PROTO}")
message(DEBUG "CMAKE_BUILD_AMAPROCESSOR_PROTO: ${CMAKE_BUILD_AMAPROCESSOR_PROTO}")
message(DEBUG "Protobuf_INCLUDE_DIR: ${Protobuf_INCLUDE_DIR}")
message(DEBUG "Protobuf_IMPORT_DIRS: ${Protobuf_IMPORT_DIRS}")

INCLUDE_DIRECTORIES(
  ${Protobuf_INCLUDE_DIRS}
  ${CMAKE_CURRENT_SOURCE_DIR}
)

# generate pb2_grpc (client and server python classes) to CMAKE_CURRENT_BINARY_DIR directory
function(protobuf_service_generate_python PY_PROTO PROTOBUF_FILES)
  foreach(PROTOBUF_FILE ${PROTOBUF_FILES})
    get_filename_component(PROTOBUF_FILE_PATH ${PROTOBUF_FILE} ABSOLUTE)
    get_filename_component(PROTOBUF_FILE_NAME ${PROTOBUF_FILE} NAME_WE)

    list(APPEND GENERATED_PROTO_FILES
      "${CMAKE_CURRENT_BINARY_DIR}/${PROTOBUF_FILE_NAME}_pb2.py"
      "${CMAKE_CURRENT_BINARY_DIR}/${PROTOBUF_FILE_NAME}_pb2_grpc.py")

    add_custom_command(OUTPUT ${GENERATED_PROTO_FILES}
      COMMAND ${Python3_EXECUTABLE} -m grpc_tools.protoc --proto_path=${CMAKE_CURRENT_SOURCE_DIR} --grpc_python_out=${CMAKE_CURRENT_BINARY_DIR} --python_out=${CMAKE_CURRENT_BINARY_DIR} ${PROTOBUF_FILE_PATH}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      COMMENT "Running python protocol buffer compiler on ${PROTOBUF_FILE}"
    )
  endforeach()
  set(PY_PROTO ${GENERATED_PROTO_FILES} PARENT_SCOPE)
endfunction()


# AMADB protobuf files
list(APPEND AMADB_PROTOBUF_MESSAGES
  hash.proto
  utils.proto
  workspace.proto
  job.proto
  amadb_requests.proto
)
list(APPEND AMADB_PROTOBUF_SERVICES
  amadb.proto
)
list(APPEND AMADB_PROTOBUF_FILES ${AMADB_PROTOBUF_MESSAGES} ${AMADB_PROTOBUF_SERVICES})


# AMACONTROLLER protobuf files
list(APPEND AMACONTROLLER_PROTOBUF_MESSAGES
  workspace.proto
  option.proto
  module.proto
  utils.proto
  job.proto
  amactl_requests.proto
)
list(APPEND AMACONTROLLER_PROTOBUF_SERVICES
  amactl.proto
)
list(APPEND AMACONTROLLER_PROTOBUF_FILES ${AMACONTROLLER_PROTOBUF_MESSAGES} ${AMACONTROLLER_PROTOBUF_SERVICES})

# AMAPROCESSOR protobuf files
list(APPEND AMAPROCESSOR_PROTOBUF_FILES
  option.proto
  utils.proto
  amaproc_requests.proto
  amactl_requests.proto
  module.proto
  workspace.proto
  amaproc.proto
  hash.proto
)


if(CMAKE_BUILD_AMADB_PY_PROTO OR CMAKE_BUILD_AMADB_CXX_PROTO)
  add_custom_target(amadb_protos ALL)
  if(CMAKE_BUILD_AMADB_PY_PROTO)
    protobuf_generate_python(PY_PROTO ${AMADB_PROTOBUF_MESSAGES}) # generate only message protos
    list(APPEND AMADB_GENERATED_PY_PROTOS ${PY_PROTO})

    protobuf_service_generate_python(PY_PROTO ${AMADB_PROTOBUF_SERVICES})
    list(APPEND AMADB_GENERATED_PY_PROTOS ${PY_PROTO})

    list(APPEND AMA_GENERATE_PY_PROTOS ${AMADB_GENERATED_PY_PROTOS})
    message(DEBUG "AMADB_GENERATED_PY_PROTOS: ${AMADB_GENERATED_PY_PROTOS}")
    add_custom_target(amadb_py_protos ALL
      DEPENDS ${AMADB_GENERATED_PY_PROTOS})
    add_dependencies(amadb_protos amadb_py_protos)

    #copy generated proto files to AMADB_PROTO_DESTINATION
    if(EXISTS ${AMADB_PY_PROTO_DESTINATION})
      foreach(GENERATED_PROTOBUF_FILE ${AMADB_GENERATED_PY_PROTOS})
        add_custom_command(TARGET amadb_py_protos POST_BUILD
          COMMAND ${CMAKE_COMMAND} -E copy ${GENERATED_PROTOBUF_FILE} ${AMADB_PY_PROTO_DESTINATION})
      endforeach()
    endif()
  endif()

  if(CMAKE_BUILD_AMADB_CXX_PROTO)
    protobuf_generate_cpp(CXX_PROTO CXX_PROTO_HEADERS ${AMADB_PROTOBUF_FILES})
    add_library(amadb_cxx_protos SHARED ${CXX_PROTO} ${CXX_PROTO_HEADERS})
    target_link_libraries(amadb_cxx_protos ${Protobuf_LIBRARIES})
    add_dependencies(amadb_protos amadb_cxx_protos)
  endif()
endif()

if(CMAKE_BUILD_AMACONTROLLER_PY_PROTO OR CMAKE_BUILD_AMACONTROLLER_CXX_PROTO)
  add_custom_target(amacontroller_protos ALL)
  if(CMAKE_BUILD_AMACONTROLLER_PY_PROTO)
    protobuf_generate_python(PY_PROTO ${AMACONTROLLER_PROTOBUF_MESSAGES}) # generate only message protos
    list(APPEND AMACONTROLLER_GENERATED_PY_PROTOS ${PY_PROTO})

    protobuf_service_generate_python(PY_PROTO ${AMACONTROLLER_PROTOBUF_SERVICES})
    list(APPEND AMACONTROLLER_GENERATED_PY_PROTOS ${PY_PROTO})

    list(APPEND AMA_GENERATE_PY_PROTOS ${AMACONTROLLER_GENERATED_PY_PROTOS})
    message(DEBUG "AMACONTROLLER_GENERATED_PY_PROTOS: ${AMADB_GENERATED_PY_PROTOS}")
    add_custom_target(amacontroller_py_protos ALL
      DEPENDS ${AMACONTROLLER_GENERATED_PY_PROTOS})
    add_dependencies(amacontroller_protos amacontroller_py_protos)

    # copy generated proto files to AMACONTROLLER_PROTO_DESTINATION
    if(EXISTS ${AMACONTROLLER_PY_PROTO_DESTINATION})
      foreach(GENERATED_PROTOBUF_FILE ${AMACONTROOLLER_GENERATED_PY_PROTOS})
        add_custom_command(TARGET amacontroller_py_protos POST_BUILD
          COMMAND ${CMAKE_COMMAND} -E copy ${GENERATED_PROTOBUF_FILE} ${AMACONTROLLER_PY_PROTO_DESTINATION})
      endforeach()
    endif()
  endif()

  if(CMAKE_BUILD_AMACONTROLLER_CXX_PROTO)
    protobuf_generate_cpp(CXX_PROTO CXX_PROTO_HEADERS ${AMACONTROLLER_PROTOBUF_FILES})
    add_library(amacontroller_cxx_protos SHARED ${CXX_PROTO} ${CXX_PROTO_HEADERS})
    target_link_libraries(amacontroller_cxx_protos ${Protobuf_LIBRARIES})
    add_dependencies(amacontroller_protos amacontroller_cxx_protos)
  endif()
endif()

if(CMAKE_BUILD_AMAPROCESSOR_PROTO)
  add_custom_target(amaprocessor_protos ALL)
  protobuf_generate_cpp(CXX_PROTO CXX_PROTO_HEADERS ${AMAPROCESSOR_PROTOBUF_FILES})
  add_library(amaprocessor_cxx_protos SHARED ${CXX_PROTO} ${CXX_PROTO_HEADERS})
  target_link_libraries(amaprocessor_cxx_protos ${Protobuf_LIBRARIES})
  add_dependencies(amaprocessor_protos amaprocessor_cxx_protos)
endif()


if(CMAKE_BUILD_TESTS)
  enable_testing()
  add_subdirectory(tests)
  Python_add_library(ama_protos ${AMA_GENERATED_PY_PROTOS}) # temporal python module to test generated python protobuf files
  add_custom_target(pytest
    COMMAND ${Python3_EXECUTABLE} -m pytest -v ${CMAKE_CURRENT_SOURCE_DIR}/tests)
endif()
