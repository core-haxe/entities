package cases;

import cases.basic.BasicEntity;
import utest.Assert;
import entities.EntityManager;
import cases.basic.DBCreator;
import utest.Async;
import utest.Test;

@:timeout(2000)
class TestMultipleCalls extends Test {
    function setupClass() {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
    }

    function teardownClass() {
        logging.LogManager.instance.clearAdaptors();
    }

    function setup(async:Async) {
        new DBCreator().create(false).then(_ -> {
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function teardown(async:Async) {
        EntityManager.instance.reset();
        async.done();
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