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
            Assert.equals(7, user.properties.length);
            Assert.equals("ihar123456", user.getProperty("user.login.special.hash"));
            Assert.equals(101, user.getProperty("user.login.count"));
            Assert.equals(82.7, user.getProperty("user.login.percent"));
            Assert.equals(true, user.getProperty("user.login.isAdmin"));
            Assert.equals("ihar.specific.value", user.getProperty("some.shared.property1"));
            Assert.equals("shared.value_A", user.getProperty("some.shared.property2"));
            Assert.equals("shared.value_B", user.getProperty("some.shared.property3"));

            return User.findByProperty("user.login.special.hash", "bob123456");
        }).then(user -> {
            Assert.equals("bbar", user.username);
            Assert.equals(4, user.properties.length);
            Assert.equals("bob123456", user.getProperty("user.login.special.hash"));
            Assert.equals("bob.specific.value", user.getProperty("some.shared.property1"));
            Assert.equals("shared.value_A", user.getProperty("some.shared.property2"));
            Assert.equals("shared.value_C", user.getProperty("some.shared.property3"));

            return User.findByProperty("user.login.special.hash", "tim123456");
        }).then(user -> {
            Assert.equals("ttim", user.username);
            Assert.equals(4, user.properties.length);
            Assert.equals("tim123456", user.getProperty("user.login.special.hash"));
            Assert.equals("tim.specific.value", user.getProperty("some.shared.property1"));
            Assert.equals("shared.value_C", user.getProperty("some.shared.property2"));
            Assert.equals("shared.value_B", user.getProperty("some.shared.property3"));

            complete();
            async.done();
        }, error -> {
            trace(error);
            async.done();
        });
    }

    function testSimpleProperiesWithMultipleResults(async:Async) {
        start("TestUser.testSimpleProperiesWithMultipleResults");

        User.findAllByProperty("user.login.special.hash", "ihar123456").then(users -> {
            Assert.equals(1, users.length);

            Assert.equals("ihar", users[0].username);
            Assert.equals(7, users[0].properties.length);
            Assert.equals("ihar123456", users[0].getProperty("user.login.special.hash"));
            Assert.equals(101, users[0].getProperty("user.login.count"));
            Assert.equals(82.7, users[0].getProperty("user.login.percent"));
            Assert.equals(true, users[0].getProperty("user.login.isAdmin"));
            Assert.equals("ihar.specific.value", users[0].getProperty("some.shared.property1"));
            Assert.equals("shared.value_A", users[0].getProperty("some.shared.property2"));
            Assert.equals("shared.value_B", users[0].getProperty("some.shared.property3"));

            return User.findAllByProperty("some.shared.property2", "shared.value_A");
        }).then(users -> {
            Assert.equals(2, users.length);

            Assert.equals("ihar", users[0].username);
            Assert.equals(7, users[0].properties.length);
            Assert.equals("ihar123456", users[0].getProperty("user.login.special.hash"));
            Assert.equals(101, users[0].getProperty("user.login.count"));
            Assert.equals(82.7, users[0].getProperty("user.login.percent"));
            Assert.equals(true, users[0].getProperty("user.login.isAdmin"));
            Assert.equals("ihar.specific.value", users[0].getProperty("some.shared.property1"));
            Assert.equals("shared.value_A", users[0].getProperty("some.shared.property2"));
            Assert.equals("shared.value_B", users[0].getProperty("some.shared.property3"));

            Assert.equals("bbar", users[1].username);
            Assert.equals(4, users[1].properties.length);
            Assert.equals("bob123456", users[1].getProperty("user.login.special.hash"));
            Assert.equals("bob.specific.value", users[1].getProperty("some.shared.property1"));
            Assert.equals("shared.value_A", users[1].getProperty("some.shared.property2"));
            Assert.equals("shared.value_C", users[1].getProperty("some.shared.property3"));

            return User.findAllByProperty("some.shared.property3", "shared.value_B");
        }).then(users -> {
            Assert.equals(2, users.length);

            Assert.equals("ihar", users[0].username);
            Assert.equals(7, users[0].properties.length);
            Assert.equals("ihar123456", users[0].getProperty("user.login.special.hash"));
            Assert.equals(101, users[0].getProperty("user.login.count"));
            Assert.equals(82.7, users[0].getProperty("user.login.percent"));
            Assert.equals(true, users[0].getProperty("user.login.isAdmin"));
            Assert.equals("ihar.specific.value", users[0].getProperty("some.shared.property1"));
            Assert.equals("shared.value_A", users[0].getProperty("some.shared.property2"));
            Assert.equals("shared.value_B", users[0].getProperty("some.shared.property3"));

            Assert.equals("ttim", users[1].username);
            Assert.equals(4, users[1].properties.length);
            Assert.equals("tim123456", users[1].getProperty("user.login.special.hash"));
            Assert.equals("tim.specific.value", users[1].getProperty("some.shared.property1"));
            Assert.equals("shared.value_C", users[1].getProperty("some.shared.property2"));
            Assert.equals("shared.value_B", users[1].getProperty("some.shared.property3"));

            complete();
            async.done();
        }, error -> {
            trace(error);
            async.done();
        });
    }
}