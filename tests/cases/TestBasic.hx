package cases;

import haxe.CallStack;
import haxe.io.Bytes;
import cases.basic.BasicEntity;
import utest.Assert;
import entities.EntityManager;
import cases.basic.DBCreator;
import utest.Async;

@:timeout(20000)
class TestBasic extends TestBase {
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
        start("TestBasic.testBasicTypes");

        BasicEntity.findById(1).then(basic -> {
            check("got record");
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

            Assert.equals(4, basic.arrayOfStrings.length);
            Assert.equals("string 1", basic.arrayOfStrings[0]);
            Assert.equals("string 2", basic.arrayOfStrings[1]);
            Assert.equals("string 3", basic.arrayOfStrings[2]);
            Assert.equals("string 2", basic.arrayOfStrings[3]);

            /*
            Assert.equals(10, basic.arrayOfInts.length);
            Assert.equals(1111, basic.arrayOfInts[0]);
            Assert.equals(2222, basic.arrayOfInts[1]);
            Assert.equals(3333, basic.arrayOfInts[2]);
            Assert.equals(4444, basic.arrayOfInts[3]);
            Assert.equals(5555, basic.arrayOfInts[4]);
            Assert.equals(1111, basic.arrayOfInts[5]);
            Assert.equals(2222, basic.arrayOfInts[6]);
            Assert.equals(3333, basic.arrayOfInts[7]);
            Assert.equals(4444, basic.arrayOfInts[8]);
            Assert.equals(5555, basic.arrayOfInts[9]);

            Assert.equals(7, basic.arrayOfNullInts.length);
            Assert.equals(null, basic.arrayOfNullInts[0]);
            Assert.equals(6666, basic.arrayOfNullInts[1]);
            Assert.equals(null, basic.arrayOfNullInts[2]);
            Assert.equals(null, basic.arrayOfNullInts[3]);
            Assert.equals(7777, basic.arrayOfNullInts[4]);
            Assert.equals(8888, basic.arrayOfNullInts[5]);
            Assert.equals(null, basic.arrayOfNullInts[6]);

            Assert.equals(3, basic.arrayOfFloats.length);
            Assert.equals(1.11, basic.arrayOfFloats[0]);
            Assert.equals(2.22, basic.arrayOfFloats[1]);
            Assert.equals(3.33, basic.arrayOfFloats[2]);

            Assert.equals(3, basic.arrayOfNullFloats.length);
            Assert.equals(4.44, basic.arrayOfNullFloats[0]);
            Assert.equals(null, basic.arrayOfNullFloats[1]);
            Assert.equals(5.55, basic.arrayOfNullFloats[2]);

            Assert.equals(3, basic.arrayOfBools.length);
            Assert.equals(true, basic.arrayOfBools[0]);
            Assert.equals(false, basic.arrayOfBools[1]);
            Assert.equals(true, basic.arrayOfBools[2]);

            Assert.equals(3, basic.arrayOfNullBools.length);
            Assert.equals(true, basic.arrayOfNullBools[0]);
            Assert.equals(null, basic.arrayOfNullBools[1]);
            Assert.equals(false, basic.arrayOfNullBools[2]);

            Assert.equals(3, basic.arrayOfDates.length);
            Assert.equals(2011, basic.arrayOfDates[0].getFullYear());
            Assert.equals(1, basic.arrayOfDates[0].getMonth());
            Assert.equals(2, basic.arrayOfDates[0].getDate());
            Assert.equals(3, basic.arrayOfDates[0].getHours());
            Assert.equals(4, basic.arrayOfDates[0].getMinutes());
            Assert.equals(5, basic.arrayOfDates[0].getSeconds());
            Assert.equals(2012, basic.arrayOfDates[1].getFullYear());
            Assert.equals(4, basic.arrayOfDates[1].getMonth());
            Assert.equals(5, basic.arrayOfDates[1].getDate());
            Assert.equals(6, basic.arrayOfDates[1].getHours());
            Assert.equals(7, basic.arrayOfDates[1].getMinutes());
            Assert.equals(8, basic.arrayOfDates[1].getSeconds());
            Assert.equals(2013, basic.arrayOfDates[2].getFullYear());
            Assert.equals(7, basic.arrayOfDates[2].getMonth());
            Assert.equals(8, basic.arrayOfDates[2].getDate());
            Assert.equals(9, basic.arrayOfDates[2].getHours());
            Assert.equals(10, basic.arrayOfDates[2].getMinutes());
            Assert.equals(11, basic.arrayOfDates[2].getSeconds());

            #if !neko
            Assert.equals(3, basic.arrayOfBytes.length);
            Assert.equals(Bytes.ofString("bytes 1").toString(), basic.arrayOfBytes[0].toString());
            Assert.equals(Bytes.ofString("bytes 2").toString(), basic.arrayOfBytes[1].toString());
            Assert.equals(Bytes.ofString("bytes 3").toString(), basic.arrayOfBytes[2].toString());
            #end
            */

            complete();
            async.done();
        }, error -> {
            trace(error);
            trace(CallStack.toString(CallStack.exceptionStack(true)));
        });
    }

    function testBasicUpdateTypes(async:Async) {
        start("TestBasic.testBasicUpdateTypes");

        BasicEntity.findById(1).then(basic -> {
            check("got record");

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

            Assert.equals(4, basic.arrayOfStrings.length);
            Assert.equals("string 1", basic.arrayOfStrings[0]);
            Assert.equals("string 2", basic.arrayOfStrings[1]);
            Assert.equals("string 3", basic.arrayOfStrings[2]);
            Assert.equals("string 2", basic.arrayOfStrings[3]);

            basic.boolField = false;
            basic.intField = 2222;
            basic.floatField = 3333.4444;
            basic.stringField = "this is an updated string";
            basic.dateField = new Date(2002, 6, 7, 18, 9, 10);
            basic.bytesField = Bytes.ofString("these are updated bytes");

            basic.arrayOfStrings = ["updated string 1", "updated String 2"];
            /*
            basic.arrayOfInts = [1, 2, 3];
            basic.arrayOfNullInts = [4, null, 5];
            basic.arrayOfFloats = [1.1, 2.2, 3.3];
            basic.arrayOfNullFloats = [null, 4.4, null];
            basic.arrayOfBools = [true, true];
            basic.arrayOfNullBools = [false, true, null];
            basic.arrayOfDates = [new Date(2015, 8, 9, 10, 11, 12)];
            basic.arrayOfBytes = [Bytes.ofString("this is new bytes 1"), Bytes.ofString("this is new bytes 2")];
            */

            return basic.update();
        }).then(basic -> {
            check("updated record");

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

            Assert.equals(2, basic.arrayOfStrings.length);
            Assert.equals("updated string 1", basic.arrayOfStrings[0]);
            Assert.equals("updated String 2", basic.arrayOfStrings[1]);

            /*
            Assert.equals(3, basic.arrayOfInts.length);
            Assert.equals(1, basic.arrayOfInts[0]);
            Assert.equals(2, basic.arrayOfInts[1]);
            Assert.equals(3, basic.arrayOfInts[2]);

            Assert.equals(3, basic.arrayOfNullInts.length);
            Assert.equals(4, basic.arrayOfNullInts[0]);
            Assert.equals(null, basic.arrayOfNullInts[1]);
            Assert.equals(5, basic.arrayOfNullInts[2]);

            Assert.equals(3, basic.arrayOfFloats.length);
            Assert.equals(1.1, basic.arrayOfFloats[0]);
            Assert.equals(2.2, basic.arrayOfFloats[1]);
            Assert.equals(3.3, basic.arrayOfFloats[2]);

            Assert.equals(3, basic.arrayOfNullFloats.length);
            Assert.equals(null, basic.arrayOfNullFloats[0]);
            Assert.equals(4.4, basic.arrayOfNullFloats[1]);
            Assert.equals(null, basic.arrayOfNullFloats[2]);

            Assert.equals(1, basic.arrayOfDates.length);
            Assert.equals(2015, basic.arrayOfDates[0].getFullYear());
            Assert.equals(8, basic.arrayOfDates[0].getMonth());
            Assert.equals(9, basic.arrayOfDates[0].getDate());
            Assert.equals(10, basic.arrayOfDates[0].getHours());
            Assert.equals(11, basic.arrayOfDates[0].getMinutes());
            Assert.equals(12, basic.arrayOfDates[0].getSeconds());

            #if !neko
            Assert.equals(2, basic.arrayOfBytes.length);
            Assert.equals(Bytes.ofString("this is new bytes 1").toString(), basic.arrayOfBytes[0].toString());
            Assert.equals(Bytes.ofString("this is new bytes 2").toString(), basic.arrayOfBytes[1].toString());
            #end
            */

            return basic.refresh(); // lets refresh just to make sure
        }).then(basic -> {
            check("refreshed record");
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
            
            Assert.equals(2, basic.arrayOfStrings.length);
            Assert.equals("updated string 1", basic.arrayOfStrings[0]);
            Assert.equals("updated String 2", basic.arrayOfStrings[1]);

            /*
            Assert.equals(3, basic.arrayOfInts.length);
            Assert.equals(1, basic.arrayOfInts[0]);
            Assert.equals(2, basic.arrayOfInts[1]);
            Assert.equals(3, basic.arrayOfInts[2]);

            Assert.equals(3, basic.arrayOfNullInts.length);
            Assert.equals(4, basic.arrayOfNullInts[0]);
            Assert.equals(null, basic.arrayOfNullInts[1]);
            Assert.equals(5, basic.arrayOfNullInts[2]);

            Assert.equals(3, basic.arrayOfFloats.length);
            Assert.equals(1.1, basic.arrayOfFloats[0]);
            Assert.equals(2.2, basic.arrayOfFloats[1]);
            Assert.equals(3.3, basic.arrayOfFloats[2]);

            Assert.equals(3, basic.arrayOfNullFloats.length);
            Assert.equals(null, basic.arrayOfNullFloats[0]);
            Assert.equals(4.4, basic.arrayOfNullFloats[1]);
            Assert.equals(null, basic.arrayOfNullFloats[2]);

            Assert.equals(1, basic.arrayOfDates.length);
            Assert.equals(2015, basic.arrayOfDates[0].getFullYear());
            Assert.equals(8, basic.arrayOfDates[0].getMonth());
            Assert.equals(9, basic.arrayOfDates[0].getDate());
            Assert.equals(10, basic.arrayOfDates[0].getHours());
            Assert.equals(11, basic.arrayOfDates[0].getMinutes());
            Assert.equals(12, basic.arrayOfDates[0].getSeconds());

            #if !neko
            Assert.equals(2, basic.arrayOfBytes.length);
            Assert.equals(Bytes.ofString("this is new bytes 1").toString(), basic.arrayOfBytes[0].toString());
            Assert.equals(Bytes.ofString("this is new bytes 2").toString(), basic.arrayOfBytes[1].toString());
            #end
            */

            complete();
            async.done();
        }, error -> {
            trace(error);
        });
    }
}