package cases;

import db.IDatabase;
import cases.simple.C;
import cases.simple.B;
import cases.simple.A;
import utest.Assert;
import entities.EntityManager;
import cases.simple.DBCreator;
import utest.Async;

@:timeout(20000)
class TestSimple extends TestBase {
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

    function testMulitpleEntitiesOfSameType(async:Async) {
        start("TestBasic.testMulitpleEntitiesOfSameType");
        var entityA = new A();
        entityA.name = "Entity A";
        entityA.simpleC = new C();
        entityA.simpleC.name = "Entity A - Simple C";

        entityA.entity1 = new B();
        entityA.entity1.name = "Entity A1";
        entityA.entity1.simpleC = new C();
        entityA.entity1.simpleC.name = "Entity A1 - Simple C";

        entityA.entity2 = new B();
        entityA.entity2.name = "Entity A2";
        entityA.entity2.simpleC = new C();
        entityA.entity2.simpleC.name = "Entity A2 - Simple C";

        entityA.entityArray = [];
        var entity = new B();
        entity.name = "Array Entity A - 1";
        entity.simpleC = new C();
        entity.simpleC.name = "Array Entity A - 1 - Simple C";
        entityA.entityArray.push(entity);
        var entity = new B();
        entity.name = "Array Entity A - 2";
        entity.simpleC = new C();
        entity.simpleC.name = "Array Entity A - 2 - Simple C";
        entityA.entityArray.push(entity);
        var entity = new B();
        entity.name = "Array Entity A - 3";
        entity.simpleC = new C();
        entity.simpleC.name = "Array Entity A - 3 - Simple C";
        entityA.entityArray.push(entity);

        entityA.entityArray2 = [];
        var entity = new B();
        entity.name = "Array Entity A - 4";
        entity.simpleC = new C();
        entity.simpleC.name = "Array Entity A - 4 - Simple C";
        entityA.entityArray2.push(entity);
        var entity = new B();
        entity.name = "Array Entity A - 5";
        entity.simpleC = new C();
        entity.simpleC.name = "Array Entity A - 5 - Simple C";
        entityA.entityArray2.push(entity);

        entityA.add().then(_ -> {
            return A.findById(1);
        }).then(simple -> {
            Assert.equals("Entity A", simple.name);
            Assert.notNull(simple.simpleC);
            //trace(simple.simpleC);
            Assert.equals("Entity A - Simple C", simple.simpleC.name);

            Assert.notNull(simple.entity1);
            Assert.equals("Entity A1", simple.entity1.name);
            Assert.notNull(simple.entity1.simpleC);
            Assert.equals("Entity A1 - Simple C", simple.entity1.simpleC.name);

            Assert.notNull(simple.entity2);
            Assert.equals("Entity A2", simple.entity2.name);
            Assert.notNull(simple.entity2.simpleC);
            Assert.equals("Entity A2 - Simple C", simple.entity2.simpleC.name);

            Assert.equals(3, simple.entityArray.length);
            AssertionTools.shouldContain({ name: "Array Entity A - 1", simpleC: { name: "Array Entity A - 1 - Simple C" } }, simple.entityArray);
            AssertionTools.shouldContain({ name: "Array Entity A - 2", simpleC: { name: "Array Entity A - 2 - Simple C" } }, simple.entityArray);
            AssertionTools.shouldContain({ name: "Array Entity A - 3", simpleC: { name: "Array Entity A - 3 - Simple C" } }, simple.entityArray);

            Assert.equals(2, simple.entityArray2.length);
            AssertionTools.shouldContain({ name: "Array Entity A - 4", simpleC: { name: "Array Entity A - 4 - Simple C" } }, simple.entityArray2);
            AssertionTools.shouldContain({ name: "Array Entity A - 5", simpleC: { name: "Array Entity A - 5 - Simple C" } }, simple.entityArray2);

            complete();
            async.done();
        }, error -> {
            trace(error);
            //async.done();
        });
    }
}