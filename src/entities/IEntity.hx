package entities;

import db.IDatabase;
import db.Record;
import promises.Promise;

interface IEntity<T> {
    public var db:IDatabase;
    public function load(id:Int):Promise<T>;
    private function definition():EntityDefinition;
    private function fromData(records:Array<Record>, fieldPrefix:String = null, depth:Int = 0):Void;
}
