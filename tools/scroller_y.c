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
    uint8_t yTable[256];
    unsigned int i;
    
    for(i=0; i<256; i++)
    {
        yTable[i] = round(32 * (1.0 + cos(6.0*i*M_PI/256.0)) / 2.0);
    }
    
    out = fopen("txt_scroll_y.inc", "wb");
        outputTable(out, "txt_scroll_y", yTable, 256);
    fclose(out);
    
    return 0;
}