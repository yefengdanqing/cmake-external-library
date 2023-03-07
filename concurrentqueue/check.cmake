get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)
string(REPLACE "_" "-" _DEP_LNAME "${_DEP_NAME}")

set(_DEP_TAG 7e8f20941fa00a784ab06c89f13e4ddec7708c28)
set(_DEP_URL https://github.com/cameron314/concurrentqueue.git)

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

if(NOT EXISTS ${_DEP_PREFIX}/include/concurrentqueue/concurrentqueue.h)
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/concurrentqueue.h)
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
    endif()
    if(NOT EXISTS ${_DEP_PREFIX}/include/concurrentqueue/concurrentqueue.h)
        message(STATUS "Installing ${_DEP_NAME}")
        execute_process(
            COMMAND mkdir -p ${_DEP_PREFIX}/include/concurrentqueue/
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "mkdir -p ${_DEP_NAME} - FAIL")
        endif()
        execute_process(
            COMMAND cp -r internal concurrentqueue.h blockingconcurrentqueue.h ${_DEP_PREFIX}/include/concurrentqueue/
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "cp -r ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Installing ${_DEP_NAME} - done")
    endif()
    file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/src)
endif()

if(EXISTS ${_DEP_PREFIX}/include)
    set(_DEP_INCLUDE_DIR ${_DEP_PREFIX}/include)
    set(${_DEP_UNAME}_INCLUDE_DIR ${_DEP_INCLUDE_DIR})
endif()

if(NOT TARGET ${_DEP_NAME}::${_DEP_NAME} AND EXISTS ${_DEP_INCLUDE_DIR}/${_DEP_NAME})
    add_library(${_DEP_NAME}::${_DEP_NAME} IMPORTED INTERFACE)
    set_target_properties(${_DEP_NAME}::${_DEP_NAME} PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_LNAME)
unset(_DEP_TAG)
unset(_DEP_URL)
unset(_DEP_PREFIX)
unset(_DEP_INCLUDE_DIR)
