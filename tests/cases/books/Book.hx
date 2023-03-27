package cases.books;

import entities.IEntity;

class Book implements IEntity {
    public var isbn:String;
    public var title:String;
    public var subTitle:String;
    public var authors:Array<Author>;
    public var published:String; // TODO: use date
    public var publisher:Publisher;
    public var pages:Int;
    public var description:String;
    public var categories:Array<Category>;
}