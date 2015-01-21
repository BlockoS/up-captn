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
 * Encode sprite
 * author : MooZ
 */ 
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include <string.h>

#define get16(x) ((x[1]<<8)|x[0])

typedef struct {
  unsigned char       manufacturer;
  unsigned char       version;
  unsigned char       encoding;
  unsigned char       bitsperpixel;
  unsigned char       xmin[2],  ymin[2];
  unsigned char       xmax[2],  ymax[2];
  unsigned char       hDpi[2],  vDpi[2];
  unsigned char       colormap[48];
  unsigned char       reserved;
  unsigned char       nplanes;
  unsigned char       bitsPerLine[2];
  unsigned char       paletteInfo[2];
  unsigned char       hscreenSize[2], vscreenSize[2];
  unsigned char       filler[54];
}PCX_header;

int main(int argc, char *argv[])
{
    FILE* input;
    FILE* output;

    PCX_header     header;
    unsigned char* buffer;
    unsigned char* ptr;
    unsigned char* pptr;
    unsigned char* nextLine;
    uint16_t out[32*4];
    unsigned int   w, h;

    unsigned int i, j, l, k;

    unsigned char c, p;

    if(argc < 3) {
        fprintf(stderr,"Usage: %s input.pcx output.bin\n",argv[0]);
        return 1;
    }

    /* Read pcx file */
    if(!(input = fopen(argv[1],"rb"))) {
        fprintf(stderr,"Error while loading %s\n",argv[1]);
        return 1;
    }


    fread(&header, 1, sizeof(PCX_header), input);

    if((header.bitsperpixel * header.nplanes) != 8) {
        fprintf(stderr,"%s must be a 8bpp pcx image\n",argv[1]);
        fclose(input);
        return 1;
    }

    w = get16(header.xmax) - get16(header.xmin) + 1;
    h = get16(header.ymax) - get16(header.ymin) + 1;

    buffer = (unsigned char*)malloc(w * h * sizeof(unsigned char));
    assert(buffer);

    ptr = buffer;
    for(i=0; i<h; ++i) {
                nextLine = ptr + w;
                pptr = ptr;

				p = 0;
				do
				{
					fread(&c, 1, sizeof(unsigned char), input);
					if ((c & 0xC0) == 0xC0) {
							j = c & 0x3F;
							fread(&c, 1, sizeof(unsigned char), input);

							while (j--) {
									*pptr = c;
									pptr++;
									if (pptr >= nextLine) {
											p++;
											pptr = ptr + p;
									}
							}
					} else {
							*pptr = c;
							pptr++;
							if (pptr >= nextLine) {
									p++;
									pptr = ptr + p;
							}
					}
				} while(!p);
                ptr = nextLine;
    }

	fseek(input, SEEK_END, -769);
    fread(&c, 1, sizeof(unsigned char), input);

	for(i=0; i<16; i++)
	{
		uint8_t col[3], r, g, b, n;
		n = fread(col, 1, 3, input);
	
        r = col[0] >> 5;
		g = col[1] >> 5;
		b = col[2] >> 5;

		printf("$%02x, $%02x, \n", (b | (r << 3) | (g << 6)) & 0xff, (g >> 2));
	}

    fclose(input);

    ////////////////////////////////////////////////////////////////////

	/* Open output */
	if(!(output = fopen(argv[2],"wb"))) {
	   fprintf(stderr,"Error while opening %s\n",argv[2]);
		return 1;
	}
	
	for(j=0; j<h; j+=16)
	{
		for(i=0; i<w; i+=16)
		{
			ptr  = buffer + i + (j*w);
			memset(out, 0, 32*4);
			for(l=0; l<16; ++l, ptr+=w)
			{
				for(k=0; k<16; ++k)
				{
					out[     l] |= ((ptr[k] & 0x01)     ) << (15 - k); 
					out[16 + l] |= ((ptr[k] & 0x02) >> 1) << (15 - k); 
					out[32 + l] |= ((ptr[k] & 0x04) >> 2) << (15 - k); 
					out[48 + l] |= ((ptr[k] & 0x08) >> 3) << (15 - k); 
				}
			}
			fwrite( out, 1, 32*4, output );
		}
	}

	free(buffer);
	
    fclose(output);
	
    return 0;
}
