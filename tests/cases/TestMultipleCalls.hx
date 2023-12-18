package cases;

import db.IDatabase;
import cases.basic.BasicEntity;
import utest.Assert;
import entities.EntityManager;
import cases.basic.DBCreator;
import utest.Async;
import utest.Test;

@:timeout(2000)
class TestMultipleCalls extends Test {
    private var db:IDatabase;

    public function new(db:IDatabase) {
        super();
        this.db = db;
    }

    function setup(async:Async) {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
        new DBCreator().create(db).then(_ -> {
            async.done();
        });
    }

    function teardown(async:Async) {
        logging.LogManager.instance.clearAdaptors();
        EntityManager.instance.reset().then(_ -> {
            new DBCreator().cleanUp();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testEnsureCheckTablesMultipleCalls(async:Async) {
        var max = 1000;
        Assert.equals(1, 1);
        for (_ in 0...max) {
            @:privateAccess BasicEntity.CheckTables().then(_ -> {
                max--;
                if (max == 0) {
                    async.done();
                }
            }, error -> {
                trace("error", error);
            });
        }
    }

    function testEnsureFindMultipleCalls(async:Async) {
        var max = 1000;
        Assert.equals(1, 1);
        for (_ in 0...max) {
            BasicEntity.findById(-1).then(_ -> {
                max--;
                if (max == 0) {
                    async.done();
                }
            }, error -> {
                trace("error", error);
            });
        }
    }
}