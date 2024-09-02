package cases;

import db.IDatabase;
import haxe.io.Bytes;
import cases.fakeorg.AddressLine;
import cases.fakeorg.Organization;
import cases.fakeorg.Icon;
import entities.EntityManager;
import utest.Assert;
import cases.fakeorg.Worker;
import cases.fakeorg.DBCreator;
import utest.Async;

@:timeout(2000)
class TestFakeOrgEntities extends TestBase {
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

    function testBasicWorker(async:Async) {
        start("TestFakeOrgEntities.testBasicWorker");
        Worker.findById(1).then(worker -> { // find "ian"
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
            
            return Worker.findById(2); // find "bob"
        }).then(worker -> {
            Assert.equals("bob_barker", worker.username);
            Assert.equals("/icons/users/bob_barker.png", worker.icon.path);
            // address
            AssertionTools.shouldMatch({
                lines: [{text: "POBOX 15"}],
                postCode: "112 335"
            }, worker.address);
            // orgs
            Assert.equals(2, worker.organizations.length);
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
            }, worker.organizations);

            return Worker.findById(4); // find "jim"
        }).then(worker -> {
            Assert.equals("jim_jefferies", worker.username);
            Assert.equals("/icons/users/jim_jefferies.png", worker.icon.path);
            // address
            AssertionTools.shouldMatch({
                lines: [{text: "Nowhere avenue"}, {text: "Moresville"}],
                postCode: "MOR 762"
            }, worker.address);
            // orgs
            Assert.equals(1, worker.organizations.length);
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
        });
    }

    function testBasicUpdate(async:Async) {
        start("TestFakeOrgEntities.testBasicUpdate");
        Worker.findById(1).then(worker -> { // find "ian"
            worker.username += " - edited";
            worker.icon.path = "some_new_icon.png";
            worker.address.postCode += " - edited";
            worker.address.lines[0].text = "NEW LINE 000";
            worker.address.lines[2].text = "NEW LINE 222";
            return worker.update();
        }).then(worker -> {
            // ensure fields are right
            Assert.equals("ian_harrigan - edited", worker.username);
            Assert.equals("some_new_icon.png", worker.icon.path);
            AssertionTools.shouldMatch({
                lines: [{text: "NEW LINE 000"}, {text: "Some street"}, {text: "NEW LINE 222"}],
                postCode: "SLM 001 - edited"
            }, worker.address);
            return Worker.findById(1); // reload from the database to make doubley sure (should happen automatically anyway)
        }).then(worker -> {
            Assert.equals("ian_harrigan - edited", worker.username);
            Assert.equals("some_new_icon.png", worker.icon.path);
            AssertionTools.shouldMatch({
                lines: [{text: "NEW LINE 000"}, {text: "Some street"}, {text: "NEW LINE 222"}],
                postCode: "SLM 001 - edited"
            }, worker.address);
            complete();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testSharedIconUpdate(async:Async) {
        start("TestFakeOrgEntities.testSharedIconUpdate");
        Icon.findById(2).then(icon -> { // find "/icons/orgs/shared_icon.png"
            Assert.equals("/icons/orgs/shared_icon.png", icon.path);
            icon.path = "this_is_a_new_shared_icon.png";
            return icon.update();
        }).then(icon -> {
            // ensure fields are right
            Assert.equals("this_is_a_new_shared_icon.png", icon.path);
            return Organization.findById(2); // find "Globex" (which uses the shared icon)
        }).then(org -> {
            Assert.equals("Globex", org.name);
            Assert.equals("this_is_a_new_shared_icon.png", org.icon.path);
            return Organization.findById(4); // find "Hooli" (which uses the shared icon)
        }).then(org -> {
            Assert.equals("Hooli", org.name);
            Assert.equals("this_is_a_new_shared_icon.png", org.icon.path);
            complete();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testSharedOrganizationUpdate(async:Async) {
        start("TestFakeOrgEntities.testSharedOrganizationUpdate");
        Organization.findById(1).then(org -> { // find "ACME"
            Assert.equals("ACME", org.name);
            Assert.equals("ACM ARZ", org.address.postCode);
            org.name += " - edited 1";
            org.address.postCode = "NEW ACME POSTCODE";
            return org.update();
        }).then(success -> {
            return Organization.findById(2); // find "Globex"
        }).then(org -> {
            Assert.equals("Globex", org.name);
            Assert.equals("SPR 009", org.address.postCode);
            org.name += " - edited 2";
            org.address.postCode = "NEW GLOBTEX POSTCODE";
            return org.update();
        }).then(success -> {
            return Organization.findById(5); // find "Massive Dynamic"
        }).then(org -> {
            Assert.equals("Massive Dynamic", org.name);
            Assert.equals("MSV 001", org.address.postCode);
            org.name += " - edited 3";
            org.address.postCode = "NEW MASSIVE DYNAMIC POSTCODE";
            return org.update();
        }).then(success -> {
            return Worker.findById(1); // find "ian"
        }).then(worker -> {
            Assert.equals("ian_harrigan", worker.username);
            // orgs
            Assert.equals(4, worker.organizations.length);
            // ACME
            AssertionTools.shouldContain({
                name: "ACME - edited 1",
                address: {
                    postCode: "NEW ACME POSTCODE"
                }
            }, worker.organizations);
            // Globex
            AssertionTools.shouldContain({
                name: "Globex - edited 2",
                address: {
                    postCode: "NEW GLOBTEX POSTCODE"
                }
            }, worker.organizations);
            // Hooli
            AssertionTools.shouldContain({
                name: "Hooli",
                address: {
                    postCode: "ABC XYZ"
                }
            }, worker.organizations);
            // Massive Dynamic
            AssertionTools.shouldContain({
                name: "Massive Dynamic - edited 3",
                address: {
                    postCode: "NEW MASSIVE DYNAMIC POSTCODE"
                }
            }, worker.organizations);

            return Worker.findById(2); // find "bob"
        }).then(worker -> {
            Assert.equals("bob_barker", worker.username);
            // orgs
            Assert.equals(2, worker.organizations.length);
            // Globex
            AssertionTools.shouldContain({
                name: "Globex - edited 2",
                address: {
                    postCode: "NEW GLOBTEX POSTCODE"
                }
            }, worker.organizations);
            // IniTech
            AssertionTools.shouldContain({
                name: "IniTech",
                address: {
                    postCode: "MCG 834"
                }
            }, worker.organizations);

            return Worker.findById(4); // find "jim"
        }).then(worker -> {
            Assert.equals("jim_jefferies", worker.username);
            // orgs
            Assert.equals(1, worker.organizations.length);
            // Massive Dynamic
            /*
            AssertionTools.shouldContain({
                name: "Massive Dynamic - edited 3",
                address: {
                    postCode: "NEW MASSIVE DYNAMIC POSTCODE"
                }
            }, worker.organizations);
            */

            complete();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testChangeUserIconThatExists(async:Async) {
        var theWorker = null;
        start("TestFakeOrgEntities.testChangeUserIconThatExists");
        Worker.findById(1).then(worker -> { // find "ian"
            Assert.equals("ian_harrigan", worker.username);
            Assert.equals("/icons/users/ian_harrigan.png", worker.icon.path);
            theWorker = worker;
            return Icon.findById(8); // find "/icons/users/jim_jefferies.png"
        }).then(icon -> {
            Assert.equals("/icons/users/jim_jefferies.png", icon.path);
            theWorker.icon = icon;
            return theWorker.update();
        }).then(worker -> {
            Assert.equals("ian_harrigan", worker.username);
            Assert.equals("/icons/users/jim_jefferies.png", worker.icon.path);
            return Worker.findById(1); // find "ian" - lets make doubly sure
        }).then(worker -> {
            Assert.equals("ian_harrigan", worker.username);
            Assert.equals("/icons/users/jim_jefferies.png", worker.icon.path);
            complete();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testChangeUserIconToNewIcon(async:Async) {
        start("TestFakeOrgEntities.testChangeUserIconToNewIcon");
        var theWorker = null;
        Worker.findById(1).then(worker -> { // find "ian"
            Assert.equals("ian_harrigan", worker.username);
            Assert.equals("/icons/users/ian_harrigan.png", worker.icon.path);
            theWorker = worker;
            
            var newIcon = new Icon();
            newIcon.path = "new_icon.png";
            theWorker.icon = newIcon;
            return theWorker.update();
        }).then(worker -> {
            Assert.equals("ian_harrigan", worker.username);
            Assert.equals("new_icon.png", worker.icon.path);
            return Worker.findById(1); // find "ian" - lets make doubly sure
        }).then(worker -> {
            Assert.equals("ian_harrigan", worker.username);
            Assert.equals("new_icon.png", worker.icon.path);
            complete();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testAddUserAddressLine(async:Async) {
        start("TestFakeOrgEntities.testAddUserAddressLine");
        Worker.findById(1).then(worker -> { // find "ian"
            Assert.equals("ian_harrigan", worker.username);
            AssertionTools.shouldMatch({
                lines: [{text: "52"}, {text: "Some street"}, {text: "Sliema"}],
                postCode: "SLM 001"
            }, worker.address);
            
            var newAddressLine = new AddressLine();
            newAddressLine.text = "this is a new address line";
            worker.address.lines.push(newAddressLine);

            return worker.update();
        }).then(worker -> {
            AssertionTools.shouldMatch({
                lines: [{text: "52"}, {text: "Some street"}, {text: "Sliema"}, {text: "this is a new address line"}],
                postCode: "SLM 001"
            }, worker.address);

            return Worker.findById(1); // find "ian", lets making doubley sure
        }).then(worker -> {
            AssertionTools.shouldMatch({
                lines: [{text: "52"}, {text: "Some street"}, {text: "Sliema"}, {text: "this is a new address line"}],
                postCode: "SLM 001"
            }, worker.address);

            complete();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testRemoveUserAddressLine(async:Async) {
        start("TestFakeOrgEntities.testRemoveUserAddressLine");
        Worker.findById(1).then(worker -> { // find "ian"
            Assert.equals("ian_harrigan", worker.username);
            AssertionTools.shouldMatch({
                lines: [{text: "52"}, {text: "Some street"}, {text: "Sliema"}],
                postCode: "SLM 001"
            }, worker.address);
            
            var addressLine = worker.address.lines[1];
            worker.address.lines.remove(addressLine);

            return worker.update();
        }).then(worker -> {
            AssertionTools.shouldMatch({
                lines: [{text: "52"}, {text: "Sliema"}],
                postCode: "SLM 001"
            }, worker.address);

            return Worker.findById(1); // find "ian", lets making doubley sure
        }).then(worker -> {
            AssertionTools.shouldMatch({
                lines: [{text: "52"}, {text: "Sliema"}],
                postCode: "SLM 001"
            }, worker.address);

            complete();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testAddAndRemoveUserAddressLine(async:Async) {
        start("TestFakeOrgEntities.testAddAndRemoveUserAddressLine");
        Worker.findById(1).then(worker -> {  // find "ian"
            Assert.equals("ian_harrigan", worker.username);
            AssertionTools.shouldMatch({
                lines: [{text: "52"}, {text: "Some street"}, {text: "Sliema"}],
                postCode: "SLM 001"
            }, worker.address);
            
            var addressLine = worker.address.lines[1];
            worker.address.lines.remove(addressLine);

            var newAddressLine = new AddressLine();
            newAddressLine.text = "this is a new address line";
            worker.address.lines.push(newAddressLine);

            return worker.update();
        }).then(worker -> {
            AssertionTools.shouldMatch({
                lines: [{text: "52"}, {text: "Sliema"}, {text: "this is a new address line"}],
                postCode: "SLM 001"
            }, worker.address);

            return Worker.findById(1); // find "ian", lets making doubley sure
        }).then(worker -> {
            AssertionTools.shouldMatch({
                lines: [{text: "52"}, {text: "Sliema"}, {text: "this is a new address line"}],
                postCode: "SLM 001"
            }, worker.address);

            complete();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testAddThreeAndRemoveTwoUserAddressLines(async:Async) {
        start("TestFakeOrgEntities.testAddThreeAndRemoveTwoUserAddressLines");
        Worker.findById(1).then(worker -> { // find "ian"
            Assert.equals("ian_harrigan", worker.username);
            AssertionTools.shouldMatch({
                lines: [{text: "52"}, {text: "Some street"}, {text: "Sliema"}],
                postCode: "SLM 001"
            }, worker.address);
            
            var addressLine = worker.address.lines[0];
            worker.address.lines.remove(addressLine);
            var addressLine = worker.address.lines[0];
            worker.address.lines.remove(addressLine);

            var newAddressLine = new AddressLine();
            newAddressLine.text = "this is a new address line #1";
            worker.address.lines.push(newAddressLine);

            var newAddressLine = new AddressLine();
            newAddressLine.text = "this is a new address line #2";
            worker.address.lines.push(newAddressLine);

            var newAddressLine = new AddressLine();
            newAddressLine.text = "this is a new address line #3";
            worker.address.lines.push(newAddressLine);

            return worker.update();
        }).then(worker -> {
            AssertionTools.shouldMatch({
                lines: [{text: "Sliema"}, {text: "this is a new address line #1"}, {text: "this is a new address line #2"}, {text: "this is a new address line #3"}],
                postCode: "SLM 001"
            }, worker.address);

            return Worker.findById(1); // find "ian", lets making doubley sure
        }).then(worker -> {
            AssertionTools.shouldMatch({
                lines: [{text: "Sliema"}, {text: "this is a new address line #1"}, {text: "this is a new address line #2"}, {text: "this is a new address line #3"}],
                postCode: "SLM 001"
            }, worker.address);

            complete();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testRemoveUserAddress(async:Async) {
        start("TestFakeOrgEntities.testRemoveUserAddress");
        var theWorker = null;
        Worker.findById(1).then(worker -> { // find "ian"
            Assert.equals("ian_harrigan", worker.username);
            theWorker = worker;

            AssertionTools.shouldMatch({
                lines: [{text: "52"}, {text: "Some street"}, {text: "Sliema"}],
                postCode: "SLM 001"
            }, worker.address);

            return worker.address.delete();
        }).then(success -> {
            Assert.equals(null, theWorker.address);
            return Worker.findById(1); // find "ian", lets making doubley sure
        }).then(worker -> {
            Assert.equals(null, worker.address);

            complete();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testDateQuery(async:Async) {
        start("TestFakeOrgEntities.testDateQuery");

        var date1 = new Date(2000, 0, 1, 0, 0, 0);
        var date2 = new Date(2010, 11, 31, 0, 0, 0);
        Worker.findByStartDates(date1, date2).then(workers -> {
            Assert.equals(2, workers.length);
            Assert.equals("ian_harrigan", workers[0].username);
            Assert.equals("jim_jefferies", workers[1].username);
            complete();
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testImages(async:Async) {
        start("TestFakeOrgEntities.testImages");
        Worker.findById(1).then(worker -> { // find "ian"
            Assert.equals("ian_harrigan", worker.username);

            Assert.equals(6, worker.images.length);
            AssertionTools.shouldContain({ path: "/images/ian/ian_001.jpg" }, worker.images);
            AssertionTools.shouldContain({ path: "/images/ian/ian_002.jpg" }, worker.images);
            AssertionTools.shouldContain({ path: "/images/ian/ian_003.jpg" }, worker.images);
            AssertionTools.shouldContain({ path: "/images/shared/shared_001.jpg" }, worker.images);
            AssertionTools.shouldContain({ path: "/images/shared/shared_002.jpg" }, worker.images);
            AssertionTools.shouldContain({ path: "/images/shared/shared_003.jpg" }, worker.images);

            Assert.equals(6, worker.thumbs.length);
            AssertionTools.shouldContain({ path: "/images/ian/ian_thumb_001.jpg" }, worker.thumbs);
            AssertionTools.shouldContain({ path: "/images/ian/ian_thumb_002.jpg" }, worker.thumbs);
            AssertionTools.shouldContain({ path: "/images/ian/ian_thumb_003.jpg" }, worker.thumbs);
            AssertionTools.shouldContain({ path: "/images/shared/shared_thumb_001.jpg" }, worker.thumbs);
            AssertionTools.shouldContain({ path: "/images/shared/shared_thumb_002.jpg" }, worker.thumbs);
            AssertionTools.shouldContain({ path: "/images/shared/shared_thumb_003.jpg" }, worker.thumbs);

            return Worker.findById(2); // find "bob"
        }).then(worker -> {
            Assert.equals("bob_barker", worker.username);

            Assert.equals(4, worker.images.length);
            AssertionTools.shouldContain({ path: "/images/bob/bob_001.jpg" }, worker.images);
            AssertionTools.shouldContain({ path: "/images/bob/bob_002.jpg" }, worker.images);
            AssertionTools.shouldContain({ path: "/images/shared/shared_003.jpg" }, worker.images);
            AssertionTools.shouldContain({ path: "/images/shared/shared_004.jpg" }, worker.images);

            Assert.equals(4, worker.thumbs.length);
            AssertionTools.shouldContain({ path: "/images/bob/bob_thumb_001.jpg" }, worker.thumbs);
            AssertionTools.shouldContain({ path: "/images/bob/bob_thumb_002.jpg" }, worker.thumbs);
            AssertionTools.shouldContain({ path: "/images/shared/shared_thumb_003.jpg" }, worker.thumbs);
            AssertionTools.shouldContain({ path: "/images/shared/shared_thumb_004.jpg" }, worker.thumbs);

            return Worker.findById(3); // find "tim"
        }).then(worker -> {
            Assert.equals("tim_taylor", worker.username);

            Assert.equals(0, worker.images.length);

            Assert.equals(0, worker.thumbs.length);

            return Worker.findById(4); // find "jim"
        }).then(worker -> {
            Assert.equals("jim_jefferies", worker.username);

            Assert.equals(3, worker.images.length);
            AssertionTools.shouldContain({ path: "/images/jim/jim_001.jpg" }, worker.images);
            AssertionTools.shouldContain({ path: "/images/shared/shared_001.jpg" }, worker.images);
            AssertionTools.shouldContain({ path: "/images/shared/shared_004.jpg" }, worker.images);

            Assert.equals(3, worker.thumbs.length);
            AssertionTools.shouldContain({ path: "/images/jim/jim_thumb_001.jpg" }, worker.thumbs);
            AssertionTools.shouldContain({ path: "/images/shared/shared_thumb_001.jpg" }, worker.thumbs);
            AssertionTools.shouldContain({ path: "/images/shared/shared_thumb_004.jpg" }, worker.thumbs);

            complete();
            async.done();
        }, error -> {
            trace(error);
        });
    }
}