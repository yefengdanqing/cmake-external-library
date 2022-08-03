include(${CMAKE_CURRENT_LIST_DIR}/../check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../absl/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../c-ares/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../protobuf/check.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../re2/check.cmake)

function(Process)
    PrepareDep(1.47.0 MODULES gpr grpc grpc++)
    DownloadDep(TAG v${_DEP_VER} SPEED_UP_FILE ${_DEP_NAME}-${_DEP_VER}.tar.gz)
    Ninja(ARGS -DgRPC_INSTALL=ON
            -DgRPC_BUILD_TESTS=OFF
            -DgRPC_BUILD_GRPC_PHP_PLUGIN=OFF
            -DgRPC_ABSL_PROVIDER=package
            -DgRPC_CARES_PROVIDER=package
            -DgRPC_PROTOBUF_PROVIDER=package
            -DgRPC_RE2_PROVIDER=package
            -DgRPC_SSL_PROVIDER=package
            -DgRPC_ZLIB_PROVIDER=package)
    PostProcess()
endfunction(Process)
Process()
ProcessAddLibrary()