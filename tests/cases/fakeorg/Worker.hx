package cases.fakeorg;

import haxe.io.Bytes;
import entities.IEntity;

class Worker implements IEntity {
    public var username:String;
    @:cascade
    public var address:Address;
    public var icon:Icon;
    public var organizations:Array<Organization>;
    public var contractDocument:Bytes;
}