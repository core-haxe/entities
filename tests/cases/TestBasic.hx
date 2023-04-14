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

    function testBasicTypes(async:Async) {
        BasicEntity.findById(1).then(basic -> {
            Assert.equals(true, basic.boolField);
            Assert.equals(1111, basic.intField);
            Assert.equals(2222.3333, basic.floatField);
            Assert.equals("this is a string", basic.stringField);
            Assert.equals(1234, basic.dateField.getFullYear());
            Assert.equals(5, basic.dateField.getMonth());
            Assert.equals(6, basic.dateField.getDate());
            Assert.equals(17, basic.dateField.getHours());
            Assert.equals(8, basic.dateField.getMinutes());
            Assert.equals(9, basic.dateField.getSeconds());
            async.done();
        }, error -> {
            trace(error);
        });
    }
}