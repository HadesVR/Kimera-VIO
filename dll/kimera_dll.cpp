#include "kimera_dll.h"

#include <opencv2/core/utility.hpp>

void kimera_dll_set_opencv_threads(int n) { cv::setNumThreads(n); }

int kimera_dll_get_opencv_threads(void) { return cv::getNumThreads(); }
