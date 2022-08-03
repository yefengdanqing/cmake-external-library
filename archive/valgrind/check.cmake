get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

# template variables
set(_DEP_CUR_DIR ${CMAKE_CURRENT_LIST_DIR})
set(_NEED_REBUILD TRUE)
set(_DEP_PREFIX ${CMAKE_CURRENT_LIST_DIR})

set(_DEP_VER 3.18.1)
if (DEFINED ENV{SPEED_UP_URL})
    set(_DEP_URL $ENV{SPEED_UP_URL}/${_DEP_NAME}-${_DEP_VER}.tar.bz2)
else ()
    set(_DEP_URL https://sourceware.org/pub/${_DEP_NAME}/${_DEP_NAME}-${_DEP_VER}.tar.bz2)
endif ()

SetDepPrefix()
CheckVersion()
message(STATUS "${_DEP_UNAME}: _NEED_REBUILD=${_NEED_REBUILD}, _DEP_PREFIX=${_DEP_PREFIX}, "
        "CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}")

set(_DEP_NAME_INSTALL_CHECK "valgrind/libcoregrind-amd64-linux.a")
if ((${_NEED_REBUILD}) OR (NOT EXISTS ${_DEP_PREFIX}/lib/${_DEP_NAME_INSTALL_CHECK}))
    DownloadDep()
    ExtractDep()
    Configure()
    MakeBuild()
    MakeInstall()
endif ()

SetDepPath()
message(STATUS "${_DEP_NAME}: ${_DEP_UNAME}_LIB_DIR=${${_DEP_UNAME}_LIB_DIR}, "
        "${_DEP_UNAME}_INCLUDE_DIR=${${_DEP_UNAME}_INCLUDE_DIR}")
AppendCMakePrefix()

find_path(VALGRIND_INCLUDE_DIR valgrind.h)
find_library(VALGRIND_LIBRARIES valgrind)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Valgrind
        DEFAULT_MSG
        VALGRIND_LIBRARIES
        VALGRIND_INCLUDE_DIR)

mark_as_advanced(VALGRIND_INCLUDE_DIR
        VALGRIND_LIBRARIES)

message(STATUS "VALGRIND_INCLUDE_DIR=${VALGRIND_INCLUDE_DIR} VALGRIND_LIBRARIES=${VALGRIND_LIBRARIES}")
if (VALGRIND_FOUND)
    message(STATUS "found valgrind. VALGRIND_FOUND=${VALGRIND_FOUND}")
else ()
    message(FATAL_ERROR "valgrind not found")
endif ()

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_VER)
unset(_DEP_PREFIX)
unset(_NEED_REBUILD)
unset(_DEP_CUR_DIR)
unset(_DEP_BIN_DIR)
unset(_DEP_LIB_DIR)
unset(_DEP_INCLUDE_DIR)
unset(_DEP_NAME_SPACE)
unset(_DEP_NAME_INSTALL_CHECK)
unset(_EXTRA_DEFINE)