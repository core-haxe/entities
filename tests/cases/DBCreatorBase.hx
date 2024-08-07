package cases;

import haxe.Json;
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

            resetEntities();
            EntityManager.instance.database = db;
            @:privateAccess EntityManager.instance.connect().then(_ -> {
                return db.delete();
            }).then(_ -> {
                return db.create();
            }).then(_ -> {
                if (!createData) {
                    return null;
                }
                return createDummyData();
            }).then(_ -> {
                resolve(true);
            }, error -> {
                trace(error);
                trace(Json.stringify(error));
            });
        });
    }

    public function resetEntities() {

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