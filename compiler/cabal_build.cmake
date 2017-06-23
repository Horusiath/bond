# This is a workaround for Windows quirks.
# CMake Visual Studio generator translates add_custom_command into a batch file
# embedded in Visual Studio project. Batch files have problems with paths that
# contain non-ascii characters because they are limited to DOS encoding. It so
# happens that cabal is quite likely to be installed in such a path because by
# default cabal install uses directory under %APPDATA% which contains user name.
# As a workaround we execute this .cmake script as a custom command and use CMake
# cache to get access to variables set during configuration.

cmake_policy (SET CMP0012 NEW)

# if appveyor chokes on shakespeare this will need to be implemented

# if ($ENV{APPVEYOR})
#     # AppVeyor Azure VMs have limited memory and shakespeare package doesn't
#     # install as a dependency of the Bond compiler. As a workaround we install
#     # shakespeare explicitly when running under AppVeyor and we limit the heap
#     # used by ghc to 400 MB.
#     execute_process (
#         COMMAND ${Haskell_CABAL_EXECUTABLE} install shakespeare --with-compiler=${Haskell_GHC_EXECUTABLE} --jobs --ghc-option=+RTS --ghc-option=-M400m --ghc-option=-RTS
#         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
#         RESULT_VARIABLE error)
#
#     if (error)
#         message (FATAL_ERROR)
#     endif()
# endif()

execute_process (
    COMMAND ${STACK_EXECUTABLE} setup
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    RESULT_VARIABLE error)

if (error)
    message (FATAL_ERROR)
endif()

# execute_process (
#     COMMAND ${STACK_EXECUTABLE} configure ${cabal_options} --with-compiler=${Haskell_GHC_EXECUTABLE} --builddir=${build_dir}
#     WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
#     RESULT_VARIABLE error)
#
# if (error)
#     message (FATAL_ERROR)
# endif()

set (buildGhcOptions "-O2")

# time outs for travis

# if ($ENV{TRAVIS})
#     # We've been seeing timeouts building gbc on the Travis infrastructure.
#     # Building without optimizations reduces the build time significantly
#     # and shouldn't affect build or test results.
#     set (buildGhcOptions "-O0")
# endif()

execute_process (
    COMMAND ${STACK_EXECUTABLE} build --no-run-tests ${cabal_options}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    RESULT_VARIABLE error)

if (error)
    message (FATAL_ERROR)
endif()

execute_process (
    COMMAND ${STACK_EXECUTABLE} path --dist-dir
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE dist_dir
    RESULT_VARIABLE error)

if (error)
    message (FATAL_ERROR)
endif()

string(STRIP ${dist_dir} dist_dir)

file (COPY "${dist_dir}/build" DESTINATION "${build_dir}")

# execute_process (
#     COMMAND cmake -E copy_directory "${dist_dir}\build" "C:/Users/edus/azure/newbond/bond/build/compiler/build"
#     WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
#     RESULT_VARIABLE error)
#
# if (error)
#     message (FATAL_ERROR)
# endif()
