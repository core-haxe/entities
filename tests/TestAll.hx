package;

import db.DatabaseFactory;
import db.IDatabase;
import utest.ui.common.HeaderDisplayMode;
import utest.ui.Report;
import utest.Runner;
import cases.*;

class TestAll {
    public static function main() {
        var runner = new Runner();

        addBasicCases(runner, sqlite("basic"));
        addSimpleCases(runner, sqlite("simple"));
        addFakeOrgCases(runner, sqlite("fakeorg"));
        addBooksCases(runner, sqlite("books"));
        addUsersCases(runner, sqlite("users"));

        Report.create(runner, SuccessResultsDisplayMode.AlwaysShowSuccessResults, HeaderDisplayMode.NeverShowHeader);
        runner.run();
    }

    private static function addBasicCases(runner:Runner, db:IDatabase) {
        runner.addCase(new TestBasic(db));
        runner.addCase(new TestMultipleCalls(db));
        runner.addCase(new TestBasicStructInit(db));
    }

    private static function addSimpleCases(runner:Runner, db:IDatabase) {
        runner.addCase(new TestSimple(db));
    }

    private static function addFakeOrgCases(runner:Runner, db:IDatabase) {
        runner.addCase(new TestFakeOrgEntities(db));
        runner.addCase(new TestFakeOrgRelationships(db));
    }

    private static function addBooksCases(runner:Runner, db:IDatabase) {
        runner.addCase(new TestBooks(db));
    }

    private static function addUsersCases(runner:Runner, db:IDatabase) {
        runner.addCase(new TestUser(db));
    }

    private static function sqlite(name:String):IDatabase {
        return DatabaseFactory.instance.createDatabase(DatabaseFactory.SQLITE, {
            filename: name + ".db"
        });
    }

    private static function mysql(name):IDatabase {
        return DatabaseFactory.instance.createDatabase(DatabaseFactory.MYSQL, {
            database: name,
            host: Sys.getEnv("MYSQL_HOST"),
            user: Sys.getEnv("MYSQL_USER"),
            pass: Sys.getEnv("MYSQL_PASS")
        });
    }
}