include(${CMAKE_CURRENT_LIST_DIR}/../check.cmake)

function(Process)
    if (NOT CMAKE_CXX_STANDARD)
        set(CMAKE_CXX_STANDARD 14)
    endif ()

    PrepareDep(2022-06-01)
    DownloadDep(AUTHOR google SPEED_UP_FILE ${_DEP_NAME}-${_DEP_VER}.tar.gz)
    Ninja()
    PostProcess()
endfunction(Process)
Process()
ProcessAddLibrary()