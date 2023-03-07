get_filename_component(_DEP_NAME ${CMAKE_CURRENT_LIST_DIR} NAME)
string(TOUPPER ${_DEP_NAME} _DEP_UNAME)

set(_DEP_VER 8.0.0)
set(_DEP_LLVM_URL              http://releases.llvm.org/${_DEP_VER}/llvm-${_DEP_VER}.src.tar.xz)
set(_DEP_CFE_URL               http://releases.llvm.org/${_DEP_VER}/cfe-${_DEP_VER}.src.tar.xz)
set(_DEP_COMPILER_RT_URL       http://releases.llvm.org/${_DEP_VER}/compiler-rt-${_DEP_VER}.src.tar.xz)
set(_DEP_LIBCXXABI_URL         http://releases.llvm.org/${_DEP_VER}/libcxxabi-${_DEP_VER}.src.tar.xz)
set(_DEP_LIBCXX_URL            http://releases.llvm.org/${_DEP_VER}/libcxx-${_DEP_VER}.src.tar.xz)
set(_DEP_LIBUNWIND_URL         http://releases.llvm.org/${_DEP_VER}/libunwind-${_DEP_VER}.src.tar.xz)
set(_DEP_LLD_URL               http://releases.llvm.org/${_DEP_VER}/lld-${_DEP_VER}.src.tar.xz)
set(_DEP_LLDB_URL              http://releases.llvm.org/${_DEP_VER}/lldb-${_DEP_VER}.src.tar.xz)
set(_DEP_OPENMP_URL            http://releases.llvm.org/${_DEP_VER}/openmp-${_DEP_VER}.src.tar.xz)
set(_DEP_POLLY_URL             http://releases.llvm.org/${_DEP_VER}/polly-${_DEP_VER}.src.tar.xz)
set(_DEP_CLANG_TOOLS_EXTRA_URL http://releases.llvm.org/${_DEP_VER}/clang-tools-extra-${_DEP_VER}.src.tar.xz)

set(_DEP_PREFIX ${${_DEP_UNAME}_PREFIX})
if("${_DEP_PREFIX}" STREQUAL "")
    if("${DEPS_DIR}" STREQUAL "")
        set(_DEP_PREFIX ${CMAKE_CURRENT_LIST_DIR})
    else()
        set(_DEP_PREFIX ${DEPS_DIR}/${_DEP_NAME})
    endif()
    set(${_DEP_UNAME}_PREFIX ${_DEP_PREFIX})
endif()
if("${DEPS_DIR}" STREQUAL "")
    get_filename_component(DEPS_DIR ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)
    message(STATUS "Dependencies directory has been set to: ${DEPS_DIR}")
endif()
message(STATUS "${_DEP_UNAME}_PREFIX: ${_DEP_PREFIX}")

CheckVersion()

find_program(PATCH_EXECUTABLE patch)
if(NOT PATCH_EXECUTABLE)
    message(FATAL_ERROR "command patch not found")
endif()

if(NOT EXISTS ${_DEP_PREFIX}/bin/clang)
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/packages/llvm.src.tar.xz)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/packages)
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_LLVM_URL}")
        execute_process(
            COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/llvm.src.tar.xz ${_DEP_LLVM_URL}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_LLVM_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_LLVM_URL} - done")
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_CFE_URL}")
        execute_process(
            COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/cfe.src.tar.xz ${_DEP_CFE_URL}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_CFE_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_CFE_URL} - done")
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_COMPILER_RT_URL}")
        execute_process(
            COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/compiler-rt.src.tar.xz ${_DEP_COMPILER_RT_URL}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_COMPILER_RT_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_COMPILER_RT_URL} - done")
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_LIBCXXABI_URL}")
        execute_process(
            COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/libcxxabi.src.tar.xz ${_DEP_LIBCXXABI_URL}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_LIBCXXABI_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_LIBCXXABI_URL} - done")
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_LIBCXX_URL}")
        execute_process(
            COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/libcxx.src.tar.xz ${_DEP_LIBCXX_URL}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_LIBCXX_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_LIBCXX_URL} - done")
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_LIBUNWIND_URL}")
        execute_process(
            COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/libunwind.src.tar.xz ${_DEP_LIBUNWIND_URL}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_LIBUNWIND_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_LIBUNWIND_URL} - done")
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_LLD_URL}")
        execute_process(
            COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/lld.src.tar.xz ${_DEP_LLD_URL}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_LLD_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_LLD_URL} - done")
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_LLDB_URL}")
        execute_process(
            COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/lldb.src.tar.xz ${_DEP_LLDB_URL}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_LLDB_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_LLDB_URL} - done")
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_OPENMP_URL}")
        execute_process(
            COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/openmp.src.tar.xz ${_DEP_OPENMP_URL}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_OPENMP_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_OPENMP_URL} - done")
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_POLLY_URL}")
        execute_process(
            COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/polly.src.tar.xz ${_DEP_POLLY_URL}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_POLLY_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_POLLY_URL} - done")
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_CLANG_TOOLS_EXTRA_URL}")
        execute_process(
            COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/clang-tools-extra.src.tar.xz ${_DEP_CLANG_TOOLS_EXTRA_URL}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Downloading ${_DEP_NAME}: ${_DEP_CLANG_TOOLS_EXTRA_URL} - FAIL")
        endif()
        message(STATUS "Downloading ${_DEP_NAME}: ${_DEP_CLANG_TOOLS_EXTRA_URL} - done")
    endif()
    if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/README.txt)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src)
        message(STATUS "Extracting ${_DEP_NAME}")
        execute_process(
            COMMAND tar -xf ${CMAKE_CURRENT_LIST_DIR}/packages/llvm.src.tar.xz
                        --strip-components 1 -C ${CMAKE_CURRENT_LIST_DIR}/src
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif()
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/tools/polly)
        execute_process(
            COMMAND tar -xf ${CMAKE_CURRENT_LIST_DIR}/packages/polly.src.tar.xz
                        --strip-components 1 -C ${CMAKE_CURRENT_LIST_DIR}/src/tools/polly
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif()
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/tools/clang)
        execute_process(
            COMMAND tar -xf ${CMAKE_CURRENT_LIST_DIR}/packages/cfe.src.tar.xz
                        --strip-components 1 -C ${CMAKE_CURRENT_LIST_DIR}/src/tools/clang
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif()
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/tools/clang/tools/extra)
        execute_process(
            COMMAND tar -xf ${CMAKE_CURRENT_LIST_DIR}/packages/clang-tools-extra.src.tar.xz
                        --strip-components 1 -C ${CMAKE_CURRENT_LIST_DIR}/src/tools/clang/tools/extra
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif()
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/tools/lld)
        execute_process(
            COMMAND tar -xf ${CMAKE_CURRENT_LIST_DIR}/packages/lld.src.tar.xz
                        --strip-components 1 -C ${CMAKE_CURRENT_LIST_DIR}/src/tools/lld
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif()
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/tools/lldb)
        execute_process(
            COMMAND tar -xf ${CMAKE_CURRENT_LIST_DIR}/packages/lldb.src.tar.xz
                        --strip-components 1 -C ${CMAKE_CURRENT_LIST_DIR}/src/tools/lldb
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif()
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/projects/libunwind)
        execute_process(
            COMMAND tar -xf ${CMAKE_CURRENT_LIST_DIR}/packages/libunwind.src.tar.xz
                        --strip-components 1 -C ${CMAKE_CURRENT_LIST_DIR}/src/projects/libunwind
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif()
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/projects/libcxxabi)
        execute_process(
            COMMAND tar -xf ${CMAKE_CURRENT_LIST_DIR}/packages/libcxxabi.src.tar.xz
                        --strip-components 1 -C ${CMAKE_CURRENT_LIST_DIR}/src/projects/libcxxabi
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif()
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/projects/libcxx)
        execute_process(
            COMMAND tar -xf ${CMAKE_CURRENT_LIST_DIR}/packages/libcxx.src.tar.xz
                        --strip-components 1 -C ${CMAKE_CURRENT_LIST_DIR}/src/projects/libcxx
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif()
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/projects/compiler-rt)
        execute_process(
            COMMAND tar -xf ${CMAKE_CURRENT_LIST_DIR}/packages/compiler-rt.src.tar.xz
                        --strip-components 1 -C ${CMAKE_CURRENT_LIST_DIR}/src/projects/compiler-rt
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif()
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src/projects/openmp)
        execute_process(
            COMMAND tar -xf ${CMAKE_CURRENT_LIST_DIR}/packages/openmp.src.tar.xz
                        --strip-components 1 -C ${CMAKE_CURRENT_LIST_DIR}/src/projects/openmp
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Extracting ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Extracting ${_DEP_NAME} - done")
        message(STATUS "Patching ${_DEP_NAME}")
        execute_process(
            COMMAND ${PATCH_EXECUTABLE}
                    ${CMAKE_CURRENT_LIST_DIR}/src/tools/polly/cmake/PollyConfig.cmake.in
                    ${CMAKE_CURRENT_LIST_DIR}/polly.patch
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Patching ${_DEP_NAME} - FAIL")
        endif()
        message(STATUS "Patching ${_DEP_NAME} - done")
    endif()
    if(NOT EXISTS ${_DEP_PREFIX}/bin/clang)
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build/build.stage1)
        message(STATUS "Configuring ${_DEP_NAME} stage1")
        execute_process(
            COMMAND ${CMAKE_COMMAND}
                    -G Ninja
                    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                    -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_LIST_DIR}/build/built.stage1
                    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                    ${CMAKE_CURRENT_LIST_DIR}/src
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build/build.stage1
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} stage1 - FAIL")
        endif()
        message(STATUS "Configuring ${_DEP_NAME} stage1 - done")
        message(STATUS "Building ${_DEP_NAME} stage1")
        execute_process(
            COMMAND ninja install
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build/build.stage1
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} stage1 - FAIL")
        endif()
        file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/build/build.stage1)
        message(STATUS "Building ${_DEP_NAME} stage1 - done")
        file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build/build.stage2)
        message(STATUS "Configuring ${_DEP_NAME} stage2")
        execute_process(
            COMMAND env LD_LIBRARY_PATH=${CMAKE_CURRENT_LIST_DIR}/build/built.stage1/lib
                    ${CMAKE_COMMAND}
                    -G Ninja
                    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                    -DCMAKE_INSTALL_PREFIX=${_DEP_PREFIX}
                    -DCMAKE_C_COMPILER=${CMAKE_CURRENT_LIST_DIR}/build/built.stage1/bin/clang
                    -DCMAKE_CXX_COMPILER=${CMAKE_CURRENT_LIST_DIR}/build/built.stage1/bin/clang++
                    -DCMAKE_CXX_FLAGS=-stdlib=libc++
                    -DCMAKE_EXE_LINKER_FLAGS=-fuse-ld=lld
                    -DCMAKE_MODULE_LINKER_FLAGS=-fuse-ld=lld
                    -DCMAKE_SHARED_LINKER_FLAGS=-fuse-ld=lld
                    -DSANITIZER_CXX_ABI=libc++abi
                    -DSANITIZER_CXX_ABI_LIBRARY=c++abi
                    -DLLVM_BUILD_LLVM_DYLIB=ON
                    ${CMAKE_CURRENT_LIST_DIR}/src
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build/build.stage2
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Configuring ${_DEP_NAME} stage2 - FAIL")
        endif()
        message(STATUS "Configuring ${_DEP_NAME} stage2 - done")
        message(STATUS "Building ${_DEP_NAME} stage2")
        execute_process(
            COMMAND env LD_LIBRARY_PATH=${CMAKE_CURRENT_LIST_DIR}/build/built.stage1/lib
                    ninja install
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build/build.stage2
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Building ${_DEP_NAME} stage2 - FAIL")
        endif()
        file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/build/build.stage2)
        message(STATUS "Building ${_DEP_NAME} stage2 - done")
    endif()
    file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/src)
    file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/build)
    file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/packages)
endif()

if(EXISTS ${_DEP_PREFIX}/bin)
    set(_DEP_BIN_DIR ${_DEP_PREFIX}/bin)
    set(${_DEP_UNAME}_BIN_DIR ${_DEP_BIN_DIR})
endif()
if(EXISTS ${_DEP_PREFIX}/lib)
    set(_DEP_LIB_DIR ${_DEP_PREFIX}/lib)
    set(${_DEP_UNAME}_LIB_DIR ${_DEP_LIB_DIR})
endif()
if(EXISTS ${_DEP_PREFIX}/lib64)
    set(_DEP_LIB_DIR ${_DEP_PREFIX}/lib64)
    set(${_DEP_UNAME}_LIB_DIR ${_DEP_LIB_DIR})
endif()
if(EXISTS ${_DEP_PREFIX}/include)
    set(_DEP_INCLUDE_DIR ${_DEP_PREFIX}/include)
    set(${_DEP_UNAME}_INCLUDE_DIR ${_DEP_INCLUDE_DIR})
endif()

list(FIND CMAKE_PREFIX_PATH ${_DEP_PREFIX} _DEP_INDEX)
if(_DEP_INDEX EQUAL -1)
    list(APPEND CMAKE_PREFIX_PATH ${_DEP_PREFIX})
endif()
find_package(LLVM REQUIRED CONFIG)
find_package(Clang REQUIRED CONFIG)
find_package(Polly REQUIRED CONFIG)

unset(_DEP_NAME)
unset(_DEP_UNAME)
unset(_DEP_VER)
unset(_DEP_LLVM_URL)
unset(_DEP_CFE_URL)
unset(_DEP_COMPILER_RT_URL)
unset(_DEP_LIBCXXABI_URL)
unset(_DEP_LIBCXX_URL)
unset(_DEP_LIBUNWIND_URL)
unset(_DEP_LLD_URL)
unset(_DEP_LLDB_URL)
unset(_DEP_OPENMP_URL)
unset(_DEP_POLLY_URL)
unset(_DEP_CLANG_TOOLS_EXTRA_URL)
unset(_DEP_PREFIX)
unset(_DEP_BIN_DIR)
unset(_DEP_LIB_DIR)
unset(_DEP_INCLUDE_DIR)
