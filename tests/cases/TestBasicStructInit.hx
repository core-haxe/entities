package cases;

import db.IDatabase;
import utest.Assert;
import cases.basic.BasicEntityStructInit;
import entities.EntityManager;
import cases.basic.DBCreator;
import utest.Async;

@:timeout(2000)
class TestBasicStructInit extends TestBase {
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

    function testBasicCreation(async:Async) {
        var basic:BasicEntityStructInit = {}
        Assert.equals(1, 1);
        async.done();
    }
}