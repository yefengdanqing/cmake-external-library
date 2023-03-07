get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

set(_DEP_VER r3.7.0-beta1)
set(_DEP_URL https://github.com/mongodb/mongo-cxx-driver.git)

set(_MONGO_C_DRIVER_VER 1.19.0)
set(_MONGO_C_DRIVER_URL https://github.com/mongodb/mongo-c-driver.git)

set(_DEP_PREFIX ${${_DEP_UNAME}_PREFIX})
if("${_DEP_PREFIX}" STREQUAL "")
    if("${DEPS_DIR}" STREQUAL "")
        set(_DEP_PREFIX ${CMAKE_CURRENT_LIST_DIR})
    else()
        set(_DEP_PREFIX ${DEPS_DIR}/${_DEP_NAME})
    endif()
    set(${_DEP_UNAME}_PREFIX ${_DEP_PREFIX})
endif()
message(STATUS "${_DEP_UNAME}_PREFIX: ${_DEP_PREFIX}")


CheckVersion()

if(NOT EXISTS ${_DEP_PREFIX}/lib64/libmongocxx-static.a)
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/mongo-c-driver/README.md)
        message(STATUS "Cloning ${_DEP_NAME}: ${_MONGO_C_DRIVER_URL}")
    execute_process(
        COMMAND git clone --recursive ${_MONGO_C_DRIVER_URL} src
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
        RESULT_VARIABLE rc)
    if(NOT "${rc}" STREQUAL "0")
        message(FATAL_ERROR "Cloning ${_DEP_NAME}: ${_MONGO_C_DRIVER_URL} - FAIL")
    endif()
    message(STATUS "Cloning ${_DEP_NAME}: ${_MONGO_C_DRIVER_URL} - done")
    message(STATUS "Checking out ${_DEP_NAME}: ${_MONGO_C_DRIVER_VER}")
    execute_process(
        COMMAND git checkout ${_MONGO_C_DRIVER_VER}
        WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
        RESULT_VARIABLE rc)
    if(NOT "${rc}" STREQUAL "0")
        message(FATAL_ERROR "Checking out ${_DEP_NAME}: ${_DEP_TAG} - FAIL")
    endif()
    message(STATUS "Checking out ${_DEP_NAME}: ${_MONGO_C_DRIVER_VER} - done")
    endif()

    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/build/CMakeCache.txt)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build)
        message(STATUS "Configuring ${_DEP_NAME}")
        string (REPLACE ";" "\\;" CMAKE_PREFIX_PATH_STR "${CMAKE_PREFIX_PATH}")
        execute_process(
            COMMAND ${CMAKE_COMMAND}
                -G Ninja
                -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                -DCMAKE_INSTALL_PREFIX=${_DEP_PREFIX}/mongo-c-driver
                -DBSON_ROOT_DIR=${_DEP_PREFIX}/mongo-c-driver
                -DENABLE_TESTS=OFF
                -DENABLE_STATIC=ON
                -DENABLE_EXAMPLES=OFF
                -DENABLE_EXTRA_ALIGNMENT=OFF
                -DENABLE_SASL=AUTO
                -DENABLE_SSL=AUTO
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
    if(NOT EXISTS ${_DEP_PREFIX}/mongo-c-driver/include/libmongoc-1.0/mongoc.h)
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


    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/${_DEP_NAME}/README.md)
        message(STATUS "Cloning ${_DEP_NAME}: ${_DEP_URL}")
        execute_process(
            COMMAND git clone --recursive ${_DEP_URL} src
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Cloning ${_DEP_NAME}: ${_DEP_URL} - FAIL")
        endif()
        message(STATUS "Cloning ${_DEP_NAME}: ${_DEP_URL} - done")
        message(STATUS "Checking out ${_DEP_NAME}: ${_DEP_TAG}")
        execute_process(
            COMMAND git checkout ${_DEP_VER}
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Checking out ${_DEP_NAME}: ${_DEP_TAG} - FAIL")
        endif()
        message(STATUS "Checking out ${_DEP_NAME}: ${_DEP_TAG} - done")
    endif()
    
    set(libmongoc-1.0_DIR ${_DEP_PREFIX}/mongo-c-driver/lib64/cmake/libmongoc-1.0/)
    set(libbson-1.0_DIR ${_DEP_PREFIX}/mongo-c-driver/lib64/cmake/libbson-1.0/)
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/build/CMakeCache.txt)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build)
        message(STATUS "Configuring ${_DEP_NAME}")
        string (REPLACE ";" "\\;" CMAKE_PREFIX_PATH_STR "${CMAKE_PREFIX_PATH}")
        execute_process(
            COMMAND ${CMAKE_COMMAND}
            -G Ninja
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DCMAKE_INSTALL_PREFIX=${_DEP_PREFIX}
            -DBUILD_SHARED_LIBS=ON
            -DBUILD_SHARED_AND_STATIC_LIBS=ON
            -DENABLE_TESTS=OFF
            -DENABLE_EXAMPLES=OFF
            -DBSONCXX_POLY_USE_BOOST=OFF
            -DBSONCXX_POLY_USE_MNMLSTC=OFF
            -DBSONCXX_POLY_USE_STD=OFF
            -DBOOST_ROOT=${BOOST_ROOT}
            -Dlibmongoc-1.0_DIR=${libmongoc-1.0_DIR}
            -Dlibbson-1.0_DIR=${libbson-1.0_DIR}
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
    if(NOT EXISTS ${_DEP_PREFIX}/include/mongocxx/v_noabi/mongocxx/uri.hpp)
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
endif()

if(EXISTS ${_DEP_PREFIX}/lib64/pkgconfig/libbsoncxx-static.pc)
    set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${_DEP_PREFIX}/mongo-c-driver/lib64/pkgconfig/:${_DEP_PREFIX}/lib64/pkgconfig/")
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(BSONC REQUIRED IMPORTED_TARGET libbson-1.0)
    pkg_check_modules(MONGOC REQUIRED IMPORTED_TARGET libmongoc-1.0)

    pkg_check_modules(BSONCXX REQUIRED IMPORTED_TARGET libbsoncxx)
    pkg_check_modules(MONGOCXX REQUIRED IMPORTED_TARGET libmongocxx)
    if(NOT TARGET Bson::Bson AND EXISTS ${_DEP_LIB_DIR}/libbsoncxx-static.a)
        add_library(Bson::Bson STATIC IMPORTED)
        set_target_properties(Bson::Bson PROPERTIES
            IMPORTED_LOCATION "${_DEP_LIB_DIR}/libbsoncxx-static.a"
            INTERFACE_COMPILE_DEFINITIONS "BSONCXX_STATIC "
            INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}/bsoncxx/v_noabi"
            IMPORTED_LINK_INTERFACE_LIBRARIES PkgConfig::BSONC)
    endif()

    if(NOT TARGET Mongo::Mongo AND EXISTS ${_DEP_LIB_DIR}/libmongocxx-static.a)
        add_library(Mongo::Mongo STATIC IMPORTED)
        set_target_properties(Mongo::Mongo PROPERTIES
            IMPORTED_LOCATION "${_DEP_LIB_DIR}/libmongocxx-static.a"
            INTERFACE_COMPILE_DEFINITIONS "MONGOCXX_STATIC"
            INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}/mongocxx/v_noabi"
            IMPORTED_LINK_INTERFACE_LIBRARIES PkgConfig::MONGOC)
    endif()
endif()
unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_TAG)
unset(_DEP_VER)
unset(_DEP_URL)
unset(_DEP_TOOLS_TAG)
unset(_DEP_TOOLS_URL)
unset(_DEP_PREFIX)
unset(_DEP_BIN_DIR)
unset(_DEP_LIB_DIR)
unset(_DEP_INCLUDE_DIR)
unset(_DEP_COMPILE_DEFS)

