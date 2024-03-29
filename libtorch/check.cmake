if(${USE_TORCH_CUDA})
    include(${CMAKE_CURRENT_LIST_DIR}/../cuda/check.cmake)
    #include(${CMAKE_CURRENT_LIST_DIR}/../faiss/check.cmake) # temporary delete mkl,faiss in the nps-image 
    #include(${CMAKE_CURRENT_LIST_DIR}/../xgboost/check.cmake)
endif()
get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)


#set(_DEP_VER 1.7.1)
#set(_DEP_URL https://download.pytorch.org/libtorch/cpu/libtorch-shared-with-deps-1.7.1%2Bcpu.zip)
#set(_DEP_VER 1.11.0)
set(_DEP_VER 1.8.2)
#set(_DEP_URL https://download.pytorch.org/libtorch/cpu/libtorch-shared-with-deps-1.11.0%2Bcpu.zip)
set(_DEP_URL https://download.pytorch.org/libtorch/lts/1.8/cpu/libtorch-shared-with-deps-1.8.2%2Bcpu.zip)
if(${USE_TORCH_CUDA})
    #set(_DEP_URL https://download.pytorch.org/libtorch/cu110/libtorch-shared-with-deps-1.7.1%2Bcu110.zip)
    #set(_DEP_URL https://download.pytorch.org/libtorch/cu113/libtorch-cxx11-abi-shared-with-deps-1.11.0%2Bcu113.zip)
    set(_DEP_URL https://download.pytorch.org/libtorch/lts/1.8/cu111/libtorch-shared-with-deps-1.8.2%2Bcu111.zip)
endif()

if(${USE_DEV_LIBTORCH})
    set(_DEP_VER ${DEV_LIBTORCH_VERSION})
    set(_DEP_URL https://download.pytorch.org/libtorch/cpu/libtorch-shared-with-deps-${_DEP_VER}%2Bcpu.zip)
    if(${USE_TORCH_CUDA})
        set(_DEP_URL https://download.pytorch.org/libtorch/cu113/libtorch-shared-with-deps-${_DEP_VER}%2Bcu113.zip)
    endif()
endif()

message(STATUS "${_DEP_UNAME} is ${_DEP_URL}")

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

if(NOT EXISTS ${_DEP_PREFIX}/lib/libtorch.so)
    message(STATUS "################### redownload ################")
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/packages/${_DEP_NAME}.zip)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/packages)
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_URL}")
        execute_process(
            COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/${_DEP_NAME}.zip ${_DEP_URL}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_URL} - done")
    endif()
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/libtorch/include/torch/script.h)
        message(STATUS "Extracting ${_DEP_NAME}")
        execute_process(
            COMMAND unzip ${CMAKE_CURRENT_LIST_DIR}/packages/${_DEP_NAME}.zip
            -d ${DEPS_DIR}/
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Extracting ${_DEP_NAME} - done")
    endif()
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
if(EXISTS ${_DEP_PREFIX}/share)
    set(_DEP_LIB_DIR ${_DEP_PREFIX}/share)
    set(${_DEP_UNAME}_SHARE ${_DEP_LIB_DIR})
endif()
if(EXISTS ${_DEP_PREFIX}/include)
    set(_DEP_INCLUDE_DIR ${_DEP_PREFIX}/include)
    set(${_DEP_UNAME}_INCLUDE_DIR ${_DEP_INCLUDE_DIR})
endif()

list(FIND CMAKE_PREFIX_PATH ${_DEP_PREFIX} _DEP_INDEX)
if(_DEP_INDEX EQUAL -1)
    list(APPEND CMAKE_PREFIX_PATH ${_DEP_PREFIX})
endif()

find_package(Torch REQUIRED CONFIG)
string(REGEX REPLACE "\\." "" LIBTORCH_VERSION_INT "${_DEP_VER}")
message("############### current ${LIBTORCH_VERSION} ${LIBTORCH_VERSION_INT} #####################")
unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_VER)
unset(_DEP_URL)
unset(_DEP_PREFIX)
unset(_DEP_BIN_DIR)
unset(_DEP_LIB_DIR)
unset(_DEP_INCLUDE_DIR)

