#ifndef INTERACTIVE_WINDOW_H
#define INTERACTIVE_WINDOW_H
#include "CuGLInterop.h"
#include <iostream>
#include <string>
namespace CuGLView
{
    class InteractiveWindow
    {
        public:
            InteractiveWindow(int width_in, int height_in);
            InteractiveWindow(int width_in, int height_in, std::string title_in);
            InteractiveWindow(int width_in, int height_in, bool allowOutput_in);
            InteractiveWindow(int width_in, int height_in, std::string title_in, bool allowOutput_in);
            void Build(int width_in, int height_in, std::string title_in, bool allowOutput_in);
            void InitializeGLUT(void);
            void SetOrthogonal(void);
            void InitializePixelBuffer(void);
            void Setup(void);
            void Run(void);
            void OnDisplay(void);
            void SetFill(int fillValue);
            ~InteractiveWindow(void);
        private:
            void SetBindings(void);
            void Write(std::string message);
            void WriteLine(std::string message);
            void DrawTexture(void);
            void ComputePixelBuffer(int* devicePixelBuffer);
            void Destroy(void);
            int backFill;
            int width;
            int height;
            bool allowOutput;
            bool pixelBufferInitialized;
            bool hasRun;
            bool useGLUT;
            int dummyArgC;
            char* dummyArgV[1];
            size_t totalFrames;
            std::string title;
            std::string writeStyle;
            GLuint pbo;
            GLuint tex;
            struct cudaGraphicsResource *cuda_pbo_resource;
    };
}
#endif
