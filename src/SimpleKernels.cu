#include "Config.h"
#include "SimpleKernels.h"
#include "LaunchConfiguration.h"
namespace CuGLView
{
    __global__ void K_FillBuffer(int* p, int color, int hei, int wid)
    {
        int i = blockIdx.y*blockDim.y + threadIdx.y;
		int j = blockIdx.x*blockDim.x + threadIdx.x;
        if (i < hei && j < wid)
        {
            *(p + i*wid+j) = color;
        }
    }
    
    void FillBuffer(int* p, int color, int hei, int wid)
    {    
        dim3 block, grid;
        GetConfiguration(&block, &grid, hei, wid);
        K_FillBuffer<<<grid, block>>>(p, color, hei, wid);
    }
}