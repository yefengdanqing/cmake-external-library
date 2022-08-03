include(${CMAKE_CURRENT_LIST_DIR}/../check.cmake)
set(BOOST_VERSION 1.76.0)
# https://programming.vip/docs/boost-compiler-installation-under-linux.html
function(Process)
    PrepareDep(${BOOST_VERSION} MODULES boost_system)
    DownloadDep(DEP_URL https://boostorg.jfrog.io/artifactory/main/release/${_DEP_VER}/source/${_DEP_NAME}_${_DEP_VER_}.tar.gz
            SPEED_UP_FILE ${_DEP_NAME}_${_DEP_VER_}.tar.gz)
    set(B2DIR ${CMAKE_CURRENT_LIST_DIR}/src/tools/build)
    set(ARGS toolset=gcc variant=release debug-symbols=on link=static runtime-link=shared
            threadapi=pthread threading=multi --without-mpi --without-python)
    # build b2
    BOOTSTRAP(SRC ${B2DIR} ARGS --with-toolset=gcc ENV PATH=${B2DIR}:$ENV{PATH})
    B2Build(SRC ${B2DIR} ARGS --with-toolset=gcc ENV PATH=${B2DIR}:$ENV{PATH})
    B2Install(SRC ${B2DIR} ARGS --with-toolset=gcc ENV PATH=${B2DIR}:$ENV{PATH} DEST bin/b2)
    # build boost
    BOOTSTRAP(ENV PATH=${_DEP_PREFIX}/bin:$ENV{PATH} ARGS --with-toolset=gcc)
    B2Build(ENV PATH=${_DEP_PREFIX}/bin:$ENV{PATH} ARGS ${ARGS})
    B2Install(ENV PATH=${_DEP_PREFIX}/bin:$ENV{PATH} ARGS ${ARGS})

    set(BOOST_ROOT ${_DEP_PREFIX} PARENT_SCOPE)
    PostProcess()
endfunction(Process)
Process()
UnsetExternalVars()
set(Boost_NO_SYSTEM_PATHS ON)
find_package(Boost 1.76 COMPONENTS ALL)
