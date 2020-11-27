#include "CuGLView.h"

int main(void)
{
    CuGLView::InteractiveWindow window(512, 512, "Debug Window", true);
    window.Setup();
    window.Run();
    return 0;
}
