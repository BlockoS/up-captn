/* 
 *           DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 *                    Version 2, December 2004
 *  
 * Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
 * 
 * Everyone is permitted to copy and distribute verbatim or modified
 * copies of this license document, and changing it is allowed as long
 * as the name is changed.
 *  
 *            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 *   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 *  
 *  0. You just DO WHAT THE FUCK YOU WANT TO.
 */
/* 
 * Simple and stupid image management.
 * author : MooZ
 */
#ifndef IMAGE_H
#define IMAGE_H

#include <stdint.h>

typedef struct
{
    uint8_t *data;
    int width;
    int height;
    int bytes_per_pixel;
    
    uint8_t *palette;
    int color_count;
} Image;

/**
 * Create image.
 **/
int create_image(Image* img, int width, int height, int bpp, int color_count);

/**
 * Destroy image.
 **/
void destroy_image(Image* img);

#endif /* IMAGE_H */