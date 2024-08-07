package cases.user;

import promises.PromiseUtils;
import promises.Promise;

class DBCreator extends DBCreatorBase {
    public function new() {
        super();
        sqliteFilename = "users.db";
    }
    
    public override function resetEntities() {
        super.resetEntities();
        @:privateAccess User._checkedTables = false;
        @:privateAccess Property._checkedTables = false;
    }
    
    public override function createDummyData() {
        return new Promise((resolve, reject) -> {
            var list = [];

            var ian = new User();
            ian.username = "ihar";
            ian.addProperty("user.login.special.hash", "ihar123456");
            ian.addProperty("user.login.count", 101);
            ian.addProperty("user.login.percent", 82.7);
            ian.addProperty("user.login.isAdmin", true);
            ian.addProperty("some.shared.property1", "ihar.specific.value");
            ian.addProperty("some.shared.property2", "shared.value_A");
            ian.addProperty("some.shared.property3", "shared.value_B");

            var bob = new User();
            bob.username = "bbar";
            bob.addProperty("user.login.special.hash", "bob123456");
            bob.addProperty("some.shared.property1", "bob.specific.value");
            bob.addProperty("some.shared.property2", "shared.value_A");
            bob.addProperty("some.shared.property3", "shared.value_C");

            var tim = new User();
            tim.username = "ttim";
            tim.addProperty("user.login.special.hash", "tim123456");
            tim.addProperty("some.shared.property1", "tim.specific.value");
            tim.addProperty("some.shared.property2", "shared.value_C");
            tim.addProperty("some.shared.property3", "shared.value_B");

            list.push(ian.add);
            list.push(bob.add);
            list.push(tim.add);

            PromiseUtils.runSequentially(list).then(result -> {
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }
}