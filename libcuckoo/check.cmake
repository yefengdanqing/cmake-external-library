get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)
string(REPLACE "_" "-" _DEP_LNAME "${_DEP_NAME}")

set(_DEP_BRANCH master)
set(_DEP_TAG f935d0c5a41ee84bf8838fe2e465dd08f7f4e42b)
set(_DEP_URL https://github.com/efficient/libcuckoo.git)

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

if(NOT EXISTS ${_DEP_PREFIX}/include/libcuckoo/cuckoohash_map.hh)
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/CMakeLists.txt)
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
        message(STATUS "Updating ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/build/build.ninja)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build)
        message(STATUS "Configuring ${_DEP_NAME}")
        execute_process(
            COMMAND ${CMAKE_COMMAND}
                    -G Ninja
                    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                    -DCMAKE_INSTALL_PREFIX=${_DEP_PREFIX}
                    -DBUILD_SHARED_LIBS=OFF
                    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                    ${CMAKE_CURRENT_LIST_DIR}/src
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Configuring ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${_DEP_PREFIX}/include/libcuckoo/cuckoohash_map.hh)
        message(STATUS "Installing ${_DEP_NAME}")
        execute_process(
            COMMAND ninja install
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build
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

list(FIND CMAKE_PREFIX_PATH ${_DEP_PREFIX} _DEP_INDEX)
if(_DEP_INDEX EQUAL -1)
    list(APPEND CMAKE_PREFIX_PATH ${_DEP_PREFIX})
endif()
find_package(${_DEP_NAME} REQUIRED CONFIG)

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_LNAME)
unset(_DEP_BRANCH)
unset(_DEP_TAG)
unset(_DEP_URL)
unset(_DEP_PREFIX)
unset(_DEP_INDEX)
