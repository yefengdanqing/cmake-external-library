# TODO to be done

get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

set(_DEP_VER 2.6.4)
if (DEFINED ENV{SPEED_UP_URLA})
    set(_DEP_URL $ENV{SPEED_UP_URL}/${_DEP_NAME}-${_DEP_VER}.tar.gz)
else ()
    set(_DEP_URL https://codeload.github.com/westes/${_DEP_NAME}/tar.gz/refs/tags/v${_DEP_VER})
endif ()

# template variables
set(_DEP_CUR_DIR ${CMAKE_CURRENT_LIST_DIR})
set(_NEED_REBUILD TRUE)
set(_DEP_PREFIX ${CMAKE_CURRENT_LIST_DIR})

SetDepPrefix()
CheckVersion()
message(STATUS "${_DEP_UNAME}: _NEED_REBUILD=${_NEED_REBUILD}, _DEP_PREFIX=${_DEP_PREFIX}")

if ((${_NEED_REBUILD}) OR (NOT EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}.a))
    DownloadDep()
    ExtractDep()
    Autogen()
#    CMakeNinja()
#    NinjaBuild()
#    NinjaInstall()
endif ()

#SetDepPath()
#AppendCMakePrefix()
#message(STATUS "${_DEP_NAME}: ${_DEP_UNAME}_LIB_DIR=${${_DEP_UNAME}_LIB_DIR}, "
#        "${_DEP_UNAME}_INCLUDE_DIR=${${_DEP_UNAME}_INCLUDE_DIR}, CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}")
#
#find_package(fmt REQUIRED CONFIG)

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