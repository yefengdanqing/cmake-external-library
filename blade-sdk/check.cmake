get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

set(_DEP_VER blade_cpp_sdk_cpu-0.0.0-Linux)
if(${USE_TORCH_CUDA})
    set(_DEP_VER blade_cpp_sdk_gpu-0.0.0-Linux)
endif()
set(_DEP_URL s3://mob-emr-test/ml-platform/ml-thirdparty-libs/blade-sdk/${_DEP_VER}.tar.gz)
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
    get_filename_component(DEPS_DIR ${CMAKE_CURRENT_LIST_DIR} DGIRECTORY)
    message(STATUS "Dependencies directory has been set to: ${DEPS_DIR}")
endif()
message(STATUS "${_DEP_UNAME}_PREFIX: ${_DEP_PREFIX}")

CheckVersion()

if(NOT EXISTS ${_DEP_PREFIX}/lib/libtorch_blade.so)
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/packages/${_DEP_VER}.tar.gz)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/packages)
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_URL}")
        execute_process(
            COMMAND aws s3 cp ${_DEP_URL} ${CMAKE_CURRENT_LIST_DIR}/packages/
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_URL} - done")
    endif()
    set(TAR ON)
    if(${TAR})
        message(STATUS "Extracting ${_DEP_NAME}")
        execute_process(
            COMMAND tar --exclude disc_compiler_main -zxvf ${CMAKE_CURRENT_LIST_DIR}/packages/${_DEP_VER}.tar.gz --strip-components=3 -C ${DEPS_DIR}/${_DEP_NAME}
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

if(NOT TARGET ${_DEP_NAME}::${_DEP_NAME} AND EXISTS ${_DEP_PREFIX}/lib/libral_base_context.so)
    add_library(libral_base_context SHARED IMPORTED)
    set_target_properties(libral_base_context PROPERTIES IMPORTED_LOCATION "${_DEP_PREFIX}/lib/libral_base_context.so")
    add_library(libtorch_blade SHARED IMPORTED)
    set_target_properties(libtorch_blade PROPERTIES IMPORTED_LOCATION "${_DEP_PREFIX}/lib/libtorch_blade.so")
    set(BLADE_SDK_LIBRARIES libral_base_context libtorch_blade)
endif()

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_VER)
unset(_DEP_URL)
unset(_DEP_PREFIX)
unset(_DEP_BIN_DIR)
unset(_DEP_LIB_DIR)
unset(_DEP_INCLUDE_DIR)
