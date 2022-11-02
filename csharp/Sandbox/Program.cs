namespace Sandbox;

public static class Cli
{
    public static async Task Main(string[] args)
    {
        await GenerateIdris2Bindings(
            "C:/Users/R_SD/dev/personal/SDL/include/SDL.h",
            "SDL2",
            @"C:\Users\R_SD\dev\personal\sandbox\idris2\examples",
            new()
            {
                "SDL_Event"
            },
            new()
            {
                "SDL_Init",
                "SDL_CreateWindow",
                "SDL_GetWindowSurface",
                "SDL_UpdateWindowSurface",
                "SDL_Delay",
                "SDL_CreateRenderer",
                "SDL_RenderSetLogicalSize",
                "SDL_RenderClear",
                "SDL_RenderPresent",
                "SDL_PollEvent"
            },
            new()
            {
                "System.FFI"
            },
            new()
            {
                ("SDL_INIT_VIDEO", "Int", "0x00000020"),
                ("SDL_RENDERER_ACCELERATED", "Int", "0x00000002")
            });
    }

    public static async Task GenerateIdris2Bindings(
        string cSourceFilePath,
        string moduleName,
        string outDirectoryPath,
        HashSet<string> typeNameWhitelist,
        HashSet<string> functionNameWhitelist,
        HashSet<string> imports,
        List<(string, string, string)> constants)
    {
        Program program = CParser.ParseProgram(cSourceFilePath, typeNameWhitelist, functionNameWhitelist);

        string idrisSourceCode = IdrisCodeGenerator.GenerateIdrisSourceCode(moduleName, program, imports, constants);
        await File.WriteAllTextAsync(Path.Combine(outDirectoryPath, $"{moduleName}.idr"), idrisSourceCode);

        string cSourceCode = IdrisCodeGenerator.GenerateCLibSourceCode(program);
        await File.WriteAllTextAsync(Path.Combine(outDirectoryPath, $"{moduleName}.c"), cSourceCode);
    }
}