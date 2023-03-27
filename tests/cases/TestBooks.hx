package cases;

import utest.Assert;
import entities.EntityManager;
import utest.Async;
import utest.Test;
import cases.books.DBCreator;

@:timeout(2000)
class TestBooks extends Test {

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

    function testBasicBook(async:Async) {
        Assert.equals(1, 1);
        async.done();
    }
}