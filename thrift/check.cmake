include(${CMAKE_CURRENT_LIST_DIR}/../boost/check.cmake OPTIONAL)
if("${BOOST_PREFIX}" STREQUAL "")
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires boost")
endif()
if(NOT TARGET boost::smart_ptr)
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires boost::smart_ptr")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/../openssl/check.cmake OPTIONAL)
if("${OPENSSL_PREFIX}" STREQUAL "")
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires openssl")
endif()
if(NOT TARGET openssl::ssl)
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires openssl::ssl")
endif()

include(${CMAKE_CURRENT_LIST_DIR}/../libevent/check.cmake OPTIONAL)
if("${LIBEVENT_PREFIX}" STREQUAL "")
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires libevent")
endif()
if(NOT TARGET libevent::libevent)
    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    message(FATAL_ERROR "${_DEP_NAME} requires libevent::libevent")
endif()

get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

set(_DEP_VER v0.12.0)
set(_DEP_URL https://github.com/apache/${_DEP_NAME}/archive/${_DEP_VER}.tar.gz)

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

if(NOT EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}.a)
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
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/README.md)
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
                    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
                    -DWITH_BOOST_SMART_PTR=ON
                    -DWITH_BOOST_FUNCTIONAL=ON
                    -DWITH_BOOST_STATIC=ON
                    -DWITH_JAVA=OFF
                    -DWITH_PYTHON=OFF
                    -DWITH_SHARED_LIB=OFF
                    -DBUILD_TESTING=OFF
                    -DBUILD_EXAMPLES=OFF
                    -DBUILD_TUTORIALS=OFF
                    -DLIBEVENT_ROOT=${LIBEVENT_PREFIX}
                    -DOPENSSL_ROOT_DIR=${OPENSSL_PREFIX}
                    -DBOOST_ROOT=${BOOST_PREFIX}
                    ${CMAKE_CURRENT_LIST_DIR}/src
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Configuring ${_DEP_NAME} - done")
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
        if(EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}d.a)
            file(RENAME ${_DEP_PREFIX}/lib/lib${_DEP_NAME}d.a ${_DEP_PREFIX}/lib/lib${_DEP_NAME}.a)
        endif()
        if(EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}zd.a)
            file(RENAME ${_DEP_PREFIX}/lib/lib${_DEP_NAME}zd.a ${_DEP_PREFIX}/lib/lib${_DEP_NAME}z.a)
        endif()
        if(EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}nbd.a)
            file(RENAME ${_DEP_PREFIX}/lib/lib${_DEP_NAME}nbd.a ${_DEP_PREFIX}/lib/lib${_DEP_NAME}nb.a)
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

if(NOT TARGET ${_DEP_NAME}::${_DEP_NAME} AND EXISTS ${_DEP_BIN_DIR}/${_DEP_NAME})
    add_executable(${_DEP_NAME}::${_DEP_NAME} IMPORTED)
    set_target_properties(${_DEP_NAME}::${_DEP_NAME} PROPERTIES
        IMPORTED_LOCATION "${_DEP_BIN_DIR}/${_DEP_NAME}")
endif()
if(NOT TARGET ${_DEP_NAME}::lib${_DEP_NAME} AND EXISTS ${_DEP_LIB_DIR}/lib${_DEP_NAME}.a)
    add_library(${_DEP_NAME}::lib${_DEP_NAME} STATIC IMPORTED)
    set_target_properties(${_DEP_NAME}::lib${_DEP_NAME} PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/lib${_DEP_NAME}.a"
        INTERFACE_COMPILE_DEFINITIONS "FORCE_BOOST_SMART_PTR;FORCE_BOOST_FUNCTIONAL"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET ${_DEP_NAME}::lib${_DEP_NAME}z AND EXISTS ${_DEP_LIB_DIR}/lib${_DEP_NAME}z.a)
    add_library(${_DEP_NAME}::lib${_DEP_NAME}z STATIC IMPORTED)
    set_target_properties(${_DEP_NAME}::lib${_DEP_NAME}z PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/lib${_DEP_NAME}z.a"
        INTERFACE_COMPILE_DEFINITIONS "FORCE_BOOST_SMART_PTR;FORCE_BOOST_FUNCTIONAL"
        INTERFACE_LINK_LIBRARIES "boost::smart_ptr"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
endif()
if(NOT TARGET ${_DEP_NAME}::lib${_DEP_NAME}nb AND EXISTS ${_DEP_LIB_DIR}/lib${_DEP_NAME}nb.a)
    add_library(${_DEP_NAME}::lib${_DEP_NAME}nb STATIC IMPORTED)
    set_target_properties(${_DEP_NAME}::lib${_DEP_NAME}nb PROPERTIES
        IMPORTED_LOCATION "${_DEP_LIB_DIR}/lib${_DEP_NAME}nb.a"
        INTERFACE_COMPILE_DEFINITIONS "FORCE_BOOST_SMART_PTR;FORCE_BOOST_FUNCTIONAL"
        INTERFACE_LINK_LIBRARIES "boost::smart_ptr;libevent::libevent"
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
