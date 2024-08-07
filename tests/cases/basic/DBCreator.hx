package cases.basic;

import haxe.io.Bytes;
import promises.PromiseUtils;
import promises.Promise;

class DBCreator extends DBCreatorBase {
    public function new() {
        super();
        sqliteFilename = "basic.db";
    }

    public override function resetEntities() {
        super.resetEntities();
        @:privateAccess BasicEntity._checkedTables = false;
        @:privateAccess BasicEntityStructInit._checkedTables = false;
    }

    public override function createDummyData() {
        return new Promise((resolve, reject) -> {
            var list = [];

            var basicEntity = new BasicEntity();
            basicEntity.boolField = true;
            basicEntity.intField = 1111;
            basicEntity.floatField = 2222.3333;
            basicEntity.stringField = "this is a string";
            basicEntity.dateField = new Date(2001, 5, 6, 17, 8, 9);
            basicEntity.bytesField = Bytes.ofString("these are bytes");
            basicEntity.arrayOfStrings = ["string 1", "string 2", "string 3", "string 2"];
            /*
            basicEntity.arrayOfInts = [1111, 2222, 3333, 4444, 5555, 1111, 2222, 3333, 4444, 5555];
            basicEntity.arrayOfNullInts = [null, 6666, null, null, 7777, 8888, null];
            basicEntity.arrayOfFloats = [1.11, 2.22, 3.33];
            basicEntity.arrayOfNullFloats = [4.44, null, 5.55];
            basicEntity.arrayOfBools = [true, false, true];
            basicEntity.arrayOfNullBools = [true, null, false];
            basicEntity.arrayOfDates = [new Date(2011, 1, 2, 3, 4, 5), new Date(2012, 4, 5, 6, 7, 8), new Date(2013, 7, 8, 9, 10, 11)];
            basicEntity.arrayOfBytes = [Bytes.ofString("bytes 1"), Bytes.ofString("bytes 2"), Bytes.ofString("bytes 3")];
            basicEntity.structInitEntityArray = [{}];
            */
            list.push(basicEntity.add);

            PromiseUtils.runSequentially(list).then(result -> {
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }
}