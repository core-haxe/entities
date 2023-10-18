package cases;

import cases.user.User;
import utest.Assert;
import entities.EntityManager;
import cases.user.DBCreator;
import utest.Async;
import haxe.io.Bytes;

@:timeout(20000)
class TestUser extends TestBase {
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

    function testSimpleProperies(async:Async) {
        start("TestUser.testSimpleProperies");
        User.findByProperty("user.login.special.hash", "ihar123456").then(user -> {
            Assert.notNull(user);

            Assert.equals("ihar", user.username);
            Assert.equals(1, user.properties.length);
            Assert.equals("ihar123456", user.getProperty("user.login.special.hash"));

            complete();
            async.done();
        }, error -> {
            trace(error);
            async.done();
        });
    }
}