#ifndef LAUNCH_CONFIG_H
#define LAUNCH_CONFIG_H

namespace CuGLView
{
    inline void GetConfiguration(dim3* block, dim3* grid, int hei, int wid)
    {
        int numBlocksW = (wid  + (BLOCK_SIZE-1))/BLOCK_SIZE;
        int numBlocksH = (hei + (BLOCK_SIZE-1))/BLOCK_SIZE;
        *grid =  dim3(numBlocksW, numBlocksH);
        *block = dim3(BLOCK_SIZE, BLOCK_SIZE);
    }
}

#endif