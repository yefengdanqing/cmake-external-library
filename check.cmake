include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)

function(SetDepPrefix name uname prefix)
    if (${uname}_PREFIX STREQUAL "")
        set(_DEP_PREFIX ${uname}_PREFIX PARENT_SCOPE)
    elseif (DEPS_DIR)
        set(_DEP_PREFIX "${DEPS_DIR}/${name}" PARENT_SCOPE)
    else ()
        set(_DEP_PREFIX ${prefix} PARENT_SCOPE)
    endif ()
endfunction(SetDepPrefix)

macro(CheckLibraryInstall)
    list(GET _DEP_MODULES 0 _FIRST_DEP_MODULE)
    if (ARG_FIND_BY_HEADER)
        FindHeader(install_library_${_DEP_NAME} ${_FIRST_DEP_MODULE} ${_DEP_PREFIX} ${ARG_FIND_SUFFIX})
    else ()
        FindLibrary(install_library_${_DEP_NAME} ${_FIRST_DEP_MODULE} ${_DEP_PREFIX})
    endif ()
    if (NOT install_library_${_DEP_NAME} STREQUAL "install_library_${_DEP_NAME}-NOTFOUND")
        set(_DEP_INSTALLED_LIBRARY ${install_library_${_DEP_NAME}})
    endif ()
endmacro(CheckLibraryInstall)

macro(SetTemplateVariable version)
    # _DEP_NAME _DEP_UNAME _DEP_VER _DEP_VER_ _DEP_MODULES
    # _DEP_CUR_DIR _DEP_PREFIX _DEP_BUILD_DIR _DEP_SRC_DIR _DEP_PACKAGE_DIR
    # _NEED_REBUILD _DEP_INSTALLED_LIBRARY

    get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
    string(TOUPPER ${_DEP_NAME} _DEP_UNAME)
    set(_DEP_CUR_DIR ${CMAKE_CURRENT_LIST_DIR})
    set(_DEP_BUILD_DIR ${_DEP_CUR_DIR}/build)
    set(_DEP_PACKAGE_DIR ${_DEP_CUR_DIR}/packages)
    set(_DEP_SRC_DIR ${_DEP_CUR_DIR}/src)
    set(_NEED_REBUILD TRUE)
    set(_EXTERNAL_VARS)
    if (DEFINED ${_DEP_UNAME}_VERSION)
        set(_DEP_VER ${${_DEP_UNAME}_VERSION})
    else ()
        set(_DEP_VER ${version})
    endif ()
    if (ARG_MODULES)
        set(_DEP_MODULES ${ARG_MODULES})
    else ()
        set(_DEP_MODULES ${_DEP_NAME})
    endif ()
    string(REPLACE "." "_" _DEP_VER_ "${_DEP_VER}")
    SetDepPrefix(${_DEP_NAME} ${_DEP_UNAME} ${_DEP_CUR_DIR})
    CheckLibraryInstall()
    message(STATUS "[SetTemplateVariable] _DEP_NAME=${_DEP_NAME} _DEP_UNAME=${_DEP_UNAME} "
            "_DEP_CUR_DIR=${_DEP_CUR_DIR} _DEP_PREFIX=${_DEP_PREFIX} _DEP_BUILD_DIR=${_DEP_BUILD_DIR} "
            "_DEP_SRC_DIR=${_DEP_SRC_DIR} _NEED_REBUILD=${_NEED_REBUILD} _DEP_VER=${_DEP_VER} "
            "_DEP_MODULES=${_DEP_MODULES} _DEP_VER_=${_DEP_VER_} _DEP_INSTALLED_LIBRARY=${_DEP_INSTALLED_LIBRARY}")
endmacro(SetTemplateVariable)

function(CleanDep source prefix)
    message(STATUS "Clean SRC=${source} PREFIX=${prefix}")
    if (source)
        file(REMOVE_RECURSE ${source}/src)
        file(REMOVE_RECURSE ${source}/build)
    endif ()
    if (prefix)
        file(REMOVE_RECURSE ${prefix}/bin)
        file(REMOVE_RECURSE ${prefix}/lib)
        file(REMOVE_RECURSE ${prefix}/lib64)
        file(REMOVE_RECURSE ${prefix}/include)
        file(REMOVE_RECURSE ${prefix}/share)
        file(REMOVE_RECURSE ${prefix}/doc)
    endif ()
endfunction()

function(WriteVersion version prefix)
    message(STATUS "Write VERSION file. VERSION=${version} FILE=${prefix}/VERSION")
    file(WRITE ${prefix}/VERSION ${version})
endfunction()

macro(AppendCMakePrefix)
    list(FIND CMAKE_PREFIX_PATH ${_DEP_PREFIX} _DEP_INDEX)
    if (_DEP_INDEX EQUAL -1)
        list(APPEND CMAKE_PREFIX_PATH ${_DEP_PREFIX})
        set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} PARENT_SCOPE)
    endif ()
endmacro(AppendCMakePrefix)

function(AppendPkgConfig)
    if (EXISTS ${_DEP_PREFIX}/lib/pkgconfig/)
        set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${_DEP_PREFIX}/lib/pkgconfig/")
    elseif (EXISTS ${_DEP_PREFIX}/lib64/pkgconfig/)
        set(ENV{PKG_CONFIG_PATH} "$ENV{PKG_CONFIG_PATH}:${_DEP_PREFIX}/lib64/pkgconfig/")
    endif ()
endfunction(AppendPkgConfig)

function(CheckVersion)
    if (NOT EXISTS ${_DEP_PREFIX}/VERSION)
        set(_NEED_REBUILD TRUE)
    else ()
        file(STRINGS ${_DEP_PREFIX}/VERSION BUILD_VERSION)
        if ("${BUILD_VERSION}" STREQUAL "${_DEP_VER}")
            set(_NEED_REBUILD FALSE)
        else ()
            set(_NEED_REBUILD TRUE)
        endif ()
    endif ()
    set(_NEED_REBUILD ${_NEED_REBUILD} PARENT_SCOPE)
    if (_NEED_REBUILD)
        CleanDep(${_DEP_CUR_DIR} ${_DEP_PREFIX})
        WriteVersion(${_DEP_VER} ${_DEP_PREFIX})
    endif ()
endfunction(CheckVersion)

macro(PrepareDep version)
    cmake_parse_arguments(ARG "FIND_BY_HEADER" "" "MODULES;FIND_SUFFIX" ${ARGN})

    SetTemplateVariable(${version})
    CheckVersion()
endmacro(PrepareDep)

function(DownloadDep)
    if (_DEP_INSTALLED_LIBRARY)
        return()
    endif ()

    set(ARG GIT_REPOSITORY AUTHOR PROJECT TAG SPEED_UP_FILE DEP_URL)
    cmake_parse_arguments(ARG "" "${ARG}" "" ${ARGN})

    if (NOT ARG_PROJECT)
        set(ARG_PROJECT ${_DEP_NAME})
    endif ()

    if (NOT ARG_AUTHOR)
        set(ARG_AUTHOR ${_DEP_NAME})
    endif ()

    if (NOT ARG_TAG)
        set(ARG_TAG ${_DEP_VER})
    endif ()

    if (DEFINED ENV{SPEED_UP_URL} AND ARG_SPEED_UP_FILE)
        set(_DEP_URL $ENV{SPEED_UP_URL}/${ARG_SPEED_UP_FILE})
    else ()
        set(_DEP_URL ${ARG_DEP_URL})
    endif ()

    # external git repo > speed up url > download git release > clone git repo
    set(_EXTERNAL_GIT_REPO ${${_DEP_UNAME}_GIT_REPOSITORY})
    if (_EXTERNAL_GIT_REPO)
        GitClone(${_DEP_NAME} ${_DEP_SRC_DIR} ${_EXTERNAL_GIT_REPO} ${_DEP_VER})
    elseif (_DEP_URL)
        DoDownloadDep(${_DEP_NAME} ${_DEP_PACKAGE_DIR} ${_DEP_VER} ${_DEP_URL})
        ExtractDep(${_DEP_NAME} ${_DEP_SRC_DIR} ${_DEP_PACKAGE_DIR} ${_DEP_VER})
    elseif (NOT ARG_GIT_REPOSITORY AND ARG_PROJECT)
        set(_DEP_URL https://codeload.github.com/${ARG_AUTHOR}/${ARG_PROJECT}/tar.gz/refs/tags/${ARG_TAG})
        DoDownloadDep(${_DEP_NAME} ${_DEP_PACKAGE_DIR} ${_DEP_VER} ${_DEP_URL})
        ExtractDep(${_DEP_NAME} ${_DEP_SRC_DIR} ${_DEP_PACKAGE_DIR} ${_DEP_VER})
    elseif (ARG_GIT_REPOSITORY)
        GitClone(${_DEP_NAME} ${_DEP_SRC_DIR} ${ARG_GIT_REPOSITORY} ${_DEP_VER})
    endif ()
endfunction(DownloadDep)

macro(SetSrc)
    if (ARG_SRC)
        set(SRC ${ARG_SRC})
    else ()
        set(SRC ${_DEP_SRC_DIR})
    endif ()

    set(BUILD ${_DEP_BUILD_DIR})
endmacro(SetSrc)

macro(CheckDest)
    set(PREFIX ${_DEP_PREFIX})
    if (ARG_DEST AND NOT EXISTS ${PREFIX}/${ARG_DEST})
        set(CHECK_DEST_RESULT FALSE)
    elseif (NOT _DEP_INSTALLED_LIBRARY)
        set(CHECK_DEST_RESULT FALSE)
    else ()
        set(CHECK_DEST_RESULT TRUE)
    endif ()
endmacro(CheckDest)

function(BOOTSTRAP)
    cmake_parse_arguments(ARG "" "SRC" "ENV;ARGS" ${ARGN})
    SetSrc()
    if (NOT EXISTS ${SRC}/PHASE_BOOTSTRAP)
        message(STATUS "Bootstrap ${_DEP_NAME} SRC=${SRC} ENV=${ARG_ENV} ARGS=${ARGS}. "
                "CC=${CMAKE_C_COMPILER}, CXX=${CMAKE_CXX_COMPILER}.")
        execute_process(
                COMMAND env CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} ${ARG_ENV}
                ./bootstrap.sh ${ARG_ARGS}
                WORKING_DIRECTORY ${SRC}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Bootstrap ${_DEP_NAME} - FAIL")
        else ()
            message(STATUS "Bootstrap ${_DEP_NAME} - done")
            file(WRITE ${SRC}/PHASE_BOOTSTRAP "done")
        endif ()
    endif ()
endfunction(BOOTSTRAP)

function(B2Build)
    cmake_parse_arguments(ARG "" "SRC" "ENV;ARGS" ${ARGN})
    SetSrc()

    if (NOT _DEP_INSTALLED_LIBRARY AND NOT EXISTS ${SRC}/PHASE_B2BUILD)
        message(STATUS "B2 compile. DEP=${_DEP_NAME} SRC=${SRC} ENV=${ARG_ENV} ARGS=${ARG_ARGS}")
        ProcessorCount(cpus)
        execute_process(
                COMMAND env CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} ${ARG_ENV}
                b2 --build-dir=${_DEP_BUILD_DIR} ${ARG_ARGS} -j${cpus}
                WORKING_DIRECTORY ${SRC}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "B2 build ${_DEP_NAME} ${rc} - FAIL")
        else ()
            message(STATUS "B2 compile ${_DEP_NAME} - done")
            file(WRITE ${SRC}/PHASE_B2BUILD "done")
        endif ()
    endif ()
endfunction(B2Build)

function(B2Install)
    cmake_parse_arguments(ARG "" "SRC;DEST" "ENV;ARGS" ${ARGN})
    SetSrc()
    CheckDest()

    if (NOT CHECK_DEST_RESULT)
        message(STATUS "B2 install. DEP=${_DEP_NAME} SRC=${SRC} PREFIX=${_DEP_PREFIX} "
                "ENV=${ARG_ENV} ARGS=${ARG_ARGS}")
        execute_process(
                COMMAND env CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} ${ARG_ENV}
                b2 --prefix=${_DEP_PREFIX} ${ARG_ARGS} install
                WORKING_DIRECTORY ${SRC}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "B2 install ${_DEP_NAME} - FAIL")
        else ()
            message(STATUS "B2 install ${_DEP_NAME} - done")
            file(WRITE ${SRC}/PHASE_B2INSTALL "done")
        endif ()
    endif ()
endfunction(B2Install)

function(CMakeNinja)
    if (ARG_PIC_OFF)
        set(_PIC_FLAG "-DCMAKE_POSITION_INDEPENDENT_CODE=OFF")
    else ()
        set(_PIC_FLAG "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
    endif ()

    if (ARG_BUILD_TYPE)
        set(_BUILD_TYPE ${ARG_BUILD_TYPE})
    else ()
        set(_BUILD_TYPE ${CMAKE_BUILD_TYPE})
    endif ()

    if (NOT CMAKE_CXX_STANDARD)
        set(CMAKE_CXX_STANDARD 17)
    endif ()

    if (NOT _DEP_INSTALLED_LIBRARY AND NOT EXISTS ${SRC}/PHASE_CMAKE_NINJA)
        file(MAKE_DIRECTORY ${BUILD})
        string(REPLACE ";" "\\;" CMAKE_PREFIX_PATH_STR "${CMAKE_PREFIX_PATH}")
        message(STATUS "Configuring ${_DEP_NAME}. CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH} "
                "CMAKE_PREFIX_PATH_STR=${CMAKE_PREFIX_PATH_STR} NINJA_EXTRA_DEFINE=${P_NINJA_EXTRA_DEFINE}")
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
                ${ARG_ARGS}
                ${SRC}
                WORKING_DIRECTORY ${BUILD}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} - FAIL")
        else ()
            message(STATUS "Configuring ${_DEP_NAME} - done")
            file(WRITE ${SRC}/PHASE_CMAKE_NINJA "done")
        endif ()
    endif ()
endfunction(CMakeNinja)

function(NinjaBuild)
    if (NOT _DEP_INSTALLED_LIBRARY AND NOT EXISTS ${_DEP_BUILD_DIR}/PHASE_NINJA_BUILD)
        message(STATUS "Building ${_DEP_NAME}")
        execute_process(
                COMMAND ninja
                WORKING_DIRECTORY ${BUILD}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} - FAIL")
        else ()
            message(STATUS "Building ${_DEP_NAME} - done")
            file(WRITE ${_DEP_BUILD_DIR}/PHASE_NINJA_BUILD "done")
        endif ()
    endif ()
endfunction(NinjaBuild)

function(NinjaInstall)
    if (ARG_ROOT_PERMISSION)
        set(_PERMISSION_ROLE "sudo")
    endif ()

    if (NOT _DEP_INSTALLED_LIBRARY)
        message(STATUS "Installing ${_DEP_NAME}")
        execute_process(
                COMMAND ${_PERMISSION_ROLE} ninja install
                WORKING_DIRECTORY ${BUILD}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} - FAIL")
        endif ()
        message(STATUS "Installing ${_DEP_NAME} - done")
    endif ()
endfunction(NinjaInstall)

function(Ninja)
    cmake_parse_arguments(ARG "PIC_OFF;ROOT_PERMISSION" "SRC;BUILD_TYPE" "ARGS" ${ARGN})
    SetSrc()
    CMakeNinja()
    NinjaBuild()
    NinjaInstall()
endfunction(Ninja)

function(Autogen)
    if (NOT _DEP_INSTALLED_LIBRARY AND NOT EXISTS ${_DEP_SRC_DIR}/PHASE_AUTOGEN)
        message(STATUS "Autogen ${_DEP_NAME}")
        execute_process(
                COMMAND env
                CC=${CMAKE_C_COMPILER}
                CXX=${CMAKE_CXX_COMPILER}
                CFLAGS=-fPIC
                CXXFLAGS=-fPIC
                ./autogen.sh
                WORKING_DIRECTORY ${_DEP_SRC_DIR}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Autogen ${_DEP_NAME} - FAIL")
        else ()
            message(STATUS "Autogen ${_DEP_NAME} - done")
            file(WRITE ${_DEP_SRC_DIR}/PHASE_AUTOGEN "done")
        endif ()
    endif ()
endfunction()

function(Configure)
    cmake_parse_arguments(ARG "" "CONFIGURE_COMMAND" "ARGS" ${ARGN})
    if (EXISTS ${_DEP_SRC_DIR}/configure)
        set(CONFIG_CMD configure)
    elseif (EXISTS ${_DEP_SRC_DIR}/config)
        set(CONFIG_CMD config)
    elseif (EXISTS ${_DEP_SRC_DIR}/configure.sh)
        set(CONFIG_CMD configure.sh)
    endif ()

    if (NOT ARG_CONFIGURE_COMMAND)
        set(CONFIGURE_COMMAND ${CONFIG_CMD} --prefix=${_DEP_PREFIX})
    endif ()

    if (NOT _DEP_INSTALLED_LIBRARY AND NOT EXISTS ${_DEP_SRC_DIR}/PHASE_CONFIGURE)
        message(STATUS "Configuring ${_DEP_NAME} with command ${CONFIGURE_COMMAND} ARGS=${ARG_ARGS}")
        execute_process(
                COMMAND env
                CC=${CMAKE_C_COMPILER}
                CXX=${CMAKE_CXX_COMPILER}
                CFLAGS=-fPIC
                CXXFLAGS=-fPIC
                ./${CONFIGURE_COMMAND} ${ARG_ARGS}
                WORKING_DIRECTORY ${_DEP_SRC_DIR}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} - FAIL")
        else ()
            message(STATUS "Configuring ${_DEP_NAME} - done")
            file(WRITE ${_DEP_SRC_DIR}/PHASE_CONFIGURE "done")
        endif ()
    endif ()
endfunction(Configure)

function(MakeBuild)
    cmake_parse_arguments(ARG "" "" "ARGS" ${ARGN})
    if (EXISTS ${_DEP_BUILD_DIR})
        set(_WORK_DIR ${_DEP_BUILD_DIR})
    else ()
        set(_WORK_DIR ${_DEP_SRC_DIR})
    endif ()

    if (NOT _DEP_INSTALLED_LIBRARY AND NOT EXISTS ${_DEP_SRC_DIR}/PHASE_MAKE_BUILD)
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
                ${ARG_ARGS}
                WORKING_DIRECTORY ${_WORK_DIR}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} - FAIL WORK_DIR=${_WORK_DIR}")
        else ()
            message(STATUS "Building ${_DEP_NAME} - done")
            file(WRITE ${_DEP_SRC_DIR}/PHASE_MAKE_BUILD "done")
        endif ()
    endif ()
endfunction(MakeBuild)

function(MakeInstall)
    cmake_parse_arguments(ARG "" "" "ARGS" ${ARGN})

    if (EXISTS ${_DEP_BUILD_DIR})
        set(_WORK_DIR ${_DEP_BUILD_DIR})
    else ()
        set(_WORK_DIR ${_DEP_SRC_DIR})
    endif ()

    if (NOT _DEP_INSTALLED_LIBRARY AND NOT EXISTS ${_DEP_SRC_DIR}/PHASE_MAKE_INSTALL)
        message(STATUS "Installing ${_DEP_NAME}")
        execute_process(
                COMMAND env
                CC=${CMAKE_C_COMPILER}
                CXX=${CMAKE_CXX_COMPILER}
                make
                install
                PREFIX=${_DEP_PREFIX}
                ${ARG_ARGS}
                WORKING_DIRECTORY ${_WORK_DIR}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Installing ${_DEP_NAME} - FAIL")
        else ()
            message(STATUS "Installing ${_DEP_NAME} - done")
            file(WRITE ${_DEP_SRC_DIR}/PHASE_MAKE_INSTALL "done")
        endif ()
    endif ()
endfunction(MakeInstall)

function(BuildConf)
    cmake_parse_arguments(ARG "" "" "ENV;ARGS" ${ARGN})
    if (NOT _DEP_INSTALLED_LIBRARY AND NOT EXISTS ${_DEP_SRC_DIR}/PHASE_BUILD_CONF)
        execute_process(
                COMMAND env ${ARG_ENV}
                ./buildconf
                ${ARG_ARGS}
                WORKING_DIRECTORY ${_DEP_SRC_DIR}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Build config ${_DEP_NAME} - FAIL")
        else ()
            message(STATUS "Build config ${_DEP_NAME} - done")
            file(WRITE ${_DEP_SRC_DIR}/PHASE_BUILD_CONF "done")
        endif ()
    endif ()
endfunction()

function(AutoReconf)
    if (NOT _DEP_INSTALLED_LIBRARY AND NOT EXISTS ${_DEP_SRC_DIR}/PHASE_AUTO_RECONF)
        execute_process(
                COMMAND env
                autoreconf -fi
                WORKING_DIRECTORY ${_DEP_SRC_DIR}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Auto reconf ${_DEP_NAME} - FAIL")
        else ()
            message(STATUS "Auto reconf ${_DEP_NAME} - done")
            file(WRITE ${_DEP_SRC_DIR}/PHASE_AUTO_RECONF "done")
        endif ()
    endif ()
endfunction()

macro(SetExternalVars)
    foreach (_V IN LISTS _EXTERNAL_VARS)
        set(${_V} ${${_V}} PARENT_SCOPE)
    endforeach ()
    set(_EXTERNAL_VARS ${_EXTERNAL_VARS} PARENT_SCOPE)
endmacro(SetExternalVars)

macro(PostProcess)
    AppendCMakePrefix()
    AppendPkgConfig()
    # append external vars
    list(APPEND _EXTERNAL_VARS _DEP_NAME)
    list(APPEND _EXTERNAL_VARS _DEP_PREFIX)
    list(APPEND _EXTERNAL_VARS _DEP_MODULES)

    SetExternalVars()
endmacro(PostProcess)

macro(AddLibrary MODULE)
    cmake_parse_arguments(ARG "" "PREFIX" "SUBMODULES;COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})

    if (NOT ARG_PREFIX)
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
            message(STATUS "[AddLibrary] TARGET=${TGT} LIB=${add_library_${MODULE}_${I}} "
                    "LINK_LIBRARIES=${ARG_LINK_LIBRARIES} COMPILE_OPTIONS=${ARG_COMPILE_OPTIONS}")
            set_target_properties(${TGT} PROPERTIES
                    # IMPORTED_LOCATION "${ARG_PREFIX}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}${I}${CMAKE_STATIC_LIBRARY_SUFFIX}"
                    IMPORTED_LOCATION "${add_library_${MODULE}_${I}}"
                    INCLUDE_DIRECTORIES ${ARG_PREFIX}/include
                    INTERFACE_INCLUDE_DIRECTORIES ${ARG_PREFIX}/include
                    # i.e. pthread;z
                    INTERFACE_LINK_LIBRARIES "${ARG_LINK_LIBRARIES}"
                    # i.e. -pthread
                    INTERFACE_COMPILE_OPTIONS "${ARG_COMPILE_OPTIONS}")
        else ()
            message(STATUS "[AddLibrary] target ${TGT} exists, skip.")
        endif ()
    endforeach ()
endmacro(AddLibrary)

macro(AddExecutables)
    cmake_parse_arguments(ARG "" "DEP_NAME;PREFIX" "EXECUTABLES" ${ARGN})

    foreach (I IN LISTS ARG_EXECUTABLES)
        set(EXE_TARGET ${ARG_DEP_NAME}::bin::${I})
        if (NOT TARGET ${EXE_TARGET})
            add_executable(${EXE_TARGET} IMPORTED)
            find_file(binary_path_${I}
                    NAMES ${I}
                    PATHS ${ARG_PREFIX}
                    PATH_SUFFIXES bin bin64
                    NO_DEFAULT_PATH)
            if ("${binary_path_${I}}" STREQUAL "binary_path_${I}-NOTFOUND")
                message(FATAL_ERROR "[AddExecutables] executable file not found. [name=${I}, prefix=${ARG_PREFIX}]")
            endif ()
            set_target_properties(${EXE_TARGET} PROPERTIES
                    IMPORTED_LOCATION "${binary_path_${I}}")
            message(STATUS "[AddExecutables] TARGET=${EXE_TARGET} BINARY=${binary_path_${I}}")
            unset(EXE_TARGET)
        endif ()
    endforeach ()
endmacro(AddExecutables)

macro(UnsetExternalVars)
    foreach (_I IN LISTS _EXTERNAL_VARS)
        unset(${_I})
    endforeach ()
    unset(_I)
endmacro(UnsetExternalVars)

macro(ProcessAddLibrary)
    cmake_parse_arguments(ARG "" "" "EXECUTABLES;COMPILE_OPTIONS;LINK_LIBRARIES" ${ARGN})

    if (NOT _DEP_NAME OR ${_DEP_NAME}_ADDED_LIBRARY)
        UnsetExternalVars()
        return()
    else ()
        set(${_DEP_NAME}_ADDED_LIBRARY TRUE)
        AddLibrary(${_DEP_NAME}
                PREFIX ${_DEP_PREFIX}
                SUBMODULES ${_DEP_MODULES}
                COMPILE_OPTIONS ${ARG_COMPILE_OPTIONS}
                LINK_LIBRARIES ${ARG_LINK_LIBRARIES})
        if (ARG_EXECUTABLES)
            AddExecutables(DEP_NAME ${_DEP_NAME} PREFIX ${_DEP_PREFIX} EXECUTABLES ${ARG_EXECUTABLES})
        endif ()
        UnsetExternalVars()
    endif ()
endmacro(ProcessAddLibrary)

macro(ProcessFindPackage MODULE)
    if (NOT _DEP_NAME OR ${_DEP_NAME}_ADDED_LIBRARY)
        UnsetExternalVars()
        return()
    else ()
        set(${_DEP_NAME}_ADDED_LIBRARY TRUE)
        find_package(${MODULE} REQUIRED PATHS ${_DEP_PREFIX} NO_DEFAULT_PATH)
        UnsetExternalVars()
    endif ()
endmacro(ProcessFindPackage)
