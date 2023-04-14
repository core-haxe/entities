package entities;

enum EntityFieldType {
    Boolean;
    Number;
    Text;
    Class(className:String, relationship:EntityFieldRelationship, type:EntityFieldType);
}