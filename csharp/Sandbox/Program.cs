
using ClangSharp;
using ClangSharp.Interop;
using OneOf;
using System.Text;

namespace Sandbox;

[GenerateOneOf]
public partial class DataType : OneOfBase<VoidType, S8Type, U8Type, SSizeType, USizeType, PointerType, ArrayType, StructType>
{
    public static readonly DataType Void = new VoidType();
    public static readonly DataType S8 = new S8Type();
    public static readonly DataType U8 = new S8Type();
    public static readonly DataType SSize = new SSizeType();
    public static readonly DataType USize = new USizeType();
}

public record VoidType();
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

    public static List<Struct> Structs = new();
    public static List<Function> Functions = new();

    public static async Task Main(string[] args)
    {
        const string filePath = "C:/Users/R_SD/dev/personal/SDL/include/SDL.h";

        var index = CXIndex.Create(false, true);
        var tu = CXTranslationUnit.Parse(index, filePath, new string[0], new CXUnsavedFile[0], CXTranslationUnit_Flags.CXTranslationUnit_None);

        CXClientData clientData = new();

        unsafe
        {
            //tu.Cursor.VisitChildren(VisitStructs, clientData);
            tu.Cursor.VisitChildren(VisitFunctions, clientData);
        }

        StringBuilder stringBuilder = new();
        stringBuilder.AppendLine("module SDL2");
        stringBuilder.AppendLine();

        stringBuilder.AppendLine("export");
        stringBuilder.AppendLine("SDL_INIT_VIDEO : Int");
        stringBuilder.AppendLine("SDL_INIT_VIDEO = 0x00000020");
        stringBuilder.AppendLine();

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

        await File.WriteAllTextAsync(@"C:\Users\R_SD\dev\personal\sandbox\idris2\examples\sdl2.idr", stringBuilder.ToString().ReplaceLineEndings("\n"));
    }

    unsafe public static CXChildVisitResult VisitStructs(CXCursor cursor, CXCursor parent, void* clientData)
    {
        if (cursor.Kind == CXCursorKind.CXCursor_StructDecl)
        {
            if (RecordNameWhitelist.Contains(cursor.DisplayName.CString))
            {
                Structs.Add(ParseStruct(cursor));
            }
        }

        return CXChildVisitResult.CXChildVisit_Continue;
    }

    unsafe public static CXChildVisitResult VisitFunctions(CXCursor cursor, CXCursor parent, void* clientData)
    {
        if (cursor.Kind == CXCursorKind.CXCursor_FunctionDecl)
        {
            if (FunctionNameWhitelist.Contains(cursor.Name.CString))
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