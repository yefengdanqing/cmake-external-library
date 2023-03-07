function(CheckVersion)
    if(DEFINED _DEP_VER)
        set(NEW_VERSION ${_DEP_VER})
    elseif (DEFINED _DEP_TAG)
        set(NEW_VERSION ${_DEP_TAG})
    else()
        message(FATAL_ERROR "No _DEP_TAG or _DEP_VER var found in ${_DEP_NAME}")
    endif()
    if(NOT EXISTS ${_DEP_PREFIX}/VERSION.txt)
        message(STATUS "version not found from dir ${_DEP_PREFIX}/VERSION.txt, rebuilding ${_DEP_NAME}")
        set(NEED_REBUILD TRUE)
    else()
        file (STRINGS ${_DEP_PREFIX}/VERSION.txt BUILD_VERSION)
        if ("${BUILD_VERSION}" STREQUAL "${NEW_VERSION}")
            set(NEED_REBUILD FALSE)
        else()
            message(STATUS "Found new version ${NEW_VERSION} against old version ${BUILD_VERSION} from dir ${_DEP_PREFIX}, rebuilding ${_DEP_NAME}")
            set(NEED_REBUILD TRUE)
        endif()
    endif()
    if (${NEED_REBUILD})
        message(STATUS "${_DEP_NAME} need rebuild: ${NEED_REBUILD}")
        execute_process(
            COMMAND rm -rf ${_DEP_PREFIX}
            WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
            RESULT_VARIABLE rc)
        if(NOT "${rc}" STREQUAL "0")
            message(FATAL_ERROR "Removing target directory ${_DEP_PREFIX} - FAIL")
        endif()

        file(WRITE ${_DEP_PREFIX}/VERSION.txt ${NEW_VERSION})
    endif()

endfunction(CheckVersion)
include (CMakeParseArguments)
function(MakeUnitTest)
    CMAKE_PARSE_ARGUMENTS(TARGET "None"
      "NAME"
      "SRCS;INCS;LINK_LIBS"
      ${ARGN})
    set(target ${TARGET_NAME})
    add_executable("${target}" ${TARGET_SRCS})
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 7.0)
        target_compile_options(${target} PRIVATE -std=c++11)
    else()
        target_compile_options(${target} PRIVATE -std=c++17)
    endif()
    target_include_directories(${target} PRIVATE
        ${TARGET_INCS}
    )
    target_link_libraries("${target}" pthread dl
        ${TARGET_LINK_LIBS}
    )
endfunction()


function(MakeProjectStaticLibCommon)
    CMAKE_PARSE_ARGUMENTS(STATIC_LIB "None"
      "NAME;ALIAS_NAME;EXPORT"
      "SRCS;INCS;LINK_LIBS"
      ${ARGN})
    # TODO get alias name and export name from target-name
    add_library(${STATIC_LIB_NAME} STATIC
        ${SRCS}
        )
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS 7.0)
        target_compile_options(${STATIC_LIB_NAME} PRIVATE -std=c++11)
    else()
        target_compile_options(${STATIC_LIB_NAME} PRIVATE -std=c++17)
    endif()
	target_link_libraries(${STATIC_LIB_NAME} PUBLIC
		${STATIC_LIB_LINK_LIBS}
    )
	target_include_directories(${STATIC_LIB_NAME} PRIVATE
		${STATIC_LIB_INCS}
        )
	target_include_directories(${STATIC_LIB_NAME} PRIVATE ${UNITY_TOP_DIR}/src)
	target_include_directories(${STATIC_LIB_NAME} INTERFACE $<BUILD_INTERFACE:${UNITY_TOP_DIR}/include>)
	target_include_directories(${STATIC_LIB_NAME} INTERFACE $<INSTALL_INTERFACE:$<INSTALL_PREFIX>/include>)

	target_compile_definitions(${STATIC_LIB_NAME} PRIVATE FORCE_BOOST_SMART_PTR)
	add_library(${STATIC_LIB_ALIAS_NAME} ALIAS ${STATIC_LIB_NAME})
    set_target_properties(${STATIC_LIB_NAME} PROPERTIES EXPORT_NAME ${STATIC_LIB_EXPORT})
	install(TARGETS ${STATIC_LIB_NAME}
        EXPORT ${STATIC_LIB_NAME}_targets
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)
endfunction()
function(ExportProjectStaticLibCommon)
    message("how to export lib")
endfunction()

function(CheckCUDA)
    find_program(NVCC_EXECUTABLE nvcc)
    if(NVCC_EXECUTABLE)
        message(STATUS "command NVCC found")
    endif()
endfunction(CheckCUDA)

function(SetDependPrefix)
    set(_DEP_PREFIX ${${_DEP_UNAME}_PREFIX})
    if("${_DEP_PREFIX}" STREQUAL "")
        if("${DEPS_DIR}" STREQUAL "")
            set(_DEP_PREFIX ${CMAKE_CURRENT_LIST_DIR} PARENT_SCOPE)
        else()
            set(_DEP_PREFIX ${DEPS_DIR}/${_DEP_NAME} PARENT_SCOPE)
        endif()
        set(${_DEP_UNAME}_PREFIX ${_DEP_PREFIX} PARENT_SCOPE)
    endif()
    if("${DEPS_DIR}" STREQUAL "")
        get_filename_component(DEPS_DIR ${CMAKE_CURRENT_LIST_DIR} DIRECTORY)
        message(STATUS "Dependencies directory has been set to: ${DEPS_DIR}")
    endif()
    message(STATUS "${_DEP_UNAME}_PREFIX: ${_DEP_PREFIX}")
endfunction(SetDependPrefix)
function(UnsetDependEnv)
    unset(_DEP_NAME)
    unset(_DEP_UNAME)
    unset(_DEP_VER)
    unset(_DEP_URL)
    unset(_DEP_PREFIX)
    unset(_DEP_BIN_DIR)
    unset(_DEP_LIB_DIR)
    unset(_DEP_INCLUDE_DIR)
endfunction(UnsetDependEnv)

function(FetchAndInstall)
    cmake_parse_arguments(LIB_PKG "None"
        "NAME;UNAME;URL;PREFIX;BUILD_GUARD"
        "COMMAND"
        ${ARGN})
    set(LIB_PKG_TAR ${CMAKE_CURRENT_LIST_DIR}/packages/${LIB_PKG_NAME}.tar.gz)
    message(STATUS "${LIB_PKG_NAME}\tGuard:${LIB_PKG_BUILD_GUARD}\t Tar ${LIB_PKG_TAR}")
    message(STATUS "COMMAND:${LIB_PKG_COMMAND}")
    if(NOT EXISTS ${LIB_PKG_BUILD_GUARD})
		if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/packages/${LIB_PKG_NAME}.tar.gz)
			file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/packages)
			message(STATUS "Downloading ${LIB_PKG_NAME}: ${LIB_PKG_URL}")
			execute_process(
				COMMAND wget -O ${CMAKE_CURRENT_LIST_DIR}/packages/${LIB_PKG_NAME}.tar.gz ${LIB_PKG_URL}
				RESULT_VARIABLE rc)
			if(NOT "${rc}" STREQUAL "0")
				message(FATAL_ERROR "Downloading ${LIB_PKG_NAME}: ${LIB_PKG_URL} - FAIL")
			endif()
			message(STATUS "Downloading ${LIB_PKG_NAME}: ${LIB_PKG_URL} - done")
		endif()
		if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/src/README.md)
			file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/src)
			message(STATUS "Extracting ${LIB_PKG_NAME}")
			execute_process(
				COMMAND tar -xf ${CMAKE_CURRENT_LIST_DIR}/packages/${LIB_PKG_NAME}.tar.gz
							--strip-components 1 -C ${CMAKE_CURRENT_LIST_DIR}/src
				RESULT_VARIABLE rc)
			if(NOT "${rc}" STREQUAL "0")
				message(FATAL_ERROR "Extracting ${LIB_PKG_NAME} - FAIL")
			endif()
			message(STATUS "Extracting ${LIB_PKG_NAME} - done")
		endif()
		if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/build/CMakeCache.txt)
			file(MAKE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build)
			message(STATUS "Configuring ${LIB_PKG_NAME}")
			execute_process(
				COMMAND ${CMAKE_COMMAND}
					-G Ninja
					-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
					-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
					-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
					-DCMAKE_INSTALL_PREFIX=${LIB_PKG_PREFIX}
					-DCMAKE_INSTALL_PREFIX=${LIB_PKG_PREFIX}
					${LIB_PKG_COMMAND}
					${CMAKE_CURRENT_LIST_DIR}/src
				WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build
				RESULT_VARIABLE rc)
			if(NOT "${rc}" STREQUAL "0")
				message(FATAL_ERROR "Configuring ${LIB_PKG_NAME} - FAIL")
			endif()
			message(STATUS "Configuring ${LIB_PKG_NAME} - done")
		endif()
		if(NOT EXISTS ${CMAKE_CURRENT_LIST_DIR}/build/lib${LIB_PKG_NAME}.a)
			message(STATUS "Building ${LIB_PKG_NAME}")
			execute_process(
				COMMAND ninja
				WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build
				RESULT_VARIABLE rc)
			if(NOT "${rc}" STREQUAL "0")
				message(FATAL_ERROR "Building ${LIB_PKG_NAME} - FAIL")
			endif()
			message(STATUS "Building ${LIB_PKG_NAME} - done")
		endif()
        if(NOT EXISTS ${LIB_PKG_BUILD_GUARD})
			message(STATUS "Installing ${LIB_PKG_NAME}")
			execute_process(
				COMMAND ninja install
				WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/build
				RESULT_VARIABLE rc)
			if(NOT "${rc}" STREQUAL "0")
				message(FATAL_ERROR "Installing ${LIB_PKG_NAME} - FAIL")
			endif()
			message(STATUS "Installing ${LIB_PKG_NAME} - done")
		endif()
		file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/src)
		file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/build)
		file(REMOVE_RECURSE ${CMAKE_CURRENT_LIST_DIR}/packages)
	endif()

	if(EXISTS ${LIB_PKG_PREFIX}/bin)
		set(LIB_PKG_BIN_DIR ${LIB_PKG_PREFIX}/bin)
		set(${LIB_PKG_UNAME}_BIN_DIR ${LIB_PKG_BIN_DIR})
	endif()
	if(EXISTS ${LIB_PKG_PREFIX}/lib)
		set(LIB_PKG_LIB_DIR ${LIB_PKG_PREFIX}/lib)
		set(${LIB_PKG_UNAME}_LIB_DIR ${LIB_PKG_LIB_DIR})
	endif()
	if(EXISTS ${LIB_PKG_PREFIX}/lib64)
		set(LIB_PKG_LIB_DIR ${LIB_PKG_PREFIX}/lib64)
		set(${LIB_PKG_UNAME}_LIB_DIR ${LIB_PKG_LIB_DIR})
	endif()
	if(EXISTS ${LIB_PKG_PREFIX}/include)
		set(LIB_PKG_INCLUDE_DIR ${LIB_PKG_PREFIX}/include)
		set(${LIB_PKG_UNAME}_INCLUDE_DIR ${LIB_PKG_INCLUDE_DIR})
	endif()

    set(${LIB_PKG_NAME}_LIBRARY ${LIB_PKG_LIB_DIR}/lib${LIB_PKG_NAME}.a CACHE FILEPATH "" FORCE)
    set(${LIB_PKG_NAME}_INCLUDE_DIR ${LIB_PKG_INCLUDE_DIR} CACHE PATH "" FORCE)
    list(FIND CMAKE_PREFIX_PATH ${LIB_PKG_PREFIX} _DEP_INDEX)
    if(_DEP_INDEX EQUAL -1)
        list(APPEND CMAKE_PREFIX_PATH ${LIB_NAME_PREFIX})
    endif()
    find_package(${LIB_NAME} REQUIRED CONFIG)
endfunction(FetchAndInstall)
