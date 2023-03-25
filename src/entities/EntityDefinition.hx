package entities;

typedef EntityDefinition = {
    var tableName:String;
    var primaryKeyFieldName:String;
    var primaryKeyFieldType:EntityFieldType;
    var ?primarayKeyFieldAutoIncrement:Bool;
    var fields:Array<EntityFieldDefinition>;
}