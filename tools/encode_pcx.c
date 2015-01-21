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
 * author : MooZ
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#include "image.h"
#include "pcx.h"

/**
 * Encode a 16 colors pcx file.
 **/
 int encode_img(Image* src, FILE* out)
 {
    int y, x, k, l;
    uint8_t byte;
    size_t nwritten;
    uint8_t tile[32];
    uint8_t *dest;
    
    if((src->height & 7) || (src->width & 7))
    {
        fprintf(stderr, "Invalid image size. The image size must be a multiple of 8.\n");
        return 0;
    }
    
    for(y=0; y<src->height; y+=8)
    {
        for(x=0; x<src->width; x+=8)
        {
            dest = tile;
            memset(tile, 0, 32);
            
            for(k=0; k<8; k++, dest+=2)
            {
                for(l=0; l<8; l++)
                {
                    byte = src->data[(x + l + ((y + k) * src->width))];
                    if(byte >= 16)
                    {
                        fprintf(stderr, "Invalid input. The image must contain at most 16 colors!\n");
                        return 0;
                    }

                    dest[ 0] |= ((byte   ) & 0x01) << (7-l);
                    dest[ 1] |= ((byte>>1) & 0x01) << (7-l);
                    dest[16] |= ((byte>>2) & 0x01) << (7-l);
                    dest[17] |= ((byte>>3) & 0x01) << (7-l);
                }
            }
            
			nwritten = fwrite( tile, 1, 32, out );
            if(nwritten != 32)
            {
                fprintf(stderr, "Failed to write current tile!\n");
                return 0;
            }
        }
    }
    
    return 1;
 }
 
 int main(int argc, char** argv)
 {
    Image img;
    FILE *out;
    char *out_filename;
    size_t out_len;
    int ret, offset;
    int err = 1;
  
    if(argc != 3)
    {
        fprintf(stderr, "Usage : %s pcx out\n", argv[0]);
        goto err_0;
    }

    out_len = strlen(argv[2]);
    out_filename = (char*)malloc(out_len + 5);
    if(out_filename == NULL)
    {
        fprintf(stderr, "Failed to allocate memory: %s\n", strerror(errno));
        goto err_1;
    }

    ret = pcx_load(argv[1], &img);
    if(!ret)
    {
        goto err_2;
    }
    
    if((img.bytes_per_pixel != 1) && (img.color_count != 256))
    {
        fprintf(stderr, "Invalid pcx file %s.\n", argv[1]);
        goto err_2;
    }

    strcpy(out_filename, argv[2]);
    strcpy(out_filename+out_len, ".dat");
    
    out = fopen(out_filename, "wb");
    if(out == NULL)
    {
        fprintf(stderr, "Failed to open %s : %s\n", out_filename, strerror(errno));
        goto err_2;
    }

    /* Output data */
    ret = encode_img(&img, out);
    if(!ret)
    {
        goto err_3;
    }
    
    fclose(out);

    strcpy(out_filename+out_len, ".pal");
    
    out = fopen(out_filename, "wb");
    if(out == NULL)
    {
        fprintf(stderr, "Failed to open %s : %s\n", out_filename, strerror(errno));
        goto err_2;
    }

    /* Output palette */
    for(offset=0; offset<16*3; offset+=3)
    {
        uint8_t r, g, b, color[2];
        
        r = img.palette[offset  ] >> 5;
        g = img.palette[offset+1] >> 5;
        b = img.palette[offset+2] >> 5;
        
        color[0] = b | (r << 3) | (g << 6);
        color[1] = (g >> 2) & 1;
                
        fwrite( color, 1, 2, out );
    }
       
    err = 0;
err_3:     
    fclose(out);    
err_2:
    destroy_image(&img);
err_1:
    free(out_filename);
err_0:
    return err;
}