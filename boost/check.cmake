include(${CMAKE_CURRENT_LIST_DIR}/../python2/check.cmake OPTIONAL)
if("${PYTHON2_PREFIX}" STREQUAL "")
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires python2")
endif()
if(NOT TARGET python2::libpython)
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires python2::libpython")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/../python3/check.cmake OPTIONAL)
if("${PYTHON3_PREFIX}" STREQUAL "")
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires python3")
endif()
if(NOT TARGET python3::libpython)
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires python3::libpython")
endif()

get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

set(_DEP_VER 1.76.0)
string(REPLACE "." "_" _DEP_VER_ "${_DEP_VER}")
set(_DEP_URL https://boostorg.jfrog.io/artifactory/main/release/${_DEP_VER}/source/${_DEP_NAME}_${_DEP_VER_}.tar.gz)

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

find_program(PATCH_EXECUTABLE patch)
if(NOT PATCH_EXECUTABLE)
    message(FATAL_ERROR "command patch not found")
endif()
find_program(WGET_EXECUTABLE wget)
if(NOT WGET_EXECUTABLE)
    message(FATAL_ERROR "command wget not found")
endif()

if(NOT EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}_python3.a)
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/packages/${_DEP_NAME}.tar.gz)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/packages)
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_URL}")
        execute_process(
            COMMAND ${WGET_EXECUTABLE} -O ${CMAKE_CURRENT_LIST_DIR}/packages/${_DEP_NAME}.tar.gz ${_DEP_URL}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_URL} - done")
    endif()
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/index.html)
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
    if(NOT EXISTS ${_DEP_PREFIX}/bin/b2)
        if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/tools/build/b2)
            message(STATUS "Building ${_DEP_NAME} b2")
            execute_process(
                COMMAND env
                        CC=${CMAKE_C_COMPILER}
                        ./bootstrap.sh
                        --with-toolset=cc
                WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/tools/build
                RESULT_VARIABLE rc)
            if(NOT "${rc}" STREQUAL "0")
                message(FATAL_ERROR "Building ${_DEP_NAME} b2 - FAIL")
            endif()
            message(STATUS "Building ${_DEP_NAME} b2 - done")
        endif()
        if(NOT EXISTS ${_DEP_PREFIX}/bin/b2)
            message(STATUS "Installing ${_DEP_NAME} b2")
            execute_process(
                COMMAND ./b2 --prefix=${_DEP_PREFIX} install
                WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/tools/build
                RESULT_VARIABLE rc)
            if(NOT "${rc}" STREQUAL "0")
                message(FATAL_ERROR "Installing ${_DEP_NAME} b2 - FAIL")
            endif()
            message(STATUS "Installing ${_DEP_NAME} b2 - done")
        endif()
    endif()
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/cc-wrappers/bin/g++)
        message(STATUS "Creating ${_DEP_NAME} g++ wrapper")
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/cc-wrappers/bin)
        file(WRITE ${CMAKE_CURRENT_LIST_DIR}/src/cc-wrappers/bin/g++
                   "#!/bin/bash\n\nset -e\nexec \"${CMAKE_CXX_COMPILER}\" \"\$@\"\n")
        execute_process(
            COMMAND chmod a+x ${CMAKE_CURRENT_LIST_DIR}/src/cc-wrappers/bin/g++
                RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Creating ${_DEP_NAME} g++ wrapper - FAIL")
        endif()
        message(STATUS "Creating ${_DEP_NAME} g++ wrapper - done")
    endif()
    if(NOT EXISTS ${_DEP_PREFIX}/bin/boostdep)
        if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/dist/bin/boostdep)
            message(STATUS "Building ${_DEP_NAME} boostdep")
            include(ProcessorCount)
            ProcessorCount(cpus)
            execute_process(
                COMMAND env
                        PATH=${CMAKE_CURRENT_LIST_DIR}/src/cc-wrappers/bin:$ENV{PATH}
                        ${_DEP_PREFIX}/bin/b2
                        toolset=gcc
                        variant=release
                        debug-symbols=on
                        link=static
                        runtime-link=shared
                        threadapi=pthread
                        threading=multi
                        cxxflags=-fPIC
                        --without-mpi
                        --without-python
                        -j${cpus}
                WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/tools/boostdep/build
                RESULT_VARIABLE rc)
            if(NOT "${rc}" STREQUAL "0")
                message(FATAL_ERROR "Building ${_DEP_NAME} boostdep - FAIL")
            endif()
            message(STATUS "Building ${_DEP_NAME} boostdep - done")
        endif()
        if(NOT EXISTS ${_DEP_PREFIX}/bin/boostdep)
            message(STATUS "Stripping ${_DEP_NAME} boostdep")
            execute_process(
                COMMAND strip
                        ${CMAKE_CURRENT_LIST_DIR}/src/dist/bin/boostdep
                RESULT_VARIABLE rc)
            if(NOT "${rc}" STREQUAL "0")
                message(FATAL_ERROR "Stripping ${_DEP_NAME} boostdep - FAIL")
            endif()
            message(STATUS "Stripping ${_DEP_NAME} boostdep - done")
            message(STATUS "Installing ${_DEP_NAME} boostdep")
            file(COPY ${CMAKE_CURRENT_LIST_DIR}/src/dist/bin/boostdep
                 DESTINATION ${_DEP_PREFIX}/bin)
            message(STATUS "Installing ${_DEP_NAME} boostdep - done")
        endif()
    endif()
    if(NOT EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}_system.a)
        message(STATUS "Building ${_DEP_NAME}")
        include(ProcessorCount)
        ProcessorCount(cpus)
        execute_process(
            COMMAND env
                    PATH=${CMAKE_CURRENT_LIST_DIR}/src/cc-wrappers/bin:$ENV{PATH}
                    ${_DEP_PREFIX}/bin/b2
                    toolset=gcc
                    variant=release
                    debug-symbols=on
                    link=static
                    runtime-link=shared
                    threadapi=pthread
                    threading=multi
                    cxxflags=-fPIC
                    -j${cpus}
                    --without-mpi
                    --without-python
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Building ${_DEP_NAME} - done")
        message(STATUS "Installing ${_DEP_NAME}")
        execute_process(
            COMMAND env
                    PATH=${CMAKE_CURRENT_LIST_DIR}/src/cc-wrappers/bin:$ENV{PATH}
                    ${_DEP_PREFIX}/bin/b2
                    toolset=gcc
                    variant=release
                    debug-symbols=on
                    link=static
                    runtime-link=shared
                    threadapi=pthread
                    threading=multi
                    cxxflags=-fPIC
                    -j${cpus}
                    --without-mpi
                    --without-python
                    --prefix=${_DEP_PREFIX}
                    install
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Installing ${_DEP_NAME} - done")
        message(STATUS "Patching ${_DEP_NAME}")
        file(WRITE ${_DEP_PREFIX}/include/${_DEP_NAME}/utility.hpp.patch
                   "17a18\n> #include <${_DEP_NAME}/next_prior.hpp>\n")
        execute_process(
            COMMAND ${PATCH_EXECUTABLE}
                    ${_DEP_PREFIX}/include/${_DEP_NAME}/utility.hpp
                    ${_DEP_PREFIX}/include/${_DEP_NAME}/utility.hpp.patch
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Patching ${_DEP_NAME} - FAIL")
        endif()
        file(REMOVE ${_DEP_PREFIX}/include/${_DEP_NAME}/utility.hpp.patch)
        message(STATUS "Patching ${_DEP_NAME} - done")
        message(STATUS "Clearing ${_DEP_NAME}")
        execute_process(
            COMMAND env
                    PATH=${CMAKE_CURRENT_LIST_DIR}/src/cc-wrappers/bin:$ENV{PATH}
                    ${_DEP_PREFIX}/bin/b2
                    toolset=gcc
                    variant=release
                    debug-symbols=on
                    link=static
                    runtime-link=shared
                    threadapi=pthread
                    threading=multi
                    cxxflags=-fPIC
                    -j${cpus}
                    --without-mpi
                    --without-python
                    --clean
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Clearing ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Clearing ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}_python2.a)
        message(STATUS "Building ${_DEP_NAME} python2")
        include(ProcessorCount)
        ProcessorCount(cpus)
        set(confstring)
        string(APPEND confstring "using python\n")
        string(APPEND confstring "    : ${PYTHON2_VERSION}\n")
        string(APPEND confstring "    : \"${PYTHON2_BIN_DIR}/python2\"\n")
        string(APPEND confstring "    : \"${PYTHON2_INCLUDE_PATH}\"\n")
        string(APPEND confstring "    : \"${PYTHON2_LIB_DIR}\"\n")
        string(APPEND confstring "    ;\n")
        file(WRITE ${CMAKE_CURRENT_LIST_DIR}/src/python2-config.jam "${confstring}")
        execute_process(
            COMMAND env
                    PATH=${CMAKE_CURRENT_LIST_DIR}/src/cc-wrappers/bin:$ENV{PATH}
                    ${_DEP_PREFIX}/bin/b2
                    toolset=gcc
                    variant=release
                    debug-symbols=on
                    link=static
                    runtime-link=shared
                    threadapi=pthread
                    threading=multi
                    cxxflags=-fPIC
                    -j${cpus}
                    --with-python
                    --config=${CMAKE_CURRENT_LIST_DIR}/src/python2-config.jam
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} python2 - FAIL")
        endif()
        message(STATUS "Building ${_DEP_NAME} python2 - done")
        message(STATUS "Installing ${_DEP_NAME} python2")
        execute_process(
            COMMAND env
                    PATH=${CMAKE_CURRENT_LIST_DIR}/src/cc-wrappers/bin:$ENV{PATH}
                    ${_DEP_PREFIX}/bin/b2
                    toolset=gcc
                    variant=release
                    debug-symbols=on
                    link=static
                    runtime-link=shared
                    threadapi=pthread
                    threading=multi
                    cxxflags=-fPIC
                    -j${cpus}
                    --with-python
                    --config=${CMAKE_CURRENT_LIST_DIR}/src/python2-config.jam
                    --prefix=${_DEP_PREFIX}
                    install
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} python2 - FAIL")
        endif()
        file(RENAME ${_DEP_PREFIX}/lib/lib${_DEP_NAME}_python2${PYTHON2_VERSION_MINOR}.a
                    ${_DEP_PREFIX}/lib/lib${_DEP_NAME}_python2.a)
        file(RENAME ${_DEP_PREFIX}/lib/lib${_DEP_NAME}_numpy2${PYTHON2_VERSION_MINOR}.a
                    ${_DEP_PREFIX}/lib/lib${_DEP_NAME}_numpy2.a)
        message(STATUS "Installing ${_DEP_NAME} python2 - done")
        message(STATUS "Clearing ${_DEP_NAME} python2")
        execute_process(
            COMMAND env
                    PATH=${CMAKE_CURRENT_LIST_DIR}/src/cc-wrappers/bin:$ENV{PATH}
                    ${_DEP_PREFIX}/bin/b2
                    toolset=gcc
                    variant=release
                    debug-symbols=on
                    link=static
                    runtime-link=shared
                    threadapi=pthread
                    threading=multi
                    cxxflags=-fPIC
                    -j${cpus}
                    --with-python
                    --config=${CMAKE_CURRENT_LIST_DIR}/src/python2-config.jam
                    --clean
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Clearing ${_DEP_NAME} python2 - FAIL")
        endif()
        file(REMOVE ${CMAKE_CURRENT_LIST_DIR}/src/python2-config.jam)
        message(STATUS "Clearing ${_DEP_NAME} python2 - done")
    endif()
    if(NOT EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}_python3.a)
        message(STATUS "Building ${_DEP_NAME} python3")
        include(ProcessorCount)
        ProcessorCount(cpus)
        set(confstring)
        string(APPEND confstring "using python\n")
        string(APPEND confstring "    : ${PYTHON3_VERSION}\n")
        string(APPEND confstring "    : \"${PYTHON3_BIN_DIR}/python3\"\n")
        string(APPEND confstring "    : \"${PYTHON3_INCLUDE_PATH}\"\n")
        string(APPEND confstring "    : \"${PYTHON3_LIB_DIR}\"\n")
        string(APPEND confstring "    ;\n")
        file(WRITE ${CMAKE_CURRENT_LIST_DIR}/src/python3-config.jam "${confstring}")
        execute_process(
            COMMAND env
                    PATH=${CMAKE_CURRENT_LIST_DIR}/src/cc-wrappers/bin:$ENV{PATH}
                    ${_DEP_PREFIX}/bin/b2
                    toolset=gcc
                    variant=release
                    debug-symbols=on
                    link=static
                    runtime-link=shared
                    threadapi=pthread
                    threading=multi
                    cxxflags=-fPIC
                    -j${cpus}
                    --with-python
                    --config=${CMAKE_CURRENT_LIST_DIR}/src/python3-config.jam
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} python3 - FAIL")
        endif()
        message(STATUS "Building ${_DEP_NAME} python3 - done")
        message(STATUS "Installing ${_DEP_NAME} python3")
        execute_process(
            COMMAND env
                    PATH=${CMAKE_CURRENT_LIST_DIR}/src/cc-wrappers/bin:$ENV{PATH}
                    ${_DEP_PREFIX}/bin/b2
                    toolset=gcc
                    variant=release
                    debug-symbols=on
                    link=static
                    runtime-link=shared
                    threadapi=pthread
                    threading=multi
                    cxxflags=-fPIC
                    -j${cpus}
                    --with-python
                    --config=${CMAKE_CURRENT_LIST_DIR}/src/python3-config.jam
                    --prefix=${_DEP_PREFIX}
                    install
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} python3 - FAIL")
        endif()
        file(RENAME ${_DEP_PREFIX}/lib/lib${_DEP_NAME}_python3${PYTHON3_VERSION_MINOR}.a
                    ${_DEP_PREFIX}/lib/lib${_DEP_NAME}_python3.a)
        file(RENAME ${_DEP_PREFIX}/lib/lib${_DEP_NAME}_numpy3${PYTHON3_VERSION_MINOR}.a
                    ${_DEP_PREFIX}/lib/lib${_DEP_NAME}_numpy3.a)
        message(STATUS "Installing ${_DEP_NAME} python3 - done")
        message(STATUS "Clearing ${_DEP_NAME} python3")
        execute_process(
            COMMAND env
                    PATH=${CMAKE_CURRENT_LIST_DIR}/src/cc-wrappers/bin:$ENV{PATH}
                    ${_DEP_PREFIX}/bin/b2
                    toolset=gcc
                    variant=release
                    debug-symbols=on
                    link=static
                    runtime-link=shared
                    threadapi=pthread
                    threading=multi
                    cxxflags=-fPIC
                    -j${cpus}
                    --with-python
                    --config=${CMAKE_CURRENT_LIST_DIR}/src/python3-config.jam
                    --clean
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Clearing ${_DEP_NAME} python3 - FAIL")
        endif()
        file(REMOVE ${CMAKE_CURRENT_LIST_DIR}/src/python3-config.jam)
        message(STATUS "Clearing ${_DEP_NAME} python3 - done")
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
set(BOOST_ROOT ${_DEP_PREFIX})

list(FIND CMAKE_PREFIX_PATH ${_DEP_PREFIX} _DEP_INDEX)
if(_DEP_INDEX EQUAL -1)
    list(APPEND CMAKE_PREFIX_PATH ${_DEP_PREFIX})
endif()

include(${CMAKE_CURRENT_LIST_DIR}/meta/targets.cmake)
set(Boost_NO_SYSTEM_PATHS ON)
find_package(Boost 1.76)
#https://gitlab.kitware.com/cmake/cmake/-/issues/19402

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_VER)
unset(_DEP_VER_)
unset(_DEP_URL)
unset(_DEP_PREFIX)
unset(_DEP_BIN_DIR)
unset(_DEP_LIB_DIR)
unset(_DEP_INCLUDE_DIR)
unset(_DEP_GCC_BIN_DIR)
