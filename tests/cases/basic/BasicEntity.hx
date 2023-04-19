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
    public var structInitEntity:BasicEntityStructInit;
    public var structInitEntityArray:Array<BasicEntityStructInit>;
    public var arrayOfStrings:Array<String>;
    /*
    public var arrayOfInts:Array<Int>;
    public var arrayOfNullInts:Array<Null<Int>>;
    public var arrayOfFloats:Array<Float>;
    public var arrayOfNullFloats:Array<Null<Float>>;
    public var arrayOfBools:Array<Bool>;
    public var arrayOfNullBools:Array<Null<Bool>>;
    public var arrayOfDates:Array<Null<Date>>;
    public var arrayOfBytes:Array<Null<Bytes>>;
    */
}