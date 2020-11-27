#ifndef WINDOW_STATE_H
#define WINDOW_STATE_H
#include "InteractiveWindow.h"
namespace CuGLView
{
    extern InteractiveWindow* globalWindow;
    void SetGlobalWindow(InteractiveWindow* win);
    void GlobalOnDisplay(void);
}

#endif