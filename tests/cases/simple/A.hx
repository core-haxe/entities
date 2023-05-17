package cases.simple;

import entities.IEntity;

class A implements IEntity {
    public var name:String;

    public var entity1:B;
    public var entity2:B;
    public var entityArray:Array<B>;
    public var entityArray2:Array<B>;

    public var simpleC:C;
}