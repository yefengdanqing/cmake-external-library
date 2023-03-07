include(${CMAKE_CURRENT_LIST_DIR}/../gtest/check.cmake OPTIONAL)
include(${CMAKE_CURRENT_LIST_DIR}/../sparsehash/check.cmake OPTIONAL)
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
if (${CMAKE_CXX_STANDARD} LESS 20)
    include(${CMAKE_CURRENT_LIST_DIR}/../mxnet_sdk/check.cmake OPTIONAL)
    if("${MXNET_SDK_PREFIX}" STREQUAL "")
        get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
        message(FATAL_ERROR "${_DEP_NAME} requires mxnet_sdk")
    endif()
    if(NOT TARGET mxnet_sdk::mxnet_shared)
        get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
        message(FATAL_ERROR "${_DEP_NAME} requires mxnet_sdk::mxnet_shared")
    endif()
endif()


get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)
string(REPLACE "_" "-" _DEP_LNAME "${_DEP_NAME}")

set(_DEP_BRANCH master)
set(_DEP_TAG 8ec7f5c463aa2960ba922c0c1304e107d7614fe8)
set(_DEP_URL git@gitlab.mobvista.com:ml-platform/${_DEP_LNAME}.git)
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

message(STATUS "${_DEP_PREFIX}/lib/cmake/${_DEP_NAME}/${_DEP_NAME}-targets.cmake")
if(NOT EXISTS ${_DEP_PREFIX}/lib/cmake/${_DEP_NAME}/${_DEP_NAME}-targets.cmake)
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
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/build/build.ninja)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build)
        message(STATUS "Configuring ${_DEP_NAME}")
        execute_process(
            COMMAND ${CMAKE_COMMAND}
                    -G Ninja
                    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
                    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                    -DCMAKE_INSTALL_PREFIX=${_DEP_PREFIX}
                    -DBUILD_SHARED_LIBS=OFF
                    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                    -DDEPS_DIR=${DEPS_DIR}
                    -DPYTHON2_PREFIX=${PYTHON2_PREFIX}
                    -DPYTHON3_PREFIX=${PYTHON3_PREFIX}
                    -DBOOST_PREFIX=${BOOST_PREFIX}
                    -DC-ARES_PREFIX=${C-ARES_PREFIX}
                    -DFMT_PREFIX=${FMT_PREFIX}
                    -DPROTOBUF_PREFIX=${PROTOBUF_PREFIX}
                    -DLZ4_PREFIX=${LZ4_PREFIX}
                    -DYAML-CPP_PREFIX=${YAML_CPP_PREFIX}
                    -DSEASTAR_PREFIX=${SEASTAR_PREFIX}
                    -DOPENSSL_PREFIX=${OPENSSL_PREFIX}
                    -DCURL_PREFIX=${CURL_PREFIX}
                    -DJSON11_PREFIX=${JSON11_PREFIX}
                    -DCONCURRENTQUEUE_PPREFIX=${CONCURRENTQUEUE_PPREFIX}
                    -DSPDLOG_PREFIX=${SPDLOG_PREFIX}
                    -DLOG4CPLUS_PREFIX=${LOG4CPLUS_PREFIX}
                    -DLIBUNWIND_PREFIX=${LIBUNWIND_PREFIX}
                    -DGPERFTOOLS_PREFIX=${GPERFTOOLS_PREFIX}
                    -DLIBEVENT_PREFIX=${LIBEVENT_PREFIX}
                    -DTHRIFT_PREFIX=${THRIFT_PREFIX}
                    -DMXNET_SDK_PREFIX=${MXNET_SDK_PREFIX}
                    -DGTEST_PREFIX=${GTEST_PREFIX}
                    -DUSE_TORCH_CUDA=${USE_TORCH_CUDA}
                    -DUSE_DEV_LIBTORCH=${USE_DEV_LIBTORCH}
                    -DDEV_LIBTORCH_VERSION=${DEV_LIBTORCH_VERSION}
                    -DLIBTORCH_VERSION=${LIBTORCH_VERSION_INT}
                    -DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}
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
    if(NOT EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}.a)
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
    if(NOT EXISTS ${_DEP_PREFIX}/share/graph_converter.py)
        file(MAKE_DIRECTORY ${_DEP_PREFIX}/share)
        execute_process(
            COMMAND sh -c "cp -a tools/graph_converter.py ${_DEP_PREFIX}/share"
			WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} - FAIL")
        endif()
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
endif()
set(${_DEP_UNAME}_GRAPH_CONVERTER ${_DEP_PREFIX}/share/graph_converter.py)
#find_package(${_DEP_NAME} REQUIRED CONFIG)
find_package(ml_utilities REQUIRED CONFIG)
find_package(ml_parallel REQUIRED CONFIG)
find_package(ml_async REQUIRED CONFIG)
find_package(ml_data_structures REQUIRED CONFIG)
find_package(ml_feature_extraction REQUIRED CONFIG)
find_package(ml_deviceinfo_cpp REQUIRED CONFIG)
find_package(ml_rpc REQUIRED CONFIG)
find_package(ml_networking REQUIRED CONFIG)
find_package(ml_fly REQUIRED CONFIG)
find_package(ml_predict_service_protocol REQUIRED CONFIG)
find_package(ml_mapping_service_protocol REQUIRED CONFIG)
find_package(ml_cache_service_protocol REQUIRED CONFIG)
find_package(ml_eagle REQUIRED CONFIG)
find_package(ml_model_service_client REQUIRED CONFIG)
find_package(ml_tests REQUIRED CONFIG)
if (${CMAKE_CXX_STANDARD} LESS 20)
    find_package(ml_ranking REQUIRED CONFIG)
    find_package(ml_reflection REQUIRED CONFIG)
    find_package(ml_stream REQUIRED CONFIG)
endif()

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
unset(_DEP_INDEX)
