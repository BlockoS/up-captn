#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void outputTable(FILE *out, const char* name, const uint8_t* table, size_t len)
{
    unsigned int i, j;
    fprintf(out, "%s:\n", name);
    for(i=0; (i<16) && len; i++)
    {
        fprintf(out, "\t.db ");
        for(j=0; (j<16) && len; j++)
        {
            len--;
            fprintf(out, "%3d%c", table[j+(i*16)], ((j<15) && len)?',':'\n');
        }
    }
}

int main()
{
    FILE *out;
    uint8_t gradient_lo[32], gradient_hi[32];
    unsigned int i;
    
    uint8_t first[3] = {6,6,5};
    uint8_t last[3]  = {1,1,1};
    
    float r,g,b;
    float dr, dg, db;
    
    r = first[0];
    g = first[1];
    b = first[2];
    
    dr = (last[0]-first[0]) / 16.0;
    dg = (last[1]-first[1]) / 16.0;
    db = (last[2]-first[2]) / 16.0;
    
    for(i=0; i<16; i++)
    {
        uint8_t v[3];
        uint16_t col;

        v[0] = (uint8_t)r;
        v[1] = (uint8_t)g;
        v[2] = (uint8_t)b;
        
        col = (v[0] & 0x07) | ((v[0] & 0x07)<<3) | ((v[0] & 0x07)<<6);
        
        gradient_lo[i] = col & 0xff;
        gradient_hi[i] = (col >> 8) & 0xff;
        r+=dr;
        g+=dg;
        b+=db;
    }
    
    for(i=16; i<32; i++)
    {
        gradient_lo[i] = gradient_lo[31-i];
        gradient_hi[i] = gradient_hi[31-i];
    }
    
    out = fopen("footer_gradient.inc", "wb");
        outputTable(out, "footer_gradient.lo", gradient_lo, 32);
        outputTable(out, "footer_gradient.hi", gradient_hi, 32);
    fclose(out);
    
    return 0;
}