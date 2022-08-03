include(${CMAKE_CURRENT_LIST_DIR}/../check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../gflags/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../leveldb/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../thrift/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../protobuf/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../boost/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../snappy/check.cmake)

function(Process)
    PrepareDep(1.1.0 MODULES brpc)
    DownloadDep(AUTHOR apache
            GIT_REPOSITORY https://github.com/apache/incubator-brpc.git
            TAG ${_DEP_VER} SPEED_UP_FILE ${_DEP_NAME}-${_DEP_VER}.tar.gz)
    Ninja(ARGS -DWITH_THRIFT=ON)
    PostProcess()
endfunction(Process)
Process()
ProcessAddLibrary()