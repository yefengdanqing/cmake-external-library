include(${CMAKE_CURRENT_LIST_DIR}/../check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../boost/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../openssl/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../libevent/check.cmake)

function(Process)
    # 0.9.3.1 0.11.0 0.14.2 0.15.0
    PrepareDep(0.11.0 MODULES thrift thriftz thriftnb)
    DownloadDep(AUTHOR apache SPEED_UP_FILE ${_DEP_NAME}-${_DEP_VER}.tar.gz)
    Ninja()
    PostProcess()
endfunction(Process)
Process()
ProcessAddLibrary()