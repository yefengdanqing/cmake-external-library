include(${CMAKE_CURRENT_LIST_DIR}/../boost/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../c-ares/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../fmt/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../protobuf3/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../lz4/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../yaml-cpp/check.cmake)

get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

set(_DEP_URL https://github.com/scylladb/${_DEP_NAME}.git)
if (${CMAKE_CXX_STANDARD} GREATER_EQUAL 20)
    set(_DEP_TAG e5f4a8859f4a42e13fa97a6b06ce406a60306a94)
else()
    set(_DEP_TAG bfc3d4556dc82472e3bcffcb27720ed3b91a67ea)
endif()
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
if(NOT EXISTS ${_DEP_PREFIX}/lib64/lib${_DEP_NAME}.a)
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/README.md)
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
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/build/build.ninja)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build)
        message(STATUS "Configuring ${_DEP_NAME}, CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH}")
        string (REPLACE ";" "\\;" CMAKE_PREFIX_PATH_STR "${CMAKE_PREFIX_PATH}")
        execute_process(
            COMMAND ${CMAKE_COMMAND}
                    -G Ninja
                    -DDEPS_DIR=${DEPS_DIR}
                    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                    -DCMAKE_INSTALL_PREFIX=${_DEP_PREFIX}
                    -DBUILD_SHARED_LIBS=OFF
                    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
                    -DSeastar_APPS=OFF
                    -DSeastar_DEMOS=OFF
                    -DSeastar_DOCS=OFF
                    -DSeastar_EXCLUDE_TESTS_FROM_ALL=ON
                    -DSeastar_GCC6_CONCEPTS=ON
                    -DSeastar_CXX_DIALECT=c++${CMAKE_CXX_STANDARD}
                    -DSeastar_NUMA=OFF
                    -DSeastar_HWLOC=OFF
                    -DSeastar_STD_OPTIONAL_VARIANT_STRINGVIEW=ON
                    -DSeastar_TESTING=OFF
                    -DProtobuf_USE_STATIC_LIBS=ON
                    -DBOOST_ROOT=${BOOST_ROOT}
                    -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH_STR}
                    -DSeastar_COMPRESS_DEBUG=OFF
                    ${CMAKE_CURRENT_LIST_DIR}/src
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Configuring ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/build/lib${_DEP_NAME}.a)
        message(STATUS "Building ${_DEP_NAME}")
        execute_process(
            COMMAND ninja
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Building ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${_DEP_PREFIX}/lib64/lib${_DEP_NAME}.a)
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

list(FIND CMAKE_PREFIX_PATH ${_DEP_PREFIX} _DEP_INDEX)
if(_DEP_INDEX EQUAL -1)
    list(APPEND CMAKE_PREFIX_PATH ${_DEP_PREFIX})
    list(APPEND CMAKE_MODULE_PATH ${_DEP_PREFIX}/lib64/cmake/Seastar/)
endif()
find_package(Seastar REQUIRED CONFIG)

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_TAG)
unset(_DEP_URL)
unset(_DEP_PREFIX)
unset(_DEP_BIN_DIR)
unset(_DEP_LIB_DIR)
unset(_DEP_INCLUDE_DIR)
