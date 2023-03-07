include(${CMAKE_CURRENT_LIST_DIR}/../zeromq/check.cmake OPTIONAL)
if("${ZEROMQ_PREFIX}" STREQUAL "")
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires zeromq")
endif()
if(NOT TARGET libzmq-static)
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires libzmq-static")
endif()

get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

set(_DEP_VER 4.2.0)
set(_DEP_URL https://github.com/zeromq/${_DEP_NAME}/archive/${_DEP_VER}.tar.gz)

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

if(NOT EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}-static.a)
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/packages/${_DEP_NAME}.tar.gz)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/packages)
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_URL}")
        execute_process(
            COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/${_DEP_NAME}.tar.gz ${_DEP_URL}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_URL} - done")
    endif()
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/CMakeLists.txt)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src)
        message(STATUS "Extracting ${_DEP_NAME}")
        execute_process(
            COMMAND tar -xf ${CMAKE_CURRENT_LIST_DIR}/packages/${_DEP_NAME}.tar.gz
                        --strip-components 1 -C ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Extracting ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/build/CMakeCache.txt)
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
                    -DCMAKE_PREFIX_PATH=${ZEROMQ_PREFIX}
                    ${CMAKE_CURRENT_LIST_DIR}/src
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Configuring ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/build/lib${_DEP_NAME}-static.a)
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
    if(NOT EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}-static.a)
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

if(NOT TARGET ${_DEP_NAME}::lib${_DEP_NAME} AND EXISTS ${_DEP_LIB_DIR}/lib${_DEP_NAME}.so)
    add_library(${_DEP_NAME}::lib${_DEP_NAME} SHARED IMPORTED)
    set_target_properties(${_DEP_NAME}::lib${_DEP_NAME} PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/lib${_DEP_NAME}.so"
        INTERFACE_LINK_LIBRARIES "libzmq"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET ${_DEP_NAME}::lib${_DEP_NAME}-static AND EXISTS ${_DEP_LIB_DIR}/lib${_DEP_NAME}-static.a)
    add_library(${_DEP_NAME}::lib${_DEP_NAME}-static STATIC IMPORTED)
    set_target_properties(${_DEP_NAME}::lib${_DEP_NAME}-static PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/lib${_DEP_NAME}-static.a"
        INTERFACE_LINK_LIBRARIES "libzmq-static"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_VER)
unset(_DEP_URL)
unset(_DEP_PREFIX)
unset(_DEP_BIN_DIR)
unset(_DEP_LIB_DIR)
unset(_DEP_INCLUDE_DIR)
