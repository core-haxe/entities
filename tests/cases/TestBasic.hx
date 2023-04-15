package cases;

import haxe.io.Bytes;
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
            Assert.equals(2001, basic.dateField.getFullYear());
            Assert.equals(5, basic.dateField.getMonth());
            Assert.equals(6, basic.dateField.getDate());
            Assert.equals(17, basic.dateField.getHours());
            Assert.equals(8, basic.dateField.getMinutes());
            Assert.equals(9, basic.dateField.getSeconds());
            #if !neko
            Assert.isOfType(basic.bytesField, Bytes);
            Assert.equals(Bytes.ofString("these are bytes").toString(), basic.bytesField.toString());
            #end
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testBasicUpdateTypes(async:Async) {
        var basicRef:BasicEntity = null;
        BasicEntity.findById(1).then(basic -> {
            basicRef = basic;
            Assert.equals(true, basic.boolField);
            Assert.equals(1111, basic.intField);
            Assert.equals(2222.3333, basic.floatField);
            Assert.equals("this is a string", basic.stringField);
            Assert.equals(2001, basic.dateField.getFullYear());
            Assert.equals(5, basic.dateField.getMonth());
            Assert.equals(6, basic.dateField.getDate());
            Assert.equals(17, basic.dateField.getHours());
            Assert.equals(8, basic.dateField.getMinutes());
            Assert.equals(9, basic.dateField.getSeconds());
            #if !neko
            Assert.isOfType(basic.bytesField, Bytes);
            Assert.equals(Bytes.ofString("these are bytes").toString(), basic.bytesField.toString());
            #end

            basic.boolField = false;
            basic.intField = 2222;
            basic.floatField = 3333.4444;
            basic.stringField = "this is an updated string";
            basic.dateField = new Date(2002, 6, 7, 18, 9, 10);
            basic.bytesField = Bytes.ofString("these are updated bytes");

            return basic.update();
        }).then(success -> {
            return basicRef.refresh(); // lets refresh just to make sure
        }).then(basic -> {
            Assert.equals(false, basic.boolField);
            Assert.equals(2222, basic.intField);
            Assert.equals(3333.4444, basic.floatField);
            Assert.equals("this is an updated string", basic.stringField);
            Assert.equals(2002, basic.dateField.getFullYear());
            Assert.equals(6, basic.dateField.getMonth());
            Assert.equals(7, basic.dateField.getDate());
            Assert.equals(18, basic.dateField.getHours());
            Assert.equals(9, basic.dateField.getMinutes());
            Assert.equals(10, basic.dateField.getSeconds());
            #if !neko
            Assert.isOfType(basic.bytesField, Bytes);
            Assert.equals(Bytes.ofString("these are updated bytes").toString(), basic.bytesField.toString());
            #end
            
            async.done();
        }, error -> {
            trace(error);
        });
    }
}