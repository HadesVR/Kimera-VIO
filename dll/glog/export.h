// HadesVR: glog's export macros for kimera_vio.dll, found before the SDK's
// glog/export.h (same include guard). The SDK's glog is a static build, so its
// own export.h leaves GLOG_EXPORT empty. A program using the DLL must import
// glog from it instead: the DLL holds the process's glog, and its flags are
// data (fLI::FLAGS_v, read by Kimera's inline code), which only link imported.
// The DLL's own build compiles glog's headers as before (static).
#ifndef GLOG_EXPORT_H
#define GLOG_EXPORT_H

#ifdef KIMERA_DLL_BUILD
#  define GLOG_EXPORT
#else
#  define GLOG_EXPORT __declspec(dllimport)
#endif
#define GLOG_NO_EXPORT

#ifndef GLOG_DEPRECATED
#  define GLOG_DEPRECATED __declspec(deprecated)
#endif
#ifndef GLOG_DEPRECATED_EXPORT
#  define GLOG_DEPRECATED_EXPORT GLOG_EXPORT GLOG_DEPRECATED
#endif
#ifndef GLOG_DEPRECATED_NO_EXPORT
#  define GLOG_DEPRECATED_NO_EXPORT GLOG_NO_EXPORT GLOG_DEPRECATED
#endif

#endif  // GLOG_EXPORT_H
