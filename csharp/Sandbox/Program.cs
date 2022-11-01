
using ClangSharp;
using ClangSharp.Interop;
using OneOf;
using System.Text;

namespace Sandbox;

public interface DataType { }

public static class DataTypes
{
    public static readonly DataType Void = new VoidType();
    public static readonly DataType Boolean = new BooleanType();
    public static readonly DataType S8 = new S8Type();
    public static readonly DataType U8 = new U8Type();
    public static readonly DataType U16 = new U16Type();
    public static readonly DataType S16 = new S16Type();
    public static readonly DataType U32 = new U32Type();
    public static readonly DataType S32 = new S32Type();
    public static readonly DataType U64 = new U64Type();
    public static readonly DataType S64 = new S64Type();
    public static readonly DataType SSize = new SSizeType();
    public static readonly DataType USize = new USizeType();
    public static readonly DataType Float = new FloatType();
}

public record VoidType() : DataType;
public record BooleanType() : DataType;
public record S8Type() : DataType;
public record U8Type() : DataType;
public record U16Type() : DataType;
public record S16Type() : DataType;
public record U32Type() : DataType;
public record S32Type() : DataType;
public record U64Type() : DataType;
public record S64Type() : DataType;
public record SSizeType() : DataType;
public record USizeType() : DataType;
public record FloatType() : DataType;

public record PointerType(DataType PointedToType) : DataType;
public record ArrayType(DataType ElementType) : DataType;
public record StructType(Struct Struct) : DataType;
public record UnionType(Union Union) : DataType;
public record EnumType(Enum Enum) : DataType;

public record Struct(string Name, List<Field> Fields);
public record Union(string Name, List<Field> Fields);
public record Enum(string Name);
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
    public static CXTranslationUnit tu;

    public static Dictionary<string, Struct> Structs = new();
    public static Dictionary<string, Union> Unions = new();
    public static Dictionary<string, Enum> Enums = new();
    public static Dictionary<string, Function> Functions = new();

    public static async Task Main(string[] args)
    {
        await GenerateIdris2Bindings(
            "C:/Users/R_SD/dev/personal/SDL/include/SDL.h",
            new()
            {
                "System.FFI"
            },
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
                ("SDL_INIT_VIDEO", "Int", "0x00000020"),
                ("SDL_RENDERER_ACCELERATED", "Int", "0x00000002")
            },
            "SDL2",
            @"C:\Users\R_SD\dev\personal\sandbox\idris2\examples\sdl2.idr");

        //await GenerateIdris2Bindings(
        //    @"C:\Users\R_SD\Downloads\raylib-4.2.0_win64_msvc16\raylib-4.2.0_win64_msvc16\include\raylib.h",
        //    new()
        //    {
        //    },
        //    new()
        //    {
        //        "InitWindow",
        //        "SetTargetFPS",
        //        "WindowShouldClose",
        //        "IsKeyDown",
        //        "BeginDrawing",
        //        "ClearBackground",
        //        "EndDrawing",
        //        "CloseWindow",
        //        "DrawRectangle",
        //    },
        //    new()
        //    {
        //    },
        //    "Raylib",
        //    @"C:\Users\R_SD\dev\personal\sandbox\idris2\examples\raylib.idr");
    }

    public static async Task GenerateIdris2Bindings(
        string filePath,
        HashSet<string> imports,
        HashSet<string> typeNameWhitelist,
        HashSet<string> functionNameWhitelist,
        List<(string, string, string)> constants,
        string moduleName,
        string outFilePath)
    {
        var index = CXIndex.Create(false, true);
        tu = CXTranslationUnit.Parse(index, filePath, new string[0], new CXUnsavedFile[0], CXTranslationUnit_Flags.CXTranslationUnit_None);

        CXClientData clientData = new();

        unsafe
        {
            tu.Cursor.VisitChildren(
                (CXCursor cursor, CXCursor parent, void* clientData) => ParseAst(typeNameWhitelist, functionNameWhitelist, cursor),
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

        foreach (var i in imports)
        {
            stringBuilder.AppendLine($"import {i}");
            stringBuilder.AppendLine();
        }

        foreach (var c in constants)
        {
            AppendConstant(c.Item1, c.Item2, c.Item3);
            stringBuilder.AppendLine();
        }

        foreach (var @enum in Enums.Values)
        {
            WriteEnum(stringBuilder, @enum);
            stringBuilder.AppendLine();
        }

        foreach (var @struct in Structs.Values)
        {
            WriteStruct(stringBuilder, @struct);
            stringBuilder.AppendLine();
        }

        foreach (var union in Unions.Values)
        {
            WriteUnion(stringBuilder, union);
            stringBuilder.AppendLine();
        }

        foreach (var function in Functions.Values)
        {
            WriteFunction(stringBuilder, function);
            stringBuilder.AppendLine();
        }

        await File.WriteAllTextAsync(outFilePath, stringBuilder.ToString().ReplaceLineEndings("\n"));
    }

    public static CXChildVisitResult ParseAst(HashSet<string> typeNameWhitelist, HashSet<string> functionNameWhitelist, CXCursor cursor)
    {
        if (cursor.Kind == CXCursorKind.CXCursor_FunctionDecl)
        {
            if (functionNameWhitelist.Contains(cursor.Name.CString))
            {
                var function = ParseFunction(cursor);
                Functions.Add(function.Name, function);
            }
        }
        else if (cursor.Kind == CXCursorKind.CXCursor_StructDecl)
        {
            if (typeNameWhitelist.Contains(cursor.DisplayName.CString))
            {
                var @struct = ParseStruct(cursor);
                Structs.Add(@struct.Name, @struct);
            }
        }
        else if (cursor.Kind == CXCursorKind.CXCursor_UnionDecl)
        {
            if (typeNameWhitelist.Contains(cursor.DisplayName.CString))
            {
                var union = ParseUnion(cursor);
                Unions.Add(union.Name, union);
            }
        }

        return CXChildVisitResult.CXChildVisit_Continue;
    }

    public static CXChildVisitResult FindAndParseType(string name, CXCursor cursor)
    {
        if (cursor.Kind == CXCursorKind.CXCursor_StructDecl)
        {
            if (cursor.DisplayName.CString == name)
            {
                var @struct = ParseStruct(cursor);
                Structs.Add(@struct.Name, @struct);
            }
        }
        else if (cursor.Kind == CXCursorKind.CXCursor_UnionDecl)
        {
            if (cursor.DisplayName.CString == name)
            {
                var union = ParseUnion(cursor);
                Unions.Add(union.Name, union);
            }
        }
        else if (cursor.Kind == CXCursorKind.CXCursor_EnumDecl)
        {
            if (GetName(cursor) == name)
            {
                var @enum = ParseEnum(cursor.DisplayName.CString);
                Enums.Add(@enum.Name, @enum);
            }
        }
        else if (cursor.Kind == CXCursorKind.CXCursor_TypedefDecl)
        {
            if (cursor.DisplayName.CString == name)
            {
                CXType underlyingType = cursor.TypedefDeclUnderlyingType;

                if (underlyingType.CanonicalType.kind == CXTypeKind.CXType_Enum)
                {
                    var @enum = ParseEnum(name);
                    Enums.Add(name, @enum);
                }
            }
        }

        return CXChildVisitResult.CXChildVisit_Continue;
    }

    public static Function ParseFunction(CXCursor cursor) =>
        new Function(
            cursor.Name.CString,
            cursor.GetArguments().Select(ParseParameter).ToList(),
            ParseType(cursor, cursor.ReturnType));

    public static Parameter ParseParameter(CXCursor cursor) =>
        new Parameter(
            cursor.Mangling.CString,
            ParseType(cursor, cursor.Type));

    public static Struct ParseStruct(CXCursor cursor) =>
        new Struct(
            cursor.DisplayName.CString,
            cursor.GetFields().Select(ParseField).ToList());

    public static Union ParseUnion(CXCursor cursor) =>
        new Union(
            cursor.DisplayName.CString,
            cursor.GetFields().Select(ParseField).ToList());

    public static Enum ParseEnum(string name) =>
        new Enum(
            name);

    public static Field ParseField(CXCursor cursor) =>
        new Field(
            cursor.DisplayName.CString,
            ParseType(cursor, cursor.Type));

    public static DataType ParseType(CXCursor cursor, CXType type)
    {
        type = type.CanonicalType;

        if (type.TypeClass == CX_TypeClass.CX_TypeClass_Builtin)
        {
            return type.kind switch
            {
                CXTypeKind.CXType_Void => DataTypes.Void,
                CXTypeKind.CXType_Bool => DataTypes.Boolean,
                CXTypeKind.CXType_Char_S => DataTypes.S8,
                CXTypeKind.CXType_Char_U => DataTypes.U8,
                CXTypeKind.CXType_UChar => DataTypes.U8,
                CXTypeKind.CXType_Short => DataTypes.S16,
                CXTypeKind.CXType_UShort => DataTypes.U16,
                CXTypeKind.CXType_Int => DataTypes.S16,
                CXTypeKind.CXType_Long => DataTypes.U32,
                CXTypeKind.CXType_ULong => DataTypes.S32,
                CXTypeKind.CXType_LongLong => DataTypes.U64,
                CXTypeKind.CXType_ULongLong => DataTypes.S64,
                CXTypeKind.CXType_UInt => DataTypes.USize,
                CXTypeKind.CXType_Float => DataTypes.Float,
                _ => throw new NotImplementedException()
            };
        }
        else if (type.TypeClass == CX_TypeClass.CX_TypeClass_Pointer)
        {
            if (type.PointeeType.TypeClass == CX_TypeClass.CX_TypeClass_Record)
            {
                return new PointerType(DataTypes.Void);
            }
            else
            {
                return new PointerType(ParseType(cursor, type.PointeeType));
            }
        }
        else if (type.TypeClass == CX_TypeClass.CX_TypeClass_ConstantArray)
        {
            return new ArrayType(ParseType(cursor, type.ElementType));
        }
        else if ((type.TypeClass == CX_TypeClass.CX_TypeClass_Record) || (type.TypeClass == CX_TypeClass.CX_TypeClass_Enum))
        {
            return GetUserDefinedType(cursor, type);
        }

        throw new NotImplementedException();
    }

    public static DataType? TryGetCachedUserDefinedType(string name)
    {
        Struct? @struct = Structs.GetValueOrDefault(name);

        if (@struct != null)
        {
            return new StructType(@struct);
        }

        Union? union = Unions.GetValueOrDefault(name);

        if (union != null)
        {
            return new UnionType(union);
        }

        Enum? @enum = Enums.GetValueOrDefault(name);

        if (@enum != null)
        {
            return new EnumType(@enum);
        }

        return null;
    }

    public static string? GetName(CXCursor cursor)
    {
        if (cursor.DisplayName.CString != null)
        {
            return cursor.DisplayName.CString;
        }
        else if (cursor.Mangling.CString != null)
        {
            return cursor.Mangling.CString;
        }

        return null;
    }

    public static string? GetName(CXType type)
    {
        if (!string.IsNullOrEmpty(type.Declaration.DisplayName.CString))
        {
            return type.Declaration.DisplayName.CString;
        }
        else if (!string.IsNullOrEmpty(type.Spelling.CString))
        {
            return type.Spelling.CString;
        }
        else
        {
            return type.Declaration.DisplayName.CString;
        }
    }

    public static DataType GetUserDefinedType(CXCursor cursor, CXType type)
    {
        string name = GetName(type);
        DataType? dataType = TryGetCachedUserDefinedType(name);
        if (dataType != null)
        {
            return dataType;
        }

        CXClientData clientData = new();

        unsafe
        {
            cursor.TranslationUnit.Cursor.VisitChildren(
                (CXCursor cursor, CXCursor parent, void* clientData) => FindAndParseType(name, cursor),
                clientData);
        }

        dataType = TryGetCachedUserDefinedType(name);

        if (dataType == null)
        {
            throw new Exception();
        }

        return dataType;
    }

    public static void WriteStruct(StringBuilder stringBuilder, Struct node)
    {
        IEnumerable<string> fields =
            node.Fields
                .Select(f => $"(\"{f.Name}\", {ToIdrisTypeString(f.Type)})");

        stringBuilder.AppendLine($"{node.Name} : Type");
        stringBuilder.AppendLine($"{node.Name} = Struct \"{node.Name}\" [{string.Join(", ", fields)}]");
    }

    public static void WriteUnion(StringBuilder stringBuilder, Union node)
    {
        IEnumerable<string> fields =
            node.Fields
                .Select(f => $"(\"{f.Name}\", {ToIdrisTypeString(f.Type)})");

        stringBuilder.AppendLine($"{node.Name} : Type");
        stringBuilder.AppendLine($"{node.Name} = Struct \"{node.Name}\" [{string.Join(", ", fields)}]");
    }

    public static void WriteEnum(StringBuilder stringBuilder, Enum node)
    {
        stringBuilder.AppendLine($"{node.Name} : Type");
        stringBuilder.AppendLine($"{node.Name} = Int");

        //stringBuilder.AppendLine($"data {node.Name} = {string.Join(" | ", node.)}");
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
        dataType switch
        {
            _ when dataType is VoidType => "()",
            _ when dataType is BooleanType => "Bool",
            _ when dataType is S8Type => "Bits8",
            _ when dataType is U8Type => "Bits8",
            _ when dataType is U16Type => "Bits16",
            _ when dataType is S16Type => "Bits16",
            _ when dataType is U32Type => "Bits32",
            _ when dataType is S32Type => "Bits32",
            _ when dataType is U64Type => "Bits64",
            _ when dataType is S64Type => "Bits64",
            _ when dataType is SSizeType => "Int",
            _ when dataType is USizeType => "Int",
            _ when dataType is FloatType => "Double",
            _ when dataType is PointerType ptrType =>
            ptrType.PointedToType switch
            {
                _ when (ptrType.PointedToType is S8Type) => "String",
                _ when (ptrType.PointedToType is VoidType) => "AnyPtr",
                _ => $"Ptr {ToIdrisTypeString(ptrType.PointedToType)}"
            },
            _ when dataType is ArrayType arrayType => $"[{ToIdrisTypeString(arrayType.ElementType)}]",
            _ when dataType is StructType structType => structType.Struct.Name,
            _ when dataType is EnumType enumType => enumType.Enum.Name,
            _ when dataType is UnionType unionType => unionType.Union.Name,
            _ => throw new NotImplementedException()
        };
}