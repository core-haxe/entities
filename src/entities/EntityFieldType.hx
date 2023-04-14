package entities;

enum EntityFieldType {
    Boolean;
    Number;
    Text;
    Date;
    Class(className:String, relationship:EntityFieldRelationship, type:EntityFieldType);
}