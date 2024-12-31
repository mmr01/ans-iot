/*
 * ANS Coder/Decoder
 *
 * Date: 2021-07-07
 *
 * Author: Michal Markiewicz
 * Author: Jaroslaw Duda
 */
#include <stdio.h>

#define SYMBOLS_POWER 3 // Three bits define symbol
#define SYMBOLS (1 << SYMBOLS_POWER) // Alphabet of symbols
#define R_BIG 6
#define R_SMALL (R_BIG + 1) // 2^r= 2L
#define L (1 << R_BIG) // States count: 64

#define int16_t signed short
#define uint16_t unsigned short
#define uint8_t unsigned char

#define ABSOLUTE_VALUE_SYMBOL 7
#define TEMPERATURES_COUNT 7

#define BIT_BUFFER_MAX_SIZE_IN_BYTES (((1 + MAX_TEMPERATURES_TO_ENCODE) * (6 + 14))/8)

void showHex(uint8_t *bitBuffer, int bitsInBuffer)
{
    for (int i = 0; i < bitsInBuffer; i++)
    {
        printf("%02X ", bitBuffer[i]);
    }
    printf("\n");
}

void showShortHex(uint16_t *temp, int tempCount)
{
    for (uint8_t i = 0; i < tempCount; i++)
    {
        printf("%04X", temp[i]);
    }
    printf("\n");
}

// bits to write are read from the lowest to the highest and wrote from the highest to lowest
void writeBits(uint8_t howManyBitsToWrite, uint8_t bitsToWrite, uint8_t *bitBuffer, int *bitsInBuffer)
{
    bitsToWrite = (uint8_t)(bitsToWrite & ~(0xFF << howManyBitsToWrite));
    printf("   Write:  %d#%02X\n", howManyBitsToWrite, bitsToWrite);
    bitBuffer[*bitsInBuffer] = bitsToWrite;
    *bitsInBuffer = *bitsInBuffer + 1;
}

uint8_t readBits(uint8_t howManyBitsToRead, uint8_t* bitBuffer, int* bitsInBuffer)
{
    *bitsInBuffer = *bitsInBuffer - 1;
    uint8_t bitsRead = bitBuffer[*bitsInBuffer];
    printf("    Read:  %d#%02X\n", howManyBitsToRead, bitsRead);
    return bitsRead;
}

#define SHIFT_16_BITS_VALUE_TO_14_BITS 2
#define ABS(x) ((x < 0) ? (-x) : (x))

int encode(uint16_t *temperaturesToEncode, uint8_t *bitBuffer)
{
    uint16_t nb[SYMBOLS] = { 704, 704, 416, 34, 416, 704, 704, 704 };
    int16_t start[SYMBOLS] = { -1, 0, -4, -39, 49, 60, 61, 62 };
    uint8_t encodingTable[L] = { 127, 124, 64, 72, 81, 90, 99, 108, 66, 67, 68, 69, 70, 71, 74, 75, 76, 77, 78, 79, 80, 83, 84, 85, 86, 87, 88, 89, 91, 93, 94, 95, 96, 97, 98, 100, 102, 103, 104, 105, 106, 107, 109, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 65, 73, 82, 92, 101, 110, 123, 126, 125 };
    int bitsInBuffer = 0;
#define MAX_TEMP_DIFF_FOR_SYMBOL 3
    uint8_t symbolsEncodingTemperatures[TEMPERATURES_COUNT] = {0};
    short tempCurr;
    short tempPrev = 0;
    for (int i = 0; i < TEMPERATURES_COUNT; i++)
    {
        tempCurr = (uint16_t)(temperaturesToEncode[i] >> SHIFT_16_BITS_VALUE_TO_14_BITS);
        if (i == 0)
        {
            symbolsEncodingTemperatures[i] = ABSOLUTE_VALUE_SYMBOL;
        }
        else
        {
            uint16_t diff = (uint16_t)(tempCurr - tempPrev);
            if (ABS(diff) <= MAX_TEMP_DIFF_FOR_SYMBOL)
            {
                symbolsEncodingTemperatures[i] = (uint8_t)(diff + MAX_TEMP_DIFF_FOR_SYMBOL);
            }
            else
            {
                symbolsEncodingTemperatures[i] = ABSOLUTE_VALUE_SYMBOL;
            }
        }
        tempPrev = tempCurr;
    }
    unsigned char x = L;
    unsigned char nbBits;
    for (uint8_t i = 0; i < TEMPERATURES_COUNT; i++)
    {
        uint8_t symbolToEncode = symbolsEncodingTemperatures[i];
        printf("Encoding: %x\n", symbolToEncode);
        nbBits = (x + nb[symbolToEncode]) >> R_SMALL;
        //printf("   nBits: %d\n", nbBits);
        writeBits(nbBits, x, bitBuffer, &bitsInBuffer);
        if (symbolToEncode == ABSOLUTE_VALUE_SYMBOL)
        {
            writeBits(8, (temperaturesToEncode[i] >> SHIFT_16_BITS_VALUE_TO_14_BITS) & 0xFF, bitBuffer, &bitsInBuffer);
            writeBits(6, ((temperaturesToEncode[i] >> SHIFT_16_BITS_VALUE_TO_14_BITS) >> 8) & 0x3F, bitBuffer, &bitsInBuffer);
        }
        uint8_t idx = start[symbolToEncode] + (x >> nbBits);
        if (idx <= 64)
        {
            x = encodingTable[idx];
        }
        else
        {
            printf("EncodingTable idx too big: %d \n", idx);
        }
        //printf("   new x: %d\n", x);
    }
    writeBits(R_BIG, x & (L-1), bitBuffer, &bitsInBuffer);
    return bitsInBuffer;
}

void decode(uint8_t *bitBuffer, int bitsInBuffer, uint16_t* temperaturesDecoded)
{
    uint8_t decodingTableSymbol[L] = { 2, 4, 3, 3, 3, 3, 3, 3, 2, 4, 3, 3, 3, 3, 3, 3, 3, 2, 4, 3, 3, 3, 3, 3, 3, 3, 2, 3, 4, 3, 3, 3, 3, 3, 3, 2, 3, 4, 3, 3, 3, 3, 3, 3, 2, 3, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 5, 1, 7, 6, 0 };
    uint8_t decodingTableNBits[L] = { 4, 4, 1, 1, 1, 1, 1, 1, 4, 4, 1, 1, 1, 1, 1, 1, 1, 3, 3, 1, 1, 1, 1, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6 };
    uint8_t decodingTableNewX[L] = { 32, 32, 30, 32, 34, 36, 38, 40, 48, 48, 42, 44, 46, 48, 50, 52, 54, 0, 0, 56, 58, 60, 62, 0, 1, 2, 8, 3, 8, 4, 5, 6, 7, 8, 9, 16, 10, 16, 11, 12, 13, 14, 15, 16, 24, 17, 24, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 0, 0, 0, 0, 0 };
    uint8_t symbolsDecoded[TEMPERATURES_COUNT] = {0};
    uint8_t X = readBits(R_BIG, bitBuffer, &bitsInBuffer);
    for (uint8_t i = 0; i < TEMPERATURES_COUNT; i++)
    {
        if (decodingTableSymbol[X] == ABSOLUTE_VALUE_SYMBOL)
        {
            uint16_t v = (readBits(6, bitBuffer, &bitsInBuffer) & 0x3F) << 8;
            v |= readBits(8, bitBuffer, &bitsInBuffer);
            temperaturesDecoded[i] = v;
            printf("Absolute value: %04x\n", v);
        }
        else
        {
            temperaturesDecoded[i] = 0;
        }
        symbolsDecoded[i] = decodingTableSymbol[X];
        printf("Decoding: %04x\n", decodingTableSymbol[X]);
        X = decodingTableNewX[X] + readBits(decodingTableNBits[X], bitBuffer, &bitsInBuffer);
    }
    uint16_t lastTemperature = 0;
    for (uint8_t i = 0; i < TEMPERATURES_COUNT; i++)
    {
        uint8_t idx = TEMPERATURES_COUNT - 1 - i;
        if (symbolsDecoded[idx] == ABSOLUTE_VALUE_SYMBOL)
        {
            lastTemperature = temperaturesDecoded[idx];
        }
        else
        {
            lastTemperature -= MAX_TEMP_DIFF_FOR_SYMBOL - symbolsDecoded[idx];
            temperaturesDecoded[idx] = lastTemperature;
        }
        temperaturesDecoded[idx] <<= SHIFT_16_BITS_VALUE_TO_14_BITS;
    }
    for (uint8_t i = 0; i < TEMPERATURES_COUNT >> 1; i++)
    {
        uint16_t v = temperaturesDecoded[i];
        temperaturesDecoded[i] = temperaturesDecoded[TEMPERATURES_COUNT - 1 - i];
        temperaturesDecoded[TEMPERATURES_COUNT - 1 - i] = v;
    }
}

int main(int argc, char **argv) {
    printf("ANS-C\n");

    uint16_t temperaturesToEncode[TEMPERATURES_COUNT] = { 0x1C2C,  0x1C2C,  0x1C2C, 0x1D14, 0x1D14, 0x1D14, 0x1D14 };
    uint16_t temperaturesDecoded[TEMPERATURES_COUNT];
    uint8_t bitBuffer[TEMPERATURES_COUNT * 24];
    int bitsInBuffer = encode(temperaturesToEncode, bitBuffer);
    showHex(bitBuffer, bitsInBuffer);
    showShortHex(temperaturesToEncode, TEMPERATURES_COUNT);
    decode(bitBuffer, bitsInBuffer, temperaturesDecoded);
    showShortHex(temperaturesDecoded, TEMPERATURES_COUNT);
    return 0;
}


