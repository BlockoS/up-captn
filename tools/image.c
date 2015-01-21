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
#include <stdlib.h>
#include <string.h>
#include "image.h"

/**
 * Create image.
 **/
int create_image(Image* img, int width, int height, int bpp, int color_count)
{
    img->width  = width;
    img->height = height;
    img->bytes_per_pixel = bpp;
    
    img->color_count = color_count;
    
    img->data = (uint8_t*)malloc(width*height*bpp*sizeof(uint8_t));
    if(img->data == NULL)
    {
        return 0;
    }
    
    if(color_count)
    {
        img->palette = (uint8_t*)malloc(color_count*3*sizeof(uint8_t));
        if(img->palette == NULL)
        {
            free(img->data);
            img->data = NULL;
            return 0;
        }
    }
    else
    {
        img->palette = NULL;
    }
    
    return 1;
}

/**
 * Destroy image.
 **/
void destroy_image(Image* img)
{
    if(img->data != NULL)
    {
        free(img->data);
    }
    
    if(img->palette != NULL)
    {
        free(img->palette);
    }
    
    memset(img, 0, sizeof(Image));
}