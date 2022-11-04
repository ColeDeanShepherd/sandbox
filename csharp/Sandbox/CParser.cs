using ClangSharp.Interop;

namespace Sandbox;

public record CParserContext(
    HashSet<string> TypeNameWhitelist,
    HashSet<string> FunctionNameWhitelist,
    Program Program);

public static class CParser
{
    public static Program ParseProgram(
        string filePath,
        HashSet<string> typeNameWhitelist,
        HashSet<string> functionNameWhitelist)
    {
        var index = CXIndex.Create(false, true);
        var tu = CXTranslationUnit.Parse(index, filePath, new string[0], new CXUnsavedFile[0], CXTranslationUnit_Flags.CXTranslationUnit_None);

        CXClientData clientData = new();

        Program program = new(
            new(),
            new(),
            new(),
            new());

        CParserContext context = new(typeNameWhitelist, functionNameWhitelist, program);
        
        unsafe
        {
            tu.Cursor.VisitChildren(
                (CXCursor cursor, CXCursor parent, void* clientData) => ParseAst(context, cursor),
                clientData);
        }

        return program;
    }

    public static CXChildVisitResult ParseAst(CParserContext context, CXCursor cursor)
    {
        if (cursor.Kind == CXCursorKind.CXCursor_FunctionDecl)
        {
            if (context.FunctionNameWhitelist.Contains(cursor.Name.CString))
            {
                var function = ParseFunction(context, cursor);
                context.Program.Functions.Add(function.Name, function);
            }
        }
        else if (cursor.Kind == CXCursorKind.CXCursor_StructDecl)
        {
            if (context.TypeNameWhitelist.Contains(cursor.DisplayName.CString))
            {
                var @struct = ParseStruct(context, cursor);
                context.Program.Structs.Add(@struct.Name, @struct);
            }
        }
        else if (cursor.Kind == CXCursorKind.CXCursor_UnionDecl)
        {
            if (context.TypeNameWhitelist.Contains(cursor.DisplayName.CString))
            {
                var union = ParseUnion(context, cursor);
                context.Program.Unions.Add(union.Name, union);
            }
        }

        return CXChildVisitResult.CXChildVisit_Continue;
    }

    public static CXChildVisitResult FindAndParseType(CParserContext context, string name, CXCursor cursor)
    {
        if (cursor.Kind == CXCursorKind.CXCursor_StructDecl)
        {
            if (cursor.DisplayName.CString == name)
            {
                var @struct = ParseStruct(context, cursor);
                context.Program.Structs.Add(@struct.Name, @struct);
            }
        }
        else if (cursor.Kind == CXCursorKind.CXCursor_UnionDecl)
        {
            if (cursor.DisplayName.CString == name)
            {
                var union = ParseUnion(context, cursor);
                context.Program.Unions.Add(union.Name, union);
            }
        }
        else if (cursor.Kind == CXCursorKind.CXCursor_EnumDecl)
        {
            if (GetName(cursor) == name)
            {
                var @enum = ParseEnum(context, cursor.DisplayName.CString);
                context.Program.Enums.Add(@enum.Name, @enum);
            }
        }
        else if (cursor.Kind == CXCursorKind.CXCursor_TypedefDecl)
        {
            if (cursor.DisplayName.CString == name)
            {
                CXType underlyingType = cursor.TypedefDeclUnderlyingType;

                if (underlyingType.CanonicalType.kind == CXTypeKind.CXType_Enum)
                {
                    var @enum = ParseEnum(context, name);
                    context.Program.Enums.Add(name, @enum);
                }
            }
        }

        return CXChildVisitResult.CXChildVisit_Continue;
    }

    public static Function ParseFunction(CParserContext context, CXCursor cursor) =>
        new Function(
            cursor.Name.CString,
            cursor.GetArguments().Select(c => ParseParameter(context, c)).ToList(),
            ParseType(context, cursor, cursor.ReturnType));

    public static Parameter ParseParameter(CParserContext context, CXCursor cursor) =>
        new Parameter(
            cursor.Mangling.CString,
            ParseType(context, cursor, cursor.Type));

    public static Struct ParseStruct(CParserContext context, CXCursor cursor) =>
        new Struct(
            cursor.DisplayName.CString,
            cursor.GetFields().Select(c => ParseField(context, c)).ToList(),
            (uint)cursor.Type.SizeOf);

    public static Union ParseUnion(CParserContext context, CXCursor cursor) =>
        new Union(
            cursor.DisplayName.CString,
            cursor.GetFields().Select(c => ParseField(context, c)).ToList(),
            (uint)cursor.Type.SizeOf);

    public static Enum ParseEnum(CParserContext context, string name) =>
        new Enum(
            name);

    public static Field ParseField(CParserContext context, CXCursor cursor) =>
        new Field(
            cursor.DisplayName.CString,
            ParseType(context, cursor, cursor.Type),
            (uint)(cursor.OffsetOfField / 32));

    public static DataType ParseType(CParserContext context, CXCursor cursor, CXType type)
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
                CXTypeKind.CXType_Int => DataTypes.SSize,
                CXTypeKind.CXType_UInt => DataTypes.USize,
                CXTypeKind.CXType_Long => DataTypes.U32,
                CXTypeKind.CXType_ULong => DataTypes.S32,
                CXTypeKind.CXType_LongLong => DataTypes.U64,
                CXTypeKind.CXType_ULongLong => DataTypes.S64,
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
                return new PointerType(ParseType(context, cursor, type.PointeeType));
            }
        }
        else if (type.TypeClass == CX_TypeClass.CX_TypeClass_ConstantArray)
        {
            return new ArrayType(ParseType(context, cursor, type.ElementType));
        }
        else if ((type.TypeClass == CX_TypeClass.CX_TypeClass_Record) || (type.TypeClass == CX_TypeClass.CX_TypeClass_Enum))
        {
            return GetUserDefinedType(context, cursor, type);
        }

        throw new NotImplementedException();
    }

    public static DataType? TryGetCachedUserDefinedType(CParserContext context, string name)
    {
        Struct? @struct = context.Program.Structs.GetValueOrDefault(name);

        if (@struct != null)
        {
            return new StructType(@struct);
        }

        Union? union = context.Program.Unions.GetValueOrDefault(name);

        if (union != null)
        {
            return new UnionType(union);
        }

        Enum? @enum = context.Program.Enums.GetValueOrDefault(name);

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

    public static DataType GetUserDefinedType(CParserContext context, CXCursor cursor, CXType type)
    {
        string? name = GetName(type);
        if (name == null)
        {
            throw new Exception();
        }

        DataType? dataType = TryGetCachedUserDefinedType(context, name);
        if (dataType != null)
        {
            return dataType;
        }

        CXClientData clientData = new();

        unsafe
        {
            cursor.TranslationUnit.Cursor.VisitChildren(
                (CXCursor cursor, CXCursor parent, void* clientData) => FindAndParseType(context, name, cursor),
                clientData);
        }

        dataType = TryGetCachedUserDefinedType(context, name);

        if (dataType == null)
        {
            throw new Exception();
        }

        return dataType;
    }
}

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