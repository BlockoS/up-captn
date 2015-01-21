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
 * Simple pcx reader.
 * author : MooZ
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <errno.h>

#include "image.h"

#define get16(x) ((x[1]<<8)|x[0])

typedef struct
{
    union
    {
        struct
        {
          uint8_t manufacturer;
          uint8_t version;
          uint8_t encoding;
          uint8_t bitsperpixel;
          uint8_t xmin[2],  ymin[2];
          uint8_t xmax[2],  ymax[2];
          uint8_t hDpi[2],  vDpi[2];
          uint8_t colormap[48];
          uint8_t reserved;
          uint8_t nplanes;
          uint8_t bitsPerLine[2];
          uint8_t paletteInfo[2];
          uint8_t hscreenSize[2], vscreenSize[2];
          uint8_t filler[54];
        } info;
        uint8_t raw[128];
    };
}PCX_header;

/**
 * Read header.
 **/
static int pcx_read_header(FILE* input, Image* dest)
{
    PCX_header header;
    size_t nread;
    nread = fread(header.raw, 1, 128, input);
    if(nread != 128)
    {
       return 0;
    }
    
    dest->bytes_per_pixel = header.info.nplanes;
    if((dest->bytes_per_pixel != 3) && (dest->bytes_per_pixel != 1))
    {
       return 0;
    }

    dest->width  = get16(header.info.xmax) - get16(header.info.xmin) + 1;
    dest->height = get16(header.info.ymax) - get16(header.info.ymin) + 1;

    return 1;
}

/**
 * Read data.
 **/
static int pcx_read_data(FILE* input, Image* dest)
{
    uint8_t *row, *out;
    uint8_t byte;

    size_t nread;

    int x, y, component;

    for(y=0; y<dest->height; y++)
    {
        row = dest->data + y * dest->width * dest->bytes_per_pixel;
        
        for(component=0; component<dest->bytes_per_pixel; component++)
        {
            for(x=0, out=row; x<dest->width; )
            {
                nread = fread(&byte, 1, 1, input);
                if(nread != 1)
                {
                    fprintf(stderr, "Read error: %s\n", strerror(errno));
                    return 0;
                }
                
                /* Check for RLE encoding. */
                if((byte & 0xC0) == 0xC0)
                {
                    uint8_t count, data;
                    nread = fread(&data, 1, 1, input);
                    if(nread != 1)
                    {
                        fprintf(stderr, "Read error: %s\n", strerror(errno));
                        return 0;
                    }

                    for(count=byte&0x3f; count && (x<dest->width); count--)
                    {
                       *out = data;
                       out += dest->bytes_per_pixel;
                       x++;
                    }
                   
                    if(count && (x >= dest->width))
                    {
                        fprintf(stderr, "Read aborted: malformed PCX data!\n");
                        return 0;
                    }
                }
                else
                {
                    *out = byte;
                    out += dest->bytes_per_pixel;
                    x++;
                }
            }
            row++;
        }
    }

    return 1;
}

/**
 * Read palette.
 **/
static int pcx_read_palette(FILE* input, Image* dest)
{
    uint8_t dummy;
    size_t nread;
    
    fseek(input, SEEK_END, -769);
    nread = fread(&dummy, 1, 1, input);
    if(nread != 1)
    {
        fprintf(stderr, "Read error: %s", strerror(errno));
        return 0;
    }
    if(dummy != 0x0C)
    {
        return 1;
    }
    
    dest->color_count = 256;
    dest->palette = (uint8_t*)malloc(dest->color_count*3*sizeof(uint8_t));
    if(dest->palette == NULL)
    {
        fprintf(stderr, "Failed to allocate palette: %s", strerror(errno));
        return 0;
    }
    
    nread = fread(dest->palette, 1, 3*dest->color_count, input);
    if(nread != 3*dest->color_count)
    {
        fprintf(stderr, "Read error: %s", strerror(errno));
        return 0;
    }
    return 1;
}

/**
 * Load a pcx image file.
 **/
int pcx_load(const char* filename, Image* dest)
{
    FILE* input;
    int ok = 0;
    
    input = fopen(filename, "rb");
    if(input == NULL)
    {
        fprintf(stderr, "Unable to open file %s: %s\n", filename, strerror(errno));
        return 0;
    }
    
    ok = pcx_read_header(input, dest);
    if(ok)
    {
        dest->data = (uint8_t*)malloc(dest->width * dest->height * dest->bytes_per_pixel * sizeof(uint8_t));
        if(dest->data != NULL)
        {
            ok = pcx_read_data(input, dest);
            if(ok)
            {
                if(dest->bytes_per_pixel == 1)
                {
                    if( !(ok = pcx_read_palette(input, dest)) )
                    {
                        fprintf(stderr, "Failed to read pcx palette from %s\n", filename);
                    }
                }
                else
                {
                    dest->palette = NULL;
                    dest->color_count = 0;
                }
            }
            else
            {
                fprintf(stderr, "Failed to read pcx data from %s\n", filename);
            }
        }
        else
        {
            fprintf(stderr, "Failed to allocate image buffer: %s\n", strerror(errno));
            ok = 0;
        }
    }
    else
    {    
        fprintf(stderr, "Failed to read pcx header from %s\n", filename);
    }
        
    if(!ok)
    {
        destroy_image(dest);
    }

    fclose(input);
    return ok;
}
