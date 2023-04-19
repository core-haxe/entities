package cases;

import utest.Assert;
import cases.basic.BasicEntityStructInit;
import entities.EntityManager;
import cases.basic.DBCreator;
import utest.Async;
import utest.Test;

@:timeout(2000)
class TestBasicStructInit extends TestBase {
    function setupClass() {
        logging.LogManager.instance.addAdaptor(new logging.adaptors.ConsoleLogAdaptor({
            levels: [logging.LogLevel.Info, logging.LogLevel.Error]
        }));
    }

    function teardownClass() {
        logging.LogManager.instance.clearAdaptors();
    }

    function setup(async:Async) {
        new DBCreator().create().then(_ -> {
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function teardown(async:Async) {
        EntityManager.instance.reset();
        async.done();
    }

    function testBasicCreation(async:Async) {
        var basic:BasicEntityStructInit = {}
        Assert.equals(1, 1);
        async.done();
    }
}