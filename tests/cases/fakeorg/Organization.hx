package cases.fakeorg;

import db.Query;
import entities.IEntity;
import promises.Promise;

class Organization implements IEntity {
    public var name:String;
    @:cascade
    public var address:Address;
    public var icon:Icon;

    public var workers(get, null):Promise<Array<Worker>>;
    private function get_workers():Promise<Array<Worker>> {
        return Worker.all(Query.query($Worker_Organization.organizationId = organizationId));
    }
}