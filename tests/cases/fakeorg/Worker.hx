package cases.fakeorg;

import entities.IEntity;

class Worker implements IEntity {
    public var username:String;
    @:cascade
    public var address:Address;
    public var icon:Icon;
    public var organizations:Array<Organization>;
}