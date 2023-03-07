include(${CMAKE_CURRENT_LIST_DIR}/../curl/check.cmake REQUIRED)

function(Process)
    PrepareDeps(v0.2.3 MODULES ppconsul)
    AddProject(
            DEP_AUTHOR oliora
            DEP_PROJECT ${_DEP_NAME}
            DEP_TAG ${_DEP_VER}
            NINJA_EXTRA_DEFINE -DBUILD_STATIC_LIB=ON -DBUILD_TESTS=OFF
            NINJA)
endfunction(Process)
Process()
ProcessAddLibrary()
