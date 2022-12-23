// Number guessing game

// Ideas pure/impure analyzer
// Warn concrete uses of non-DI'd stuff

namespace Sandbox;

public interface IConsole
{
    void WriteLine(string? value);
}

public class ConsoleImpl : IConsole
{
    public void WriteLine(string? value) => Console.WriteLine(value);
}

public static class Cli
{
    public static void Main(string[] args)
    {
        ConsoleImpl consoleImpl = new();

        Injected<IConsole>.Register(consoleImpl);
        using var _ = Implicit<IConsole>.With(consoleImpl);

        RunHelloWorld();
        RunHelloWorld2();
    }

    public static void RunHelloWorld(Implicit<IConsole> console = default)
    {
        console.Value.WriteLine("Hello, world!");
    }

    public static void RunHelloWorld2(Injected<IConsole> console = default)
    {
        console.Value.WriteLine("Hello, world!");
    }
}