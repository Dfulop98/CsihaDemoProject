
namespace Server;
public class Server
{
    private static void Main(string[] args)
    {
        Console.WriteLine(ServerMessage());
    }

    internal static string ServerMessage() => Lib.Lib.GetServerGreating();
}