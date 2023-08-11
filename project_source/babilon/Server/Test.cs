using NUnit.Framework;

namespace Server
{
    [TestFixture]
    public class Test
    {
        [Test]
        public void ServerMessage_ReturnsCorrectMessage()
        {
            var result = Server.ServerMessage();

            Assert.AreEqual("Hello Server!", result);
        }
    }
}