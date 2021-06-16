#/* Copyright 2019-2020 The MathWorks, Inc. */
SET(SUB_PROJECT_NAME msgproto)

# read all .proto file names expect CoSimMsgs.proto 
file(GLOB PROTO_FILES
    "${PROJECT_SOURCE_DIR}/msgsproto/*.proto"
)

# generate proto source and header for each proto
foreach(ARG ${PROTO_FILES})
    message(" Building ... ${ARG}") 
    execute_process (
    COMMAND bash -c "protoc --proto_path=${PROJECT_SOURCE_DIR}/msgsproto/ --cpp_out=${PROJECT_SOURCE_DIR}/msgsproto/  ${ARG}")
endforeach()

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/export/lib)

# read all .pb.cc amd .pb.h files and create library
file(GLOB PROTO_SOURCES
    "${PROJECT_SOURCE_DIR}/msgsproto/*.pb.cc"
    "${PROJECT_SOURCE_DIR}/msgsproto/*.pb.h"
)

add_library(msgproto SHARED ${PROTO_SOURCES})
install(TARGETS msgproto DESTINATION ${PROJECT_SOURCE_DIR}/export/lib)
