get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

if (${CMAKE_CXX_STANDARD} GREATER_EQUAL 20)
  # 3.99.3.0
  set(_DEP_TAG 3bf6dd31b63403a178ba13180ed3fb9ea6e691e6)
  set(_DEP_TOOLS_TAG 070d064dc80b84cbb54330fc246602b70aebc99c)
  return()
else()
  set(_DEP_TAG ba252cb776f92fae082d5d422aa2852a9be46849)
  set(_DEP_TOOLS_TAG d4b1a7670829228f4ec81ecdccc598ce03ae8e80)
endif()

set(_DEP_URL https://github.com/bloomberg/${_DEP_NAME}.git)
set(_DEP_TOOLS_URL https://github.com/bloomberg/${_DEP_NAME}-tools.git)

set(_DEP_PREFIX ${${_DEP_UNAME}_PREFIX})
if("${_DEP_PREFIX}" STREQUAL "")
    if("${DEPS_DIR}" STREQUAL "")
        set(_DEP_PREFIX ${CMAKE_CURRENT_LIST_DIR})
    else()
        set(_DEP_PREFIX ${DEPS_DIR}/${_DEP_NAME})
    endif()
    set(${_DEP_UNAME}_PREFIX ${_DEP_PREFIX})
endif()
if("${DEPS_DIR}" STREQUAL "")
    get_filename_component(DEPS_DIR ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)
    message(STATUS "Dependencies directory has been set to: ${DEPS_DIR}")
endif()
message(STATUS "${_DEP_UNAME}_PREFIX: ${_DEP_PREFIX}")

CheckVersion()

if(NOT EXISTS ${_DEP_PREFIX}/lib/libbsl.a)
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}/Readme.md)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src)
        message(STATUS "Cloning ${_DEP_NAME}: ${_DEP_URL}")
        execute_process(
            COMMAND git clone ${_DEP_URL} ${_DEP_NAME}
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Cloning ${_DEP_NAME}: ${_DEP_URL} - FAIL")
        endif()
        message(STATUS "Cloning ${_DEP_NAME}: ${_DEP_URL} - done")
        message(STATUS "Checking out ${_DEP_NAME}: ${_DEP_TAG}")
        execute_process(
            COMMAND git checkout ${_DEP_TAG}
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Checking out ${_DEP_NAME}: ${_DEP_TAG} - FAIL")
        endif()
        message(STATUS "Checking out ${_DEP_NAME}: ${_DEP_TAG} - done")
        message(STATUS "Updating ${_DEP_NAME}")
        execute_process(
            COMMAND git submodule update --init --recursive
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Updating ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Updating ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}-tools/README.md)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src)
        message(STATUS "Cloning ${_DEP_NAME}-tools: ${_DEP_TOOLS_URL}")
        execute_process(
            COMMAND git clone ${_DEP_TOOLS_URL} ${_DEP_NAME}-tools
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Cloning ${_DEP_NAME}-tools: ${_DEP_TOOLS_URL} - FAIL")
        endif()
        message(STATUS "Cloning ${_DEP_NAME}-tools: ${_DEP_TOOLS_URL} - done")
        message(STATUS "Checking out ${_DEP_NAME}-tools: ${_DEP_TOOLS_URL}")
        execute_process(
            COMMAND git checkout ${_DEP_TOOLS_TAG}
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}-tools
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Checking out ${_DEP_NAME}-tools: ${_DEP_TOOLS_URL} - FAIL")
        endif()
        message(STATUS "Checking out ${_DEP_NAME}-tools: ${_DEP_TOOLS_URL} - done")
        message(STATUS "Updating ${_DEP_NAME}-tools: ${_DEP_TOOLS_URL}")
        execute_process(
            COMMAND git submodule update --init --recursive
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}-tools
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Updating ${_DEP_NAME}-tools - FAIL")
        endif()
        message(STATUS "Updating ${_DEP_NAME}-tools - done")
    endif()
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}/build/config.log)
        message(STATUS "Configuring ${_DEP_NAME}")
        execute_process(
            COMMAND env
                    CC=${CMAKE_C_COMPILER}
                    CXX=${CMAKE_CXX_COMPILER}
                    ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}-tools/bin/waf
                    configure
                    --prefix=${_DEP_PREFIX}
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Configuring ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}/build/groups/bsl/libbsl.a)
        message(STATUS "Building ${_DEP_NAME}")
        include(ProcessorCount)
        ProcessorCount(cpus)
        execute_process(
            COMMAND env
                    CC=${CMAKE_C_COMPILER}
                    CXX=${CMAKE_CXX_COMPILER}
                    ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}-tools/bin/waf
                    build
                    -j${cpus}
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Building ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${_DEP_PREFIX}/lib/libbsl.a)
        message(STATUS "Installing ${_DEP_NAME}")
        execute_process(
            COMMAND env
                    CC=${CMAKE_C_COMPILER}
                    CXX=${CMAKE_CXX_COMPILER}
                    ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}-tools/bin/waf
                    install
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Installing ${_DEP_NAME} - done")
    endif()
    file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/src)
    file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/build)
    file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/packages)
endif()

if(EXISTS ${_DEP_PREFIX}/bin)
    set(_DEP_BIN_DIR ${_DEP_PREFIX}/bin)
    set(${_DEP_UNAME}_BIN_DIR ${_DEP_BIN_DIR})
endif()
if(EXISTS ${_DEP_PREFIX}/lib)
    set(_DEP_LIB_DIR ${_DEP_PREFIX}/lib)
    set(${_DEP_UNAME}_LIB_DIR ${_DEP_LIB_DIR})
endif()
if(EXISTS ${_DEP_PREFIX}/lib64)
    set(_DEP_LIB_DIR ${_DEP_PREFIX}/lib64)
    set(${_DEP_UNAME}_LIB_DIR ${_DEP_LIB_DIR})
endif()
if(EXISTS ${_DEP_PREFIX}/include)
    set(_DEP_INCLUDE_DIR ${_DEP_PREFIX}/include)
    set(${_DEP_UNAME}_INCLUDE_DIR ${_DEP_INCLUDE_DIR})
endif()

if(NOT TARGET ${_DEP_NAME}::protoc AND EXISTS ${_DEP_BIN_DIR}/protoc)
    add_executable(${_DEP_NAME}::protoc IMPORTED)
    set_target_properties(${_DEP_NAME}::protoc PROPERTIES
        IMPORTED_LOCATION "${_DEP_BIN_DIR}/protoc")
endif()
if(NOT TARGET ${_DEP_NAME}::${_DEP_NAME} AND EXISTS ${_DEP_LIB_DIR}/lib${_DEP_NAME}.a)
    add_library(${_DEP_NAME}::${_DEP_NAME} STATIC IMPORTED)
    set_target_properties(${_DEP_NAME}::${_DEP_NAME} PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/lib${_DEP_NAME}.a"
        INTERFACE_LINK_LIBRARIES "pthread;z"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}"
        INTERFACE_COMPILE_OPTIONS "-pthread")
endif()
if(NOT TARGET ${_DEP_NAME}::${_DEP_NAME}-lite AND EXISTS ${_DEP_LIB_DIR}/lib${_DEP_NAME}-lite.a)
    add_library(${_DEP_NAME}::${_DEP_NAME}-lite STATIC IMPORTED)
    set_target_properties(${_DEP_NAME}::${_DEP_NAME}-lite PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/lib${_DEP_NAME}-lite.a"
        INTERFACE_LINK_LIBRARIES "pthread"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}"
        INTERFACE_COMPILE_OPTIONS "-pthread")
endif()

if(NOT TARGET decnumber::decnumber AND EXISTS ${_DEP_LIB_DIR}/libdecnumber.a)
    add_library(decnumber::decnumber STATIC IMPORTED)
    set_target_properties(decnumber::decnumber PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libdecnumber.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET inteldfp::inteldfp AND EXISTS ${_DEP_LIB_DIR}/libinteldfp.a)
    add_library(inteldfp::inteldfp STATIC IMPORTED)
    set_target_properties(inteldfp::inteldfp PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libinteldfp.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET pcre2::pcre2 AND EXISTS ${_DEP_LIB_DIR}/libpcre2.a)
    add_library(pcre2::pcre2 STATIC IMPORTED)
    set_target_properties(pcre2::pcre2 PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libpcre2.a"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET ${_DEP_NAME}::bsl AND EXISTS ${_DEP_LIB_DIR}/libbsl.a)
    set(_DEP_COMPILE_DEFS)
    list(APPEND _DEP_COMPILE_DEFS ${_DEP_UNAME}_BUILD_TARGET_DBG)
    list(APPEND _DEP_COMPILE_DEFS ${_DEP_UNAME}_BUILD_TARGET_EXC)
    list(APPEND _DEP_COMPILE_DEFS ${_DEP_UNAME}_BUILD_TARGET_MT)
    list(APPEND _DEP_COMPILE_DEFS ${_DEP_UNAME}_BUILD_TARGET_CPP11)
    list(APPEND _DEP_COMPILE_DEFS _POSIX_PTHREAD_SEMANTICS)
    list(APPEND _DEP_COMPILE_DEFS _REENTRANT)
    add_library(${_DEP_NAME}::bsl STATIC IMPORTED)
    set_target_properties(${_DEP_NAME}::bsl PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libbsl.a"
        INTERFACE_LINK_LIBRARIES "pthread;rt"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}"
        INTERFACE_COMPILE_DEFINITIONS "${_DEP_COMPILE_DEFS}"
        INTERFACE_COMPILE_OPTIONS "-pthread")
endif()
if(NOT TARGET ${_DEP_NAME}::bdl AND EXISTS ${_DEP_LIB_DIR}/libbdl.a)
    add_library(${_DEP_NAME}::bdl STATIC IMPORTED)
    set_target_properties(${_DEP_NAME}::bdl PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libbdl.a"
        INTERFACE_LINK_LIBRARIES "${_DEP_NAME}::bsl;decnumber;inteldfp;pcre2"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET ${_DEP_NAME}::bal AND EXISTS ${_DEP_LIB_DIR}/libbal.a)
    add_library(${_DEP_NAME}::bal STATIC IMPORTED)
    set_target_properties(${_DEP_NAME}::bal PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libbal.a"
        INTERFACE_LINK_LIBRARIES "${_DEP_NAME}::bdl;${_DEP_NAME}::bsl"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET ${_DEP_NAME}::bbl AND EXISTS ${_DEP_LIB_DIR}/libbbl.a)
    add_library(${_DEP_NAME}::bbl STATIC IMPORTED)
    set_target_properties(${_DEP_NAME}::bbl PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libbbl.a"
        INTERFACE_LINK_LIBRARIES "${_DEP_NAME}::bdl;${_DEP_NAME}::bsl"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET ${_DEP_NAME}::btl AND EXISTS ${_DEP_LIB_DIR}/libbtl.a)
    add_library(${_DEP_NAME}::btl STATIC IMPORTED)
    set_target_properties(${_DEP_NAME}::btl PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libbtl.a"
        INTERFACE_LINK_LIBRARIES "${_DEP_NAME}::bdl;${_DEP_NAME}::bsl"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_TAG)
unset(_DEP_URL)
unset(_DEP_TOOLS_TAG)
unset(_DEP_TOOLS_URL)
unset(_DEP_PREFIX)
unset(_DEP_BIN_DIR)
unset(_DEP_LIB_DIR)
unset(_DEP_INCLUDE_DIR)
unset(_DEP_COMPILE_DEFS)
