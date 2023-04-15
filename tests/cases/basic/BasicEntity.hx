package cases.basic;

import haxe.io.Bytes;
import entities.IEntity;

class BasicEntity implements IEntity {
    public var boolField:Bool;
    public var intField:Int;
    public var floatField:Float;
    public var stringField:String;    
    public var dateField:Date;
    public var bytesField:Bytes;
}