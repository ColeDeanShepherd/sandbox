
using ClangSharp;
using ClangSharp.Interop;
using OneOf;
using System.Text;

namespace Sandbox;

[GenerateOneOf]
public partial class DataType : OneOfBase<VoidType, BooleanType, S8Type, U8Type, SSizeType, USizeType, PointerType, ArrayType, StructType>
{
    public static readonly DataType Void = new VoidType();
    public static readonly DataType Boolean = new BooleanType();
    public static readonly DataType S8 = new S8Type();
    public static readonly DataType U8 = new U8Type();
    public static readonly DataType SSize = new SSizeType();
    public static readonly DataType USize = new USizeType();
}

public record VoidType();
public record BooleanType();
public record S8Type();
public record U8Type();
public record SSizeType();
public record USizeType();
public record PointerType(DataType PointedToType);
public record ArrayType(DataType ElementType);
public record StructType(Struct Struct);

public record Struct(string Name, List<Field> Fields);
public record Field(string Name, DataType Type);
public record Function(string Name, List<Parameter> Parameters, DataType ReturnType);
public record Parameter(string Name, DataType Type);

public static class Extensions
{
    public static IEnumerable<CXCursor> GetArguments(this CXCursor cursor) =>
        Enumerable.Range(0, cursor.NumArguments)
            .Select(i => (uint)i)
            .Select(cursor.GetArgument);

    public static IEnumerable<CXCursor> GetFields(this CXCursor cursor) =>
        Enumerable.Range(0, cursor.NumFields)
            .Select(i => (uint)i)
            .Select(cursor.GetField);
}

public static class Program
{
    public static List<Struct> Structs = new();
    public static List<Function> Functions = new();

    public static async Task Main(string[] args)
    {
        await GenerateIdris2Bindings(
            "C:/Users/R_SD/dev/personal/SDL/include/SDL.h",
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
                "SDL_RenderPresent"
            },
            new()
            {
                ("SDL_INIT_VIDEO", "Int", "0x00000020"),
                ("SDL_RENDERER_ACCELERATED", "Int", "0x00000002")
            },
            "SDL2",
            @"C:\Users\R_SD\dev\personal\sandbox\idris2\examples\sdl2.idr");

        await GenerateIdris2Bindings(
            @"C:\Users\R_SD\Downloads\raylib-4.2.0_win64_msvc16\raylib-4.2.0_win64_msvc16\include\raylib.h",
            new()
            {
            },
            new()
            {
                "InitWindow",
                "SetTargetFPS",
                "WindowShouldClose",
                "IsKeyDown",
                "BeginDrawing",
                "ClearBackground",
                "EndDrawing",
                "CloseWindow",
                "DrawRectangle",
            },
            new()
            {
            },
            "Raylib",
            @"C:\Users\R_SD\dev\personal\sandbox\idris2\examples\raylib.idr");
    }

    public static async Task GenerateIdris2Bindings(
        string filePath,
        HashSet<string> recordNameWhitelist,
        HashSet<string> functionNameWhitelist,
        List<(string, string, string)> constants,
        string moduleName,
        string outFilePath)
    {
        var index = CXIndex.Create(false, true);
        var tu = CXTranslationUnit.Parse(index, filePath, new string[0], new CXUnsavedFile[0], CXTranslationUnit_Flags.CXTranslationUnit_None);

        CXClientData clientData = new();

        unsafe
        {
            tu.Cursor.VisitChildren(
                (CXCursor cursor, CXCursor parent, void* clientData) => VisitStructs(recordNameWhitelist, cursor),
                clientData);
            tu.Cursor.VisitChildren(
                (CXCursor cursor, CXCursor parent, void* clientData) => VisitFunctions(functionNameWhitelist, cursor),
                clientData);
        }

        StringBuilder stringBuilder = new();

        void AppendConstant(string name, string type, string value)
        {
            stringBuilder.AppendLine("export");
            stringBuilder.AppendLine($"{name} : {type}");
            stringBuilder.AppendLine($"{name} = {value}");
        }

        stringBuilder.AppendLine($"module {moduleName}");
        stringBuilder.AppendLine();

        foreach (var c in constants)
        {
            AppendConstant(c.Item1, c.Item2, c.Item3);
        }

        foreach (var @struct in Structs)
        {
            WriteStruct(stringBuilder, @struct);
            stringBuilder.AppendLine();
        }

        foreach (var function in Functions)
        {
            WriteFunction(stringBuilder, function);
            stringBuilder.AppendLine();
        }

        await File.WriteAllTextAsync(outFilePath, stringBuilder.ToString().ReplaceLineEndings("\n"));
    }

    unsafe public static CXChildVisitResult VisitStructs(HashSet<string> recordNameWhitelist, CXCursor cursor)
    {
        if (cursor.Kind == CXCursorKind.CXCursor_StructDecl)
        {
            if (recordNameWhitelist.Contains(cursor.DisplayName.CString))
            {
                Structs.Add(ParseStruct(cursor));
            }
        }

        return CXChildVisitResult.CXChildVisit_Continue;
    }

    unsafe public static CXChildVisitResult VisitFunctions(HashSet<string> functionNameWhitelist, CXCursor cursor)
    {
        if (cursor.Kind == CXCursorKind.CXCursor_FunctionDecl)
        {
            if (functionNameWhitelist.Contains(cursor.Name.CString))
            {
                Functions.Add(ParseFunction(cursor));
            }
        }

        return CXChildVisitResult.CXChildVisit_Continue;
    }

    public static Function ParseFunction(CXCursor cursor) =>
        new Function(
            cursor.Name.CString,
            cursor.GetArguments().Select(ParseParameter).ToList(),
            ParseType(cursor.ReturnType));

    public static Parameter ParseParameter(CXCursor cursor) =>
        new Parameter(
            cursor.Mangling.CString,
            ParseType(cursor.Type));

    public static Struct ParseStruct(CXCursor cursor) =>
        new Struct(
            cursor.DisplayName.CString,
            cursor.GetFields().Select(ParseField).ToList());

    public static Field ParseField(CXCursor cursor) =>
        new Field(
            cursor.DisplayName.CString,
            ParseType(cursor.Type));

    public static DataType ParseType(CXType type)
    {
        type = type.CanonicalType;

        if (type.TypeClass == CX_TypeClass.CX_TypeClass_Builtin)
        {
            return type.kind switch
            {
                CXTypeKind.CXType_Void => DataType.Void,
                CXTypeKind.CXType_Bool => DataType.Boolean,
                CXTypeKind.CXType_Char_S => DataType.S8,
                CXTypeKind.CXType_Char_U => DataType.U8,
                CXTypeKind.CXType_UChar => DataType.U8,
                CXTypeKind.CXType_Int => DataType.SSize,
                CXTypeKind.CXType_UInt => DataType.USize,
                _ => throw new NotImplementedException()
            };
        }
        else if (type.TypeClass == CX_TypeClass.CX_TypeClass_Pointer)
        {
            if (type.PointeeType.TypeClass == CX_TypeClass.CX_TypeClass_Record)
            {
                return new PointerType(DataType.Void);
            }
            else
            {
                return new PointerType(ParseType(type.PointeeType));
            }
        }
        else if (type.TypeClass == CX_TypeClass.CX_TypeClass_ConstantArray)
        {
            return new ArrayType(ParseType(type.ElementType));
        }
        else if (type.TypeClass == CX_TypeClass.CX_TypeClass_Record)
        {
            Struct @struct = Structs.First(s => s.Name == type.Declaration.DisplayName.CString);
            return new StructType(@struct);
        }

        throw new NotImplementedException();
    }
    public static void WriteStruct(StringBuilder stringBuilder, Struct node)
    {
        IEnumerable<string> fields =
            node.Fields
                .Select(f => $"(\"{f.Name}\", {ToIdrisTypeString(f.Type)})");

        stringBuilder.AppendLine($"{node.Name} : Type");
        stringBuilder.AppendLine($"{node.Name} = Struct \"{node.Name}\" [{string.Join(", ", fields)}]");
    }

    public static void WriteFunction(StringBuilder stringBuilder, Function node)
    {
        IEnumerable<string> paramAndReturnTypes =
            node.Parameters
                .Select(p => ToIdrisTypeString(p.Type))
                .Concat(new[] { $"PrimIO {ToIdrisTypeString(node.ReturnType)}" });

        stringBuilder.AppendLine($"%foreign \"C:{node.Name},SDL2\"");
        stringBuilder.AppendLine("export");
        stringBuilder.AppendLine($"{node.Name} : {string.Join(" -> ", paramAndReturnTypes)}");
    }

    private static string ToIdrisTypeString(DataType dataType) =>
        dataType.Match(
            voidType => "()",
            booleanType => "Bool",
            s8Type => "Int",
            u8Type => "Int",
            sSizeType => "Int",
            uSizeType => "Int",
            ptrType =>
                ptrType.PointedToType switch
                {
                    _ when (ptrType.PointedToType.Value is S8Type) => "String",
                    _ when (ptrType.PointedToType.Value is VoidType) => "AnyPtr",
                    _ => $"Ptr {ToIdrisTypeString(ptrType.PointedToType)}"
                },
            arrayType => $"[{ToIdrisTypeString(arrayType.ElementType)}]",
            structType => structType.Struct.Name);
}