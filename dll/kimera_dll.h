// HadesVR: what kimera_vio.dll adds to Kimera's own API.
//
// The DLL carries its own copy of every dependency, OpenCV included, and a
// program that also uses OpenCV has a second copy. Process-wide OpenCV settings
// then have to be made in both; these reach the DLL's copy.
#pragma once

#ifdef KIMERA_DLL_BUILD
#define KIMERA_DLL_API extern "C" __declspec(dllexport)
#else
#define KIMERA_DLL_API extern "C" __declspec(dllimport)
#endif

// cv::setNumThreads / cv::getNumThreads on the DLL's OpenCV.
KIMERA_DLL_API void kimera_dll_set_opencv_threads(int n);
KIMERA_DLL_API int kimera_dll_get_opencv_threads(void);
