get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

set(_DEP_VER_MAJOR 2)
set(_DEP_VER_MINOR 7)
set(_DEP_VER_PATCH 15)
set(_DEP_VER ${_DEP_VER_MAJOR}.${_DEP_VER_MINOR})
set(_DEP_VER_ ${_DEP_VER}.${_DEP_VER_PATCH})
set(_DEP_URL https://www.python.org/ftp/python/${_DEP_VER_}/Python-${_DEP_VER_}.tgz)

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

if(NOT EXISTS ${_DEP_PREFIX}/bin/${_DEP_NAME})
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
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/README)
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
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/Makefile)
        message(STATUS "Configuring ${_DEP_NAME}")
        execute_process(
            COMMAND env
                    CC=${CMAKE_C_COMPILER}
                    CXX=${CMAKE_CXX_COMPILER}
                    ./configure
                    --prefix=${_DEP_PREFIX}
                    --enable-shared
                    --enable-unicode=ucs4
                    --with-ensurepip=yes
                    LDFLAGS=-Wl,-rpath,\\\$\$ORIGIN/../lib
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Configuring ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/python)
        message(STATUS "Building ${_DEP_NAME}")
        include(ProcessorCount)
        ProcessorCount(cpus)
        execute_process(
            COMMAND env
                    CC=${CMAKE_C_COMPILER}
                    CXX=${CMAKE_CXX_COMPILER}
                    make
                    -j${cpus}
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Building ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${_DEP_PREFIX}/bin/${_DEP_NAME})
        message(STATUS "Installing ${_DEP_NAME}")
        execute_process(
            COMMAND env
                    CC=${CMAKE_C_COMPILER}
                    CXX=${CMAKE_CXX_COMPILER}
                    make
                    install
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Installing ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${_DEP_PREFIX}/bin/f2py)
        message(STATUS "Updating ${_DEP_NAME} pip")
        execute_process(
            COMMAND env
                    CC=${CMAKE_C_COMPILER}
                    CXX=${CMAKE_CXX_COMPILER}
                    ${_DEP_PREFIX}/bin/${_DEP_NAME}
                    -m pip install --upgrade
                    pip setuptools wheel six numpy
                    --trusted-host pypi.python.org
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Updating ${_DEP_NAME} pip - FAIL")
        endif()
        message(STATUS "Updating ${_DEP_NAME} pip - done")
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
if(EXISTS ${_DEP_INCLUDE_DIR}/python${_DEP_VER})
    set(_DEP_INCLUDE_PATH ${_DEP_INCLUDE_DIR}/python${_DEP_VER})
    set(${_DEP_UNAME}_INCLUDE_PATH ${_DEP_INCLUDE_PATH})
    set(${_DEP_UNAME}_VERSION_MAJOR ${_DEP_VER_MAJOR})
    set(${_DEP_UNAME}_VERSION_MINOR ${_DEP_VER_MINOR})
    set(${_DEP_UNAME}_VERSION ${_DEP_VER})
endif()

if(NOT TARGET ${_DEP_NAME}::${_DEP_NAME} AND EXISTS ${_DEP_BIN_DIR}/${_DEP_NAME})
    add_executable(${_DEP_NAME}::${_DEP_NAME} IMPORTED)
    set_target_properties(${_DEP_NAME}::${_DEP_NAME} PROPERTIES
        IMPORTED_LOCATION "${_DEP_BIN_DIR}/${_DEP_NAME}")
endif()
if(NOT TARGET ${_DEP_NAME}::libpython AND EXISTS ${_DEP_LIB_DIR}/libpython${_DEP_VER}.so)
    add_library(${_DEP_NAME}::libpython SHARED IMPORTED)
    set_target_properties(${_DEP_NAME}::libpython PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/libpython${_DEP_VER}.so"
        INTERFACE_LINK_LIBRARIES "pthread"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_PATH}"
        INTERFACE_COMPILE_OPTIONS "-pthread")
endif()

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_VER_MAJOR)
unset(_DEP_VER_MINOR)
unset(_DEP_VER_PATCH)
unset(_DEP_VER)
unset(_DEP_VER_)
unset(_DEP_URL)
unset(_DEP_PREFIX)
unset(_DEP_BIN_DIR)
unset(_DEP_LIB_DIR)
unset(_DEP_INCLUDE_DIR)
unset(_DEP_INCLUDE_PATH)
