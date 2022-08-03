function(CheckVars)
    foreach (_V IN LISTS _VARS)
        if (NOT DEFINED ${_V})
            message(FATAL_ERROR "CheckVars: not found variable ${_V}")
        endif ()
    endforeach ()
endfunction(CheckVars)

function(CheckVarsV2)
    foreach (_V IN LISTS ARGV)
        if (NOT DEFINED ${_V})
            message(FATAL_ERROR "CheckVars: not found variable ${_V}")
        endif ()
    endforeach ()
endfunction()

function(CleanDep)
    set(_VARS _DEP_CUR_DIR _DEP_PREFIX)
    CheckVars()

    if (NOT ${_DEP_CUR_DIR} STREQUAL "")
        file(REMOVE_RECURSE ${_DEP_PREFIX}/bin)
        file(REMOVE_RECURSE ${_DEP_PREFIX}/lib)
        file(REMOVE_RECURSE ${_DEP_PREFIX}/lib64)
        file(REMOVE_RECURSE ${_DEP_PREFIX}/include)
        file(REMOVE_RECURSE ${_DEP_PREFIX}/share)
        file(REMOVE_RECURSE ${_DEP_PREFIX}/doc)
        file(REMOVE_RECURSE ${_DEP_CUR_DIR}/src)
        file(REMOVE_RECURSE ${_DEP_CUR_DIR}/build)
    endif ()
endfunction()

function(CheckVersion)
    set(_VARS _DEP_VER _DEP_NAME _DEP_PREFIX _NEED_REBUILD _DEP_CUR_DIR)
    CheckVars()

    if (DEFINED _DEP_VER)
        set(NEW_VERSION ${_DEP_VER})
    else ()
        message(FATAL_ERROR "Variable _DE_VER not found")
    endif ()

    if (NOT EXISTS ${_DEP_PREFIX}/VERSION)
        message(STATUS "VERSION file not found under dir ${_DEP_PREFIX}, rebuilding ${_DEP_NAME}")
        set(_NEED_REBUILD TRUE)
    else ()
        file(STRINGS ${_DEP_PREFIX}/VERSION BUILD_VERSION)
        if ("${BUILD_VERSION}" STREQUAL "${NEW_VERSION}")
            set(_NEED_REBUILD FALSE)
        else ()
            message(STATUS "Found new version ${NEW_VERSION} against old version ${BUILD_VERSION} from dir "
                    "${_DEP_PREFIX}, rebuilding ${_DEP_NAME}")
            set(_NEED_REBUILD TRUE)
        endif ()
    endif ()
    set(_NEED_REBUILD ${_NEED_REBUILD} PARENT_SCOPE)
    if (${_NEED_REBUILD})
        CleanDep()
    endif ()
    WriteVersion()
endfunction(CheckVersion)

function(CheckVersionV2)
    CheckVarsV2(_DEP_VER _DEP_NAME _DEP_PREFIX _NEED_REBUILD _DEP_CUR_DIR)

    if (DEFINED ${${_DEP_NAME}_VERSION})
        set(_DEP_VER ${${_DEP_NAME}_VERSION})
    endif ()

    if (DEFINED _DEP_VER)
        set(NEW_VERSION ${_DEP_VER})
    else ()
        message(FATAL_ERROR "Variable _DE_VER not found")
    endif ()

    if (NOT EXISTS ${_DEP_PREFIX}/VERSION)
        message(STATUS "VERSION file not found under dir ${_DEP_PREFIX}, rebuilding ${_DEP_NAME}")
        set(_NEED_REBUILD TRUE)
    else ()
        file(STRINGS ${_DEP_PREFIX}/VERSION BUILD_VERSION)
        if ("${BUILD_VERSION}" STREQUAL "${NEW_VERSION}")
            set(_NEED_REBUILD FALSE)
        else ()
            message(STATUS "Found new version ${NEW_VERSION} against old version ${BUILD_VERSION} from dir "
                    "${_DEP_PREFIX}, rebuilding ${_DEP_NAME}")
            set(_NEED_REBUILD TRUE)
        endif ()
    endif ()
    set(_NEED_REBUILD ${_NEED_REBUILD} PARENT_SCOPE)
    if (${_NEED_REBUILD})
        CleanDep()
    endif ()
    WriteVersion()
endfunction(CheckVersionV2)

function(WriteVersion)
    set(_VARS _DEP_PREFIX _DEP_VER)
    CheckVars()

    message(STATUS "Write VERSION file. VERSION=${_DEP_VER} FILE=${_DEP_PREFIX}/VERSION")
    file(WRITE ${_DEP_PREFIX}/VERSION ${_DEP_VER})
endfunction()

function(SetDepPrefix)
    set(_VARS _DEP_UNAME _DEP_CUR_DIR _DEP_PREFIX)
    CheckVars()

    set(_DEP_PREFIX ${${_DEP_UNAME}_PREFIX})
    if ("${_DEP_PREFIX}" STREQUAL "")
        if ("${DEPS_DIR}" STREQUAL "")
            set(_DEP_PREFIX ${_DEP_CUR_DIR})
        else ()
            set(_DEP_PREFIX ${DEPS_DIR}/${_DEP_NAME})
        endif ()
        set(${_DEP_UNAME}_PREFIX ${_DEP_PREFIX})
    endif ()
    message(STATUS "${_DEP_UNAME}_PREFIX: ${_DEP_PREFIX}")
    set(_DEP_PREFIX ${_DEP_PREFIX} PARENT_SCOPE)
endfunction()

function(IsEmpty)
    set(_VARS _DIR_TO_CHECK)
    CheckVars()

    set(_DIR_TO_CHECK_SIZE 0)
    if (EXISTS ${_DIR_TO_CHECK})
        file(GLOB _SRC_DIR "${_DIR_TO_CHECK}/*")
        list(LENGTH _SRC_DIR _DIR_TO_CHECK_SIZE)
    endif ()
    set(_DIR_TO_CHECK_SIZE ${_DIR_TO_CHECK_SIZE} PARENT_SCOPE)
    #    message(STATUS "Empty check, _DIR_TO_CHECK=${_DIR_TO_CHECK}, _DIR_TO_CHECK_SIZE=${_DIR_TO_CHECK_SIZE}")
endfunction()

function(ExistsLib)
    set(_VARS _DEP_PREFIX _DEP_NAME)
    CheckVars()

    if (NOT DEFINED _DEP_NAME_INSTALL_CHECK)
        set(_DEP_NAME_INSTALL_CHECK lib${_DEP_NAME}.a)
    endif ()

    set(_T_LIB_FILE "${_DEP_PREFIX}/lib/${_DEP_NAME_INSTALL_CHECK}")
    set(_T_LIB64_FILE "${_DEP_PREFIX}/lib64/${_DEP_NAME_INSTALL_CHECK}")
    if ((EXISTS ${_T_LIB_FILE}) OR (EXISTS ${_T_LIB64_FILE}))
        set(_LIB_DOES_EXISTS TRUE PARENT_SCOPE)
        set(_LIB_DOES_NOT_EXISTS FALSE PARENT_SCOPE)
    else ()
        set(_LIB_DOES_EXISTS FALSE PARENT_SCOPE)
        set(_LIB_DOES_NOT_EXISTS TRUE PARENT_SCOPE)
    endif ()
endfunction()

function(CheckLibExists)
    CheckVars(_DEP_PREFIX _DEP_NAME)

    if (NOT DEFINED _DEP_NAME_INSTALL_CHECK)
        set(_DEP_NAME_INSTALL_CHECK lib${_DEP_NAME}.a)
    endif ()

    set(_FILES_TO_CHECK
            "${_DEP_PREFIX}/lib/${_DEP_NAME_INSTALL_CHECK}"
            "${_DEP_PREFIX}/lib64/${_DEP_NAME_INSTALL_CHECK}")

    set(_LIB_DOES_EXISTS FALSE)
    set(_LIB_DOES_NOT_EXISTS TRUE PARENT_SCOPE)

    foreach (_FILE_TO_CHECK IN LISTS _FILES_TO_CHECK)
        message(STATUS "[CheckLibExists] checking file ${_FILE_TO_CHECK}")
        if (EXISTS ${_FILE_TO_CHECK})
            set(_LIB_DOES_EXISTS TRUE)
            set(_LIB_DOES_NOT_EXISTS FALSE PARENT_SCOPE)
        endif ()
    endforeach ()
endfunction()

function(SetDepPath)
    set(_VARS _DEP_UNAME _DEP_PREFIX)
    CheckVars()

    set(${_DEP_UNAME}_PREFIX ${_DEP_PREFIX} PARENT_SCOPE)
    if (EXISTS ${_DEP_PREFIX}/bin)
        set(_DEP_BIN_DIR ${_DEP_PREFIX}/bin)
        set(_DEP_BIN_DIR ${_DEP_PREFIX}/bin PARENT_SCOPE)
        set(${_DEP_UNAME}_BIN_DIR ${_DEP_BIN_DIR} PARENT_SCOPE)
        list(APPEND _EXTERNAL_VARS ${_DEP_UNAME}_BIN_DIR)
    endif ()
    if (EXISTS ${_DEP_PREFIX}/lib)
        set(_DEP_LIB_DIR ${_DEP_PREFIX}/lib)
        set(_DEP_LIB_DIR ${_DEP_PREFIX}/lib PARENT_SCOPE)
        set(${_DEP_UNAME}_LIB_DIR ${_DEP_LIB_DIR})
        set(${_DEP_UNAME}_LIB_DIR ${_DEP_LIB_DIR} PARENT_SCOPE)
        list(APPEND _EXTERNAL_VARS ${_DEP_UNAME}_LIB_DIR)
    endif ()
    if (EXISTS ${_DEP_PREFIX}/lib64)
        set(_DEP_LIB_DIR ${_DEP_PREFIX}/lib64)
        set(_DEP_LIB_DIR ${_DEP_PREFIX}/lib64 PARENT_SCOPE)
        set(${_DEP_UNAME}_LIB_DIR ${_DEP_LIB_DIR} PARENT_SCOPE)
        list(APPEND _EXTERNAL_VARS ${_DEP_UNAME}_LIB_DIR)
    endif ()
    if (EXISTS ${_DEP_PREFIX}/include)
        set(_DEP_INCLUDE_DIR ${_DEP_PREFIX}/include)
        set(_DEP_INCLUDE_DIR ${_DEP_PREFIX}/include PARENT_SCOPE)
        set(${_DEP_UNAME}_INCLUDE_DIR ${_DEP_INCLUDE_DIR} PARENT_SCOPE)
        list(APPEND _EXTERNAL_VARS ${_DEP_UNAME}_INCLUDE_DIR)
    endif ()
    set(_EXTERNAL_VARS ${_EXTERNAL_VARS} PARENT_SCOPE)
endfunction()

function(AppendCMakePrefix)
    CheckVarsV2(_DEP_UNAME _DEP_PREFIX)

    list(FIND CMAKE_PREFIX_PATH ${_DEP_PREFIX} _DEP_INDEX)
    if (_DEP_INDEX EQUAL -1)
        list(APPEND CMAKE_PREFIX_PATH ${_DEP_PREFIX})
        set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} PARENT_SCOPE)
        list(APPEND _EXTERNAL_VARS CMAKE_PREFIX_PATH)
    endif ()

    # set pkg service
    if (EXISTS ${_DEP_PREFIX}/lib/pkgconfig/)
        set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${_DEP_PREFIX}/lib/pkgconfig/")
    elseif (EXISTS ${_DEP_PREFIX}/lib64/pkgconfig/)
        set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${_DEP_PREFIX}/lib64/pkgconfig/")
    endif ()
    set(${_DEP_UNAME}_PKG_CONFIG_PATH ${_DEP_PREFIX}/lib/pkgconfig/ PARENT_SCOPE)
    list(APPEND _EXTERNAL_VARS ${_DEP_UNAME}_PKG_CONFIG_PATH)
    set(_EXTERNAL_VARS ${_EXTERNAL_VARS} PARENT_SCOPE)
endfunction()

function(FindStaticLibrary)
    set(_VARS _DEP_NAME _DEP_LIB_DIR _DEP_INCLUDE_DIR)
    CheckVars()
    if (NOT DEFINED _DEP_NAME_SPACE)
        set(_DEP_NAME_SPACE ${_DEP_NAME})
    endif ()
    if (NOT DEFINED _FIND_DEP_NAME)
        set(_FIND_DEP_NAME ${_DEP_NAME})
    endif ()

    if (${_NO_SPACE})
        set(_FINAL_FIND_DEP_NAME ${_DEP_NAME})
    else ()
        set(_FINAL_FIND_DEP_NAME ${_FIND_DEP_NAME}::${_DEP_NAME_SPACE})
    endif ()

    AppendCMakePrefix()
    set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} PARENT_SCOPE)

    message(STATUS "Try to add library: ${_FINAL_FIND_DEP_NAME}")
    if (NOT TARGET ${_FINAL_FIND_DEP_NAME} AND EXISTS ${_DEP_LIB_DIR}/lib${_DEP_NAME_SPACE}.a)
        message(STATUS "Add library ${_FINAL_FIND_DEP_NAME}")
        add_library(${_FINAL_FIND_DEP_NAME} STATIC IMPORTED GLOBAL)
        set_target_properties(${_FINAL_FIND_DEP_NAME} PROPERTIES
                IMPORTED_LOCATION "${_DEP_LIB_DIR}/lib${_DEP_NAME_SPACE}.a"
                ${_FIND_STATIC_LIBRARY_EXTRA}
                INTERFACE_INCLUDE_DIRECTORIES "${_DEP_INCLUDE_DIR}")
    endif ()
    message(STATUS "${${_FINAL_FIND_DEP_NAME}} ${_DEP_LIB_DIR}/lib${_DEP_NAME_SPACE}.a")
endfunction()

function(DownloadDep)
    set(_VARS _DEP_NAME _DEP_VER _DEP_CUR_DIR _DEP_URL)
    CheckVars()

    if (NOT EXISTS ${_DEP_CUR_DIR}/packages/${_DEP_NAME}-${_DEP_VER}.tar.gz)
        file(MAKE_DIRECTORY ${_DEP_CUR_DIR}/packages)
        set(_DEST_DOWNLOADING ${_DEP_CUR_DIR}/packages/${_DEP_NAME}-${_DEP_VER}.downloading)
        set(_DEST ${_DEP_CUR_DIR}/packages/${_DEP_NAME}-${_DEP_VER}.tar.gz)
        message(STATUS "Downloading ${_DEP_NAME}:${_DEP_URL}, DEST=${_DEST_DOWNLOADING}")
        execute_process(
                COMMAND wget -O ${_DEST_DOWNLOADING} ${_DEP_URL}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_URL} - FAIL")
        endif ()
        execute_process(
                COMMAND mv ${_DEST_DOWNLOADING} ${_DEST}
                RESULT_VARIABLE rc)
        message(STATUS "Download ${_DEP_NAME}: ${_DEP_URL} - done")
    endif ()
endfunction()

function(DownloadDepV2 _GIT_USER)
    CheckVarsV2(_DEP_NAME _DEP_VER _DEP_CUR_DIR)

    if (DEFINED ENV{SPEED_UP_URL})
        set(DEP_URL $ENV{SPEED_UP_URL}/${_DEP_NAME}-${_DEP_VER}.tar.gz)
    else ()
        set(DEP_URL https://codeload.github.com/${_GIT_USER}/${_DEP_NAME}/tar.gz/refs/tags/v${_DEP_VER})
    endif ()

    if (NOT EXISTS ${_DEP_CUR_DIR}/packages/${_DEP_NAME}-${_DEP_VER}.tar.gz)
        file(MAKE_DIRECTORY ${_DEP_CUR_DIR}/packages)
        set(_DEST_DOWNLOADING ${_DEP_CUR_DIR}/packages/${_DEP_NAME}-${_DEP_VER}.downloading)
        set(_DEST ${_DEP_CUR_DIR}/packages/${_DEP_NAME}-${_DEP_VER}.tar.gz)
        message(STATUS "Downloading ${_DEP_NAME}:${DEP_URL}, DEST=${_DEST_DOWNLOADING}")
        execute_process(
                COMMAND wget -O ${_DEST_DOWNLOADING} ${DEP_URL}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${DEP_URL} - FAIL")
        endif ()
        execute_process(
                COMMAND mv ${_DEST_DOWNLOADING} ${_DEST}
                RESULT_VARIABLE rc)
        message(STATUS "Download ${_DEP_NAME}: ${DEP_URL} - done")
    endif ()
endfunction(DownloadDepV2)

function(DownloadDepV3 version url)
    CheckVarsV2(_DEP_NAME _DEP_CUR_DIR)

    if (NOT EXISTS ${_DEP_CUR_DIR}/packages/${_DEP_NAME}-${version}.tar.gz)
        file(MAKE_DIRECTORY ${_DEP_CUR_DIR}/packages)
        set(_DEST_DOWNLOADING ${_DEP_CUR_DIR}/packages/${_DEP_NAME}-${version}.downloading)
        set(_DEST ${_DEP_CUR_DIR}/packages/${_DEP_NAME}-${version}.tar.gz)
        message(STATUS "Downloading ${_DEP_NAME}:${url}, DEST=${_DEST_DOWNLOADING}")
        execute_process(
                COMMAND wget -O ${_DEST_DOWNLOADING} ${url}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${url} - FAIL")
        endif ()
        execute_process(
                COMMAND mv ${_DEST_DOWNLOADING} ${_DEST}
                RESULT_VARIABLE rc)
        message(STATUS "Download ${_DEP_NAME}: ${url} - done")
    endif ()
endfunction(DownloadDepV3)

function(GitClone)
    set(_VARS _DEP_NAME _DEP_VER _DEP_CUR_DIR _DEP_URL)
    CheckVars()

    find_package(Git REQUIRED)

    set(_DIR_TO_CHECK ${_DEP_CUR_DIR}/src)
    IsEmpty()
    if (_DIR_TO_CHECK_SIZE EQUAL 0)
        message(STATUS "Cloning ${_DEP_NAME}: ${_DEP_URL}")
        execute_process(
                COMMAND "${GIT_EXECUTABLE}" clone --recurse-submodules ${_DEP_URL} src
                WORKING_DIRECTORY "${_DEP_CUR_DIR}"
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Cloning ${_DEP_NAME}: ${_DEP_URL} - FAIL")
        endif ()
        message(STATUS "Cloning ${_DEP_NAME}: ${_DEP_URL} - done")
    endif ()

    # check out commit
    message(STATUS "Checking out ${_DEP_NAME}: ${_DEP_VER}")
    execute_process(
            COMMAND git checkout ${_DEP_VER}
            WORKING_DIRECTORY ${_DEP_CUR_DIR}/src
            RESULT_VARIABLE rc)
    if (NOT "${rc}" STREQUAL "0")
        message(FATAL_ERROR "Checking out ${_DEP_NAME}: ${_DEP_VER} - FAIL")
    endif ()
    message(STATUS "Checking out ${_DEP_NAME}: ${_DEP_VER} - done")
endfunction()

function(GitCloneV2 repository version)
    CheckVarsV2(_DEP_NAME _DEP_CUR_DIR)

    find_package(Git REQUIRED)

    set(_DIR_TO_CHECK ${_DEP_CUR_DIR}/src)
    IsEmpty()
    if (_DIR_TO_CHECK_SIZE EQUAL 0)
        message(STATUS "Cloning ${_DEP_NAME}: ${repository}")
        execute_process(
                COMMAND "${GIT_EXECUTABLE}" clone --recurse-submodules ${repository} src
                WORKING_DIRECTORY "${_DEP_CUR_DIR}"
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Cloning ${_DEP_NAME}: ${repository} - FAIL")
        endif ()
        message(STATUS "Cloning ${_DEP_NAME}: ${repository} - done")
    endif ()

    # check out commit
    message(STATUS "Checking out ${_DEP_NAME}: ${version}")
    execute_process(
            COMMAND git checkout ${version}
            WORKING_DIRECTORY ${_DEP_CUR_DIR}/src
            RESULT_VARIABLE rc)
    if (NOT "${rc}" STREQUAL "0")
        message(FATAL_ERROR "Checking out ${_DEP_NAME}: ${version} - FAIL")
    endif ()
    message(STATUS "Checking out ${_DEP_NAME}: ${version} - done")
endfunction(GitCloneV2)

function(ExtractDep)
    set(_VARS _DEP_NAME _DEP_VER _DEP_CUR_DIR)
    CheckVars()

    set(_DIR_TO_CHECK ${_DEP_CUR_DIR}/src)
    IsEmpty()
    if (_DIR_TO_CHECK_SIZE EQUAL 0)
        file(MAKE_DIRECTORY ${_DEP_CUR_DIR}/src)
        message(STATUS "Extracting ${_DEP_NAME}")
        execute_process(
                COMMAND tar -xf ${_DEP_CUR_DIR}/packages/${_DEP_NAME}-${_DEP_VER}.tar.gz
                --strip-components 1 -C ${_DEP_CUR_DIR}/src
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Extracting ${_DEP_NAME} - done")
    endif ()
endfunction()

function(ExtractDepV2 version)
    set(_VARS _DEP_NAME _DEP_CUR_DIR)
    CheckVars()

    set(_DIR_TO_CHECK ${_DEP_CUR_DIR}/src)
    IsEmpty()
    if (_DIR_TO_CHECK_SIZE EQUAL 0)
        file(MAKE_DIRECTORY ${_DEP_CUR_DIR}/src)
        message(STATUS "Extracting ${_DEP_NAME}")
        execute_process(
                COMMAND tar -xf ${_DEP_CUR_DIR}/packages/${_DEP_NAME}-${version}.tar.gz
                --strip-components 1 -C ${_DEP_CUR_DIR}/src
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Extracting ${_DEP_NAME} - done")
    endif ()
endfunction(ExtractDepV2)

function(CMakeNinja)
    set(_VARS _DEP_NAME _DEP_CUR_DIR _DEP_PREFIX)
    CheckVars()

    if (NOT DEFINED _BUILD_TYPE)
        set(_BUILD_TYPE Release)
    endif ()

    if (_PIC_OFF)
        set(_PIC_FLAG "-DCMAKE_POSITION_INDEPENDENT_CODE=OFF")
    else ()
        set(_PIC_FLAG "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
    endif ()
    if (NOT EXISTS ${_DEP_CUR_DIR}/build/build.ninja)
        file(MAKE_DIRECTORY ${_DEP_CUR_DIR}/build)
        string(REPLACE ";" "\\;" CMAKE_PREFIX_PATH_STR "${CMAKE_PREFIX_PATH}")
        message(STATUS "Configuring ${_DEP_NAME}, CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH}, "
                "CMAKE_PREFIX_PATH_STR ${CMAKE_PREFIX_PATH_STR}")
        execute_process(
                COMMAND ${CMAKE_COMMAND}
                -G Ninja
                -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
                -DCMAKE_BUILD_TYPE=${_BUILD_TYPE}
                -DCMAKE_INSTALL_PREFIX=${_DEP_PREFIX}
                -DBUILD_SHARED_LIBS=OFF
                -DCMAKE_INSTALL_LIBDIR=lib
                -DCMAKE_INSTALL_BINDIR=bin
                -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH_STR}
                ${_PIC_FLAG}
                ${_EXTRA_DEFINE}
                ${_DEP_CUR_DIR}/src
                WORKING_DIRECTORY ${_DEP_CUR_DIR}/build
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Configuring ${_DEP_NAME} - done")
    endif ()
endfunction()

function(CMakeNinjaV2)
    CheckVars(_DEP_NAME _DEP_CUR_DIR _DEP_PREFIX)
    set(options NoneOptions)
    set(oneValueArgs NoneArg)
    set(multiValueArgs NINJA_EXTRA_DEFINE)
    cmake_parse_arguments(P "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT DEFINED _BUILD_TYPE)
        set(_BUILD_TYPE Release)
    endif ()

    if (_PIC_OFF)
        set(_PIC_FLAG "-DCMAKE_POSITION_INDEPENDENT_CODE=OFF")
    else ()
        set(_PIC_FLAG "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
    endif ()
    if (NOT EXISTS ${_DEP_CUR_DIR}/build/build.ninja)
        file(MAKE_DIRECTORY ${_DEP_CUR_DIR}/build)
        string(REPLACE ";" "\\;" CMAKE_PREFIX_PATH_STR "${CMAKE_PREFIX_PATH}")
        message(STATUS "Configuring ${_DEP_NAME}, CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH}, "
                "CMAKE_PREFIX_PATH_STR ${CMAKE_PREFIX_PATH_STR}, NINJA_EXTRA_DEFINE ${P_NINJA_EXTRA_DEFINE}")
        execute_process(
                COMMAND ${CMAKE_COMMAND}
                -G Ninja
                -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
                -DCMAKE_BUILD_TYPE=${_BUILD_TYPE}
                -DCMAKE_INSTALL_PREFIX=${_DEP_PREFIX}
                -DBUILD_SHARED_LIBS=OFF
                -DCMAKE_INSTALL_LIBDIR=lib
                -DCMAKE_INSTALL_BINDIR=bin
                -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH_STR}
                -DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}
                ${_PIC_FLAG}
                ${P_NINJA_EXTRA_DEFINE}
                ${_DEP_CUR_DIR}/src
                WORKING_DIRECTORY ${_DEP_CUR_DIR}/build
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Configuring ${_DEP_NAME} - done")
    endif ()
endfunction(CMakeNinjaV2)

function(MesonNinja)
    set(_VARS _DEP_NAME _DEP_CUR_DIR _DEP_PREFIX)
    CheckVars()

    set(_DIR_TO_CHECK ${_DEP_CUR_DIR}/build)
    IsEmpty()
    if (_DIR_TO_CHECK_SIZE EQUAL 0)
        file(MAKE_DIRECTORY ${_DEP_CUR_DIR}/build)
        message(STATUS "Configuring ${_DEP_NAME}")
        execute_process(
                COMMAND meson --prefix=${_DEP_PREFIX} ${_DEP_CUR_DIR}/build
                WORKING_DIRECTORY ${_DEP_CUR_DIR}/src
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Configuring ${_DEP_NAME} - done")
    endif ()
endfunction()

function(NinjaBuild)
    set(_VARS _DEP_NAME _DEP_CUR_DIR)
    CheckVars()

    if (NOT DEFINED _DEP_NAME_BUILD_CHECK)
        set(_DEP_NAME_BUILD_CHECK lib${_DEP_NAME}.a)
    endif ()

    set(_DEP_LIB_DIR_ ${_DEP_CUR_DIR}/build/lib/${_DEP_NAME_BUILD_CHECK})
    set(_DEP_LIB64_DIR_ ${_DEP_CUR_DIR}/build/lib64/${_DEP_NAME_BUILD_CHECK})

    if ((NOT EXISTS _DEP_LIB_DIR_) AND (NOT EXISTS _DEP_LIB64_DIR_))
        message(STATUS "Building ${_DEP_NAME}")
        execute_process(
                COMMAND ninja
                WORKING_DIRECTORY ${_DEP_CUR_DIR}/build
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Building ${_DEP_NAME} - done")
    else ()
        message(STATUS "Skip ninja build for ${_DEP_NAME}")
    endif ()
endfunction()

function(NinjaBuildV2)
    CheckVars(_DEP_NAME _DEP_CUR_DIR _DEP_BUILD_DONE)

    if (NOT DEFINED _DEP_NAME_BUILD_CHECK)
        set(_DEP_NAME_BUILD_CHECK lib${_DEP_NAME}.a)
    endif ()

    set(_DEP_LIB_DIR_ ${_DEP_CUR_DIR}/build/lib/${_DEP_NAME_BUILD_CHECK})
    set(_DEP_LIB64_DIR_ ${_DEP_CUR_DIR}/build/lib64/${_DEP_NAME_BUILD_CHECK})

    if (NOT ${_DEP_INSTALL_DONE})
        message(STATUS "Building ${_DEP_NAME}")
        execute_process(
                COMMAND ninja
                WORKING_DIRECTORY ${_DEP_CUR_DIR}/build
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Building ${_DEP_NAME} - done")
    else ()
        message(STATUS "Skip ninja build for ${_DEP_NAME}")
    endif ()
endfunction(NinjaBuildV2)

function(NinjaInstall)
    set(_VARS _DEP_NAME _DEP_PREFIX _DEP_CUR_DIR)
    CheckVars()

    if (${_PERMISSION})
        set(_PERMISSION_ROLE "sudo")
    endif ()

    if (NOT DEFINED _DEP_NAME_INSTALL_CHECK)
        set(_DEP_NAME_INSTALL_CHECK lib${_DEP_NAME}.a)
    endif ()

    ExistsLib()
    if (${_LIB_DOES_NOT_EXISTS})
        #    if (NOT EXISTS ${_DEP_CUR_DIR}/lib/${_DEP_NAME_INSTALL_CHECK})
        message(STATUS "Installing ${_DEP_NAME}")
        execute_process(
                COMMAND ${_PERMISSION_ROLE} ninja install
                WORKING_DIRECTORY ${_DEP_CUR_DIR}/build
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Installing ${_DEP_NAME} - done")
    else ()
        message(STATUS "Skip ninja install for ${_DEP_NAME}")
    endif ()
endfunction()

function(NinjaInstallV2)
    CheckVars(_DEP_NAME _DEP_PREFIX _DEP_CUR_DIR)

    if (${_PERMISSION})
        set(_PERMISSION_ROLE "sudo")
    endif ()

    if (NOT ${_DEP_INSTALL_DONE})
        message(STATUS "Installing ${_DEP_NAME}")
        execute_process(
                COMMAND ${_PERMISSION_ROLE} ninja install
                WORKING_DIRECTORY ${_DEP_CUR_DIR}/build
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Installing ${_DEP_NAME} - done")
    else ()
        message(STATUS "Skip ninja install for ${_DEP_NAME}")
    endif ()
endfunction(NinjaInstallV2)

function(B2Build)
    CheckVarsV2(_DEP_NAME _DEP_BUILD_DIR _DEP_SRC_DIR)
    if (NOT ${_DEP_INSTALL_DONE} AND NOT EXISTS ${_DEP_SRC_DIR}/PHASE_B2BUILD)
        message(STATUS "B2 compile ${_DEP_NAME}. ENV=${P_B2BUILD_ENV}, ARGS=${P_B2BUILD_ARGS}. PATH=$ENV{PATH}")
        ProcessorCount(cpus)
        execute_process(
                COMMAND env CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} ${P_B2BUILD_ENV}
                b2 --build-dir=${_DEP_BUILD_DIR} ${P_B2BUILD_ARGS} -j${cpus}
                WORKING_DIRECTORY ${_DEP_SRC_DIR}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "B2 build ${_DEP_NAME} ${rc} - FAIL")
        endif ()
        message(STATUS "B2 compile ${_DEP_NAME} - done")
        file(WRITE ${_DEP_SRC_DIR}/PHASE_B2BUILD "done")
    endif ()
endfunction(B2Build)

function(B2Install)
    CheckVarsV2(_DEP_NAME _DEP_BUILD_DIR)
    if ("${P_B2INSTALL_SRC_DIR}" STREQUAL "")
        set(P_B2INSTALL_SRC_DIR ${_DEP_BUILD_DIR})
    endif ()
    if (NOT ${_DEP_INSTALL_DONE} AND NOT EXISTS ${P_B2INSTALL_SRC_DIR}/PHASE_B2INSTALL)
        message(STATUS "B2 install ${_DEP_NAME}. SRC=${P_B2INSTALL_SRC_DIR}, PREFIX=${_DEP_PREFIX}. "
                "ENV=${P_B2INSTALL_ENV}, ARGS=${P_B2INSTALL_ARGS}")
        execute_process(
                COMMAND env CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} ${P_B2INSTALL_ENV}
                b2 --prefix=${_DEP_PREFIX} ${P_B2INSTALL_ARGS} install
                WORKING_DIRECTORY ${P_B2INSTALL_SRC_DIR}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "B2 install ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "B2 install ${_DEP_NAME} - done")
        file(WRITE ${P_B2INSTALL_SRC_DIR}/PHASE_B2INSTALL "done")
    endif ()
endfunction(B2Install)

function(Autogen)
    set(_VARS _DEP_NAME _DEP_CUR_DIR)
    CheckVars()

    if (NOT EXISTS ${_DEP_CUR_DIR}/src/PHASE_AUTOGEN)
        message(STATUS "Autogen ${_DEP_NAME}")
        execute_process(
                COMMAND env
                CC=${CMAKE_C_COMPILER}
                CXX=${CMAKE_CXX_COMPILER}
                CFLAGS=-fPIC
                CXXFLAGS=-fPIC
                ./autogen.sh
                WORKING_DIRECTORY ${_DEP_CUR_DIR}/src
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Autogen ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Autogen ${_DEP_NAME} - done")
        file(WRITE ${_DEP_CUR_DIR}/src/PHASE_AUTOGEN "done")
    endif ()
endfunction()

function(BuildConf)
    set(_VARS _DEP_CUR_DIR)
    CheckVars()

    execute_process(
            COMMAND env
            ./buildconf
            WORKING_DIRECTORY ${_DEP_CUR_DIR}/src
            RESULT_VARIABLE rc)

    if (NOT "${rc}" STREQUAL "0")
        message(FATAL_ERROR "Build config ${_DEP_NAME} - FAIL")
    else ()
        message(STATUS "Build config ${_DEP_NAME} - done")
    endif ()
endfunction()

function(AutoReconf)
    set(_VARS _DEP_CUR_DIR)
    CheckVars()

    execute_process(
            COMMAND env
            autoreconf -fi
            WORKING_DIRECTORY ${_DEP_CUR_DIR}/src
            RESULT_VARIABLE rc)

    if (NOT "${rc}" STREQUAL "0")
        message(FATAL_ERROR "Auto reconf ${_DEP_NAME} - FAIL")
    else ()
        message(STATUS "Auto reconf ${_DEP_NAME} - done")
    endif ()
endfunction()

function(AutoReConfV2)
    CheckVarsV2(_DEP_CUR_DIR)

    if (NOT EXISTS ${_DEP_CUR_DIR}/src/PHASE_AUTO_RE_CONF)
        execute_process(
                COMMAND env
                autoreconf -fi
                WORKING_DIRECTORY ${_DEP_CUR_DIR}/src
                RESULT_VARIABLE rc)

        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Auto re-conf ${_DEP_NAME} - FAIL")
        else ()
            file(WRITE ${_DEP_CUR_DIR}/src/PHASE_AUTO_RE_CONF "done")
            message(STATUS "Auto re-conf ${_DEP_NAME} - done")
        endif ()
    endif ()
endfunction(AutoReConfV2)

function(Configure)
    set(_VARS _DEP_NAME _DEP_CUR_DIR)
    CheckVars()

    if (EXISTS ${_DEP_CUR_DIR}/src/configure)
        set(CONFIG_CMD configure)
    elseif (EXISTS ${_DEP_CUR_DIR}/src/config)
        set(CONFIG_CMD config)
    else ()
        message(FATAL_ERROR "Config command (configure or config) not found")
    endif ()

    if (NOT EXISTS ${_DEP_CUR_DIR}/src/PHASE_CONFIGURE)
        message(STATUS "Configuring ${_DEP_NAME}")
        execute_process(
                COMMAND env
                CC=${CMAKE_C_COMPILER}
                CXX=${CMAKE_CXX_COMPILER}
                CFLAGS=-fPIC
                CXXFLAGS=-fPIC
                ./${CONFIG_CMD}
                --prefix=${_DEP_PREFIX}
                ${_EXTRA_DEFINE}
                WORKING_DIRECTORY ${_DEP_CUR_DIR}/src
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Configuring ${_DEP_NAME} - done")
        file(WRITE ${_DEP_CUR_DIR}/src/PHASE_CONFIGURE "done")
    endif ()
endfunction()

function(ConfigureV2)
    set(options NoneOpt)
    set(oneValueArgs CONFIGURE_COMMAND)
    set(multiValueArgs NoneMulti EXTRA_DEFINE)
    cmake_parse_arguments(P "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    CheckVars(_DEP_NAME _DEP_CUR_DIR)

    if (EXISTS ${_DEP_CUR_DIR}/src/configure)
        set(CONFIG_CMD configure)
    elseif (EXISTS ${_DEP_CUR_DIR}/src/config)
        set(CONFIG_CMD config)
    endif ()

    if ("${CONFIGURE_COMMAND}" STREQUAL "")
        set(CONFIGURE_COMMAND ${CONFIG_CMD} --prefix=${_DEP_PREFIX})
    endif ()

    if (DEFINED CONFIG_CMD AND DEFINED CONFIG_CMD AND NOT EXISTS ${_DEP_CUR_DIR}/src/PHASE_CONFIGURE)
        message(STATUS "Configuring ${_DEP_NAME} with command ${CONFIGURE_COMMAND} EXTRA_DEFINE=${P_EXTRA_DEFINE}")
        execute_process(
                COMMAND env
                CC=${CMAKE_C_COMPILER}
                CXX=${CMAKE_CXX_COMPILER}
                CFLAGS=-fPIC
                CXXFLAGS=-fPIC
                ./${CONFIGURE_COMMAND} ${P_EXTRA_DEFINE}
                WORKING_DIRECTORY ${_DEP_CUR_DIR}/src
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Configuring ${_DEP_NAME} - done")
        file(WRITE ${_DEP_CUR_DIR}/src/PHASE_CONFIGURE "done")
    endif ()
endfunction()

function(CMakeBuild)
    set(_VARS _DEP_PREFIX _DEP_CUR_DIR)
    CheckVars()

    make_directory(${_DEP_CUR_DIR}/build)
    execute_process(
            COMMAND ${CMAKE_COMMAND}
            -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
            -DCMAKE_BUILD_TYPE=${_BUILD_TYPE}
            -DCMAKE_INSTALL_PREFIX=${_DEP_PREFIX}
            -DBUILD_SHARED_LIBS=OFF
            -DCMAKE_INSTALL_LIBDIR=lib
            -DCMAKE_INSTALL_BINDIR=bin
            -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
            -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
            -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH_STR}
            ${_CMAKE_BUILD_EXTRA_DEFINE}
            ${_DEP_CUR_DIR}/src
            WORKING_DIRECTORY ${_DEP_CUR_DIR}/build
            RESULT_VARIABLE rc)
    if (NOT "${rc}" STREQUAL "0")
        message(FATAL_ERROR "Cmake build ${_DEP_NAME} - FAIL")
    endif ()
endfunction()

function(MakeBuild)
    set(_VARS _DEP_NAME _DEP_CUR_DIR)
    CheckVars()

    set(_DIR_TO_CHECK ${_DEP_CUR_DIR}/build)
    IsEmpty()
    if (_DIR_TO_CHECK_SIZE EQUAL 0)
        set(_CHECK_LIB_FIFE ${_DEP_CUR_DIR}/src/src/{_BUILD_LIB_DIR}/lib${_DEP_NAME}.a)
        set(_WORK_DIR ${_DEP_CUR_DIR}/src)
    else ()
        set(_CHECK_LIB_FIFE ${_DEP_CUR_DIR}/build/{_BUILD_LIB_DIR}/lib${_DEP_NAME}.a)
        set(_WORK_DIR ${_DEP_CUR_DIR}/build)
    endif ()

    if (NOT EXISTS ${_CHECK_LIB_FIFE})
        message(STATUS "Building ${_DEP_NAME}")
        include(ProcessorCount)
        ProcessorCount(cpus)
        execute_process(
                COMMAND env
                CC=${CMAKE_C_COMPILER}
                CXX=${CMAKE_CXX_COMPILER}
                make
                PREFIX=${_DEP_PREFIX}
                -j${cpus}
                ${_MAKE_BUILD_EXTRA_DEFINE}
                WORKING_DIRECTORY ${_WORK_DIR}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} - FAIL _WORK_DIR=${_WORK_DIR}")
        endif ()
        message(STATUS "Building ${_DEP_NAME} - done")
    endif ()
endfunction()

function(MakeBuildV2)
    CheckVars(_DEP_NAME _DEP_CUR_DIR _DEP_BUILD_DONE)
    set(_DIR_TO_CHECK ${_DEP_CUR_DIR}/build)
    IsEmpty()
    if (_DIR_TO_CHECK_SIZE EQUAL 0)
        set(_CHECK_LIB_FIFE ${_DEP_CUR_DIR}/src/src/{_BUILD_LIB_DIR}/lib${_DEP_NAME}.a)
        set(_WORK_DIR ${_DEP_CUR_DIR}/src)
    else ()
        set(_CHECK_LIB_FIFE ${_DEP_CUR_DIR}/build/{_BUILD_LIB_DIR}/lib${_DEP_NAME}.a)
        set(_WORK_DIR ${_DEP_CUR_DIR}/build)
    endif ()

    if (NOT ${_DEP_BUILD_DONE})
        message(STATUS "Building ${_DEP_NAME}")
        include(ProcessorCount)
        ProcessorCount(cpus)
        execute_process(
                COMMAND env
                CC=${CMAKE_C_COMPILER}
                CXX=${CMAKE_CXX_COMPILER}
                make
                PREFIX=${_DEP_PREFIX}
                -j${cpus}
                ${_MAKE_BUILD_EXTRA_DEFINE}
                WORKING_DIRECTORY ${_WORK_DIR}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} - FAIL _WORK_DIR=${_WORK_DIR}")
        endif ()
        message(STATUS "Building ${_DEP_NAME} - done")
    endif ()
endfunction(MakeBuildV2)

function(MakeInstall)
    set(_VARS _DEP_NAME _DEP_CUR_DIR _DEP_PREFIX)
    CheckVars()

    set(_DIR_TO_CHECK ${_DEP_CUR_DIR}/build)
    IsEmpty()
    if (_DIR_TO_CHECK_SIZE EQUAL 0)
        set(_WORK_DIR ${_DEP_CUR_DIR}/src)
    else ()
        set(_WORK_DIR ${_DEP_CUR_DIR}/build)
    endif ()

    if (NOT EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}.a)
        message(STATUS "Installing ${_DEP_NAME}")
        execute_process(
                COMMAND env
                CC=${CMAKE_C_COMPILER}
                CXX=${CMAKE_CXX_COMPILER}
                make
                install
                PREFIX=${_DEP_PREFIX}
                ${_CMAKE_INSTALL_EXTRA_DEFINE}
                WORKING_DIRECTORY ${_WORK_DIR}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Installing ${_DEP_NAME} - done")
    endif ()
endfunction()

function(MakeInstallV2)
    CheckVars(_DEP_NAME _DEP_CUR_DIR _DEP_PREFIX _DEP_INSTALL_DONE)

    set(_DIR_TO_CHECK ${_DEP_CUR_DIR}/build)
    IsEmpty()
    if (_DIR_TO_CHECK_SIZE EQUAL 0)
        set(_WORK_DIR ${_DEP_CUR_DIR}/src)
    else ()
        set(_WORK_DIR ${_DEP_CUR_DIR}/build)
    endif ()

    if (NOT ${_DEP_INSTALL_DONE})
        message(STATUS "Installing ${_DEP_NAME}")
        execute_process(
                COMMAND env
                CC=${CMAKE_C_COMPILER}
                CXX=${CMAKE_CXX_COMPILER}
                make
                install
                PREFIX=${_DEP_PREFIX}
                ${_CMAKE_INSTALL_EXTRA_DEFINE}
                WORKING_DIRECTORY ${_WORK_DIR}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Installing ${_DEP_NAME} - done")
    else ()
        message(STATUS "Already Installed ${_DEP_NAME}")
    endif ()
endfunction(MakeInstallV2)

function(Bootstrap)
    set(_VARS _DEP_NAME _DEP_CUR_DIR)
    CheckVars()

    if (NOT EXISTS ${_DEP_CUR_DIR}/src/PHASE_BOOTSTRAP)
        message(STATUS "Bootstrap ${_DEP_NAME}")
        execute_process(
                COMMAND ./bootstrap.sh ${_BOOTSTRAP_OPTIONS}
                WORKING_DIRECTORY ${_DEP_CUR_DIR}/src
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Bootstrap ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Bootstrap ${_DEP_NAME} - done")
        file(WRITE ${_DEP_CUR_DIR}/src/PHASE_BOOTSTRAP "done")
    endif ()
endfunction()

function(BootstrapV2)
    CheckVarsV2(_DEP_NAME _DEP_SRC_DIR)
    if ("${P_BOOTSTRAP_SRC_DIR}" STREQUAL "")
        set(P_BOOTSTRAP_SRC_DIR ${_DEP_SRC_DIR})
    endif ()
    if (NOT ${_DEP_INSTALL_DONE} AND NOT EXISTS ${P_BOOTSTRAP_SRC_DIR}/PHASE_BOOTSTRAP)
        message(STATUS "Bootstrap ${_DEP_NAME}. SRC=${P_BOOTSTRAP_SRC_DIR}. "
                "ENV=${P_BOOTSTRAP_ENV}, ARGS=${P_BOOTSTRAP_ARGS}. "
                "CC=${CMAKE_C_COMPILER}, CXX=${CMAKE_CXX_COMPILER}.")
        execute_process(
                COMMAND env CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} ${P_BOOTSTRAP_ENV}
                ./bootstrap.sh ${P_BOOTSTRAP_ARGS}
                WORKING_DIRECTORY ${P_BOOTSTRAP_SRC_DIR}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Bootstrap ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Bootstrap ${_DEP_NAME} - done")
        file(WRITE ${P_BOOTSTRAP_SRC_DIR}/PHASE_BOOTSTRAP "done")
    endif ()
endfunction()

macro(SetExternalVars)
    CheckVarsV2(_EXTERNAL_VARS)
    foreach (_V IN LISTS _EXTERNAL_VARS)
        set(${_V} ${${_V}} PARENT_SCOPE)
    endforeach ()
endmacro(SetExternalVars)

macro(SetDepPrefixV2)
    CheckVarsV2(_DEP_UNAME _DEP_CUR_DIR)

    set(_DEP_PREFIX ${${_DEP_UNAME}_PREFIX})
    if ("${_DEP_PREFIX}" STREQUAL "")
        if ("${DEPS_DIR}" STREQUAL "")
            set(_DEP_PREFIX ${_DEP_CUR_DIR})
        else ()
            set(_DEP_PREFIX ${DEPS_DIR}/${_DEP_NAME})
        endif ()
        set(${_DEP_UNAME}_PREFIX ${_DEP_PREFIX})
    endif ()
endmacro(SetDepPrefixV2)

macro(PrepareDeps version)
    set(options FindByHeader)
    set(oneValueArgs NoneOneArgs)
    set(multiValueArgs MODULES FindPathSuffix)
    cmake_parse_arguments(P "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    string(TOUPPER ${_DEP_NAME} _DEP_UNAME)
    set(_DEP_CUR_DIR ${CMAKE_CURRENT_LIST_DIR})
    set(_DEP_BUILD_DIR ${_DEP_CUR_DIR}/build)
    set(_DEP_SRC_DIR ${_DEP_CUR_DIR}/src)
    set(_NEED_REBUILD TRUE)
    set(_EXTERNAL_VARS)
    if (DEFINED ${_DEP_UNAME}_VERSION)
        set(_DEP_VER ${${_DEP_UNAME}_VERSION})
        message(STATUS "[PrepareDeps] set version with external variable ${_DEP_UNAME}_VERSION=${${_DEP_UNAME}_VERSION}")
    else ()
        set(_DEP_VER ${version})
    endif ()
    set(_DEP_MODULES ${P_MODULES})
    string(REPLACE "." "_" _DEP_VER_ "${_DEP_VER}")

    SetDepPrefixV2()
    CheckVersionV2()

    # check library output
    list(GET _DEP_MODULES 0 _FIRST_DEP_MODULE)
    find_library(build_library_${_DEP_NAME}
            NAMES ${_FIRST_DEP_MODULE} lib${_FIRST_DEP_MODULE}
            PATHS ${_DEP_CUR_DIR}/src ${_DEP_CUR_DIR}/build ${_DEP_CUR_DIR}
            PATH_SUFFIXES src .libs lib lib64 lib/.libs lib64/.libs
            NO_DEFAULT_PATH)
    if ("${build_library_${_DEP_NAME}}" STREQUAL "build_library_${_DEP_NAME}-NOTFOUND")
        set(_DEP_BUILD_DONE FALSE)
    else ()
        set(_DEP_BUILD_DONE TRUE)
    endif ()

    if (${P_FindByHeader})
        find_file(output_library_${_DEP_NAME}
                NAMES ${_FIRST_DEP_MODULE}.h ${_FIRST_DEP_MODULE}.cc ${_FIRST_DEP_MODULE}.c
                ${_FIRST_DEP_MODULE}.hpp ${_FIRST_DEP_MODULE}.hxx ${_FIRST_DEP_MODULE}.H
                ${_FIRST_DEP_MODULE}.hh ${_FIRST_DEP_MODULE}.h++
                PATHS ${_DEP_PREFIX}
                PATH_SUFFIXES include ${P_FindPathSuffix}
                NO_DEFAULT_PATH)
    else ()
        find_library(output_library_${_DEP_NAME}
                NAMES ${_FIRST_DEP_MODULE} lib${_FIRST_DEP_MODULE}
                PATHS ${_DEP_PREFIX}
                PATH_SUFFIXES lib lib64
                NO_DEFAULT_PATH)
    endif ()

    if ("${output_library_${_DEP_NAME}}" STREQUAL "output_library_${_DEP_NAME}-NOTFOUND")
        set(_DEP_INSTALL_DONE FALSE)
    else ()
        set(_DEP_INSTALL_DONE TRUE)
    endif ()
    message(STATUS "[PrepareDeps] prepare done. [DEP=${_DEP_NAME}, MODULES=${P_MODULES}, "
            "BUILD_DONE=${_DEP_BUILD_DONE}, INSTALL_DONE=${_DEP_INSTALL_DONE} ${build_library_${_DEP_NAME}}, "
            "${output_library_${_DEP_NAME}}, DEP_PREFIX=${_DEP_PREFIX} ${output_library_${_DEP_NAME}}]")
endmacro(PrepareDeps)

macro(AddLibrary MODULE)
    set(options NONE)
    set(oneValueArgs PREFIX LINK_LIBRARIES COMPILE_OPTIONS)
    set(multiValueArgs SUBMODULES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    message(STATUS "[AddLibrary] MODULE=${MODULE} PREFIX=${ARG_PREFIX} DEP=${ARG_DEP} SUBMODULES=${ARG_SUBMODULES}")


    if ("${ARG_PREFIX}" STREQUAL "")
        message(FATAL_ERROR "PREFIX should not be empty")
    endif ()
    foreach (I IN LISTS ARG_SUBMODULES)
        set(TGT ${MODULE}::${I})
        if (NOT TARGET ${TGT})
            add_library(${TGT} STATIC IMPORTED GLOBAL)
            find_library(add_library_${MODULE}_${I}
                    NAMES lib${I}${CMAKE_STATIC_LIBRARY_SUFFIX} ${I}${CMAKE_STATIC_LIBRARY_SUFFIX} ${I}
                    PATHS ${ARG_PREFIX}
                    PATH_SUFFIXES lib lib64
                    NO_DEFAULT_PATH)
            message(STATUS "[AddLibrary] TARGET=${TGT} LIB=${add_library_${MODULE}_${I}}")
            set_target_properties(${TGT} PROPERTIES
                    # IMPORTED_LOCATION "${ARG_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}${I}${CMAKE_STATIC_LIBRARY_SUFFIX}"
                    IMPORTED_LOCATION "${add_library_${MODULE}_${I}}"
                    INCLUDE_DIRECTORIES ${ARG_PREFIX}/include
                    INTERFACE_INCLUDE_DIRECTORIES ${ARG_PREFIX}/include
                    # eg. pthread;z
                    INTERFACE_LINK_LIBRARIES "${ARG_LINK_LIBRARIES}"
                    # eg. -pthread
                    INTERFACE_COMPILE_OPTIONS "${ARG_COMPILE_OPTIONS}")
        else ()
            message(STATUS "[AddLibrary] target ${TGT} exists, skip.")
        endif ()
    endforeach ()
endmacro(AddLibrary)

if (NOT CMAKE_PROPERTY_LIST)
    execute_process(COMMAND cmake --help-property-list OUTPUT_VARIABLE CMAKE_PROPERTY_LIST)
    # Convert command output into a CMake list
    string(REGEX REPLACE ";" "\\\\;" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")
    string(REGEX REPLACE "\n" ";" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")
endif ()

function(PrintTargetProperties target)
    if (NOT TARGET ${target})
        message(STATUS "There is no target named '${target}'")
        return()
    endif ()

    foreach (property ${CMAKE_PROPERTY_LIST})
        string(REPLACE "<CONFIG>" "${CMAKE_BUILD_TYPE}" property ${property})

        if (property STREQUAL "LOCATION" OR property MATCHES "^LOCATION_" OR property MATCHES "_LOCATION$")
            continue()
        endif ()

        get_property(was_set TARGET ${target} PROPERTY ${property} SET)
        if (was_set)
            get_target_property(value ${target} ${property})
            message("${target} ${property} = ${value}")
        endif ()
    endforeach ()
endfunction()

macro(AddExecutables)
    set(options NoneOpt)
    set(oneValueArgs DEP_NAME PREFIX)
    set(multiValueArgs EXECUTABLES)
    cmake_parse_arguments(P "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    foreach (I IN LISTS P_EXECUTABLES)
        set(EXE_TARGET ${P_DEP_NAME}::bin::${I})
        if (TARGET ${EXE_TARGET})
            message(STATUS "[AddExecutables] TARGET=${EXE_TARGET} BINARY=${binary_path_${I}} already added.")
        else ()
            add_executable(${EXE_TARGET} IMPORTED)
            find_file(binary_path_${I}
                    NAMES ${I}
                    PATHS ${P_PREFIX}
                    PATH_SUFFIXES bin bin64
                    NO_DEFAULT_PATH)
            if ("${binary_path_${I}}" STREQUAL "binary_path_${I}-NOTFOUND")
                message(FATAL_ERROR "[AddExecutables] executable file not found. [name=${I}, prefix=${P_PREFIX}]")
            endif ()
            set_target_properties(${EXE_TARGET} PROPERTIES
                    IMPORTED_LOCATION "${binary_path_${I}}")
            message(STATUS "[AddExecutables] TARGET=${EXE_TARGET} BINARY=${binary_path_${I}}")
            # PrintTargetProperties(${EXE_TARGET})
            unset(EXE_TARGET)
        endif ()
    endforeach ()
endmacro(AddExecutables)

macro(AddProject)
    set(options MAKE INSTALL NINJA AUTO_RE_CONF CONFIGURE AUTOGEN BOOTSTRAP B2BUILD B2INSTALL)
    set(oneValueArgs GIT_REPOSITORY GIT_TAG DEP_AUTHOR DEP_PROJECT DEP_TAG SPEED_UP_FILE DEP_URL
            BOOTSTRAP_SRC_DIR B2INSTALL_SRC_DIR)
    set(multiValueArgs CONFIGURE_DEFINE NINJA_EXTRA_DEFINE BOOTSTRAP_ENV BOOTSTRAP_ARGS B2BUILD_ENV B2BUILD_ARGS
            B2INSTALL_ENV B2INSTALL_ARGS)
    cmake_parse_arguments(P "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT ${_DEP_INSTALL_DONE})
        if (DEFINED ENV{SPEED_UP_URL} AND NOT ${P_SPEED_UP_FILE} STREQUAL "")
            set(_DEP_URL $ENV{SPEED_UP_URL}/${P_SPEED_UP_FILE})
        else ()
            set(_DEP_URL ${P_DEP_URL})
        endif ()

        # external git repo > speed up url > download git release > clone git repo
        set(_EXTERNAL_GIT_REPO ${${_DEP_UNAME}_GIT_REPOSITORY})
        if (DEFINED _EXTERNAL_GIT_REPO AND NOT ${_EXTERNAL_GIT_REPO} STREQUAL "")
            message(STATUS "[AddProject] use external defined git repo for ${_DEP_NAME}. "
                    "[GIT_REPOSITORY=${_EXTERNAL_GIT_REPO}, VERSION=${_DEP_VER}]")
            GitCloneV2(${_EXTERNAL_GIT_REPO} ${_DEP_VER})
        elseif (NOT ${_DEP_URL} STREQUAL "")
            message(STATUS "[AddProject] download deps. [URL=${_DEP_URL}, VERSION=${_DEP_VER}]")
            DownloadDepV3(${_DEP_VER} ${_DEP_URL})
            ExtractDepV2(${_DEP_VER})
        elseif ("${P_GIT_REPOSITORY}" STREQUAL "" AND NOT "${P_DEP_PROJECT}" STREQUAL "")
            set(_DEP_URL https://codeload.github.com/${P_DEP_AUTHOR}/${P_DEP_PROJECT}/tar.gz/refs/tags/${P_DEP_TAG})
            message(STATUS "[AddProject] github, URL=${_DEP_URL}, VERSION=${_DEP_VER}")
            DownloadDepV3(${_DEP_VER} ${_DEP_URL})
            ExtractDepV2(${_DEP_VER})
        elseif (NOT "${P_GIT_REPOSITORY}" STREQUAL "")
            message(STATUS "[AddProject] GIT=${P_GIT_REPOSITORY}, TAG=${_DEP_VER}")
            GitCloneV2(${P_GIT_REPOSITORY} ${_DEP_VER})
        endif ()
        if (${P_AUTOGEN})
            Autogen()
        endif ()
        if (${P_AUTO_RE_CONF})
            AutoReConfV2()
        endif ()
        if (${P_CONFIGURE})
            ConfigureV2(EXTRA_DEFINE ${P_CONFIGURE_DEFINE})
        endif ()
        if (${P_MAKE})
            MakeBuildV2()
        endif ()
        if (${P_INSTALL})
            MakeInstallV2()
        endif ()
        if (${P_NINJA})
            CMakeNinjaV2(NINJA_EXTRA_DEFINE ${P_NINJA_EXTRA_DEFINE})
            NinjaBuildV2()
            NinjaInstallV2()
        endif ()
        if (${P_BOOTSTRAP})
            BootstrapV2()
        endif ()
        if (${P_B2BUILD})
            B2Build()
        endif ()
        if (${P_B2INSTALL})
            B2Install()
        endif ()
    endif ()

    SetDepPath()
    AppendCMakePrefix()

    # append external vars
    list(APPEND _EXTERNAL_VARS _DEP_NAME)
    list(APPEND _EXTERNAL_VARS _DEP_PREFIX)
    list(APPEND _EXTERNAL_VARS _DEP_MODULES)

    SetExternalVars()
endmacro(AddProject)

macro(ProcessAddLibrary)
    set(options NoneOpt)
    set(oneValueArgs COMPILE_OPTIONS LINK_LIBRARIES)
    set(multiValueArgs EXECUTABLES)
    cmake_parse_arguments(P "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (DEFINED ${_DEP_NAME}_ADD_LIBRARY)
        return()
    endif ()
    set(${_DEP_NAME}_ADD_LIBRARY TRUE)
    AddLibrary(${_DEP_NAME} PREFIX ${_DEP_PREFIX} SUBMODULES ${_DEP_MODULES}
            COMPILE_OPTIONS ${P_COMPILE_OPTIONS}
            LINK_LIBRARIES ${P_LINK_LIBRARIES})
    if (P_EXECUTABLES)
        AddExecutables(DEP_NAME ${_DEP_NAME} PREFIX ${_DEP_PREFIX} EXECUTABLES ${P_EXECUTABLES})
    endif ()

    unset(_DEP_NAME)
    unset(_DEP_PREFIX)
    unset(_DEP_MODULES)
endmacro(ProcessAddLibrary)

macro(ProcessFindPackage MODULE)
    find_package(${MODULE} REQUIRED PATHS ${_DEP_PREFIX} NO_DEFAULT_PATH)
    # unset template variables
    unset(_DEP_NAME)
    unset(_DEP_PREFIX)
    unset(_DEP_MODULES)
endmacro(ProcessFindPackage)
