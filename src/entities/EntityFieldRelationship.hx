package entities;

enum EntityFieldRelationship {
    OneToOne(table1:String, field1:String, table2:String, field2:String);
    OneToMany(table1:String, field1:String, table2:String, field2:String);
}
