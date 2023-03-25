package entities;

enum EntityFieldType {
    Number;
    Text;
    Class(className:String, relationship:EntityFieldRelationship, type:EntityFieldType);
}