#include "kimera-vio/utils/FilesystemUtils.h"

#include <filesystem>

#include <glog/logging.h>

namespace VIO {
namespace common {

std::string pathAppend(const std::string& p1, const std::string& p2) {
  char sep = '/';
  std::string tmp = p1;
  if (p1[p1.length()] != sep) {  // Need to add a
    tmp += sep;                  // path separator
    return (tmp + p2);
  } else {
    return (p1 + p2);
  }
}

bool createDirectory(const std::string& dir_path,
                     const std::string& dir_name,
                     bool override_if_exists) {
  std::string path = pathAppend(dir_path, dir_name);
  std::error_code ec;
  bool created = std::filesystem::create_directory(path, ec);
  if (!ec && (created || std::filesystem::exists(path))) {
    LOG(INFO) << "Directory created: " << path;
    return true;
  } else {
    LOG(ERROR) << "Directory creation failed for: " << path << '\n'
               << "Error code: " << ec.message();
    return false;
  }
}

}  // namespace common
}  // namespace VIO
