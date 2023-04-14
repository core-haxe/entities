package cases.basic;

import promises.PromiseUtils;
import entities.EntityManager;
import db.DatabaseFactory;
import sys.io.File;
import db.IDatabase;
import promises.Promise;

class DBCreator {
    public var db:IDatabase;
    public var filename:String = "basic.db";

    public function new() {
        
    }

    public function clear() {
        return new Promise((resolve, reject) -> {
            File.saveContent(filename, "");
            resolve(true);
        });
    }
    
    public function create() {
        return new Promise((resolve, reject) -> {
            clear().then(_ -> {
                File.saveContent(filename, "");
                var db = DatabaseFactory.instance.createDatabase("sqlite", {
                    filename: filename
                });
                this.db = db;
                return db.connect();
            }).then(_ -> {
                EntityManager.instance.database = db;
                return createDummyData();
            }).then(_ -> {
                resolve(true);                
            }, error -> {
                reject(error);
            });
        });
    }

    public function createDummyData() {
        return new Promise((resolve, reject) -> {
            var list = [];

            var basicEntity = new BasicEntity();
            basicEntity.boolField = true;
            basicEntity.intField = 1111;
            basicEntity.floatField = 2222.3333;
            basicEntity.stringField = "this is a string";
            list.push(basicEntity.add);

            PromiseUtils.runSequentially(list).then(result -> {
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }
}