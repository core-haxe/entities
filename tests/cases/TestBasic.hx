package cases;

import cases.basic.BasicEntity;
import utest.Assert;
import entities.EntityManager;
import cases.basic.DBCreator;
import utest.Async;
import utest.Test;

@:timeout(2000)
class TestBasic extends Test {
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

    function testString(async:Async) {
        BasicEntity.findById(1).then(basic -> {
            Assert.equals(1111, basic.intField);
            Assert.equals(2222.3333, basic.floatField);
            Assert.equals("this is a string", basic.stringField);
            async.done();
        }, error -> {
            trace(error);
        });
    }
}