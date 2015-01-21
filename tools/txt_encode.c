#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdint.h>

typedef const char* const_str;
typedef const_str entry_t[4];

#define CURVE_POINTS 128

const entry_t greetings[] =
{
    {   "YOU FOUND THE",
        "HIDDEN PART!",
        NULL,
        NULL
    },
    {
        "GRAB YOUR",
        "3 FREE TICKETS",
        "WWW.DATASTORM.SE",
        "/5EKR1TT-PCE"
    },
    {
        "UP ROUGH",
        "GENESIS PROJECT",
        "DIVINE STYLERS",
        "AND TULOU",
    },
    {
        "ONCE AGAIN",
        "INVITES YOU TO",
        "DATASTORM",
        NULL
    },
    {
        "THE FINAL",
        "DATASTORM!",
        NULL,
        NULL
    },
    {
        "THE BUILDING",
        "WHERE WE HOST",
        "DATASTORM WILL",
        "BE WRECKED!",
    },
    {
        "CREDITS FOR",
        "THIS INTRO",
        "FOLLOWS...",
        NULL
    },
    {
        "CODE: MOOZ",
        "GFX: SPOT",
        "SFX: OCTAPUS",
        NULL
    },
    {
        "THE MADNESS IS",
        "GOING DOWN",
        "ON THE 14-16 OF",
        "FEBRUARY 2014",
    },
    {
        "THE TICKETS",
        "WILL BE RELEASED",
        "ON THE 24:TH OF",
        "OCTOBER AT 20:00",
    },
    {
        "SWEDISH TIME.",
        "DON'T MISS OUT!",
        "YOU WILL REGRET",
        "IT DEEPLY!",
    },
    {
        "THE LAST FEW",
        "YEARS OF",
        "DATASTORM SPEAK",
        "FOR THEMSELVES",
    },
    {
        "WE ARE NOW",
        "NORTHERN",
        "EUROPE'S",
        "LARGEST",
    },
    {
        "OLDSKOOL PARTY!",
        "DATASTORM IS THE",
        "DEFINITE PARTY",
        "FOR THE ELITE!",
    },
    {
        "THE PARTY",
        "LOCATION THAT",
        "YOU HAVE LEARNED",
        "TO LOVE IS THERE",
    },
    {
        "FOR YOU, IN THE",
        "CITY OF GBG ON",
        "THE SWEDISH WEST",
        "COAST. THE CITY",
    },
    {
        "IS EASY TO REACH",
        "THROUGH TWO",
        "INTERNATIONAL",
        "AIRPORTS,",
    },
    {
        "FERRY, TRAIN AND",
        "CAR.",
        NULL,
        NULL
    },
    {
        "THE ENTRANCE FEE",
        "IS SET TO",
        "300 SEK",
        "(ABOUT 30E).",
    },
    {
        "WE ONLY ACCEPT",
        "SWEDISH CURRENCY.",
        "THERE IS AN ATM",
        "NEARBY.",
    },
    {
        "DINNER IS",
        "INCLUDED",
        "ON SATURDAY AND",
        "BREAKFAST",
    },
    {
        "IS INCLUDED ON",
        "SATURDAY AND",
        "SUNDAY.",
        NULL
    },
    {
        "DEMO COMPOS:",
        "A500, A1200,",
        "C64, CONSOLES",
        NULL
    },
    {
        "INTRO COMPOS:",
        "AMIGA (4K, 64K,",
        "BOOTBLOCK),",
        "C64 (4K).",
    },
    {
        "MUSIC COMPOS:",
        "AMIGA (CHIP,",
        "EXE, TRACKED)",
        "C64 AND CONSOLES",
    },
    {
        "GRAPHIC COMPOS:",
        "AMIGA (PIXEL,",
        "ASCII,",
        "COLORCYCLING)",
    },
    {
        "C64 (PIXEL,",
        "PETSCII) AND",
        "CONSOLES",
        NULL,
    },
    {
        "RULES",
        "SINCE THE PARTY",
        "IS BEING HELD AT",
        "A LICENSED",
    },
    {
        "NIGHTCLUB YOU",
        "CAN'T BRING YOUR",
        "OWN BOOZE DUE TO",
        "STRICT SWEDISH",
    },
    {
        "LAWS ON ALCOHOL.",
        "HOWEVER, WE",
        "ASSURE YOU THAT",
        "YOU WILL BE",
    },
    {
        "PERFECTLY",
        "SATISFIED WITH",
        "THE IN-HOUSE",
        "ASSORTMENT OF",
    },
    {
        "BEVERAGES WHICH",
        "IS SERVED AT A",
        "VERY REASONABLE",
        "PRICE, A GLASS",
    },
    {
        "OF WINE IS 25",
        "SEK WHICH IS",
        "ABOUT 2.5 EUR.",
        "BECAUSE OF THIS",
    },
    {
        "YOU HAVE TO BE",
        "18 YEARS OR",
        "OLDER TO ENTER",
        "THE PARTY. IN",
    },
    {
        "ORDER NOT TO",
        "SHUT ANY YOUNG",
        "CREATIVE MINDS",
        "OUT FROM THE",
    },
    {
        "ACTION, WE",
        "MIGHT GRANT",
        "ACCESS TO THE",
        "PARTY FOR",
    },
    {
        "MINORS ON A",
        "CASE-TO-CASE",
        "BASIS, CONTACT",
        "US ABOUT THIS",
    },
    {
        "IF YOU ARE",
        "AFFECTED.",
        "SMOKE OUTSIDE.",
        "SMOKING IS",
    },
    {
        "ILLEGAL IN",
        "NIGHTCLUBS IN",
        "SWEDEN.",
        NULL,
    },
    {
        "DON'T FORGET",
        "TO BRING:",
        "ELECTRICITY",
        "MULTI-SOCKETS.",
    },
    {
        "REAL HARDWARE.",
        "LAPTOPS MAY",
        "ONLY BE BROUGHT",
        "INSIDE THE",
    },
    {
        "PARTYHALL FOR",
        "CROSSDEV",
        "PURPOSES.",
        NULL,
    },
    {
        "PRINTOUTS OF",
        "THE MAPS.",
        "AS IT LOOKS NOW",
        "THE BAR WON'T",
    },
    {
        "MANAGE CREDIT/",
        "DEBIT-CARDS, SO",
        "BRING CASH!",
        "AN ATM IS",
    },
    {
        "REACHABLE NEAR",
        "THE PARTYPLACE",
        NULL,
        NULL
    },
    {
        "FOR MORE DETAILED",
        "INFO GO TO",
        "WWW.DATASTORM.SE",
        NULL
    },
    {
        "GREETINGS TO:",
        NULL,
        NULL,
        NULL
    },
    {
        "AFRIKA ",
        "BLACK MAIDEN",
        "BOOZE DESIGNS",
        "BOOZOHOLICS",
    },
    {
        "CENSOR DESIGN",
        "CTRL-ALT-TEST",
        "DA JORMAS, DCS",
        "DEKADENCE, DEPTH",
    },
    {
        "DIVINE STYLERS,",
        "DUREX, ELUDE,",
        "EPHIDRENA,",
        "FIT,",
    },
    {
        "FOCUS DESIGN ",
        "FUNKTION",
        "GENESIS PROJECT",
        "HACK'N'TRADE",
    },
    {
        "HAUJOBB, HBB",
        "INSTINCT, IRIS",
        "JOSSYSTEM, JUDAS",
        "LAXATIVE EFFECTS",
    },
    {
        "LOONIES, MANKIND",
        "MAWI, NATURE,",
        "NUKLEUS,",
        "ONSALA SECTOR",
    },
    {
        "ONSLAUGHT",
        "OUTBREAK",
        "PLANET JAZZ",
        "PANDA DESIGN,",
    },
    {
        "PUNK FLOYD",
        "RNO, RAZOR 1911",
        "UNSTABLE LABEL",
        "TPOLM, TRAKTOR",
    },
    {
        "TRIAD, TULOU,",
        "UK SCENE ALLSTARS",
        "UNIQUE AND ZENON",
        NULL
    },
    {
        "FUCKINGS TO",
        "FAIRLIGHT AND",
        "TBL FOR NEVER",
        "GREETING US.",
    },
    {
        "SEE YOU AT",
        "DATASTORM!!!",
        NULL,
        NULL
    }
};

const size_t charLen[] =
{
    //   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P
        14, 14, 12, 14, 12, 12, 14, 14,  6, 14, 14, 12, 14, 14, 12, 14,
    //   Q   R   S   T   U   V   W   X   Y   Z   '   (   )   0   1   2
        14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 10, 14, 14, 14, 10, 14,
    //   3   4   5   6   7   8   9   ?   !   -   +   .   ,   :   /   
        14, 14, 14, 14, 14, 14, 14, 14, 12, 14, 14, 10, 10, 12, 14
};

const size_t maxLen = 16;
const size_t spriteWidth  = 8;
const size_t spriteHeight = 8;
const size_t spriteHSpacing = 8;
const size_t spriteVSpacing = 16;
const size_t screenWidth  = 256;
const size_t screenHeight = 240;
const size_t yoff = 64;
const size_t xoff = 16;

void PrintArray(FILE* out, const char name[], int16_t tab[CURVE_POINTS])
{
    int i;
    char c;
    fprintf(out, "%s:\n", name);
    for(i=0; i<CURVE_POINTS; i++)
    {
        if((i%8) == 0)
        {
            fprintf(out, "\t.dw ");
        }
        c = ((i+1)%8) ? ',' : '\n';
        
        fprintf(out, "%4d%c", tab[i], c);
    }
}

void GenerateCurve()
{
    FILE *txtOut;
    int i;
    int pmax = CURVE_POINTS/2-1;
    int16_t x[CURVE_POINTS], y[CURVE_POINTS];
    
    for(i=0; i<CURVE_POINTS; i++)
    {
        double s = (pmax - i) / (double)pmax;
        double t = 4.0 * M_PI * s;
        double sn = sin(t);
        double cs = cos(t);
        double a =  s * sn * 128.0;
        double b = -s * cs * 160.0;
        x[i] = (int16_t)rint(a);
        y[i] = (int16_t)rint(b);
    }

    txtOut = fopen("curve.dat", "wb");
    for(i=0; i<CURVE_POINTS; i++)
    {
        fprintf(txtOut, "%d    %d\n", x[i], y[i]);
    }
    fclose(txtOut);

    txtOut = fopen("curve.inc", "wb");
    fprintf(txtOut, "SPIRAL_POINT_COUNT = %d\n", CURVE_POINTS); 
    PrintArray(txtOut, "spiral_x", x);
    PrintArray(txtOut, "spiral_y", y);
    fclose(txtOut);
}

int main()
{
    size_t elementCount = sizeof(greetings) / sizeof(greetings[0]);
    int i, j, k;
    size_t x, y;
    size_t len;
    size_t ymax;
    size_t w;
    unsigned char buffer[256];
    
    FILE *txtOut;
    
    txtOut = fopen("invtro_txt.inc", "wb");
    fprintf(txtOut, "TXT_COUNT = %d\n"
                    "TXT_V_SPACING = %d\n"
                    "TXT_H_SPACING = %d\n"
                    "TXT_SPACING = %d\n"
                    "txtData:\n", elementCount, spriteVSpacing, spriteHSpacing*2, spriteHSpacing);
                
    ymax = 0;
    for(i=0; i<elementCount; i++)
    {
        for(j=0; j<4; j++)
        {
            if(greetings[i][j] == NULL)
            {
                break;
            }
        }
        
        y = (screenHeight - j*spriteVSpacing) /2;
        if(y > ymax) { ymax = y; }

        fprintf(txtOut, "\t.db ");
        fprintf(txtOut, "%3d, %3d\n", j, y+yoff);
 
        for(j=0; j<4; j++)
        {
            if(greetings[i][j] == NULL)
            {
                break;
            }
            
            len = strlen(greetings[i][j]);
            
            fprintf(txtOut, "\t.db ");
            w = 0;
            for(k=0; k<len; k++)
            {
                unsigned char c = greetings[i][j][k];
                if((c >= 'A') && (c <= 'Z'))
                {
                    c -= 'A';
                }
                else if((c >= '0') && (c <= '9'))
                {
                    c = (c - '0') + 'Z'-'A' + 4;
                }
                else if(c == '\'')
                {
                    c = (c - '\'') + 'Z'-'A' + 1;
                }
                else if(c == '(')
                {
                    c = (c - '(') + 'Z'-'A' + 2;
                }
                else if(c == ')')
                {
                    c = (c - ')') + 'Z'-'A' + 3;
                }
                else if(c == '?')
                {
                    c = 39;
                }
                else if(c == '!')
                {
                    c = 40;
                }
                else if(c == '-')
                {
                    c = 41;
                }
                else if(c == '+')
                {
                    c = 42;
                }
                else if(c == '.')
                {
                    c = 43;
                }
                else if(c == ',')
                {
                    c = 44;
                }
                else if(c == ':')
                {
                    c = 45;
                }
                else if(c == '/')
                {
                    c = 46;
                }
                else
                {
                    c = 0xfe;
                }
                buffer[k] = c;
                
                if(c != 0xfe)
                {
                    w += charLen[c]/2;
                }
                else
                {
                    w += spriteHSpacing/2;
                }
            }
            
            x = (screenWidth - w)/2;
            fprintf(txtOut, "%3d, ", x+xoff);
            
            for(k=0; k<len; k++)
            {
                fprintf(txtOut, "$%02x,", buffer[k]);
            }
            fprintf(txtOut, "$ff\n");
        }        
    }

    fclose(txtOut);
    
    //GenerateCurve();
    
    return 0;
}
