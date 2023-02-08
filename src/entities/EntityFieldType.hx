package entities;

enum EntityFieldType {
    Integer;
    String;
    Class(type:String, relationship:EntityFieldRelationship);
}
