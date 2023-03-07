PROJECT(RANKER)
CMAKE_MINIMUM_REQUIRED(VERSION 3.11)

IF(NOT CMAKE_CXX_STANDARD)
    SET(CMAKE_CXX_STANDARD 17)
ENDIF()
SET(CMAKE_CXX_STANDARD_REQUIRED ON)
IF(NOT CMAKE_BUILD_TYPE)
    SET(CMAKE_BUILD_TYPE RelWithDebInfo
        CACHE STRING "Choose the type of build : None Debug Release RelWithDebInfo Asan Pprof."
        FORCE)
ENDIF(NOT CMAKE_BUILD_TYPE)

# Update the documentation string of CMAKE_BUILD_TYPE for GUIs
SET( CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING
    "Choose the type of build, options are: None Debug Release RelWithDebInfo Asan Pprof."
    FORCE )
execute_process( COMMAND uname -m COMMAND tr -d '\n' OUTPUT_VARIABLE ARCHITECTURE )
message("## Current build type is : ${CMAKE_BUILD_TYPE} and ${CMAKE_CXX_STANDARD} Architecture ${ARCHITECTURE} ##")

SET( CMAKE_CXX_FLAGS_ASAN "-O2 -g -fsanitize=address -fno-omit-frame-pointer" CACHE STRING
    "Flags used by the C++ compiler during asan builds."
    FORCE )
SET( CMAKE_C_FLAGS_ASAN "-O2 -g -fsanitize=address -fno-omit-frame-pointer" CACHE STRING
    "Flags used by the C compiler during asan builds."
    FORCE )
SET( CMAKE_EXE_LINKER_FLAGS_ASAN
    "-static-libasan" CACHE STRING
    "Flags used for linking binaries during asan builds."
    FORCE )

#SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wno-ignored-qualifiers -Wno-maybe-uninitialized -Wno-nonnull")
#SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wno-ignored-qualifiers -Wno-maybe-uninitialized -Wno-nonnull")
if( ${ARCHITECTURE} STREQUAL "aarch64" )
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -march=armv8.2-a+fp16+rcpc+dotprod+crypto -mtune=neoverse-n1")
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv8.2-a+fp16+rcpc+dotprod+crypto -mtune=neoverse-n1")
    SET(CMAKE_THREAD_LIBS_INIT "-lpthread")
endif()
message(STATUS "##CMAKE_C_FLAGS ${CMAKE_C_FLAGS} ##")
message(STATUS "##CMAKE_CXX_FLAGS ${CMAKE_C_FLAGS} ##")
MARK_AS_ADVANCED(
    CMAKE_CXX_FLAGS_ASAN
    CMAKE_C_FLAGS_ASAN
    CMAKE_EXE_LINKER_FLAGS_ASAN )

INCLUDE(${CMAKE_CURRENT_LIST_DIR}/check.cmake)
