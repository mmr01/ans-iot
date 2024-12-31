/*
 * ANS Coder/Decoder
 *
 * Date: 2021-08-12
 *
 * Author: Michal Markiewicz
 */

using System;


namespace ANS
{
    public class Compressor
    {
        //const byte SYMBOLS_POWER = 3; // Three bits define symbol
        //const byte SYMBOLS = (1 << SYMBOLS_POWER); // Alphabet of symbols
        const byte R_BIG = 6;
        const byte R_SMALL = (R_BIG + 1); // 2^r= 2L
        const byte L = (1 << R_BIG); // States count: 64
        const byte MAX_TEMP_DIFF_FOR_SYMBOL = 3;
        const byte ABSOLUTE_VALUE_SYMBOL = 7;
        const byte SHIFT_16_BITS_VALUE_TO_14_BITS = 2;
        //static readonly byte[] symbols = { 2, 4, 3, 3, 3, 3, 3, 3, 2, 4, 3, 3, 3, 3, 3, 3, 3, 2, 4, 3, 3, 3, 3, 3, 3, 3, 2, 3, 4, 3, 3, 3, 3, 3, 3, 2, 3, 4, 3, 3, 3, 3, 3, 3, 2, 3, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 5, 1, 7, 6, 0 };
        static readonly short[] nb = { 704, 704, 416, 34, 416, 704, 704, 704 };
        static readonly short[] start = { -1, 0, -4, -39, 49, 60, 61, 62 };
        static readonly byte[] encodingTable = { 127, 124, 64, 72, 81, 90, 99, 108, 66, 67, 68, 69, 70, 71, 74, 75, 76, 77, 78, 79, 80, 83, 84, 85, 86, 87, 88, 89, 91, 93, 94, 95, 96, 97, 98, 100, 102, 103, 104, 105, 106, 107, 109, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 65, 73, 82, 92, 101, 110, 123, 126, 125 };
        static readonly byte[] decodingTableSymbol = { 2, 4, 3, 3, 3, 3, 3, 3, 2, 4, 3, 3, 3, 3, 3, 3, 3, 2, 4, 3, 3, 3, 3, 3, 3, 3, 2, 3, 4, 3, 3, 3, 3, 3, 3, 2, 3, 4, 3, 3, 3, 3, 3, 3, 2, 3, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 5, 1, 7, 6, 0 };
        static readonly byte[] decodingTableNBits = { 4, 4, 1, 1, 1, 1, 1, 1, 4, 4, 1, 1, 1, 1, 1, 1, 1, 3, 3, 1, 1, 1, 1, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 3, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 6, 6, 6 };
        static readonly byte[] decodingTableNewX = { 32, 32, 30, 32, 34, 36, 38, 40, 48, 48, 42, 44, 46, 48, 50, 52, 54, 0, 0, 56, 58, 60, 62, 0, 1, 2, 8, 3, 8, 4, 5, 6, 7, 8, 9, 16, 10, 16, 11, 12, 13, 14, 15, 16, 24, 17, 24, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 0, 0, 0, 0, 0 };

        public static void WriteBits(int howManyBitsToWrite, byte bitsToWrite, byte[] bitBuffer, ref int bitsInBuffer)
        {
            if ((8 - (bitsInBuffer % 8)) >= howManyBitsToWrite)
            {
                bitBuffer[bitsInBuffer / 8] =
                    Convert.ToByte((((bitsToWrite << (8 - howManyBitsToWrite)) & 0xff) >> (bitsInBuffer % 8)) |
                                   bitBuffer[bitsInBuffer / 8]);
            }
            else
            {
                bitBuffer[bitsInBuffer / 8] = Convert.ToByte((((bitsToWrite << (8 - howManyBitsToWrite)) & 0xff) >> (bitsInBuffer % 8)) | bitBuffer[bitsInBuffer / 8]);
                bitBuffer[bitsInBuffer / 8 + 1] = Convert.ToByte((bitsToWrite << (8 - howManyBitsToWrite + (8 - (bitsInBuffer % 8)))) & 0xff);
            }

            bitsInBuffer += howManyBitsToWrite;
        }
        public static byte ReadBits(int howManyBitsToRead, byte[] bitBuffer, ref int bitsInBuffer)
        {
            int bufferBits = bitsInBuffer;
            bitsInBuffer -= howManyBitsToRead;
            return ((bufferBits % 8) >= howManyBitsToRead) ? Convert.ToByte(((bitBuffer[bufferBits / 8] << ((bufferBits % 8) - howManyBitsToRead)) & 0xff) >> (8 - howManyBitsToRead)) : Convert.ToByte((bitBuffer[bufferBits / 8] >> (8 - (bufferBits % 8))) | (((bitBuffer[bufferBits / 8 - 1] << (8 - (howManyBitsToRead - (bufferBits % 8)))) & 0xff) >> (8 - howManyBitsToRead)));
        }
        public static void WriteBitsOngoing(int howManyBitsToWrite, byte bitsToWrite, byte[] bitBuffer, ref int bitsInBuffer)
        {
            bitsToWrite = (byte)(bitsToWrite & ~(-1 << howManyBitsToWrite));
            int howManyBitsAvailableInThe1StByte = 8 - (bitsInBuffer % 8);
            int howManyBitsAvailableInThe2NdByte = Math.Max(0, howManyBitsToWrite - howManyBitsAvailableInThe1StByte);
            //byte b1b = bitBuffer[bitsInBuffer >> 3];
            //byte b2b = bitBuffer[(bitsInBuffer >> 3) + 1];
            bitBuffer[bitsInBuffer >> 3] = (byte)((bitBuffer[bitsInBuffer >> 3] & ~(-1 << howManyBitsAvailableInThe1StByte)) | (bitsToWrite << (bitsInBuffer % 8)));
            bitBuffer[(bitsInBuffer >> 3) + 1] = (byte)(bitsToWrite & ~(-1 << howManyBitsAvailableInThe2NdByte));
            //byte b1a = bitBuffer[bitsInBuffer >> 3];
            //byte b2a = bitBuffer[(bitsInBuffer >> 3) + 1];
            //Console.WriteLine("    Write: {5:X2} {4:X2} <= [{7}]{1:X2} [{6}]{0:X2} < {3}#{2:X2} ", b1b, b2b, bitsToWrite, howManyBitsToWrite, b1a, b2a, bitsInBuffer >> 3, (bitsInBuffer >> 3) + 1);
            //Console.WriteLine("   Write:  {1}#{0:X2}", bitsToWrite, howManyBitsToWrite);
            bitsInBuffer += howManyBitsToWrite;
        }
        public static byte ReadBitsOngoing(int howManyBitsToRead, byte[] bitBuffer, ref int bitsInBuffer)
        {
            int howManyBitsFrom2NdByte = Math.Min(bitsInBuffer % 8, howManyBitsToRead);
            int howManyBitsFrom1StByte = Math.Max(0, howManyBitsToRead - howManyBitsFrom2NdByte);
            int indexOf2NdByte = bitsInBuffer >> 3;
            int indexOf1StByte = Math.Max(0, (bitsInBuffer >> 3) - 1);
            byte bitsRead = (byte)((((bitBuffer[indexOf2NdByte]) & ~(-1 << howManyBitsFrom2NdByte))) |
                (((bitBuffer[indexOf1StByte] & (-1 << (8 - howManyBitsFrom1StByte))) >> (8 - howManyBitsFrom1StByte))) << howManyBitsFrom2NdByte);
            //Console.WriteLine("    Read:  {1}#{0:X2}", bitsRead, howManyBitsToRead);
            bitsInBuffer -= howManyBitsToRead;
            return bitsRead;
        }
        static void Main3()
        {
            byte[] bitBuffer = new byte[100];
            int bitsInBuffer = 0;
            byte bitsToWrite = 0xFF;
            for (int i = 0; i < 8; i++)
            {
                int howManyBitsToWrite = i;
                //Console.WriteLine(((bitsToWrite << 8-howManyBitsToWrite) & 0xff) >> (8 - howManyBitsToWrite));
                WriteBits(howManyBitsToWrite, bitsToWrite, bitBuffer, ref bitsInBuffer);
                ShowHex(bitBuffer, bitsInBuffer);
            }
            for (int i = 7; i >= 0; i--)
            {
                ShowHex(bitBuffer, bitsInBuffer);
                int howManyBitsToRead = i;
                //Console.WriteLine(ReadBits(howManyBitsToRead, bitBuffer, ref bitsInBuffer));
            }
        }
        public static int Encode(short[] temperaturesToEncode, byte[] bitBuffer)
        {
            byte howManyTemperatures = (byte)temperaturesToEncode.Length;
            byte[] symbolsEncodingTemperatures = new byte[howManyTemperatures];
            short tempCurr;
            short tempPrev = 0;
            for (int i = 0; i < howManyTemperatures; i++)
            {
                tempCurr = (short)(temperaturesToEncode[i] >> SHIFT_16_BITS_VALUE_TO_14_BITS);
                if (i == 0)
                {
                    symbolsEncodingTemperatures[i] = ABSOLUTE_VALUE_SYMBOL;
                }
                else 
                {
                    short diff = (short)(tempCurr - tempPrev);
                    if (Math.Abs(diff) <= MAX_TEMP_DIFF_FOR_SYMBOL)
                    {
                        symbolsEncodingTemperatures[i] = (byte)(diff + MAX_TEMP_DIFF_FOR_SYMBOL);
                    }
                    else
                    {
                        symbolsEncodingTemperatures[i] = ABSOLUTE_VALUE_SYMBOL;
                    }
                }
                tempPrev = tempCurr;
            }
            //Console.WriteLine("SymbolsEncodingTemperatures:");
            for (int i = 0; i < symbolsEncodingTemperatures.Length; i++)
            {
                //Console.Write("{0:X2} ", symbolsEncodingTemperatures[i]);
            }
            //Console.WriteLine();

            byte x = L;
            byte nbBits;
            int bitsInBuffer = 0;
            for (byte i = 0; i < howManyTemperatures; i++)
            {
                byte symbolToEncode = symbolsEncodingTemperatures[i];
                //Console.WriteLine("Encoding: {0:x}", symbolToEncode);
                nbBits = (byte)((x + nb[symbolToEncode]) >> R_SMALL);
                WriteBits(nbBits, x, bitBuffer, ref bitsInBuffer);
                if (symbolToEncode == ABSOLUTE_VALUE_SYMBOL)
                {
                    WriteBits(8, (byte)((temperaturesToEncode[i] >> SHIFT_16_BITS_VALUE_TO_14_BITS) & 0xFF), bitBuffer, ref bitsInBuffer);
                    WriteBits(6, (byte)(((temperaturesToEncode[i] >> SHIFT_16_BITS_VALUE_TO_14_BITS) >> 8) & 0x3F), bitBuffer, ref bitsInBuffer);
                }
                x = encodingTable[start[symbolToEncode] + (x >> nbBits)];
            }
            //Console.WriteLine("Write  X: {0:X2}", (byte)(x & (L - 1)));
            WriteBits(R_BIG, (byte)(x & (L - 1)), bitBuffer, ref bitsInBuffer);
            if (bitsInBuffer % 8 != 0)
            {
                bitBuffer[(bitsInBuffer / 8) + 1] = Convert.ToByte(bitsInBuffer % 8);
                bitsInBuffer += (8 - (bitsInBuffer % 8)) + 8; //In case we want to add last byte

            }
            else
            {
                bitBuffer[bitsInBuffer / 8] = 8;
                bitsInBuffer += 8;
            }
            return bitsInBuffer;
        }
        public static void Decode(byte[] bitBuffer, ref int bitsInBuffer, short[] temperaturesDecoded, int howManyTemperatures)
        {
            byte[] symbolsDecoded = new byte[temperaturesDecoded.Length];
            byte X = ReadBits(R_BIG, bitBuffer, ref bitsInBuffer);
            //Console.WriteLine("Read  X: {0:X2}", X);
            for (int i = 0; i < howManyTemperatures; i++)
            {
                //Console.WriteLine("Decoding: {0:x}", decodingTableSymbol[X]);
                if (decodingTableSymbol[X] == ABSOLUTE_VALUE_SYMBOL)
                {
                    short v = (short)((ReadBits(6, bitBuffer, ref bitsInBuffer) & 0x3F) << 8);
                    v |= (short)ReadBits(8, bitBuffer, ref bitsInBuffer);
                    temperaturesDecoded[i] = v;
                }
                else
                {
                    temperaturesDecoded[i] = 0;
                }
                symbolsDecoded[i] = decodingTableSymbol[X];
                X = (byte)(decodingTableNewX[X] + ReadBits(decodingTableNBits[X], bitBuffer, ref bitsInBuffer));
            }
            short lastTemperature = 0;
            for (int i = 0; i < howManyTemperatures; i++)
            {
                int idx = howManyTemperatures - 1 - i;
                if (symbolsDecoded[idx] == ABSOLUTE_VALUE_SYMBOL)
                {
                    lastTemperature = temperaturesDecoded[idx];
                }
                else
                {
                    lastTemperature -= (short)(MAX_TEMP_DIFF_FOR_SYMBOL - symbolsDecoded[idx]);
                    temperaturesDecoded[idx] = lastTemperature;
                }
                temperaturesDecoded[idx] <<= SHIFT_16_BITS_VALUE_TO_14_BITS;
            }
            for (int i = 0; i < howManyTemperatures >> 1; i++)
            {
                short v = temperaturesDecoded[i];
                temperaturesDecoded[i] = temperaturesDecoded[howManyTemperatures - 1 - i];
                temperaturesDecoded[howManyTemperatures - 1 - i] = v;
            }
        }

        public static void ShowHex(byte[] bitBuffer, int bitsInBuffer)
        {
            for (int i = 0; i < Math.Ceiling(bitsInBuffer / 8.0); i++)
            {
                //Console.Write("{0:X2}", bitBuffer[i]);
            }
            //Console.WriteLine();
        }
        public static void ShowHex(short[] array)
        {
            for (int i = 0; i < array.Length; i++)
            {
                //Console.Write("{0:X4} ", array[i]);
            }
            //Console.WriteLine();
        }

        static void Main2()
        {
            //Console.WriteLine("ANS C#");
            short[] temperaturesToEncode = { 0x1C2C, 0x1C2C, 0x1C2C, 0x1D14, 0x1D14, 0x1D14, 0x1D14 };
            byte[] bitBuffer = new byte[temperaturesToEncode.Length * 3];
            int bitsInBuffer = Compressor.Encode(temperaturesToEncode, bitBuffer);
            Compressor.ShowHex(bitBuffer, bitsInBuffer);
            Compressor.ShowHex(temperaturesToEncode);
            short[] temperaturesDecoded = new short[temperaturesToEncode.Length];
            Compressor.Decode(bitBuffer, ref bitsInBuffer, temperaturesDecoded, temperaturesDecoded.Length);
            Compressor.ShowHex(temperaturesDecoded);
        }

        static void Main(string[] args)
        {
            if (args.Length < 3)
            {
                //Console.WriteLine("ANS C#");
                //Console.WriteLine(args.Length);
                //short[] temperaturesToEncode = { 0x1C2C, 0x1C2C, 0x1C2C, 0x1D14, 0x1D14, 0x1D14, 0x1D14 };
                //short[] temperaturesToEncode = { 0x1020, 0x1020, 0x1020, 0x1020, 0x1020, 0x1020, 0x1020 };
                int howManyTemperatures = Convert.ToInt32(args[0]);
                short[] temperaturesToEncode = new short[howManyTemperatures];

                //Console.WriteLine(args[1].Length / 2);
                //Console.WriteLine(howManyTemperatures);

                for (int i = 0; i < args[1].Length; i = i + 4)
                {
                    temperaturesToEncode[i / 4] = (short)Convert.ToUInt16(args[1].Substring(i, 4), 16);
                }

                byte[] bitBuffer = new byte[256];
                int bitsInBuffer = Compressor.Encode(temperaturesToEncode, bitBuffer);
                //Console.WriteLine("Encoded:");
                Compressor.ShowHex(bitBuffer, 256);
                Compressor.ShowHex(temperaturesToEncode);
                //ANSDecode:
                bitsInBuffer = bitBuffer.Length * 8; // FIXME
                while (bitBuffer[(bitsInBuffer / 8) - 1] == 0)
                {
                    bitsInBuffer -= 8;
                }
                bitsInBuffer -= 8 + (8 - bitBuffer[(bitsInBuffer / 8) - 1]);
                //Console.WriteLine(bitsInBuffer);
                short[] temperaturesDecoded = new short[howManyTemperatures];

                Compressor.Decode(bitBuffer, ref bitsInBuffer, temperaturesDecoded, temperaturesDecoded.Length);
                Compressor.ShowHex(temperaturesDecoded);

                byte[] temperaturesDecodedAsBytes = new byte[howManyTemperatures * 2];
                for (int i = 0; i < howManyTemperatures; i++)
                {
                    temperaturesDecodedAsBytes[2 * i] = (byte)((temperaturesDecoded[i] >> 8) & 0xFF);
                    temperaturesDecodedAsBytes[2 * i + 1] = (byte)(temperaturesDecoded[i] & 0xFF);
                }
                //Console.WriteLine("Decoded:");
                Compressor.ShowHex(temperaturesDecodedAsBytes, howManyTemperatures * 16);
            }
            else
            {
                if (Convert.ToInt32(args[2]) == 0)
                {
                    int howManyTemperatures = Convert.ToInt32(args[0]);
                    short[] temperaturesToEncode = new short[howManyTemperatures];

                    for (int i = 0; i < args[1].Length; i = i + 4)
                    {
                        temperaturesToEncode[i / 4] = (short)Convert.ToUInt16(args[1].Substring(i, 4), 16);
                    }

                    byte[] bitBuffer = new byte[256];
                    int bitsInBuffer = Compressor.Encode(temperaturesToEncode, bitBuffer);
                    //Console.WriteLine(bitsInBuffer);
                    //Console.WriteLine("Encoded:");
                    Compressor.ShowHex(bitBuffer, 256);
                    Compressor.ShowHex(temperaturesToEncode);
                }
                else if (Convert.ToInt32(args[2]) == 1)
                {

                    int howManyTemperatures = Convert.ToInt32(args[0]);
                    byte[] bitBuffer = new byte[256];

                    for (int i = 0; i < args[1].Length - 1; i = i + 2)
                    {
                        bitBuffer[i / 2] = (byte)Convert.ToUInt16(args[1].Substring(i, 2), 16);
                    }


                    int bitsInBuffer = bitBuffer.Length * 8; // FIXME
                    while (bitBuffer[(bitsInBuffer / 8) - 1] == 0)
                    {
                        bitsInBuffer -= 8;
                    }
                    bitsInBuffer -= 8 + (8 - bitBuffer[(bitsInBuffer / 8) - 1]);
                    //Console.WriteLine(bitsInBuffer);
                    short[] temperaturesDecoded = new short[howManyTemperatures];

                    Compressor.Decode(bitBuffer, ref bitsInBuffer, temperaturesDecoded, temperaturesDecoded.Length);
                    Compressor.ShowHex(temperaturesDecoded);

                    byte[] temperaturesDecodedAsBytes = new byte[howManyTemperatures * 2];
                    for (int i = 0; i < howManyTemperatures; i++)
                    {
                        temperaturesDecodedAsBytes[2 * i] = (byte)((temperaturesDecoded[i] >> 8) & 0xFF);
                        temperaturesDecodedAsBytes[2 * i + 1] = (byte)(temperaturesDecoded[i] & 0xFF);
                    } 
                    //Console.WriteLine("Decoded:");
                    Compressor.ShowHex(temperaturesDecodedAsBytes, howManyTemperatures * 16);
                }
            }

        }

        public static string To16Bits(int x)
        {
            char[] buff = new char[16];

            for (int i = 15; i >= 0; i--)
            {
                int mask = 1 << i;
                buff[15 - i] = (x & mask) != 0 ? '1' : '0';
            }

            return new string(buff);
        }

        static void Main4()
        {
            //Console.WriteLine("ANS C#");

            int howManyTemperatures = 60;
            //string buff;
            int score = 0;
            int t = 0;
            short[] temperaturesToEncode = new short[60];
            int tablesCount = 0;

            for (int i = 0; i < Math.Pow(2, 14); i++)
            {
                /*
                buff = To16Bits(i * 4);
                for (int j = 0; j < buff.Length; j++) {
                    //Console.Write(buff[j]);
                }
                //Console.Write("\n");*/
                

                for (int j = 0; j < 9; j++) {
                    temperaturesToEncode[t] = (short)(i * 4);
                    t++;
                    if (t > 59)
                    {
                        t = 0;
                        break;
                    }
                }
                //short[] temperaturesToEncode = { (short)(i * 4) };

                if (temperaturesToEncode[temperaturesToEncode.Length - 1] != 0)
                {
                    Compressor.ShowHex(temperaturesToEncode);
                    byte[] bitBuffer = new byte[256];
                    int bitsInBuffer = Compressor.Encode(temperaturesToEncode, bitBuffer);
                    //Console.WriteLine("Encoded:");
                    Compressor.ShowHex(bitBuffer, 256);

                    short[] temperaturesDecoded = new short[howManyTemperatures];
                    Compressor.Decode(bitBuffer, ref bitsInBuffer, temperaturesDecoded, temperaturesDecoded.Length);
                    //Console.WriteLine("Decoded:");
                    Compressor.ShowHex(temperaturesDecoded);
                    bool s = true;
                    for (int l = 0; l < temperaturesToEncode.Length; l++) {
                        if (temperaturesToEncode[l] == temperaturesDecoded[l])
                        {
                            s = true;
                        }
                        else {
                            s = false;
                            break;
                        }
                    }
                    if (s)
                    {
                        score++;
                    }
                    tablesCount++;
                    //Console.WriteLine();
                }
            }
            
            //Console.WriteLine("Score: " + ((score/tablesCount)*100) + "%");

        }
    }
}
