#include "WindowState.h"
namespace CuGLView
{
    InteractiveWindow* globalWindow;
    
    void SetGlobalWindow(InteractiveWindow* win)
    {
        globalWindow = win;
    }
    
    void GlobalOnDisplay(void)
    {
        globalWindow->OnDisplay();
    }
}