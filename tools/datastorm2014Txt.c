#include <stdio.h>
#include <stdlib.h>

char translationTable[] =
{
     '.',  ':',  '/', '\\',  '!',  '(',  ')', 0xFF,  '-',  '?', 0xFF,  '`',  '%',
    0xE9, 0xE8, 0xFF, 0xE0, 0xEC, 0xFF, 0xF2, 0xFF, 0xF9, 0xF4, 0xFB, 0xFF, 0xFF,  
    0xE7, 0xFF, 0xFF, 0xFF,  '=',  '&',  '>',  '&', 0xFF,  '*',  '@',  '[',  ']',
     '|',  ',',  ';',  '_',  '$'
};

int main(int argc, char **argv)
{
    FILE *out;
    FILE *in;
    
    size_t charCount, tblCount;
    size_t i, j, k;
    char *txt;
    
    in = fopen(argv[1], "rb");
    
    fseek(in, 0, SEEK_END);
    charCount = ftell(in);
    fseek(in, 0, SEEK_SET);
    charCount-= ftell(in);
    
    txt = (char*)malloc(charCount);
    fread(txt, 1, charCount, in);
    fclose(in);
    
    tblCount = sizeof(translationTable) / sizeof(translationTable[0]);
    
    out = fopen("txt_datastorm2014.inc", "wb");
    fprintf(out, "txt_data_start:\n");
    for(i=0; i<charCount; )
    {
        fprintf(out, "\t.db ");
        for(k=0; (k<16) && (i<charCount); k++, i++)
        {
            unsigned int c;
            char spacer;
            
            if((txt[i] >= 'A') && (txt[i] <= 'Z'))
            { c = txt[i] - 'A'; }
            else if((txt[i] >= 'a') && (txt[i] <= 'z'))
            { c = txt[i] - 'a'; }
            else if((txt[i] >= '0') && (txt[i] <= '9'))
            { c = txt[i] - '0' + 26; }
            else if((txt[i] == ' ') || (txt[i] == '\t') || (txt[i] =='\n') || (txt[i] =='\r'))
            { c = 82; }
            else 
            {
                c = 0xff;
                for(j=0; j<tblCount; j++)
                {
                    if(txt[i] == translationTable[j])
                    {
                        c = j + 36;
                        break;
                    }
                }
                if(c == 0xff) printf("%c %d\n", txt[i], txt[i]);
            }
            spacer = ((k < 15) && (i<(charCount-1))) ? ',' : '\n';
            fprintf(out, "%3d%c",c,spacer);
        }
    }
    fprintf(out, "txt_data_end:\n");
    fclose(out);
    
    free(txt);
    
    return 0;
}