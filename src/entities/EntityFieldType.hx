package entities;

enum EntityFieldType {
    Unknown;
    Boolean;
    Number;
    Decimal;
    Text;
    Date;
    Binary;
    Array(type:EntityFieldType);
    Class(className:String, relationship:EntityFieldRelationship, type:EntityFieldType);
}