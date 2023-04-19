package cases.fakeorg;

import Query;
import promises.Promise;
import haxe.io.Bytes;
import entities.IEntity;

class Worker implements IEntity {
    public var username:String;
    @:cascade
    public var address:Address;
    public var icon:Icon;
    public var organizations:Array<Organization>;
    public var contractDocument:Bytes;
    public var startDate:Date;
    public var images:Array<Image>;
    public var thumbs:Array<Image>;

    public static function findByStartDates(start:Date, end:Date):Promise<Array<Worker>> {
        return Worker.all(Query.query($startDate >= start && $startDate <= end));
    }
}