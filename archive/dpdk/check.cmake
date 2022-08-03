get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

set(_DEP_VER 19.05)
if (DEFINED ENV{SPEED_UP_URL})
    set(_DEP_URL $ENV{SPEED_UP_URL}/${_DEP_NAME}-${_DEP_VER}.tar.gz)
else ()
    set(_DEP_URL https://codeload.github.com/sunzhenkai/dpdk/tar.gz/refs/tags/${_DEP_VER})
endif ()

# template variables
set(_DEP_CUR_DIR ${CMAKE_CURRENT_LIST_DIR})
set(_NEED_REBUILD TRUE)
set(_DEP_PREFIX ${CMAKE_CURRENT_LIST_DIR})

SetDepPrefix()
CheckVersion()
message(STATUS "${_DEP_UNAME}: _NEED_REBUILD=${_NEED_REBUILD}, _DEP_PREFIX=${_DEP_PREFIX}")

if ((${_NEED_REBUILD}) OR (NOT EXISTS ${_DEP_PREFIX}/lib/lib${_DEP_NAME}.a))
    set(_DEP_NAME_BUILD_CHECK "librte_acl.a")
    set(_DEP_NAME_INSTALL_CHECK "x86_64-linux-gnu/librte_acl.a")
    set(_PERMISSION TRUE)

    DownloadDep()
    ExtractDep()
    MesonNinja()
    NinjaBuild()
    NinjaInstall()
endif ()

AppendCMakePrefix()

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_VER)
unset(_DEP_PREFIX)
unset(_NEED_REBUILD)
unset(_DEP_CUR_DIR)
unset(_DEP_BIN_DIR)
unset(_DEP_LIB_DIR)
unset(_DEP_INCLUDE_DIR)