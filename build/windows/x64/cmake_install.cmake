# Install script for directory: C:/Projects/medical-app/windows

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "$<TARGET_FILE_DIR:temp_platform_project>")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Projects/medical-app/build/windows/x64/flutter/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Projects/medical-app/build/windows/x64/runner/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Projects/medical-app/build/windows/x64/plugins/agora_rtc_engine/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Projects/medical-app/build/windows/x64/plugins/connectivity_plus/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Projects/medical-app/build/windows/x64/plugins/iris_method_channel/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Projects/medical-app/build/windows/x64/plugins/url_launcher_windows/cmake_install.cmake")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Debug/temp_platform_project.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Debug" TYPE EXECUTABLE FILES "C:/Projects/medical-app/build/windows/x64/runner/Debug/temp_platform_project.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Profile/temp_platform_project.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Profile" TYPE EXECUTABLE FILES "C:/Projects/medical-app/build/windows/x64/runner/Profile/temp_platform_project.exe")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Release/temp_platform_project.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Release" TYPE EXECUTABLE FILES "C:/Projects/medical-app/build/windows/x64/runner/Release/temp_platform_project.exe")
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Debug/data/icudtl.dat")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Debug/data" TYPE FILE FILES "C:/Projects/medical-app/windows/flutter/ephemeral/icudtl.dat")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Profile/data/icudtl.dat")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Profile/data" TYPE FILE FILES "C:/Projects/medical-app/windows/flutter/ephemeral/icudtl.dat")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Release/data/icudtl.dat")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Release/data" TYPE FILE FILES "C:/Projects/medical-app/windows/flutter/ephemeral/icudtl.dat")
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Debug/flutter_windows.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Debug" TYPE FILE FILES "C:/Projects/medical-app/windows/flutter/ephemeral/flutter_windows.dll")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Profile/flutter_windows.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Profile" TYPE FILE FILES "C:/Projects/medical-app/windows/flutter/ephemeral/flutter_windows.dll")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Release/flutter_windows.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Release" TYPE FILE FILES "C:/Projects/medical-app/windows/flutter/ephemeral/flutter_windows.dll")
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Debug/agora_rtc_engine_plugin.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/AgoraRtcWrapper.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/agora_rtc_sdk.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/glfw3.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora-fdkaac.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora-ffmpeg.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora-soundtouch.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora-wgc.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_ai_echo_cancellation_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_ai_echo_cancellation_ll_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_ai_noise_suppression_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_ai_noise_suppression_ll_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_audio_beauty_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_clear_vision_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_content_inspect_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_face_capture_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_face_detection_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_lip_sync_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_screen_capture_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_segmentation_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_spatial_audio_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_video_av1_decoder_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_video_av1_encoder_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_video_decoder_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_video_encoder_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libagora_video_quality_analyzer_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/libaosl.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/video_dec.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/video_enc.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/connectivity_plus_plugin.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/iris_method_channel_plugin.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/iris_method_channel.dll;C:/Projects/medical-app/build/windows/x64/runner/Debug/url_launcher_windows_plugin.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Debug" TYPE FILE FILES
      "C:/Projects/medical-app/build/windows/x64/plugins/agora_rtc_engine/Debug/agora_rtc_engine_plugin.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/iris/lib/iris_4.5.2-build.1_DCG_Windows/x64/Release/AgoraRtcWrapper.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/agora_rtc_sdk.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/glfw3.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora-fdkaac.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora-ffmpeg.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora-soundtouch.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora-wgc.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_ai_echo_cancellation_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_ai_echo_cancellation_ll_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_ai_noise_suppression_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_ai_noise_suppression_ll_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_audio_beauty_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_clear_vision_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_content_inspect_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_face_capture_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_face_detection_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_lip_sync_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_screen_capture_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_segmentation_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_spatial_audio_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_av1_decoder_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_av1_encoder_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_decoder_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_encoder_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_quality_analyzer_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libaosl.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/video_dec.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/video_enc.dll"
      "C:/Projects/medical-app/build/windows/x64/plugins/connectivity_plus/Debug/connectivity_plus_plugin.dll"
      "C:/Projects/medical-app/build/windows/x64/plugins/iris_method_channel/Debug/iris_method_channel_plugin.dll"
      "C:/Projects/medical-app/build/windows/x64/plugins/iris_method_channel/shared/Debug/iris_method_channel.dll"
      "C:/Projects/medical-app/build/windows/x64/plugins/url_launcher_windows/Debug/url_launcher_windows_plugin.dll"
      )
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Profile/agora_rtc_engine_plugin.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/AgoraRtcWrapper.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/agora_rtc_sdk.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/glfw3.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora-fdkaac.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora-ffmpeg.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora-soundtouch.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora-wgc.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_ai_echo_cancellation_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_ai_echo_cancellation_ll_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_ai_noise_suppression_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_ai_noise_suppression_ll_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_audio_beauty_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_clear_vision_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_content_inspect_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_face_capture_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_face_detection_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_lip_sync_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_screen_capture_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_segmentation_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_spatial_audio_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_video_av1_decoder_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_video_av1_encoder_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_video_decoder_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_video_encoder_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libagora_video_quality_analyzer_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/libaosl.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/video_dec.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/video_enc.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/connectivity_plus_plugin.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/iris_method_channel_plugin.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/iris_method_channel.dll;C:/Projects/medical-app/build/windows/x64/runner/Profile/url_launcher_windows_plugin.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Profile" TYPE FILE FILES
      "C:/Projects/medical-app/build/windows/x64/plugins/agora_rtc_engine/Profile/agora_rtc_engine_plugin.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/iris/lib/iris_4.5.2-build.1_DCG_Windows/x64/Release/AgoraRtcWrapper.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/agora_rtc_sdk.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/glfw3.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora-fdkaac.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora-ffmpeg.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora-soundtouch.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora-wgc.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_ai_echo_cancellation_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_ai_echo_cancellation_ll_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_ai_noise_suppression_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_ai_noise_suppression_ll_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_audio_beauty_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_clear_vision_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_content_inspect_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_face_capture_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_face_detection_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_lip_sync_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_screen_capture_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_segmentation_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_spatial_audio_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_av1_decoder_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_av1_encoder_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_decoder_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_encoder_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_quality_analyzer_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libaosl.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/video_dec.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/video_enc.dll"
      "C:/Projects/medical-app/build/windows/x64/plugins/connectivity_plus/Profile/connectivity_plus_plugin.dll"
      "C:/Projects/medical-app/build/windows/x64/plugins/iris_method_channel/Profile/iris_method_channel_plugin.dll"
      "C:/Projects/medical-app/build/windows/x64/plugins/iris_method_channel/shared/Profile/iris_method_channel.dll"
      "C:/Projects/medical-app/build/windows/x64/plugins/url_launcher_windows/Profile/url_launcher_windows_plugin.dll"
      )
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Release/agora_rtc_engine_plugin.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/AgoraRtcWrapper.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/agora_rtc_sdk.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/glfw3.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora-fdkaac.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora-ffmpeg.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora-soundtouch.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora-wgc.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_ai_echo_cancellation_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_ai_echo_cancellation_ll_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_ai_noise_suppression_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_ai_noise_suppression_ll_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_audio_beauty_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_clear_vision_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_content_inspect_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_face_capture_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_face_detection_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_lip_sync_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_screen_capture_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_segmentation_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_spatial_audio_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_video_av1_decoder_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_video_av1_encoder_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_video_decoder_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_video_encoder_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libagora_video_quality_analyzer_extension.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/libaosl.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/video_dec.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/video_enc.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/connectivity_plus_plugin.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/iris_method_channel_plugin.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/iris_method_channel.dll;C:/Projects/medical-app/build/windows/x64/runner/Release/url_launcher_windows_plugin.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Release" TYPE FILE FILES
      "C:/Projects/medical-app/build/windows/x64/plugins/agora_rtc_engine/Release/agora_rtc_engine_plugin.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/iris/lib/iris_4.5.2-build.1_DCG_Windows/x64/Release/AgoraRtcWrapper.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/agora_rtc_sdk.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/glfw3.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora-fdkaac.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora-ffmpeg.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora-soundtouch.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora-wgc.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_ai_echo_cancellation_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_ai_echo_cancellation_ll_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_ai_noise_suppression_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_ai_noise_suppression_ll_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_audio_beauty_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_clear_vision_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_content_inspect_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_face_capture_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_face_detection_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_lip_sync_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_screen_capture_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_segmentation_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_spatial_audio_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_av1_decoder_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_av1_encoder_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_decoder_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_encoder_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libagora_video_quality_analyzer_extension.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/libaosl.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/video_dec.dll"
      "C:/Projects/medical-app/windows/flutter/ephemeral/.plugin_symlinks/agora_rtc_engine/windows/third_party/native/lib/Agora_Native_SDK_for_Windows_FULL/sdk/x86_64/video_enc.dll"
      "C:/Projects/medical-app/build/windows/x64/plugins/connectivity_plus/Release/connectivity_plus_plugin.dll"
      "C:/Projects/medical-app/build/windows/x64/plugins/iris_method_channel/Release/iris_method_channel_plugin.dll"
      "C:/Projects/medical-app/build/windows/x64/plugins/iris_method_channel/shared/Release/iris_method_channel.dll"
      "C:/Projects/medical-app/build/windows/x64/plugins/url_launcher_windows/Release/url_launcher_windows_plugin.dll"
      )
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Debug/")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Debug" TYPE DIRECTORY FILES "C:/Projects/medical-app/build/native_assets/windows/")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Profile/")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Profile" TYPE DIRECTORY FILES "C:/Projects/medical-app/build/native_assets/windows/")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Release/")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Release" TYPE DIRECTORY FILES "C:/Projects/medical-app/build/native_assets/windows/")
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    
  file(REMOVE_RECURSE "C:/Projects/medical-app/build/windows/x64/runner/Debug/data/flutter_assets")
  
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    
  file(REMOVE_RECURSE "C:/Projects/medical-app/build/windows/x64/runner/Profile/data/flutter_assets")
  
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    
  file(REMOVE_RECURSE "C:/Projects/medical-app/build/windows/x64/runner/Release/data/flutter_assets")
  
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Debug/data/flutter_assets")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Debug/data" TYPE DIRECTORY FILES "C:/Projects/medical-app/build//flutter_assets")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Profile/data/flutter_assets")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Profile/data" TYPE DIRECTORY FILES "C:/Projects/medical-app/build//flutter_assets")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Release/data/flutter_assets")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Release/data" TYPE DIRECTORY FILES "C:/Projects/medical-app/build//flutter_assets")
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xRuntimex" OR NOT CMAKE_INSTALL_COMPONENT)
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Profile/data/app.so")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Profile/data" TYPE FILE FILES "C:/Projects/medical-app/build/windows/app.so")
  elseif("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Projects/medical-app/build/windows/x64/runner/Release/data/app.so")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
        message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
file(INSTALL DESTINATION "C:/Projects/medical-app/build/windows/x64/runner/Release/data" TYPE FILE FILES "C:/Projects/medical-app/build/windows/app.so")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "C:/Projects/medical-app/build/windows/x64/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
