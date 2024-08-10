package cases;

import cases.fakeorg.Worker;
import db.IDatabase;
import haxe.CallStack;
import haxe.io.Bytes;
import cases.basic.BasicEntity;
import utest.Assert;
import entities.EntityManager;
import cases.fakeorg.DBCreator;
import utest.Async;

@:timeout(20000)
class TestLimits extends TestBase {
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

    function testBasicLimits(async:Async) {
        Worker.all().then(workers -> {
            Assert.equals(4, workers.length);
            return Worker.all(2);
        }).then(workers -> {
            Assert.equals(2, workers.length);
            return Worker.all(Query.query($workerId = 1 || $workerId = 2 || $workerId = 3 || $workerId = 4), 3);
        }).then(workers -> {
            Assert.equals(3, workers.length);
            async.done();
        }, error -> {
            trace("error", error);
            async.done();
        });
    }
}