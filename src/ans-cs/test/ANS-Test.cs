using ANS;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ANSTest
{
    [TestClass]
    public class ANSTest
    {
        [TestMethod]
        public void TestReadWrite()
        {
            byte[] bitBuffer = new byte[100];
            int bitsInBuffer = 0;
            int loop = 200;
            for (int i = 0; i < loop; i++)
            {
                TestSingleReadWrite(i, bitBuffer, ref bitsInBuffer);
                for (int j = 0; j < loop; j++)
                {
                    TestSingleReadWrite(j, bitBuffer, ref bitsInBuffer);
                }
            }
        }
        [TestMethod]
        public void Test86()
        {
            byte[] bitBuffer = new byte[100];
            int bitsInBuffer = 0;
            byte[] sizes = { 8, 6, 6, 6, 8, 6 };
            //byte[] sizes = { 8, 6 };
            for (int i = 0; i < sizes.Length; i++)
            {
                Compressor.WriteBits(sizes[i], (byte)(31 - i), bitBuffer, ref bitsInBuffer);
            }
            for (int i = sizes.Length - 1; i >= 0; i--)
            {
                Assert.AreEqual(31 - i, Compressor.ReadBits(sizes[i], bitBuffer, ref bitsInBuffer));
            }
        }


        private void TestSingleReadWrite(int idx, byte[] bitBuffer, ref int bitsInBuffer)
        {
            byte n = (byte)(idx % 8);
            byte v = (byte)(idx & ((1 << n) - 1));
            Compressor.WriteBits(n, v, bitBuffer, ref bitsInBuffer);
            byte r = Compressor.ReadBits(n, bitBuffer, ref bitsInBuffer);
            Assert.AreEqual(v, r);
        }
    }
}
