#include "InteractiveWindow.h"
#include "WindowState.h"
#include "SimpleKernels.h"
namespace CuGLView
{    
    InteractiveWindow::InteractiveWindow(int width_in, int height_in)
    {
        Build(width_in, height_in, "window", false);
    }
    
    InteractiveWindow::InteractiveWindow(int width_in, int height_in, bool allowOutput_in)
    {
        Build(width_in, height_in, "window", allowOutput_in);
    }
    
    InteractiveWindow::InteractiveWindow(int width_in, int height_in, std::string title_in)
    {
        Build(width_in, height_in, title_in, false);
    }
    
    InteractiveWindow::InteractiveWindow(int width_in, int height_in, std::string title_in, bool allowOutput_in)
    {
        Build(width_in, height_in, title_in, allowOutput_in);
    }

    void InteractiveWindow::Build(int width_in, int height_in, std::string title_in, bool allowOutput_in)
    {
        pixelBufferInitialized = false;
        hasRun = false;
        title = title_in;
        allowOutput = allowOutput_in;
        width = width_in;
        height = height_in;
        dummyArgC = 0;
        useGLUT = true;
        writeStyle = "[" + title + "] :: ";
        totalFrames = 0;
        backFill = 0xffffffff;
        WriteLine("Created window \"" + title + "\" with size " + std::to_string(height) + " x " + std::to_string(width) + ".");
    }
    
    void InteractiveWindow::Setup(void)
    {
        WriteLine("Setup window... ");
        globalWindow = this;
        if (useGLUT) InitializeGLUT();
        SetOrthogonal();
        if (useGLUT) SetBindings();
        InitializePixelBuffer();
        WriteLine("Done");
    }
    
    void InteractiveWindow::SetBindings(void)
    {
        SetGlobalWindow(this);
        glutDisplayFunc(GlobalOnDisplay);
    }
    
    void InteractiveWindow::Run(void)
    {
        if (useGLUT)
        {
            hasRun = true;
            glutMainLoop();
        }
    }
    
    void InteractiveWindow::OnDisplay(void)
    {
        int* oglDeviceBuf = 0;
        cudaGraphicsMapResources(1, &cuda_pbo_resource, 0);
        cudaGraphicsResourceGetMappedPointer((void **)&(oglDeviceBuf), NULL, cuda_pbo_resource);
        ComputePixelBuffer(oglDeviceBuf);
        cudaGraphicsUnmapResources(1, &cuda_pbo_resource, 0);
        DrawTexture();
        if (useGLUT) glutSwapBuffers();
    }
    
    void InteractiveWindow::ComputePixelBuffer(int* devicePixelBuffer)
    {
        totalFrames++;
        WriteLine(std::to_string(totalFrames));
        FillBuffer(devicePixelBuffer, backFill, height, width);
    }
    
    void InteractiveWindow::DrawTexture(void)
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
        glEnable(GL_TEXTURE_2D);
        glBegin(GL_QUADS);
        glTexCoord2f(0.0f, 0.0f); glVertex2f(0, 0);
        glTexCoord2f(0.0f, 1.0f); glVertex2f(0, height);
        glTexCoord2f(1.0f, 1.0f); glVertex2f(width, height);
        glTexCoord2f(1.0f, 0.0f); glVertex2f(width, 0);
        glEnd();
        glDisable(GL_TEXTURE_2D);
    }
    
    void InteractiveWindow::InitializePixelBuffer(void)
    {
        pixelBufferInitialized = true;
        glGenBuffers(1, &pbo);
        glBindBuffer(GL_PIXEL_UNPACK_BUFFER, pbo);
        glBufferData(GL_PIXEL_UNPACK_BUFFER, 4*width*height*sizeof(GLubyte), 0,GL_STREAM_DRAW);
        glGenTextures(1, &tex);
        glBindTexture(GL_TEXTURE_2D, tex);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        cudaGraphicsGLRegisterBuffer(&cuda_pbo_resource, pbo, cudaGraphicsMapFlagsWriteDiscard);
    }
    
    void InteractiveWindow::SetOrthogonal(void)
    {
        gluOrtho2D(0, width, height, 0);
    }
    
    void InteractiveWindow::InitializeGLUT(void)
    {
        glutInit(&dummyArgC, dummyArgV);
        glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE);
        glutInitWindowSize(width, height);
        glutCreateWindow(title.c_str());
#ifndef __APPLE__
        glewInit();
#endif
    }
    
    void InteractiveWindow::Destroy(void)
    {
        if (pixelBufferInitialized && hasRun)
        {
            if (pbo)
            {
                WriteLine("Destroy \"" + title + "\"...");
                pixelBufferInitialized = false;
                cudaGraphicsUnregisterResource(cuda_pbo_resource);
                glDeleteBuffers(1, &pbo);
                glDeleteTextures(1, &tex);
                WriteLine("Done");
            }
        }
    }
    
    InteractiveWindow::~InteractiveWindow(void)
    {
        Destroy();
    }
    
    void InteractiveWindow::Write(std::string message)
    {
        if (allowOutput)
        {
            std::cout << writeStyle << message;
        }
    }
    
    void InteractiveWindow::WriteLine(std::string message)
    {
        if (allowOutput)
        {
            std::cout << writeStyle << message << std::endl;
        }
    }
}