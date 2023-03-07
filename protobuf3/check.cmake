get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

set(_DEP_VER 3.20.3)
set(_DEP_URL https://codeload.github.com/protocolbuffers/protobuf/tar.gz/refs/tags/v${_DEP_VER})

set(_DEP_PREFIX ${${_DEP_UNAME}_PREFIX})
if ("${_DEP_PREFIX}" STREQUAL "")
    if ("${DEPS_DIR}" STREQUAL "")
        set(_DEP_PREFIX ${CMAKE_CURRENT_LIST_DIR})
    else ()
        set(_DEP_PREFIX ${DEPS_DIR}/${_DEP_NAME})
    endif ()
    set(${_DEP_UNAME}_PREFIX ${_DEP_PREFIX})
endif ()
if ("${DEPS_DIR}" STREQUAL "")
    get_filename_component(DEPS_DIR ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)
    message(STATUS "Dependencies directory has been set to: ${DEPS_DIR}")
endif ()
message(STATUS "${_DEP_UNAME}_PREFIX: ${_DEP_PREFIX}")

CheckVersion()

if (NOT EXISTS ${_DEP_PREFIX}/lib/libprotobuf.a)
    if (NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/packages/${_DEP_NAME}.tar.gz)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/packages)
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_URL}")
        execute_process(
                COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/${_DEP_NAME}.tar.gz ${_DEP_URL}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_URL} - FAIL")
        endif ()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_URL} - done")
    endif ()
    if (NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/README.md)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src)
        message(STATUS "Extracting ${_DEP_NAME}")
        execute_process(
                COMMAND tar -xf ${CMAKE_CURRENT_LIST_DIR}/packages/${_DEP_NAME}.tar.gz
                --strip-components 1 -C ${CMAKE_CURRENT_LIST_DIR}/src
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Extracting ${_DEP_NAME} - done")
    endif ()
    if (NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/configure)
        message(STATUS "Autogen ${_DEP_NAME}")
        execute_process(
                COMMAND bash autogen.sh
                WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Autogen ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Autogen ${_DEP_NAME} - done")
    endif ()
    if (NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/config.log)
        message(STATUS "Configuring ${_DEP_NAME}")
        execute_process(
                COMMAND env
                CC=${CMAKE_C_COMPILER}
                CXX=${CMAKE_CXX_COMPILER}
                CFLAGS=-fPIC
                CXXFLAGS=-fPIC
                ./configure
                --prefix=${_DEP_PREFIX}
                --enable-shared=no
                WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Configuring ${_DEP_NAME} - done")
    endif ()
    if (NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/libprotobuf.a)
        message(STATUS "Building ${_DEP_NAME}")
        include(ProcessorCount)
        ProcessorCount(cpus)
        execute_process(
                COMMAND env
                CC=${CMAKE_C_COMPILER}
                CXX=${CMAKE_CXX_COMPILER}
                make
                -j${cpus}
                WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Building ${_DEP_NAME} - done")
    endif ()
    if (NOT EXISTS ${_DEP_PREFIX}/lib/libprotobuf.a)
        message(STATUS "Installing ${_DEP_NAME}")
        execute_process(
                COMMAND env
                CC=${CMAKE_C_COMPILER}
                CXX=${CMAKE_CXX_COMPILER}
                make
                install
                WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Installing ${_DEP_NAME} - done")
    endif ()
    file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/src)
    file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/build)
    file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/packages)
endif ()

if (EXISTS ${_DEP_PREFIX}/bin)
    set(_DEP_BIN_DIR ${_DEP_PREFIX}/bin)
    set(${_DEP_UNAME}_BIN_DIR ${_DEP_BIN_DIR})
endif ()
if (EXISTS ${_DEP_PREFIX}/lib)
    set(_DEP_LIB_DIR ${_DEP_PREFIX}/lib)
    set(${_DEP_UNAME}_LIB_DIR ${_DEP_LIB_DIR})
endif ()
if (EXISTS ${_DEP_PREFIX}/lib64)
    set(_DEP_LIB_DIR ${_DEP_PREFIX}/lib64)
    set(${_DEP_UNAME}_LIB_DIR ${_DEP_LIB_DIR})
endif ()
if (EXISTS ${_DEP_PREFIX}/include)
    set(_DEP_INCLUDE_DIR ${_DEP_PREFIX}/include)
    set(${_DEP_UNAME}_INCLUDE_DIR ${_DEP_INCLUDE_DIR})
endif ()

set(Protobuf_INCLUDE_DIR ${_DEP_INCLUDE_DIR} CACHE PATH "" FORCE)
set(Protobuf_PROTOC_EXECUTABLE ${_DEP_BIN_DIR}/protoc CACHE FILEPATH "" FORCE)
set(Protobuf_PROTOC_LIBRARY ${_DEP_LIB_DIR}/libprotoc.a CACHE FILEPATH "" FORCE)
set(Protobuf_LIBRARY ${_DEP_LIB_DIR}/libprotobuf.a CACHE FILEPATH "" FORCE)
set(Protobuf_LITE_LIBRARY ${_DEP_LIB_DIR}/libprotobuf-lite.a CACHE FILEPATH "" FORCE)

if (NOT TARGET protobuf::protoc AND EXISTS ${_DEP_BIN_DIR}/protoc)
    add_executable(protobuf::protoc IMPORTED)
    set_target_properties(protobuf::protoc PROPERTIES
            IMPORTED_LOCATION "${_DEP_BIN_DIR}/protoc")
endif ()
if (NOT TARGET protobuf::protobuf AND EXISTS ${_DEP_LIB_DIR}/libprotobuf.a)
    add_library(protobuf::protobuf STATIC IMPORTED)
    set_target_properties(protobuf::protobuf PROPERTIES
            IMPORTED_LOCATION "${_DEP_LIB_DIR}/libprotobuf.a"
            INTERFACE_LINK_LIBRARIES "pthread;z"
            INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}"
            INTERFACE_COMPILE_OPTIONS "-pthread")
endif ()
if (NOT TARGET protobuf::protobuf-lite AND EXISTS ${_DEP_LIB_DIR}/libprotobuf-lite.a)
    add_library(protobuf::protobuf-lite STATIC IMPORTED)
    set_target_properties(protobuf::protobuf-lite PROPERTIES
            IMPORTED_LOCATION "${_DEP_LIB_DIR}/libprotobuf-lite.a"
            INTERFACE_LINK_LIBRARIES "pthread"
            INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}"
            INTERFACE_COMPILE_OPTIONS "-pthread")
endif ()

list(FIND CMAKE_PREFIX_PATH ${_DEP_PREFIX} _DEP_INDEX)
if (_DEP_INDEX EQUAL -1)
    list(APPEND CMAKE_PREFIX_PATH ${_DEP_PREFIX})
endif ()

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_VER)
unset(_DEP_URL)
unset(_DEP_PREFIX)
unset(_DEP_BIN_DIR)
unset(_DEP_LIB_DIR)
unset(_DEP_INCLUDE_DIR)
