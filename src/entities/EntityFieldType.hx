package entities;

enum EntityFieldType {
    Unknown;
    Boolean;
    Number;
    Text;
    Date;
    Binary;
    Array(type:EntityFieldType);
    Class(className:String, relationship:EntityFieldRelationship, type:EntityFieldType);
}