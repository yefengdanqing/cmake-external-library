get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)
execute_process(
    COMMAND python3 -c "import sysconfig; print(sysconfig.get_paths()['purelib'], end='');"
    RESULT_VARIABLE RES
    OUTPUT_VARIABLE PYTHON_LIBRARY
    ERROR_QUIET
)
execute_process(
    COMMAND python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc(), end='')"
    RESULT_VARIABLE RES
    OUTPUT_VARIABLE PYTHON_INCLUDE_DIR
    ERROR_QUIET
)
message("${PYTHON_LIBRARY} @@@@ ${PYTHON_INCLUDE_DIR}")
set(Torch_DIR ${PYTHON_LIBRARY}/torch/share/cmake/Torch)
find_package(Torch REQUIRED)
unset(_DEP_NAME)
unset(_DEP_UNAME)
