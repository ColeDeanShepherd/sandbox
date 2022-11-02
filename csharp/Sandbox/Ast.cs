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
public record Union(string Name, List<Field> Fields, uint SizeInBytes);
public record Enum(string Name);
public record Field(string Name, DataType Type, uint OffsetInBytes);
public record Function(string Name, List<Parameter> Parameters, DataType ReturnType);
public record Parameter(string Name, DataType Type);

public record Program(
    Dictionary<string, Struct> Structs,
    Dictionary<string, Union> Unions,
    Dictionary<string, Enum> Enums,
    Dictionary<string, Function> Functions);