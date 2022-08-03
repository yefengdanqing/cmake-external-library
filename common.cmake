function(FindLibrary target module source)
    set(NMS ${module} lib${module})
    if (module MATCHES "^lib")
        string(SUBSTRING ${module} 3 -1 md)
        list(APPEND NMS ${md})
    endif ()
    find_library(${target}
            NAMES ${NMS}
            PATHS ${source}/src ${source}/build ${source}
            PATH_SUFFIXES src .libs lib lib64 lib/.libs lib64/.libs
            NO_DEFAULT_PATH)
    if (${target})
        set(${target}_FOUND TRUE PARENT_SCOPE)
    else ()
        set(${target}_FOUND FALSE PARENT_SCOPE)
    endif ()
endfunction(FindLibrary)

function(FindHeader target module source suffix)
    find_file(${target}
            NAMES ${module}.h ${module}.cc ${module}.c ${module}.hpp ${module}.hxx
            ${module}.H ${module}.hh ${module}.h++
            PATHS ${source}
            PATH_SUFFIXES include ${suffix}
            NO_DEFAULT_PATH)
    if (${target})
        set(${target}_FOUND TRUE PARENT_SCOPE)
    else ()
        set(${target}_FOUND FALSE PARENT_SCOPE)
    endif ()
endfunction(FindHeader)

function(DirSize target source)
    set(${target}_SIZE 0)
    if (EXISTS ${source})
        file(GLOB T_SRC_DIR "${source}/*")
        list(LENGTH T_SRC_DIR ${target}_SIZE)
    endif ()
    set(${target}_SIZE ${${target}_SIZE} PARENT_SCOPE)
endfunction(DirSize)

function(GitClone name source repository version)
    find_package(Git REQUIRED)
    file(MAKE_DIRECTORY ${source})
    DirSize(T_SRC ${source})
    if (T_SRC_SIZE EQUAL 0)
        message(STATUS "Cloning ${name}: ${repository}")
        execute_process(
                COMMAND "${GIT_EXECUTABLE}" clone --recurse-submodules ${repository} .
                WORKING_DIRECTORY "${source}"
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Cloning ${name}: ${repository} - FAIL")
        endif ()
        message(STATUS "Cloning ${name}: ${repository} - done")
    endif ()

    # check out commit
    message(STATUS "Checking out ${name}: ${version}")
    execute_process(
            COMMAND git checkout ${version}
            WORKING_DIRECTORY ${source}
            RESULT_VARIABLE rc)
    if (NOT "${rc}" STREQUAL "0")
        message(FATAL_ERROR "Checking out ${name}: ${version} - FAIL")
    endif ()
    message(STATUS "Checking out ${name}: ${version} - done")
endfunction(GitClone)

function(DoDownloadDep name destination version url)
    if (NOT EXISTS ${destination}/${name}-${version}.tar.gz)
        file(MAKE_DIRECTORY ${destination})
        set(_DEST_DOWNLOADING ${destination}/${name}-${version}.downloading)
        set(_DEST ${destination}/${name}-${version}.tar.gz)
        message(STATUS "Downloading ${name} with ${url}, DEST=${_DEST_DOWNLOADING}")
        execute_process(
                COMMAND wget -O ${_DEST_DOWNLOADING} ${url}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${name}: ${url} - FAIL")
        endif ()
        execute_process(
                COMMAND mv ${_DEST_DOWNLOADING} ${_DEST}
                RESULT_VARIABLE rc)
        message(STATUS "Download ${name}: ${url} - done")
    endif ()
endfunction(DoDownloadDep)

function(ExtractDep name source package version)
    DirSize(T_DIR ${source})
    if (T_DIR_SIZE EQUAL 0)
        file(MAKE_DIRECTORY ${source})
        message(STATUS "Extracting ${name}")
        execute_process(
                COMMAND tar -xf ${package}/${name}-${version}.tar.gz
                --strip-components 1 -C ${source}
                RESULT_VARIABLE rc)
        if (NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${name} - FAIL")
        endif ()
        message(STATUS "Extracting ${name} - done")
    endif ()
endfunction(ExtractDep)

macro(DoUnset)
    cmake_parse_arguments(ARG "" "" "TARGETS" ${ARGN})

    foreach (TGT IN LISTS ARG_TARGETS)
        unset(${TGT})
    endforeach ()

    unset(TGT)
    unset(ARG_TARGETS)
endmacro(DoUnset)