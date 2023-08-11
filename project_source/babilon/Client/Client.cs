
namespace Client;
/// <summary>
/// The 'Client' class is responsible for printing a greeting message to the console.
/// </summary>
public class Client
{
    /// <summary>
    /// Entry point of the program. Prints the greeting message to the console.
    /// </summary>
    /// <param name="args">Command line arguments.</param>
    private static void Main(string[] args)
    {
        Console.WriteLine(ClientMessage());
    }

    /// <summary>
    /// Calls the 'GetClientGreating' method from the 'Lib' class and returns the greeting message.
    /// </summary>
    /// <returns>The greeting message.</returns>
    internal static string ClientMessage() => Lib.Lib.GetClientGreating();
}