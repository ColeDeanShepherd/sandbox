using System.Text;
using System.Text.Json;

namespace Sandbox;

public record AstNode(string kind, string? name, AstType? type, List<AstNode>? inner);

public record AstType(string? desugaredQualType, string qualType);

public static class Program
{
    public const string FunctionDecl = "FunctionDecl";
    public const string ParmVarDecl = "ParmVarDecl";
    public const string RecordDecl = "RecordDecl";
    public const string FieldDecl = "FieldDecl";

    public static readonly HashSet<string> RecordNameWhitelist = new()
    {
    };

    public static readonly HashSet<string> FunctionNameWhitelist = new()
    {
        "SDL_Init",
        "SDL_CreateWindow",
        "SDL_GetWindowSurface",
        "SDL_UpdateWindowSurface",
        "SDL_Delay"
    };

    public static async Task Main(string[] args)
    {
        StringBuilder stringBuilder = new StringBuilder();
        AstNode ast = (await JsonSerializer.DeserializeAsync<AstNode>(File.OpenRead(@"C:\Users\R_SD\dev\personal\SDL\SDL_AST.json")))!;

        var recordDecls =
            GetNodesOfKind(ast, RecordDecl)
                .Where(r => (r.name != null) && r.name!.StartsWith("SDL_"))
                .Where(f => RecordNameWhitelist.Contains(f.name!));

        foreach (AstNode node in recordDecls)
        {
            WriteStruct(stringBuilder, node);
            stringBuilder.AppendLine();
        }

        var functionDecls =
            GetNodesOfKind(ast, FunctionDecl)
                .Where(f => (f.name != null) && f.name!.StartsWith("SDL_"))
                .Where(f => FunctionNameWhitelist.Contains(f.name!));

        foreach (AstNode node in functionDecls)
        {
            WriteFunction(stringBuilder, node);
            stringBuilder.AppendLine();
        }

        await File.WriteAllTextAsync(@"C:\Users\R_SD\dev\personal\sandbox\idris2\sdl2.idr", stringBuilder.ToString());
    }

    public static void WriteStruct(StringBuilder stringBuilder, AstNode node)
    {
        IEnumerable<string> fields =
            GetNodesOfKind(node, FieldDecl)
                .Select(f => $"(\"{f.name}\", {f.type.qualType})");

        stringBuilder.AppendLine($"{node.name} : Type");
        stringBuilder.AppendLine($"{node.name} = Struct \"{node.name}\" [{string.Join(", ", fields)}]");
    }

    public static void WriteFunction(StringBuilder stringBuilder, AstNode node)
    {
        string typeStr = node.type.desugaredQualType ?? node.type.qualType;
        string returnType = new string(typeStr.TakeWhile(c => c != ' ').ToArray());

        IEnumerable<string> paramAndReturnTypes = GetNodesOfKind(node, ParmVarDecl)
            .Select(p => p.type!.qualType)
            .Concat(new[] { $"IO {returnType}" })
            .Select(MapSdlTypeToIdrisType);

        stringBuilder.AppendLine($"%foreign \"C:{node.name},libsdl\"");
        stringBuilder.AppendLine($"{node.name} : {string.Join(" -> ", paramAndReturnTypes)}");
    }

    public static IEnumerable<AstNode> GetNodesOfKind(AstNode astNode, string kind)
    {
        if (astNode.kind == kind)
        {
            yield return astNode;
        }

        if (astNode.inner != null)
        {
            foreach (AstNode child in astNode.inner)
            {
                foreach (AstNode functionDecl in GetNodesOfKind(child, kind))
                {
                    yield return functionDecl;
                }
            }
        }
    }

    private static string MapSdlTypeToIdrisType(string sdlType) =>
        sdlType switch
        {
            "void" => "IO ()",
            "int" => "Int",
            "Uint32" => "Int",
            "const char *" => "Ptr String",
            _ => sdlType
        };
}