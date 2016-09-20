# This is a CMake file meant to be included via include()
# It will trigger a compilation of dlib *in the project* 
# including it

cmake_minimum_required(VERSION 2.8.4)

set(DLIB_IN_PROJECT_BUILD true)

if (POLICY CMP0054)
    cmake_policy(SET CMP0054 NEW)
endif()


set(gcc_like_compilers GNU Clang  Intel)
set(intel_archs x86_64 i386 i686)

# Setup some options to allow a user to enable SSE and AVX instruction use.  
if ((";${gcc_like_compilers};" MATCHES ";${CMAKE_CXX_COMPILER_ID};") AND
    (";${intel_archs};"        MATCHES ";${CMAKE_SYSTEM_PROCESSOR};"))
    option(USE_SSE2_INSTRUCTIONS "Compile your program with SSE2 instructions" OFF)
    option(USE_SSE4_INSTRUCTIONS "Compile your program with SSE4 instructions" OFF)
    option(USE_AVX_INSTRUCTIONS  "Compile your program with AVX instructions"  OFF)
    if(USE_AVX_INSTRUCTIONS)
        add_definitions(-mavx)
        message(STATUS "Enabling AVX instructions")
    elseif (USE_SSE4_INSTRUCTIONS)
        add_definitions(-msse4)
        message(STATUS "Enabling SSE4 instructions")
    elseif(USE_SSE2_INSTRUCTIONS)
        add_definitions(-msse2)
        message(STATUS "Enabling SSE2 instructions")
    endif()
elseif (MSVC OR "${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC") # else if using Visual Studio 
    # Use SSE2 by default when using Visual Studio.
    option(USE_SSE2_INSTRUCTIONS "Compile your program with SSE2 instructions" ON)
    # Visual Studio 2005 didn't support SSE4 
    if (NOT MSVC80)
        option(USE_SSE4_INSTRUCTIONS "Compile your program with SSE4 instructions" OFF)
    endif()
    # Visual Studio 2005 and 2008 didn't support AVX
    if (NOT MSVC80 AND NOT MSVC90)
        option(USE_AVX_INSTRUCTIONS  "Compile your program with AVX instructions"  OFF)
    endif() 
    include(CheckTypeSize)
    check_type_size( "void*" SIZE_OF_VOID_PTR)
    if(USE_AVX_INSTRUCTIONS)
        add_definitions(/arch:AVX)
        message(STATUS "Enabling AVX instructions")
    elseif (USE_SSE4_INSTRUCTIONS)
        # Visual studio doesn't have an /arch:SSE2 flag when building in 64 bit modes.
        # So only give it when we are doing a 32 bit build.
        if (SIZE_OF_VOID_PTR EQUAL 4)
            add_definitions(/arch:SSE2)  
        endif()
        message(STATUS "Enabling SSE4 instructions")
        add_definitions(-DDLIB_HAVE_SSE2)
        add_definitions(-DDLIB_HAVE_SSE3)
        add_definitions(-DDLIB_HAVE_SSE41)
    elseif(USE_SSE2_INSTRUCTIONS)
        # Visual studio doesn't have an /arch:SSE2 flag when building in 64 bit modes.
        # So only give it when we are doing a 32 bit build.
        if (SIZE_OF_VOID_PTR EQUAL 4)
            add_definitions(/arch:SSE2)
        endif()
        message(STATUS "Enabling SSE2 instructions")
        add_definitions(-DDLIB_HAVE_SSE2)
    endif()

   # By default Visual Studio does not support .obj files with more than 65k sections
   # Code generated by file_to_code_ex and code using DNN module can have them
   # this flag enables > 65k sections, but produces .obj files that will not be readable by
   # VS 2005
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj")
endif()

