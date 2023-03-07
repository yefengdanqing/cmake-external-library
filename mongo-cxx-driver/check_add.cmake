get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

set(_DEP_VER r3.5.0)
set(_DEP_URL https://github.com/mongodb/mongo-cxx-driver/archive/refs/tags/${_DEP_VER}.tar.gz)

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

# https://github.com/zviederi/building-mongo-cxx-driver-using-cmake/blob/master/cmake/FindMongoDB.cmake

#CheckVersion()

if(NOT EXISTS ${_DEP_PREFIX}/lib64/libmongocxx-static.a)
    include(ExternalProject)
    ExternalProject_Add(
        mongo-c-driver
        GIT_REPOSITORY "https://github.com/mongodb/mongo-c-driver.git"
        GIT_TAG 1.15.3
        GIT_PROGRESS ON
        GIT_SHALLOW  ON

        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX:PATH=${_DEP_PREFIX}/mongo-c-driver
            -DBSON_ROOT_DIR:PATH=${_DEP_PREFIX}/mongo-c-driver
            -DENABLE_TESTS:BOOL=OFF
            -DENABLE_STATIC:BOOL=ON
            -DENABLE_EXAMPLES:BOOL=OFF
            -DENABLE_EXTRA_ALIGNMENT:BOOL=OFF
            -DENABLE_SASL=AUTO
            -DENABLE_SSL=AUTO
        )

    set(libmongoc-1.0_DIR ${_DEP_PREFIX}/mongo-c-driver/lib64/cmake/libmongoc-1.0/)
    set(libbson-1.0_DIR ${_DEP_PREFIX}/mongo-c-driver/lib64/cmake/libbson-1.0/)
    ExternalProject_Add(
        mongo-cxx-driver
        #URL "https://github.com/mongodb/mongo-cxx-driver/archive/refs/tags/${_DEP_VER}.tar.gz"
        GIT_REPOSITORY "https://github.com/mongodb/mongo-cxx-driver.git"
        GIT_TAG ${_DEP_VER}
        SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/src
        BINARY_DIR ${CMAKE_CURRENT_LIST_DIR}/build
        GIT_PROGRESS ON
        GIT_SHALLOW  ON

        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX:PATH=${_DEP_PREFIX}
            -DBUILD_SHARED_LIBS:BOOL=ON
            -DBUILD_SHARED_AND_STATIC_LIBS=ON
            -DENABLE_TESTS:BOOL=OFF
            -DENABLE_EXAMPLES:BOOL=OFF
            -DBSONCXX_POLY_USE_BOOST:BOOL=OFF
            -DBSONCXX_POLY_USE_MNMLSTC:BOOL=OFF
            -DBSONCXX_POLY_USE_STD:BOOL=OFF
            -DBOOST_ROOT:PATH=${BOOST_ROOT}
            -Dlibmongoc-1.0_DIR:PATH=${libmongoc-1.0_DIR}
            -Dlibbson-1.0_DIR:PATH=${libbson-1.0_DIR}
        DEPENDS
            mongo-c-driver
        )
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
