package cases;

import sys.FileSystem;
import promises.Promise;
import db.IDatabase;
import db.sqlite.SqliteDatabase;
import entities.EntityManager;
import sys.io.File;

class DBCreatorBase {
    public var sqliteFilename:String = null;

    public function new() {

    }

    public function create(db:IDatabase, createData:Bool = true) {
        return new Promise((resolve, reject) -> {
            if ((db is SqliteDatabase) && sqliteFilename != null) {
                File.saveContent(sqliteFilename, "");
            }

            EntityManager.instance.database = db;
            if (!createData) {
                resolve(true);
            } else {
                createDummyData().then(_ -> {
                    resolve(true);
                }, error -> {
                    trace(haxe.Json.stringify(error));
                    trace("error", error);
                });
            }
        });
    }

    public function createDummyData() {
        return new Promise((resolve, reject) -> {
            resolve(true);
        });
    }

    public function cleanUp() {
        try {
            if (sqliteFilename != null && FileSystem.exists(sqliteFilename)) {
                FileSystem.deleteFile(sqliteFilename);
            }
        } catch (e:Dynamic) {
            trace(e);
        }
    }
}