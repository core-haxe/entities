package entities;

enum EntityFieldType {
    Boolean;
    Number;
    Text;
    Date;
    Binary;
    Class(className:String, relationship:EntityFieldRelationship, type:EntityFieldType);
}