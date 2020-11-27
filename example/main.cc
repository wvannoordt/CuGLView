#include "CuGLView.h"

int main(void)
{
    CuGLView::InteractiveWindow window(512, 512, "Debug Window", true);
    window.Setup();
    // (A) (B) (G) (R)
    window.SetFill(0xffffe31d);
    window.Run();
    return 0;
}
