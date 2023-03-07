### check cuda env and if it exist return
CheckCUDA()
if(NVCC_EXECUTABLE)
    message(STATUS "command NVCC found will exit")
    #return()
endif()

include(${CMAKE_CURRENT_LIST_DIR}/../curl/check.cmake OPTIONAL)
if("${CURL_PREFIX}" STREQUAL "")
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires curl")
endif()
if(NOT TARGET curl::libcurl)
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires curl::libcurl")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/../protobuf3/check.cmake OPTIONAL)
if("${PROTOBUF3_PREFIX}" STREQUAL "")
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires protobuf")
endif()
if(NOT TARGET protobuf::protobuf)
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires protobuf::protobuf")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/../gtest/check.cmake OPTIONAL)
if("${GTEST_PREFIX}" STREQUAL "")
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires gtest")
endif()
if(NOT TARGET GTest::gtest)
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires GTest::gtest")
endif()
if(NOT TARGET GTest::gtest_main)
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires GTest::gtest_main")
endif()

get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)
string(REPLACE "_" "-" _DEP_LNAME "${_DEP_NAME}")

set(_DEP_BRANCH sparse_hash_rebase_1.3.0)
set(_DEP_TAG 0b6eee64f4a320c42786b31a16ccd9668870616d)
set(_DEP_URL git@gitlab.mobvista.com:ml-platform/mxnet.git)
set(_S3_DEP_URL s3://mob-emr-test/ml-platform/ml-thirdparty-libs/mxnet.tar.gz)

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

if(NOT EXISTS ${_DEP_PREFIX}/lib/libmxnet.so)
    # mxnet set
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/packages/mxnet.tar.gz)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/packages)
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_URL}")
        execute_process(
            COMMAND aws s3 cp ${_S3_DEP_URL} ${CMAKE_CURRENT_LIST_DIR}/packages/
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_S3_DEP_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_S3_DEP_URL} - done")
        execute_process(
            COMMAND tar -xvf ${CMAKE_CURRENT_LIST_DIR}/packages/mxnet.tar.gz --strip-components=1 -C ${DEPS_DIR}/${_DEP_NAME}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Extracting ${_DEP_NAME} - done")
    endif()
    file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/packages)
endif()

if(NOT EXISTS ${_DEP_PREFIX}/lib/libmxnet.so)
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
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/build/libmxnet.so)
        message(STATUS "Clearing ${_DEP_NAME}")
        execute_process(
            COMMAND rm -rf build built
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Clearing ${_DEP_NAME} - FAIL")
        endif()
        execute_process(
            COMMAND git clean -dfx
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Clearing ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Clearing ${_DEP_NAME} - done")
        message(STATUS "Building ${_DEP_NAME}")
        execute_process(
            COMMAND sh build_centos7_predict.sh ${DEPS_DIR}
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Building ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${_DEP_PREFIX}/lib/libmxnet.so)
        message(STATUS "Installing ${_DEP_NAME}")
        file(MAKE_DIRECTORY ${_DEP_PREFIX}/lib)
        file(MAKE_DIRECTORY ${_DEP_PREFIX}/include)
        file(MAKE_DIRECTORY ${_DEP_PREFIX}/share)
        execute_process(
            COMMAND sh -c "cp -a built/lib64/*.so* ${_DEP_PREFIX}/lib"
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} - FAIL")
        endif()
        execute_process(
            COMMAND sh -c "cp -a built/include/{mxnet-cpp,mxnet,dmlc,nnvm} ${_DEP_PREFIX}/include"
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Installing ${_DEP_NAME} - done")
    endif()
    message(STATUS "Clean ${_DEP_NAME}")
    execute_process(
        COMMAND rm -rf src
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
        RESULT_VARIABLE rc)
    if(NOT "${rc}" STREQUAL "0")
        message(FATAL_ERROR "Clean ${_DEP_NAME} - FAIL")
    endif()
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

if(NOT TARGET ${_DEP_NAME}::mxnet_shared AND EXISTS ${_DEP_LIB_DIR}/libmxnet.so)
    add_library(${_DEP_NAME}::mxnet_shared SHARED IMPORTED)
    set_target_properties(${_DEP_NAME}::mxnet_shared PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libmxnet.so"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()

set(${_DEP_UNAME}_WHEEL_PACKAGE ${_DEP_PREFIX}/share/mxnet-1.3.0-cp27-cp27mu-linux_x86_64.whl)
set(${_DEP_UNAME}_GRAPH_CONVERTER ${_DEP_PREFIX}/share/graph_converter.py)
set(${_DEP_UNAME}_LIBMXNET_SO ${_DEP_LIB_DIR}/libmxnet.so)

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_LNAME)
unset(_DEP_BRANCH)
unset(_DEP_TAG)
unset(_DEP_URL)
unset(_DEP_PREFIX)
unset(_DEP_BIN_DIR)
unset(_DEP_LIB_DIR)
unset(_DEP_INCLUDE_DIR)
