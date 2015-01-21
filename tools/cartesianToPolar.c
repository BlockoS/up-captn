#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

typedef float vec2[2];

typedef struct
{
    unsigned int count;
    unsigned int offset; 
} Mesh;

typedef struct
{
    unsigned int first;
    unsigned int last;
} Group;

vec2 pointData[] =
{
    { 0.50f, 0.50f },
    { 1.00f, 0.50f },
    { 1.00f, 1.00f },
    { 0.50f, 1.00f },
    
    {-0.50f,-0.50f },
    {-1.00f,-0.50f },
    {-1.00f,-1.00f },
    {-0.50f,-1.00f },
    
    { 1.00f,-0.50f },
    { 0.50f,-0.50f },
    { 0.50f,-1.00f },
    { 1.00f,-1.00f },
    
    {-1.00f, 0.50f },
    {-0.50f, 0.50f },
    {-0.50f, 1.00f },
    {-1.00f, 1.00f },

    {-0.25f, 1.50f+0.25f },
    {-0.25f, 0.25f+0.25f },
    {-1.50f, 0.25f+0.25f },
    {-1.50f,-0.25f+0.25f },
    {-0.25f,-0.25f+0.25f },
    {-0.25f,-1.50f+0.25f },
    { 0.25f,-1.50f+0.25f },
    { 0.25f,-0.25f+0.25f },
    { 1.50f,-0.25f+0.25f },
    { 1.50f, 0.25f+0.25f },
    { 0.25f, 0.25f+0.25f },
    { 0.25f, 1.50f+0.25f },    
    
    { 1.25f, 0.25f },
    { 1.00f, 0.75f },
    { 0.50f, 1.25f },
    { 0.00f, 1.50f },
    {-0.25f, 1.50f },
    {-0.25f, 1.25f },
    {-0.50f, 0.75f },
    {-1.00f, 0.25f },
    {-1.25f, 0.00f },
    {-1.00f,-0.25f },
    {-0.50f,-0.75f },
    {-0.25f,-1.25f },
    {-0.25f,-1.50f },
    { 0.00f,-1.50f },
    { 0.50f,-1.25f },
    { 1.00f,-0.75f },
    { 1.25f,-0.25f },
    
    {-0.75f, 0.50f },
    {-0.25f, 1.00f },
    {-0.75f, 1.50f },
    {-1.25f, 1.00f },
    
    { 0.00f,-1.50f },
    { 0.50f,-1.50f },
    { 0.50f,-1.00f },
    { 1.00f,-1.00f },
    { 1.00f,-0.50f },
    { 1.50f,-0.50f },
    { 1.50f, 0.00f },
    { 0.50f, 0.00f },
    { 0.50f,-0.50f },
    { 0.00f,-0.50f },    
};

Mesh objects[] = 
{
    { .count= 4, .offset=0  },
    { .count= 4, .offset=4  },
    { .count= 4, .offset=8  },
    { .count= 4, .offset=12 },
    { .count=12, .offset=16 },
    { .count=17, .offset=28 },
    { .count=4,  .offset=45 },
    { .count=10, .offset=49 },
};

Group groups[] =
{
    { .first=0, .last=4 },  // cubes
    { .first=4, .last=5 },  // cross
    { .first=6, .last=8 },
    { .first=5, .last=6 },
};

float g_x = 240.0f;
float g_scale = 32.0f;

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

void cartesianToPolar(vec2 point, float *radius, float *angle)
{
    *radius = sqrt((point[0]*point[0]) + (point[1]*point[1]));
    *angle  = atan2(point[1], point[0]);
}

int main()
{
    FILE *out;
    
    size_t i;
    float radius, angle;
    
    uint8_t *x,*t,*r;
    
    size_t pointCount  = sizeof(pointData) / sizeof(pointData[0]);
    size_t objectCount = sizeof(objects) / sizeof(objects[0]);
    size_t groupCount = sizeof(groups) / sizeof(groups[0]);
    
    x = (uint8_t*)malloc(pointCount*3);
    t = x + pointCount;
    r = t + pointCount;
    
    for(i=0; i<pointCount; i++)
    {
        cartesianToPolar(pointData[i], &radius, &angle);
        
        if(angle < 0.0f)
        {
            angle = 2.0*M_PI + angle;
        }
        angle = angle * 256.0 / (2.0*M_PI);
        
        x[i] = (unsigned char)round(g_x);
        t[i] = (unsigned char)round(angle);
        r[i] = (unsigned char)round(g_scale*radius);
    }
 
    out = fopen("mesh.inc", "wb");
        outputTable(out, "mesh_x", x, pointCount);
        outputTable(out, "mesh_angle", t, pointCount);
        outputTable(out, "mesh_radius", r, pointCount);        
        
        fprintf(out, "mesh_angle_ptr.lo:\n");
        for(i=0; i<objectCount; i++)
        {
            fprintf(out, "\t.db low(mesh_angle+%d)\n", objects[i].offset);
        }
        fprintf(out, "mesh_angle_ptr.hi:\n");
        for(i=0; i<objectCount; i++)
        {
            fprintf(out, "\t.db high(mesh_angle+%d)\n", objects[i].offset);
        }

        fprintf(out, "mesh_radius_ptr.lo:\n");
        for(i=0; i<objectCount; i++)
        {
            fprintf(out, "\t.db low(mesh_radius+%d)\n", objects[i].offset);
        }
        fprintf(out, "mesh_radius_ptr.hi:\n");
        for(i=0; i<objectCount; i++)
        {
            fprintf(out, "\t.db high(mesh_radius+%d)\n", objects[i].offset);
        }

        fprintf(out, "mesh_point_count:\n\t.db ");
        for(i=0; i<objectCount; i++)
        {
            fprintf(out, "%d%c", objects[i].count, (i<(objectCount-1)) ? ',' : '\n');
        }
        
        fprintf(out, "mesh_first:\n\t.db ");
        for(i=0; i<groupCount; i++)
        {
            fprintf(out, "%d%c", groups[i].first, (i<(groupCount-1)) ? ',' : '\n');
        }

        fprintf(out, "mesh_last:\n\t.db ");
        for(i=0; i<groupCount; i++)
        {
            fprintf(out, "%d%c", groups[i].last, (i<(groupCount-1)) ? ',' : '\n');
        }
    fclose(out);
    
    free(x);
    return 0;
}