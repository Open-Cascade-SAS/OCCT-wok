cmake_minimum_required ( VERSION 2.6)

if (NOT BUILD_TYPE)
  set(BUILD_TYPE "Release" CACHE STRING "Build type of the __PROJECT_NAME__" FORCE)
  SET_PROPERTY(CACHE BUILD_TYPE PROPERTY STRINGS Release Debug)
endif()

set(CMAKE_CONFIGURATION_TYPES ${BUILD_TYPE} CACHE INTERNAL "" FORCE)

project(__PROJECT_NAME__)

set_property(GLOBAL PROPERTY 3RDPARTY_USE_FOLDERS ON)

set(BUILD_SHARED_LIBS ON)

IF("${BUILD_TYPE}" STREQUAL "${CMAKE_BUILD_TYPE}" AND "${BUILD_BITNESS}" STREQUAL "${BUILD_BITNESS1}")
  SET(CHANGES_ARE_NEEDED OFF)
ELSE()
  SET(CHANGES_ARE_NEEDED ON)
ENDIF()

set(BUILD_BITNESS __BITNESS__ CACHE STRING "Bitness of the __PROJECT_NAME__ project")
SET_PROPERTY(CACHE BUILD_BITNESS PROPERTY STRINGS 32 64)

SET(BUILD_BITNESS1 ${BUILD_BITNESS} CACHE INTERNAL "Temporary bitness is created to check whether change 3rdparty paths or not" FORCE)

SET( CMAKE_BUILD_TYPE ${BUILD_TYPE} CACHE INTERNAL "Build type of the __PROJECT_NAME__" FORCE )

SET( INSTALL_DIR "" CACHE PATH "Directory contains install files of the __PROJECT_NAME__" )
SET( CMAKE_INSTALL_PREFIX "${INSTALL_DIR}" CACHE INTERNAL "" FORCE )

set (BUILD_TOOLKITS "" CACHE STRING "Toolkits are included in __PROJECT_NAME__")
separate_arguments(BUILD_TOOLKITS)

__MODULE_LIST__

if (WIN32)
  set(SCRIPT_EXT bat)
else()
  set(SCRIPT_EXT sh)
endif()

if (DEFINED MSVC70)
  SET(COMPILER vc7)
elseif (DEFINED MSVC80)
  SET(COMPILER vc8)
elseif (DEFINED MSVC90)
  SET(COMPILER vc9)
elseif (DEFINED MSVC10)
  SET(COMPILER vc10)
elseif (DEFINED MSVC11)
  SET(COMPILER vc11)
else()
  SET(COMPILER ${CMAKE_GENERATOR})
endif()

if (${BUILD_BITNESS} STREQUAL 64)
  add_definitions(-D_OCC64)
endif()

add_definitions(-DCSFDB)
if(WIN32)
  add_definitions(/DWNT -wd4996)
elseif(APPLE)
  option(3RDPARTY_USE_GLX "Use X11 OpenGL on OSX?" OFF)
  add_definitions(-fexceptions -fPIC -DOCC_CONVERT_SIGNALS -DHAVE_WOK_CONFIG_H -DHAVE_CONFIG_H)
  if(3RDPARTY_USE_GLX)
    add_definitions(-DMACOSX_USE_GLX)
  endif()
else()
  add_definitions(-fexceptions -fPIC -DOCC_CONVERT_SIGNALS -DHAVE_WOK_CONFIG_H -DHAVE_CONFIG_H -DLIN)
endif()

string(REGEX MATCH "EHsc" ISFLAG "${CMAKE_CXX_FLAGS}")
IF(ISFLAG)
  STRING(REGEX REPLACE "EHsc" "EHa" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
ELSEIF(WIN32)
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -EHa")
ENDIF()

IF(WIN32)
  IF(NOT DEFINED MSVC70 AND NOT DEFINED MSVC80)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -MP")
  ENDIF()
ENDIF()

SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DNo_Exception")
SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -DNo_Exception")

SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEB")
SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DDEB")

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/out/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/out/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/out/bin)

# RESOURCES
install(DIRECTORY "__CASROOT_DIR__/src/DrawResources" DESTINATION  "${INSTALL_DIR}/res" )
install(DIRECTORY "__CASROOT_DIR__/src/StdResource" DESTINATION  "${INSTALL_DIR}/res" )
install(DIRECTORY "__CASROOT_DIR__/src/SHMessage" DESTINATION  "${INSTALL_DIR}/res" )
install(DIRECTORY "__CASROOT_DIR__/src/Textures" DESTINATION  "${INSTALL_DIR}/res" )
install(DIRECTORY "__CASROOT_DIR__/src/XSMessage" DESTINATION  "${INSTALL_DIR}/res" )
install(DIRECTORY "__CASROOT_DIR__/src/TObj" DESTINATION  "${INSTALL_DIR}/res" )
install(DIRECTORY "__CASROOT_DIR__/src/XSTEPResource" DESTINATION  "${INSTALL_DIR}/res" )
install(DIRECTORY "__CASROOT_DIR__/src/XmlOcafResource" DESTINATION  "${INSTALL_DIR}/res" )

install(FILES "__CASROOT_DIR__/src/UnitsAPI/Lexi_Expr.dat" DESTINATION  "${INSTALL_DIR}/res/UnitsAPI" )
install(FILES "__CASROOT_DIR__/src/UnitsAPI/Units.dat"     DESTINATION  "${INSTALL_DIR}/res/UnitsAPI" )

IF("${BUILD_TYPE}" STREQUAL "Release") 
  SET(BUILD_SUFFIX "")
ELSE()
  SET(BUILD_SUFFIX "d")
ENDIF()

FUNCTION(SUBDIRECTORY_NAMES MAIN_DIRECTORY RESULT)
  file(GLOB SUB_ITEMS "${MAIN_DIRECTORY}/*")
  
  foreach(ITEM ${SUB_ITEMS})
    if(IS_DIRECTORY "${ITEM}")
      GET_FILENAME_COMPONENT(ITEM_NAME "${ITEM}" NAME)
      LIST(APPEND LOCAL_RESULT "${ITEM_NAME}")
    endif()
  endforeach()
  set (${RESULT} ${LOCAL_RESULT} PARENT_SCOPE)
ENDFUNCTION()

FUNCTION(FIND_PRODUCT_DIR ROOT_DIR PRODUCT_NAME RESULT)
  string( TOLOWER "${PRODUCT_NAME}" lower_PRODUCT_NAME )
  
  LIST(APPEND SEARCH_TEMPLATES "${lower_PRODUCT_NAME}.*${COMPILER}.*${BUILD_BITNESS}")
  LIST(APPEND SEARCH_TEMPLATES "${lower_PRODUCT_NAME}.*[0-9.]+.*${COMPILER}.*${BUILD_BITNESS}")
  LIST(APPEND SEARCH_TEMPLATES "${lower_PRODUCT_NAME}.*[0-9.]+.*${BUILD_BITNESS}")
  LIST(APPEND SEARCH_TEMPLATES "${lower_PRODUCT_NAME}.*[0-9.]+")
  LIST(APPEND SEARCH_TEMPLATES "${lower_PRODUCT_NAME}")
  
  SUBDIRECTORY_NAMES( "${ROOT_DIR}" SUBDIR_NAME_LIST)
  
  FOREACH( SEARCH_TEMPLATE ${SEARCH_TEMPLATES})
    IF(LOCAL_RESULT)
      BREAK()
    ENDIF()
    
    FOREACH(SUBDIR_NAME ${SUBDIR_NAME_LIST})
      string( TOLOWER "${SUBDIR_NAME}" lower_SUBDIR_NAME )
      
      STRING(REGEX MATCH "${SEARCH_TEMPLATE}" DUMMY_VAR "${lower_SUBDIR_NAME}")
      IF(DUMMY_VAR)
        LIST(APPEND LOCAL_RESULT ${SUBDIR_NAME})
      ENDIF()
    ENDFOREACH()
  ENDFOREACH()
  
  IF(LOCAL_RESULT)
    LIST(LENGTH "${LOCAL_RESULT}" LOC_LEN)
    MATH(EXPR LAST_ELEMENT_INDEX "${LOC_LEN}-1")
    LIST(GET LOCAL_RESULT ${LAST_ELEMENT_INDEX} DUMMY)
    SET(${RESULT} ${DUMMY} PARENT_SCOPE)
  ENDIF()  
ENDFUNCTION()

IF(WIN32)
  SET(DLL_SO "dll")
  SET(DLL_SO_FOLDER "bin")
  SET(DLL_SO_PREFIX "")
ELSEIF(APPLE)
  SET(DLL_SO "dylib")
  SET(DLL_SO_FOLDER "lib")
  SET(DLL_SO_PREFIX "lib")
ELSE()
  SET(DLL_SO "so")
  SET(DLL_SO_FOLDER "lib")
  SET(DLL_SO_PREFIX "lib")
ENDIF()

SET(3RDPARTY_DIR "" CACHE PATH "Directory contains required 3rdparty products")
SET(3RDPARTY_INCLUDE_DIRS "")
SET(3RDPARTY_NOT_INCLUDED)

SET(3RDPARTY_USE_GL2PS OFF CACHE BOOL "whether use or not gl2ps product")
SET(3RDPARTY_USE_FREEIMAGE OFF CACHE BOOL "whether use or not freeimage product")
SET(3RDPARTY_USE_TBB OFF CACHE BOOL "whether use or not tbb product")

MACRO(THIRDPARTY_PRODUCT PRODUCT_NAME HEADER_NAME LIBRARY_NAME)
  IF(NOT DEFINED 3RDPARTY_${PRODUCT_NAME}_DIR)
    SET(3RDPARTY_${PRODUCT_NAME}_DIR "" CACHE PATH "Directory contains ${PRODUCT_NAME} product")
  ENDIF()
  
  IF(3RDPARTY_DIR AND ("${3RDPARTY_${PRODUCT_NAME}_DIR}" STREQUAL "" OR CHANGES_ARE_NEEDED))
    FIND_PRODUCT_DIR("${3RDPARTY_DIR}" ${PRODUCT_NAME} ${PRODUCT_NAME}_DIR_NAME)
    IF("${${PRODUCT_NAME}_DIR_NAME}" STREQUAL "")
      MESSAGE(STATUS "${PRODUCT_NAME} DON'T FIND")
    ELSE()
      SET(3RDPARTY_${PRODUCT_NAME}_DIR "${3RDPARTY_DIR}/${${PRODUCT_NAME}_DIR_NAME}" CACHE PATH "Directory contains ${PRODUCT_NAME} product" FORCE)
    ENDIF()
  ENDIF()
  
  SET(INSTALL_${PRODUCT_NAME} OFF CACHE BOOL "Is ${PRODUCT_NAME} lib copy to install directory")

  IF(3RDPARTY_${PRODUCT_NAME}_DIR)    
    IF("${3RDPARTY_${PRODUCT_NAME}_INCLUDE_DIR}" STREQUAL "" OR CHANGES_ARE_NEEDED)
      SET(3RDPARTY_${PRODUCT_NAME}_INCLUDE_DIR "3RDPARTY_${PRODUCT_NAME}_INCLUDE_DIR-NOTFOUND" CACHE FILEPATH "Directory contains headers of the ${PRODUCT_NAME} product" FORCE)
      FIND_PATH(3RDPARTY_${PRODUCT_NAME}_INCLUDE_DIR ${HEADER_NAME} PATHS "${3RDPARTY_${PRODUCT_NAME}_DIR}/include")    
    ENDIF()
    
    IF("${3RDPARTY_${PRODUCT_NAME}_LIBRARY}" STREQUAL "" OR CHANGES_ARE_NEEDED OR "${3RDPARTY_${PRODUCT_NAME}_LIBRARY}" STREQUAL "3RDPARTY_${PRODUCT_NAME}_LIBRARY-NOTFOUND")
      SET(3RDPARTY_${PRODUCT_NAME}_LIBRARY "3RDPARTY_${PRODUCT_NAME}_LIBRARY-NOTFOUND" CACHE FILEPATH "Directory contains library of the ${PRODUCT_NAME} product" FORCE)
      FIND_LIBRARY(3RDPARTY_${PRODUCT_NAME}_LIBRARY ${LIBRARY_NAME}  PATHS "${3RDPARTY_${PRODUCT_NAME}_DIR}/lib" NO_DEFAULT_PATH)
    ENDIF()
    
    IF("${3RDPARTY_${PRODUCT_NAME}_DLL}" STREQUAL "" OR CHANGES_ARE_NEEDED)
      SET(3RDPARTY_${PRODUCT_NAME}_DLL "3RDPARTY_${PRODUCT_NAME}_DLL-NOTFOUND" CACHE FILEPATH "Directory contains shared library of the ${PRODUCT_NAME} product" FORCE)
      FIND_FILE(3RDPARTY_${PRODUCT_NAME}_DLL "${DLL_SO_PREFIX}${LIBRARY_NAME}.${DLL_SO}"  PATHS "${3RDPARTY_${PRODUCT_NAME}_DIR}/${DLL_SO_FOLDER}")
    ENDIF()
    MARK_AS_ADVANCED(3RDPARTY_${PRODUCT_NAME}_DIR)
  ENDIF()
  
  # check default path for library search
  IF("${3RDPARTY_${PRODUCT_NAME}_LIBRARY}" STREQUAL "" OR "${3RDPARTY_${PRODUCT_NAME}_LIBRARY}" STREQUAL "3RDPARTY_${PRODUCT_NAME}_LIBRARY-NOTFOUND")
    SET(3RDPARTY_${PRODUCT_NAME}_LIBRARY "3RDPARTY_${PRODUCT_NAME}_LIBRARY-NOTFOUND" CACHE FILEPATH "Directory contains library of the ${PRODUCT_NAME} product" FORCE)
    FIND_LIBRARY(3RDPARTY_${PRODUCT_NAME}_LIBRARY ${LIBRARY_NAME})
  ENDIF()

  IF(3RDPARTY_${PRODUCT_NAME}_INCLUDE_DIR)
    SET(3RDPARTY_INCLUDE_DIRS "${3RDPARTY_INCLUDE_DIRS};${3RDPARTY_${PRODUCT_NAME}_INCLUDE_DIR}")
  ELSE()
    LIST(APPEND 3RDPARTY_NOT_INCLUDED 3RDPARTY_${PRODUCT_NAME}_INCLUDE_DIR)
  ENDIF()

  IF(3RDPARTY_${PRODUCT_NAME}_LIBRARY)
    GET_FILENAME_COMPONENT(3RDPARTY_${PRODUCT_NAME}_LIBRARY_DIR "${3RDPARTY_${PRODUCT_NAME}_LIBRARY}" PATH)
    SET(3RDPARTY_LIBRARY_DIRS "${3RDPARTY_LIBRARY_DIRS};${3RDPARTY_${PRODUCT_NAME}_LIBRARY_DIR}")
  ELSE()
    LIST(APPEND 3RDPARTY_NOT_INCLUDED 3RDPARTY_${PRODUCT_NAME}_LIBRARY)
  ENDIF()
  
  IF(3RDPARTY_${PRODUCT_NAME}_DLL)
    #
  ELSE()
    LIST(APPEND 3RDPARTY_NOT_INCLUDED 3RDPARTY_${PRODUCT_NAME}_DLL)
  ENDIF()

  IF(INSTALL_${PRODUCT_NAME})
    INSTALL(FILES "${3RDPARTY_${PRODUCT_NAME}_DLL}" DESTINATION "${INSTALL_DIR}/${DLL_SO_FOLDER}")
    SET(3RDPARTY_${PRODUCT_NAME}_DLL_DIR "")
  ELSE()
    GET_FILENAME_COMPONENT(3RDPARTY_${PRODUCT_NAME}_DLL_DIR "${3RDPARTY_${PRODUCT_NAME}_DLL}" PATH)
  ENDIF()
ENDMACRO()

# TCL

#tcl85 - win; tcl8.5 - lin
IF(WIN32)
  SET(TCL_SEP "")
ELSE()
  SET(TCL_SEP ".")
ENDIF()
  
THIRDPARTY_PRODUCT("TCL" "tcl.h" "tcl8${TCL_SEP}5")

#install tk and libs
IF(INSTALL_TCL)
  GET_FILENAME_COMPONENT(3RDPARTY_TK_LIB_DIR "${3RDPARTY_TCL_LIBRARY}" PATH)
  GET_FILENAME_COMPONENT(3RDPARTY_TK_DLL_DIR "${3RDPARTY_TCL_DLL}" PATH)
  
  INSTALL(FILES "${3RDPARTY_TK_DLL_DIR}/${DLL_SO_PREFIX}tk8${TCL_SEP}5.${DLL_SO}" DESTINATION "${INSTALL_DIR}/${DLL_SO_FOLDER}")
  INSTALL(DIRECTORY "${3RDPARTY_TK_LIB_DIR}/tcl8.5" DESTINATION "${INSTALL_DIR}/lib")
  INSTALL(DIRECTORY "${3RDPARTY_TK_LIB_DIR}/tk8.5" DESTINATION "${INSTALL_DIR}/lib")
ENDIF()

# FREETYPE
THIRDPARTY_PRODUCT("FREETYPE" "freetype/freetype.h" "freetype${BUILD_SUFFIX}")

# FREEIMAGE
IF(3RDPARTY_USE_FREEIMAGE)
  ADD_DEFINITIONS(-DHAVE_FREEIMAGE) 

  THIRDPARTY_PRODUCT("FREEIMAGE" "FreeImage.h" "freeimage${BUILD_SUFFIX}")
  IF(WIN32)
    IF("${3RDPARTY_FREEIMAGE_DIR}" STREQUAL "")
    ELSE()
      SET (3RDPARTY_FREEIMAGEPLUS_DIR "${3RDPARTY_FREEIMAGE_DIR}")
    ENDIF()
    
    THIRDPARTY_PRODUCT("FREEIMAGEPLUS" "FreeImagePlus.h" "freeimageplus${BUILD_SUFFIX}")
    
  ENDIF()
ENDIF()


# GL2PS
IF(3RDPARTY_USE_GL2PS)
  ADD_DEFINITIONS(-DHAVE_GL2PS)
  THIRDPARTY_PRODUCT("GL2PS" "gl2ps.h" "gl2ps${BUILD_SUFFIX}")
ENDIF()

# TBB
IF (3RDPARTY_USE_TBB)
  ADD_DEFINITIONS(-DHAVE_TBB)

  IF(${BUILD_BITNESS} STREQUAL 32)
    SET (TBB_ARCH_NAME ia32)
  ELSE()
    SET (TBB_ARCH_NAME intel64)
  ENDIF()
  
  IF(NOT DEFINED 3RDPARTY_TBB_DIR)
    SET(3RDPARTY_TBB_DIR "" CACHE PATH "Directory contains tbb product")
  ENDIF()
  
  SET(3RDPARTY_TBB_DIR_NAME "")
  IF(3RDPARTY_DIR AND ("${3RDPARTY_TBB_DIR}" STREQUAL "" OR CHANGES_ARE_NEEDED))
    FIND_PRODUCT_DIR("${3RDPARTY_DIR}" "TBB" 3RDPARTY_TBB_DIR_NAME)
    IF("${3RDPARTY_TBB_DIR_NAME}" STREQUAL "")
      MESSAGE(STATUS "TBB DON'T FIND")
    ELSE()
      SET(3RDPARTY_TBB_DIR "${3RDPARTY_DIR}/${3RDPARTY_TBB_DIR_NAME}" CACHE PATH "Directory contains tbb product" FORCE)
    ENDIF()
  ENDIF()
  
  SET(INSTALL_TBB OFF CACHE BOOL "Is tbb lib copy to install directory")

  IF(3RDPARTY_TBB_DIR)
    IF("${3RDPARTY_TBB_INCLUDE_DIR}" STREQUAL "" OR CHANGES_ARE_NEEDED)
      SET(3RDPARTY_TBB_INCLUDE_DIR "3RDPARTY_TBB_INCLUDE_DIR-NOTFOUND" CACHE PATH "Directory contains headers of the tbb product" FORCE)
      FIND_PATH(3RDPARTY_TBB_INCLUDE_DIR tbb/tbb.h PATHS "${3RDPARTY_TBB_DIR}/include")
    ENDIF()

    SET(TBB_DEBUG_POSTFIX "")
    if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
      SET(TBB_DEBUG_POSTFIX "_debug")
    ENDIF()
    
    IF("${3RDPARTY_TBB_LIBRARY}" STREQUAL "" OR CHANGES_ARE_NEEDED)
      SET(3RDPARTY_TBB_LIBRARY "3RDPARTY_TBB_LIBRARY-NOTFOUND" CACHE PATH "Directory contains library of the tbb product" FORCE)
      FIND_LIBRARY(3RDPARTY_TBB_LIBRARY tbb${TBB_DEBUG_POSTFIX} PATHS "${3RDPARTY_TBB_DIR}/lib/${TBB_ARCH_NAME}/${COMPILER}")
    ENDIF()
    
    IF("${3RDPARTY_TBB_MALLOC_LIBRARY}" STREQUAL "" OR CHANGES_ARE_NEEDED)
      SET(3RDPARTY_TBB_MALLOC_LIBRARY "3RDPARTY_TBB_MALLOC_LIBRARY-NOTFOUND" CACHE PATH "Directory contains library of the tbb malloc product" FORCE)
      FIND_LIBRARY(3RDPARTY_TBB_MALLOC_LIBRARY tbbmalloc${TBB_DEBUG_POSTFIX} PATHS "${3RDPARTY_TBB_DIR}/lib/${TBB_ARCH_NAME}/${COMPILER}")
    ENDIF()
    
    IF("${3RDPARTY_TBB_DLL}" STREQUAL "" OR CHANGES_ARE_NEEDED)
      SET(3RDPARTY_TBB_DLL "3RDPARTY_TBB_DLL-NOTFOUND" CACHE PATH "Directory contains shared library of the tbb product" FORCE)
      FIND_FILE(3RDPARTY_TBB_DLL "${DLL_SO_PREFIX}tbb${TBB_DEBUG_POSTFIX}.${DLL_SO}" PATHS "${3RDPARTY_TBB_DIR}/${DLL_SO_FOLDER}/${TBB_ARCH_NAME}/${COMPILER}")
    ENDIF()
    
    IF("${3RDPARTY_TBB_MALLOC_DLL}" STREQUAL "" OR CHANGES_ARE_NEEDED)
      SET(3RDPARTY_TBB_MALLOC_DLL "3RDPARTY_TBB_MALLOC_DLL-NOTFOUND" CACHE PATH "Directory contains shared library of the tbb malloc product" FORCE)
      FIND_FILE(3RDPARTY_TBB_MALLOC_DLL "${DLL_SO_PREFIX}tbbmalloc${TBB_DEBUG_POSTFIX}.${DLL_SO}" PATHS "${3RDPARTY_TBB_DIR}/${DLL_SO_FOLDER}/${TBB_ARCH_NAME}/${COMPILER}")
    ENDIF()

    MARK_AS_ADVANCED(3RDPARTY_TBB_DIR_NAME)
  ELSE()
    LIST(APPEND 3RDPARTY_NOT_INCLUDED 3RDPARTY_TBB_DIR)
  ENDIF()

  IF(3RDPARTY_TBB_INCLUDE_DIR)
    SET(3RDPARTY_INCLUDE_DIRS "${3RDPARTY_INCLUDE_DIRS};${3RDPARTY_TBB_INCLUDE_DIR}")
  ELSE()
    LIST(APPEND 3RDPARTY_NOT_INCLUDED 3RDPARTY_TBB_INCLUDE_DIR)
  ENDIF()

  IF(3RDPARTY_TBB_LIBRARY)
    GET_FILENAME_COMPONENT(3RDPARTY_TBB_LIBRARY_DIR "${3RDPARTY_TBB_LIBRARY}" PATH)
    SET(3RDPARTY_LIBRARY_DIRS "${3RDPARTY_LIBRARY_DIRS};${3RDPARTY_TBB_LIBRARY_DIR}")
  ELSE()
    LIST(APPEND 3RDPARTY_NOT_INCLUDED 3RDPARTY_TBB_LIBRARY)
  ENDIF()
  
  IF(3RDPARTY_TBB_MALLOC_LIBRARY)
    GET_FILENAME_COMPONENT(3RDPARTY_TBB_LIBRARY_DIR "${3RDPARTY_TBB_MALLOC_LIBRARY}" PATH)
    SET(3RDPARTY_LIBRARY_DIRS "${3RDPARTY_LIBRARY_DIRS};${3RDPARTY_TBB_LIBRARY_DIR}")
  ELSE()
    LIST(APPEND 3RDPARTY_NOT_INCLUDED 3RDPARTY_TBB_MALLOC_LIBRARY)
  ENDIF()
  
  IF(3RDPARTY_TBB_DLL)
    #
  ELSE()
    LIST(APPEND 3RDPARTY_NOT_INCLUDED 3RDPARTY_TBB_DLL)
  ENDIF()
  
  IF(3RDPARTY_TBB_MALLOC_DLL)
    #
  ELSE()
    LIST(APPEND 3RDPARTY_NOT_INCLUDED 3RDPARTY_TBB_MALLOC_DLL)
  ENDIF()

  IF(INSTALL_TBB)
    INSTALL(FILES "${3RDPARTY_TBB_DLL}" "${3RDPARTY_TBB_MALLOC_DLL}" DESTINATION "${INSTALL_DIR}/${DLL_SO_FOLDER}")

    SET(3RDPARTY_TBB_DLL_DIR "")
    SET(3RDPARTY_TBB_MALLOC_DLL_DIR "")
  ELSE()
    GET_FILENAME_COMPONENT(3RDPARTY_TBB_DLL_DIR "${3RDPARTY_TBB_DLL}" PATH)
    GET_FILENAME_COMPONENT(3RDPARTY_TBB_MALLOC_DLL_DIR "${3RDPARTY_TBB_MALLOC_DLL}" PATH)
  ENDIF()
ENDIF()

string( REGEX REPLACE ";" " " 3RDPARTY_NOT_INCLUDED "${3RDPARTY_NOT_INCLUDED}")

#CHECK ALL 3RDPARTY PATHS
IF(3RDPARTY_NOT_INCLUDED)
  MESSAGE(FATAL_ERROR "NOT FOUND: ${3RDPARTY_NOT_INCLUDED}" )
ENDIF()

list(REMOVE_DUPLICATES 3RDPARTY_INCLUDE_DIRS)
string( REGEX REPLACE ";" "\n\t" 3RDPARTY_INCLUDE_DIRS_WITH_ENDS "${3RDPARTY_INCLUDE_DIRS}")
MESSAGE(STATUS "3RDPARTY_INCLUDE_DIRS: ${3RDPARTY_INCLUDE_DIRS_WITH_ENDS}")
  include_directories( ${3RDPARTY_INCLUDE_DIRS} )

list(REMOVE_DUPLICATES 3RDPARTY_LIBRARY_DIRS)
string( REGEX REPLACE ";" "\n\t" 3RDPARTY_LIBRARY_DIRS_WITH_ENDS "${3RDPARTY_LIBRARY_DIRS}")
MESSAGE(STATUS "3RDPARTY_LIBRARY_DIRS: ${3RDPARTY_LIBRARY_DIRS_WITH_ENDS}")
  link_directories( ${3RDPARTY_LIBRARY_DIRS} )
 
#
SET(RUN_PROJECT "")
SET(CASROOT_DEFINITION "")
SET(BIN_DIR_POSTFIX "bin")
SET(RESOURCE_DIR_PREFIX "%SCRIPTROOT%\\res")

IF("${INSTALL_DIR}" STREQUAL "")
  MESSAGE(FATAL_ERROR "INSTALL_DIR is empty")
ELSE()
  # INC DIRECTORY
  install(DIRECTORY __CASROOT_DIR__/inc DESTINATION  "${INSTALL_DIR}" )

  # DRAW.BAT or DRAW.SH
  install(FILES draw.${SCRIPT_EXT} DESTINATION  "${INSTALL_DIR}" PERMISSIONS  OWNER_READ OWNER_WRITE OWNER_EXECUTE 
                                                                              GROUP_READ GROUP_WRITE GROUP_EXECUTE 
                                                                              WORLD_READ WORLD_WRITE WORLD_EXECUTE)

  configure_file(env.${SCRIPT_EXT}.in env.${SCRIPT_EXT} @ONLY)
  install(FILES "${__PROJECT_NAME___BINARY_DIR}/env.${SCRIPT_EXT}" DESTINATION  "${INSTALL_DIR}" )
ENDIF()

IF(MSVC AND "${BUILD_TYPE}" STREQUAL "Debug")
  SET(RUN_PROJECT "start __PROJECT_NAME__.sln")
  SET(BIN_DIR_POSTFIX "out\\bin\\Debug")
  SET(RESOURCE_DIR_PREFIX "%CASROOT%\\src")
  SET(CASROOT_DEFINITION "set \"CASROOT=__CASROOT_DIR__\"")
  
  configure_file(env.bat.in __PROJECT_NAME__.bat @ONLY)
ENDIF()
  
__TOOLKIT_DEPS__

__MODULE_DEPS__

list( APPEND USED_TOOLKITS ${BUILD_TOOLKITS})

foreach( TOOLKIT ${USED_TOOLKITS} )
 set(TurnONthe${TOOLKIT} ON)
 foreach( TK ${${TOOLKIT}_DEPS})
   set(TurnONthe${TK} ON)
 endforeach()
endforeach()

__INCLUDE_TOOLKITS__