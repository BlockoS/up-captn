#include <stdio.h>
#include <stdint.h>
#include <math.h>

int main()
{
	FILE *out;
	unsigned int i, j;

    unsigned int cosTab[256];
    unsigned int sinTab[256];
   
    unsigned int divTab[256];
    
    uint8_t mulTab[512];

	float focale;
	float angle;
	float z0;
	float z;
	float radius;

    float xCenter;
    float yCenter;
    
    float width;
    float height;
    
    float aspectRatio;
    
    int scale;
    
    scale = 64;
    
    width  = 220.0f;
    height = 160.0f;
    
    aspectRatio = width / height;
    
    xCenter = 0.0f;
    yCenter = height/2.0f;
    
	radius =   1.0f;
    z0     =  -4.0f;
	focale =   280.0f;

	for(i=0; i<256; i++)
	{
		angle = M_PI * i * 2.0f / 256.0f;
		
        cosTab[i] = (unsigned int)(round(cos(angle) * scale));
        sinTab[i] = (unsigned int)(round(sin(angle) * scale));

        z = i;
        if(z > 127.0) z = z - 256.0;
        z = focale / (z/64.0f - z0);
        divTab[i] = (unsigned char)round(z);
	}
        
    for(i=0; i<512; i++)
    {
        unsigned int q = i & 0xff;
        if(q > 127) q = 256 - q;
        q = round(q*q/256.0f);
        mulTab[i] = q & 0xff;
    }

    out = fopen("./rotxTable.inc", "wb");
    
    fprintf(out, "cosTable_small:\n");
    for(i=0; i<16; i++)
    {
        fprintf(out, "\t.db ");
        for(j=0; j<16; j++)
        {
            fprintf(out, "%3d%c", cosTab[j+(i*16)], (j<15)?',':'\n');
        }
    }
    fprintf(out, "sinTable_small:\n");
    for(i=0; i<16; i++)
    {
        fprintf(out, "\t.db ");
        for(j=0; j<16; j++)
        {
            fprintf(out, "%3d%c", sinTab[j+(i*16)], (j<15)?',':'\n');
        }
    }
    fprintf(out, "divTable:\n");
    for(i=0; i<16; i++)
    {
        fprintf(out, "\t.db ");
        for(j=0; j<16; j++)
        {
            fprintf(out, "%3d%c", divTab[j+(i*16)], (j<15)?',':'\n');
        }
    }
    fprintf(out, "mulTable:\n");
    for(i=0; i<32; i++)
    {
        fprintf(out, "\t.db ");
        for(j=0; j<16; j++)
        {
            fprintf(out, "$%02x%c", mulTab[j+(i*16)], (j<15)?',':'\n');
        }
    }
    fclose(out);
    
	return 0;
}
