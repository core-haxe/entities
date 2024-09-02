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
            AssertionTools.shouldMatch({
                lines: [{text: "52"}, {text: "Some street"}, {text: "Sliema"}],
                postCode: "SLM 001"
            }, workers[0].address);
            // orgs
            Assert.equals(4, workers[0].organizations.length);
            // ACME
            AssertionTools.shouldContain({
                name: "ACME",
                icon: {
                    path: "/icons/orgs/acme.png"
                },
                address: {
                    lines: [{ text: "1 Roadrunner Road"}, { text: "Arizona"}],
                    postCode: "ACM ARZ"
                }
            }, workers[0].organizations);
            // Globex
            AssertionTools.shouldContain({
                name: "Globex",
                icon: {
                    path: "/icons/orgs/shared_icon.png"
                },
                address: {
                    lines: [{ text: "27 Marge Avenue"}, { text: "Westville"}, { text: "Springfield"}, { text: "Oregon"}],
                    postCode: "SPR 009"
                }
            }, workers[0].organizations);
            // Hooli
            AssertionTools.shouldContain({
                name: "Hooli",
                icon: {
                    path: "/icons/orgs/shared_icon.png"
                },
                address: {
                    lines: [{ text: "2624 Mill Street"}],
                    postCode: "ABC XYZ"
                }
            }, workers[0].organizations);
            // Massive Dynamic
            AssertionTools.shouldContain({
                name: "Massive Dynamic",
                icon: {
                    path: "/icons/orgs/massive_dynamic.png"
                },
                address: {
                    lines: [{ text: "137 Tillman Station"}, { text: "O'Fallon"}, { text: "Connecticut"}],
                    postCode: "MSV 001"
                }
            }, workers[0].organizations);

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
            AssertionTools.shouldMatch({
                lines: [{text: "52"}, {text: "Some street"}, {text: "Sliema"}],
                postCode: "SLM 001"
            }, worker.address);
            // orgs
            Assert.equals(4, worker.organizations.length);
            // ACME
            AssertionTools.shouldContain({
                name: "ACME",
                icon: {
                    path: "/icons/orgs/acme.png"
                },
                address: {
                    lines: [{ text: "1 Roadrunner Road"}, { text: "Arizona"}],
                    postCode: "ACM ARZ"
                }
            }, worker.organizations);
            // Globex
            AssertionTools.shouldContain({
                name: "Globex",
                icon: {
                    path: "/icons/orgs/shared_icon.png"
                },
                address: {
                    lines: [{ text: "27 Marge Avenue"}, { text: "Westville"}, { text: "Springfield"}, { text: "Oregon"}],
                    postCode: "SPR 009"
                }
            }, worker.organizations);
            // Hooli
            AssertionTools.shouldContain({
                name: "Hooli",
                icon: {
                    path: "/icons/orgs/shared_icon.png"
                },
                address: {
                    lines: [{ text: "2624 Mill Street"}],
                    postCode: "ABC XYZ"
                }
            }, worker.organizations);
            // Massive Dynamic
            AssertionTools.shouldContain({
                name: "Massive Dynamic",
                icon: {
                    path: "/icons/orgs/massive_dynamic.png"
                },
                address: {
                    lines: [{ text: "137 Tillman Station"}, { text: "O'Fallon"}, { text: "Connecticut"}],
                    postCode: "MSV 001"
                }
            }, worker.organizations);

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
            AssertionTools.shouldMatch({
                lines: [{text: "52"}, {text: "Some street"}, {text: "Sliema"}],
                postCode: "SLM 001"
            }, workers[0].address);
            // orgs
            Assert.equals(4, workers[0].organizations.length);
            // ACME
            AssertionTools.shouldContain({
                name: "ACME",
                icon: {
                    path: "/icons/orgs/acme.png"
                },
                address: {
                    lines: [{ text: "1 Roadrunner Road"}, { text: "Arizona"}],
                    postCode: "ACM ARZ"
                }
            }, workers[0].organizations);
            // Globex
            AssertionTools.shouldContain({
                name: "Globex",
                icon: {
                    path: "/icons/orgs/shared_icon.png"
                },
                address: {
                    lines: [{ text: "27 Marge Avenue"}, { text: "Westville"}, { text: "Springfield"}, { text: "Oregon"}],
                    postCode: "SPR 009"
                }
            }, workers[0].organizations);
            // Hooli
            AssertionTools.shouldContain({
                name: "Hooli",
                icon: {
                    path: "/icons/orgs/shared_icon.png"
                },
                address: {
                    lines: [{ text: "2624 Mill Street"}],
                    postCode: "ABC XYZ"
                }
            }, workers[0].organizations);
            // Massive Dynamic
            AssertionTools.shouldContain({
                name: "Massive Dynamic",
                icon: {
                    path: "/icons/orgs/massive_dynamic.png"
                },
                address: {
                    lines: [{ text: "137 Tillman Station"}, { text: "O'Fallon"}, { text: "Connecticut"}],
                    postCode: "MSV 001"
                }
            }, workers[0].organizations);

            // bob
            Assert.equals("bob_barker", workers[1].username);
            Assert.equals("/icons/users/bob_barker.png", workers[1].icon.path);
            // address
            AssertionTools.shouldMatch({
                lines: [{text: "POBOX 15"}],
                postCode: "112 335"
            }, workers[1].address);
            // orgs
            Assert.equals(2, workers[1].organizations.length);
            // Globex
            AssertionTools.shouldContain({
                name: "Globex",
                icon: {
                    path: "/icons/orgs/shared_icon.png"
                },
                address: {
                    lines: [{ text: "27 Marge Avenue"}, { text: "Westville"}, { text: "Springfield"}, { text: "Oregon"}],
                    postCode: "SPR 009"
                }
            }, workers[1].organizations);
            // IniTech
            AssertionTools.shouldContain({
                name: "IniTech",
                icon: {
                    path: "/icons/orgs/initech.png"
                },
                address: {
                    lines: [{ text: "77 Daylene Drive"}, { text: "Maybee"}, { text: "Michigan"}],
                    postCode: "MCG 834"
                }
            }, workers[1].organizations);

            complete();
            async.done();
        }, error -> {
            trace(error);
            async.done();
        });
    }
}