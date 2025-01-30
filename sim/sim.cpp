#include <SDL3/SDL.h>
#include <verilated.h>

#include "VRaster.h"

struct RGBA {
    uint8_t a;
    uint8_t b;
    uint8_t g;
    uint8_t r;
};

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    auto raster = std::make_unique<VRaster>();

    raster->clock = 0;
    raster->reset = 1;
    raster->eval();
    raster->clock = 1;
    raster->eval();
    raster->clock = 0;
    raster->reset = 0;
    raster->eval();

    constexpr int WIDTH = 640;
    constexpr int HEIGHT = 480;
    SDL_Init(SDL_INIT_VIDEO);
    auto window = SDL_CreateWindow("Raster II Simulator", WIDTH, HEIGHT, 0);
    auto renderer = SDL_CreateRenderer(window, nullptr);
    auto texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBA8888, SDL_TEXTUREACCESS_STREAMING, WIDTH, HEIGHT);

    RGBA framebuffer[WIDTH * HEIGHT];
    while (true) {
        if (raster->io_de) {
            RGBA &pix = framebuffer[WIDTH * raster->io_y + raster->io_x];
            pix.r = raster->io_vga_r << 4;
            pix.g = raster->io_vga_g << 4;
            pix.b = raster->io_vga_b << 4;
            pix.a = 0xFF;
        }

        if (raster->io_x == 0 && raster->io_y == HEIGHT) {
            SDL_Event event;
            if (SDL_PollEvent(&event)) {
                if (event.type == SDL_EVENT_QUIT) {
                    break;
                }
            }

            SDL_UpdateTexture(texture, nullptr, framebuffer, WIDTH * sizeof(RGBA));
            SDL_RenderClear(renderer);
            SDL_RenderTexture(renderer, texture, nullptr, nullptr);
            SDL_RenderPresent(renderer);
        }

        raster->clock = 1;
        raster->eval();
        raster->clock = 0;
        raster->eval();
    }

    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
