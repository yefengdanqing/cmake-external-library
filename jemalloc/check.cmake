get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)



message(STATUS "_DEP_NAME: ${_DEP_NAME}")

#set(_DEP_TAG stable-4)
set(_DEP_TAG 5.2.1)
set(_DEP_URL https://github.com/${_DEP_NAME}/${_DEP_NAME}.git)
set(_DEP_PREFIX ${${_DEP_UNAME}_PREFIX})
message(STATUS "_DEP_URL: ${_DEP_URL}")
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



set(REAL_INSTALL_PREFIX ${_DEP_PREFIX})
set(REAL_INCLUDE_PREFIX ${REAL_INCLUDE_PREFIX}/include/)
set(REAL_LIB_PREFIX ${_DEP_PREFIX}/lib/)
message(STATUS "REAL_INSTALL_PREFIX: ${REAL_INSTALL_PREFIX}")

message(STATUS "CMAKE_CURRENT_LIST_DIR: ${CMAKE_CURRENT_LIST_DIR}")


if(NOT EXISTS ${REAL_LIB_PREFIX}/libjemalloc.a)
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src)
        message(STATUS "Cloning ${_DEP_NAME}: ${_DEP_URL}")
        execute_process(
            COMMAND git clone ${_DEP_URL} src
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
            RESULT_VARIABLE rc)

        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_URL} - FAIL")
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
    endif()
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/libjemalloc.a)
        message(STATUS "Building ${_DEP_NAME}")
        execute_process(
            COMMAND sh autogen.sh --prefix ${REAL_INSTALL_PREFIX}
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        execute_process(
            COMMAND make install
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Building ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${REAL_LIB_PREFIX}/libjemalloc.a)
        message(STATUS "Installing ${_DEP_NAME}")
        execute_process(
            COMMAND make install
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Installing ${_DEP_NAME} - done")
    endif()
    file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/src)
endif()

if(EXISTS ${REAL_LIB_PREFIX})
    set(_DEP_LIB_DIR ${REAL_LIB_PREFIX})
endif()
if(EXISTS ${REAL_INCLUDE_PREFIX})
    set(_DEP_INCLUDE_DIR ${REAL_INCLUDE_PREFIX})
endif()

list(FIND CMAKE_PREFIX_PATH ${_DEP_PREFIX} _DEP_INDEX)
if(_DEP_INDEX EQUAL -1)
    list(APPEND CMAKE_PREFIX_PATH ${_DEP_PREFIX})
endif()

set(${_DEP_UNAME}_DYNAMIC_LOADER ${REAL_LIB_PREFIX}/lib${_DEP_NAME}.so)
add_library(${_DEP_NAME}::${_DEP_NAME} STATIC IMPORTED)
	set_target_properties(${_DEP_NAME}::${_DEP_NAME} PROPERTIES
        IMPORTED_LOCATION "${REAL_LIB_PREFIX}/lib${_DEP_NAME}.a"
        INTERFACE_LINK_LIBRARIES "${_DEP_LINK_LIBS}"
        INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}"
        INTERFACE_COMPILE_FEATURES "cxx_std_17"
        INTERFACE_COMPILE_DEFINITIONS "${_DEP_COMPILE_DEFS}"
        INTERFACE_COMPILE_OPTIONS "${_DEP_COMPILE_OPTS}")

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_VER)
unset(_DEP_URL)
unset(_DEP_PREFIX)
