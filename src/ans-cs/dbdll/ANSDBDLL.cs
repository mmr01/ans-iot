/*
 * ANS Coder/Decoder
 *
 * Date: 2021-08-17
 *
 * Author: Henryk Telega
 * Author: Michal Markiewicz
 */
using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction] 
    public static SqlBinary ANSEncode([SqlFacet(MaxSize = 256)] SqlBinary temperaturesToEncode)
    {
        short[] temperaturesToEncodeShort = new short[temperaturesToEncode.Length / 2];
        for (int i = 0; i < temperaturesToEncodeShort.Length; i ++)
        {
            temperaturesToEncodeShort[i] = (short)((temperaturesToEncode[2 * i] << 8) + temperaturesToEncode[2 * i + 1]);
        }
        byte[] bitBuffer = new byte[256]; //FIXME:
        int bitsInBuffer = ANS.Compressor.Encode(temperaturesToEncodeShort, bitBuffer);
        int bytesInBuffer = bitsInBuffer >> 3;
        byte[] shortBitBuffer = new byte[bytesInBuffer]; 
        for (int i = 0; i < bytesInBuffer; i ++)
        {
            shortBitBuffer[i] = bitBuffer[i];
        }
        return new SqlBinary(shortBitBuffer);
    }

    [Microsoft.SqlServer.Server.SqlFunction]
    public static SqlBinary ANSDecode([SqlFacet(MaxSize = 256)] SqlBinary bitBuffer, SqlInt16 numberOfTemperaturesPerRecord)
    {
        byte[] bitBufferBytes = new byte[bitBuffer.Length];
        for (int i = 0; i < bitBuffer.Length; i++)
        {
            bitBufferBytes[i] = bitBuffer[i];
        }
        int bitsInBuffer = ((bitBuffer.Length - 1) * 8) - (8 - bitBuffer[bitBuffer.Length - 1]);
        /*int bitsInBuffer = bitBuffer.Length * 8; 
        while (bitBuffer[(bitsInBuffer / 8) - 1] == 0)
        {
            bitsInBuffer -= 8;
        }
        bitsInBuffer -= 8 + (8 - bitBuffer[(bitsInBuffer / 8) - 1]);*/
        int howManyTemperatures = (int)numberOfTemperaturesPerRecord; // 
        short[] temperaturesDecoded = new short[howManyTemperatures];

        ANS.Compressor.Decode(bitBufferBytes, ref bitsInBuffer, temperaturesDecoded, howManyTemperatures);

        byte[] temperaturesDecodedAsBytes = new byte[howManyTemperatures * 2];
        for (int i = 0; i < howManyTemperatures; i++)
        {
            //FIXME: Verify byte order
            temperaturesDecodedAsBytes[2 * i] = (byte)((temperaturesDecoded[i] >> 8) & 0xFF);
            temperaturesDecodedAsBytes[2 * i + 1] = (byte)(temperaturesDecoded[i] & 0xFF);
        }
        return temperaturesDecodedAsBytes;
    }

}
