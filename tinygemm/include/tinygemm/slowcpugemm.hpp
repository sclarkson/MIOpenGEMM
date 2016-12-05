#ifndef SLOWCPUGEMM
#define SLOWCPUGEMM

#include <vector>
#include <string>

#include "outputwriter.hpp"
#include "tinygemmgeometry.hpp"

namespace tinygemm{
namespace slowcpugemm{


template <typename TFloat>
void gemms_cpu(tinygemm::TinyGemmGeometry gg, const TFloat * a, const TFloat * b, TFloat * c, TFloat alpha, TFloat beta, std::vector<std::string> algs, outputwriting::OutputWriter & mowri);
      
} //namespace
}


#endif