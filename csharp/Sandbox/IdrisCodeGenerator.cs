using System.Text;

namespace Sandbox;

public static class IdrisCodeGenerator
{
    public static string GenerateIdrisSourceCode(
        string moduleName,
        Program program,
        HashSet<string> imports,
        List<(string, string, string)> constants)
    {
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
        }

        stringBuilder.AppendLine();

        foreach (var c in constants)
        {
            AppendConstant(c.Item1, c.Item2, c.Item3);
            stringBuilder.AppendLine();
        }

        foreach (var @enum in program.Enums.Values)
        {
            WriteEnum(stringBuilder, @enum);
            stringBuilder.AppendLine();
        }

        foreach (var @struct in program.Structs.Values)
        {
            WriteStruct(stringBuilder, @struct);
            stringBuilder.AppendLine();
        }

        foreach (var union in program.Unions.Values)
        {
            WriteUnion(stringBuilder, union);
            stringBuilder.AppendLine();
        }

        foreach (var function in program.Functions.Values)
        {
            WriteFunction(stringBuilder, moduleName, function);
            stringBuilder.AppendLine();
        }

        return stringBuilder.ToString().ReplaceLineEndings("\n");
    }

    public static void WriteStruct(StringBuilder stringBuilder, Struct node)
    {
        IEnumerable<string> fields =
            node.Fields
                .Select(f => $"(\"{f.Name}\", {ToIdrisTypeString(f.Type)})");

        stringBuilder.AppendLine("export");
        stringBuilder.AppendLine($"{node.Name} : Type");
        stringBuilder.AppendLine($"{node.Name} = Struct \"{node.Name}\" [{string.Join(", ", fields)}]");
        stringBuilder.AppendLine();

        stringBuilder.AppendLine("export");
        stringBuilder.AppendLine($"Mk{node.Name} : {node.Name}");
        stringBuilder.AppendLine($"Mk{node.Name} = unsafeCast (unsafePerformIO (Mk_)) where");
        stringBuilder.AppendLine(
@$"  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc {node.SizeInBytes}
    io_pure (unsafeCast res)
    -- onCollectAny res free");
        stringBuilder.AppendLine();
    }

    public static void WriteUnion(StringBuilder stringBuilder, Union node)
    {
        IEnumerable<string> fields =
            node.Fields
                .Select(f => $"(\"{f.Name}\", {ToIdrisTypeString(f.Type)})");

        stringBuilder.AppendLine("export");
        stringBuilder.AppendLine($"{node.Name} : Type");
        stringBuilder.AppendLine($"{node.Name} = GCAnyPtr");
        stringBuilder.AppendLine();

        stringBuilder.AppendLine("export");
        stringBuilder.AppendLine($"Mk{node.Name} : {node.Name}");
        stringBuilder.AppendLine($"Mk{node.Name} = unsafePerformIO (Mk_) where");
        stringBuilder.AppendLine(
@$"  Mk_ : IO GCAnyPtr
  Mk_ = do
    res <- malloc {node.SizeInBytes}
    io_pure (unsafeCast res)
    -- onCollectAny res free");
        stringBuilder.AppendLine();

        foreach (var field in node.Fields)
        {
            stringBuilder.AppendLine("export");
            stringBuilder.AppendLine($"{node.Name}_{field.Name} : {node.Name} -> {ToIdrisTypeString(field.Type)}");

            if ((field.Type == DataTypes.SSize) || (field.Type == DataTypes.USize))
            {
                stringBuilder.AppendLine($"{node.Name}_{field.Name} u = unsafePerformIO (primIO (deref_as_int (unsafeCast u)))");
            }
            else
            {
                stringBuilder.AppendLine($"{node.Name}_{field.Name} = believe_me");
            }

            stringBuilder.AppendLine();
        }
    }

    public static void WriteEnum(StringBuilder stringBuilder, Enum node)
    {
        stringBuilder.AppendLine("export");
        stringBuilder.AppendLine($"{node.Name} : Type");
        stringBuilder.AppendLine($"{node.Name} = Int");

        //stringBuilder.AppendLine($"data {node.Name} = {string.Join(" | ", node.)}");
    }

    public static void WriteFunction(StringBuilder stringBuilder, string moduleName, Function node)
    {
        IEnumerable<string> paramAndReturnTypes =
            node.Parameters
                .Select(p => ToIdrisTypeString(p.Type))
                .Concat(new[] { $"PrimIO {ToIdrisTypeString(node.ReturnType)}" });

        stringBuilder.AppendLine($"%foreign \"C:{node.Name},{moduleName}\"");
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
            _ when dataType is ArrayType arrayType => $"Ptr {ToIdrisTypeString(arrayType.ElementType)}",
            _ when dataType is StructType structType => structType.Struct.Name,
            _ when dataType is EnumType enumType => enumType.Enum.Name,
            _ when dataType is UnionType unionType => unionType.Union.Name,
            _ => throw new NotImplementedException()
        };
}