include(${CMAKE_CURRENT_LIST_DIR}/../hiredis/check.cmake OPTIONAL)
if("${HIREDIS_PREFIX}" STREQUAL "")
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires hiredis")
endif()
if(NOT TARGET hiredis::hiredis)
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires hiredis::hiredis")
endif()

get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

set(_DEP_TAG ml_platform_compatible)
set(_DEP_URL git@gitlab.mobvista.com:ml-platform/${_DEP_NAME}.git)

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

if(NOT EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}.a)
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/README.txt)
        message(STATUS "Cloning ${_DEP_NAME}: ${_DEP_URL}")
        execute_process(
            COMMAND git clone ${_DEP_URL} src
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Cloning ${_DEP_NAME}: ${_DEP_URL} - FAIL")
        endif()
        message(STATUS "Cloning ${_DEP_NAME}: ${_DEP_URL} - done")
        message(STATUS "Checking out ${_DEP_NAME}: ${_DEP_TAG}")
        execute_process(
            COMMAND git checkout ${_DEP_TAG}
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Checking out ${_DEP_NAME}: ${_DEP_TAG} - FAIL")
        endif()
        message(STATUS "Checking out ${_DEP_NAME}: ${_DEP_TAG} - done")
        message(STATUS "Updating ${_DEP_NAME}")
        execute_process(
            COMMAND git submodule update --init --recursive
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Updating ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Updating ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}.a)
        message(STATUS "Installing ${_DEP_NAME}")
        execute_process(
            COMMAND make
                    PREFIX=${_DEP_PREFIX}
                    HIREDIS=${HIREDIS_PREFIX}
                    CC=${CMAKE_C_COMPILER}
                    CXX=${CMAKE_CXX_COMPILER}
                    all
                    install
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
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

if(NOT TARGET ${_DEP_NAME}::${_DEP_NAME}_cmd AND EXISTS ${_DEP_BIN_DIR}/${_DEP_NAME}_cmd)
    add_executable(${_DEP_NAME}::${_DEP_NAME}_cmd IMPORTED)
    set_target_properties(${_DEP_NAME}::${_DEP_NAME}_cmd PROPERTIES
        IMPORTED_LOCATION "${_DEP_BIN_DIR}/${_DEP_NAME}_cmd")
endif()
if(NOT TARGET ${_DEP_NAME}::${_DEP_NAME} AND EXISTS ${_DEP_LIB_DIR}/lib${_DEP_NAME}.a)
    add_library(${_DEP_NAME}::${_DEP_NAME} STATIC IMPORTED)
    set_target_properties(${_DEP_NAME}::${_DEP_NAME} PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/lib${_DEP_NAME}.a"
        INTERFACE_LINK_LIBRARIES "hiredis::hiredis"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_TAG)
unset(_DEP_URL)
unset(_DEP_PREFIX)
unset(_DEP_BIN_DIR)
unset(_DEP_LIB_DIR)
unset(_DEP_INCLUDE_DIR)
