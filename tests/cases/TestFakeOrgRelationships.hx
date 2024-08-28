package cases;

import db.IDatabase;
import cases.fakeorg.Worker;
import utest.Assert;
import entities.EntityManager;
import cases.fakeorg.DBCreator;
import utest.Async;
import haxe.io.Bytes;

@:timeout(20000)
class TestFakeOrgRelationships extends TestBase {
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

    function testFindAllByIcon(async:Async) {
        start("TestRelationships.testFindAllByIcon");

        Worker.findAllByIcon("/icons/users/ian_harrigan.png").then(workers -> {
            Assert.equals(1, workers.length);

            Assert.equals("ian_harrigan", workers[0].username);
            Assert.equals(Bytes.ofString("this is ians contract document").toString(),workers[0].contractDocument.toString());
            Assert.equals("/icons/users/ian_harrigan.png", workers[0].icon.path);
            // address
            Assert.equals(3, workers[0].address.lines.length);
            Assert.equals("52", workers[0].address.lines[0].text);
            Assert.equals("Some street", workers[0].address.lines[1].text);
            Assert.equals("Sliema", workers[0].address.lines[2].text);
            Assert.equals("SLM 001", workers[0].address.postCode);
            // orgs
            Assert.equals(4, workers[0].organizations.length);
            // ACME
            Assert.equals("ACME", workers[0].organizations[0].name);
            Assert.equals("/icons/orgs/acme.png", workers[0].organizations[0].icon.path);
            Assert.equals(2, workers[0].organizations[0].address.lines.length);
            Assert.equals("1 Roadrunner Road", workers[0].organizations[0].address.lines[0].text);
            Assert.equals("Arizona", workers[0].organizations[0].address.lines[1].text);
            Assert.equals("ACM ARZ", workers[0].organizations[0].address.postCode);
            // Globex
            Assert.equals("Globex", workers[0].organizations[1].name);
            Assert.equals("/icons/orgs/shared_icon.png", workers[0].organizations[1].icon.path);
            Assert.equals(4, workers[0].organizations[1].address.lines.length);
            Assert.equals("27 Marge Avenue", workers[0].organizations[1].address.lines[0].text);
            Assert.equals("Westville", workers[0].organizations[1].address.lines[1].text);
            Assert.equals("Springfield", workers[0].organizations[1].address.lines[2].text);
            Assert.equals("Oregon", workers[0].organizations[1].address.lines[3].text);
            Assert.equals("SPR 009", workers[0].organizations[1].address.postCode);
            // Hooli
            Assert.equals("Hooli", workers[0].organizations[2].name);
            Assert.equals("/icons/orgs/shared_icon.png", workers[0].organizations[2].icon.path);
            Assert.equals(1, workers[0].organizations[2].address.lines.length);
            Assert.equals("2624 Mill Street", workers[0].organizations[2].address.lines[0].text);
            Assert.equals("ABC XYZ", workers[0].organizations[2].address.postCode);
            // Massive Dynamic
            Assert.equals("Massive Dynamic", workers[0].organizations[3].name);
            Assert.equals("/icons/orgs/massive_dynamic.png", workers[0].organizations[3].icon.path);
            Assert.equals(3, workers[0].organizations[3].address.lines.length);
            Assert.equals("137 Tillman Station", workers[0].organizations[3].address.lines[0].text);
            Assert.equals("O'Fallon", workers[0].organizations[3].address.lines[1].text);
            Assert.equals("Connecticut", workers[0].organizations[3].address.lines[2].text);
            Assert.equals("MSV 001", workers[0].organizations[3].address.postCode);

            complete();
            async.done();
        }, error -> {
            trace(error);
            async.done();
        });
    }

    function testFindByIcon(async:Async) {
        start("TestRelationships.testFindByIcon");
        Worker.findByIcon("/icons/users/ian_harrigan.png").then(worker -> { 
            Assert.notNull(worker);

            Assert.equals("ian_harrigan", worker.username);
            Assert.equals(Bytes.ofString("this is ians contract document").toString(), worker.contractDocument.toString());
            Assert.equals("/icons/users/ian_harrigan.png", worker.icon.path);
            // address
            Assert.equals(3, worker.address.lines.length);
            Assert.equals("52", worker.address.lines[0].text);
            Assert.equals("Some street", worker.address.lines[1].text);
            Assert.equals("Sliema", worker.address.lines[2].text);
            Assert.equals("SLM 001", worker.address.postCode);
            // orgs
            Assert.equals(4, worker.organizations.length);
            // ACME
            Assert.equals("ACME", worker.organizations[0].name);
            Assert.equals("/icons/orgs/acme.png", worker.organizations[0].icon.path);
            Assert.equals(2, worker.organizations[0].address.lines.length);
            Assert.equals("1 Roadrunner Road", worker.organizations[0].address.lines[0].text);
            Assert.equals("Arizona", worker.organizations[0].address.lines[1].text);
            Assert.equals("ACM ARZ", worker.organizations[0].address.postCode);
            // Globex
            Assert.equals("Globex", worker.organizations[1].name);
            Assert.equals("/icons/orgs/shared_icon.png", worker.organizations[1].icon.path);
            Assert.equals(4, worker.organizations[1].address.lines.length);
            Assert.equals("27 Marge Avenue", worker.organizations[1].address.lines[0].text);
            Assert.equals("Westville", worker.organizations[1].address.lines[1].text);
            Assert.equals("Springfield", worker.organizations[1].address.lines[2].text);
            Assert.equals("Oregon", worker.organizations[1].address.lines[3].text);
            Assert.equals("SPR 009", worker.organizations[1].address.postCode);
            // Hooli
            Assert.equals("Hooli", worker.organizations[2].name);
            Assert.equals("/icons/orgs/shared_icon.png", worker.organizations[2].icon.path);
            Assert.equals(1, worker.organizations[2].address.lines.length);
            Assert.equals("2624 Mill Street", worker.organizations[2].address.lines[0].text);
            Assert.equals("ABC XYZ", worker.organizations[2].address.postCode);
            // Massive Dynamic
            Assert.equals("Massive Dynamic", worker.organizations[3].name);
            Assert.equals("/icons/orgs/massive_dynamic.png", worker.organizations[3].icon.path);
            Assert.equals(3, worker.organizations[3].address.lines.length);
            Assert.equals("137 Tillman Station", worker.organizations[3].address.lines[0].text);
            Assert.equals("O'Fallon", worker.organizations[3].address.lines[1].text);
            Assert.equals("Connecticut", worker.organizations[3].address.lines[2].text);
            Assert.equals("MSV 001", worker.organizations[3].address.postCode);

            complete();
            async.done();
        }, error -> {
            trace(error);
            async.done();
        });
    }

    function testFindAllByOrganization(async:Async) {
        start("TestRelationships.testFindAllByOrganization");

        Worker.findAllByOrganization("Globex").then(workers -> {
            Assert.equals(2, workers.length);

            // ian
            Assert.equals("ian_harrigan", workers[0].username);
            Assert.equals(Bytes.ofString("this is ians contract document").toString(),workers[0].contractDocument.toString());
            Assert.equals("/icons/users/ian_harrigan.png", workers[0].icon.path);
            // address
            Assert.equals(3, workers[0].address.lines.length);
            Assert.equals("52", workers[0].address.lines[0].text);
            Assert.equals("Some street", workers[0].address.lines[1].text);
            Assert.equals("Sliema", workers[0].address.lines[2].text);
            Assert.equals("SLM 001", workers[0].address.postCode);
            // orgs
            Assert.equals(4, workers[0].organizations.length);
            // ACME
            Assert.equals("ACME", workers[0].organizations[0].name);
            Assert.equals("/icons/orgs/acme.png", workers[0].organizations[0].icon.path);
            Assert.equals(2, workers[0].organizations[0].address.lines.length);
            Assert.equals("1 Roadrunner Road", workers[0].organizations[0].address.lines[0].text);
            Assert.equals("Arizona", workers[0].organizations[0].address.lines[1].text);
            Assert.equals("ACM ARZ", workers[0].organizations[0].address.postCode);
            // Globex
            Assert.equals("Globex", workers[0].organizations[1].name);
            Assert.equals("/icons/orgs/shared_icon.png", workers[0].organizations[1].icon.path);
            Assert.equals(4, workers[0].organizations[1].address.lines.length);
            Assert.equals("27 Marge Avenue", workers[0].organizations[1].address.lines[0].text);
            Assert.equals("Westville", workers[0].organizations[1].address.lines[1].text);
            Assert.equals("Springfield", workers[0].organizations[1].address.lines[2].text);
            Assert.equals("Oregon", workers[0].organizations[1].address.lines[3].text);
            Assert.equals("SPR 009", workers[0].organizations[1].address.postCode);
            // Hooli
            Assert.equals("Hooli", workers[0].organizations[2].name);
            Assert.equals("/icons/orgs/shared_icon.png", workers[0].organizations[2].icon.path);
            Assert.equals(1, workers[0].organizations[2].address.lines.length);
            Assert.equals("2624 Mill Street", workers[0].organizations[2].address.lines[0].text);
            Assert.equals("ABC XYZ", workers[0].organizations[2].address.postCode);
            // Massive Dynamic
            Assert.equals("Massive Dynamic", workers[0].organizations[3].name);
            Assert.equals("/icons/orgs/massive_dynamic.png", workers[0].organizations[3].icon.path);
            Assert.equals(3, workers[0].organizations[3].address.lines.length);
            Assert.equals("137 Tillman Station", workers[0].organizations[3].address.lines[0].text);
            Assert.equals("O'Fallon", workers[0].organizations[3].address.lines[1].text);
            Assert.equals("Connecticut", workers[0].organizations[3].address.lines[2].text);
            Assert.equals("MSV 001", workers[0].organizations[3].address.postCode);

            // bob
            Assert.equals("bob_barker", workers[1].username);
            Assert.equals("/icons/users/bob_barker.png", workers[1].icon.path);
            // address
            Assert.equals(1, workers[1].address.lines.length);
            Assert.equals("POBOX 15", workers[1].address.lines[0].text);
            Assert.equals("112 335", workers[1].address.postCode);
            // orgs
            Assert.equals(2, workers[1].organizations.length);
            // Globex
            Assert.equals("Globex", workers[1].organizations[0].name);
            Assert.equals("/icons/orgs/shared_icon.png", workers[1].organizations[0].icon.path);
            Assert.equals(4, workers[1].organizations[0].address.lines.length);
            Assert.equals("27 Marge Avenue", workers[1].organizations[0].address.lines[0].text);
            Assert.equals("Westville", workers[1].organizations[0].address.lines[1].text);
            Assert.equals("Springfield", workers[1].organizations[0].address.lines[2].text);
            Assert.equals("Oregon", workers[1].organizations[0].address.lines[3].text);
            Assert.equals("SPR 009", workers[1].organizations[0].address.postCode);
            // IniTech
            Assert.equals("IniTech", workers[1].organizations[1].name);
            Assert.equals("/icons/orgs/initech.png", workers[1].organizations[1].icon.path);
            Assert.equals(3, workers[1].organizations[1].address.lines.length);
            Assert.equals("77 Daylene Drive", workers[1].organizations[1].address.lines[0].text);
            Assert.equals("Maybee", workers[1].organizations[1].address.lines[1].text);
            Assert.equals("Michigan", workers[1].organizations[1].address.lines[2].text);
            Assert.equals("MCG 834", workers[1].organizations[1].address.postCode);

            complete();
            async.done();
        }, error -> {
            trace(error);
            async.done();
        });
    }
}