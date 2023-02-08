package entities;

typedef EntityDefinition = {
    var tableName:String;
    var primaryKeyName:String;
    var fields:Array<EntityFieldDefinition>;
    var ?order:Int;
    var ?className:String;
}
