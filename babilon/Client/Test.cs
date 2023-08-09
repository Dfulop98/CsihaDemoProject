using NUnit.Framework;

namespace Client
{
    [TestFixture]
    public class Test
    {
        [Test]
        public void ClientMessage_ReturnsCorrectMessage()
        {
            var result = Client.ClientMessage();

            Assert.AreEqual("Hello Client!", result);
        }
    }
}