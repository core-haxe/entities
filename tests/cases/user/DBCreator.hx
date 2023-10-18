package cases.user;

import promises.PromiseUtils;
import entities.EntityManager;
import db.DatabaseFactory;
import sys.io.File;
import db.IDatabase;
import promises.Promise;

class DBCreator {
    public var db:IDatabase;
    public var filename:String = "users.db";

    public function new() {
        
    }

    public function clear() {
        return new Promise((resolve, reject) -> {
            File.saveContent(filename, "");
            resolve(true);
        });
    }
    
    public function create(createData:Bool = true) {
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
                if (createData) {
                    return createDummyData();
                }
                return null;
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

            var ian = new User();
            ian.username = "ihar";
            ian.addProperty("user.login.special.hash", "ihar123456");
            ian.addProperty("user.login.count", 101);
            ian.addProperty("user.login.percent", 82.7);
            ian.addProperty("user.login.isAdmin", true);
            


            list.push(ian.add);

            PromiseUtils.runSequentially(list).then(result -> {
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }
}