using NUnit.Framework;

namespace Lib
{
    [TestFixture]
    public class Test
    {

        [Test]
        public static void GetClientGreating_ReturnsCorrectGreating()
        {
            var result = Lib.GetClientGreating();
            Assert.AreEqual("Hello Client!", result);
        }
        
        [Test]
        public static void GetServerGreating_ReturnsCorrectGreating()
        {
            var result = Lib.GetServerGreating();
            Assert.AreEqual("Hello Server!", result);
        }
    }
}
