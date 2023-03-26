package cases;

import cases.fakeorg.AddressLine;
import cases.fakeorg.Organization;
import cases.fakeorg.Icon;
import entities.EntityManager;
import utest.Assert;
import cases.fakeorg.Worker;
import cases.fakeorg.DBCreator;
import utest.Test;
import utest.Async;

@:timeout(2000)
class TestFakeOrgEntities extends Test {

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

    function testBasicWorker(async:Async) {
        Worker.findById(1).then(worker -> { // find "ian"
            Assert.equals("ian_harrigan", worker.username);
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
            
            return Worker.findById(2); // find "bob"
        }).then(worker -> {
            Assert.equals("bob_barker", worker.username);
            Assert.equals("/icons/users/bob_barker.png", worker.icon.path);
            // address
            Assert.equals(1, worker.address.lines.length);
            Assert.equals("POBOX 15", worker.address.lines[0].text);
            Assert.equals("112 335", worker.address.postCode);
            // orgs
            Assert.equals(2, worker.organizations.length);
            // Globex
            Assert.equals("Globex", worker.organizations[0].name);
            Assert.equals("/icons/orgs/shared_icon.png", worker.organizations[0].icon.path);
            Assert.equals(4, worker.organizations[0].address.lines.length);
            Assert.equals("27 Marge Avenue", worker.organizations[0].address.lines[0].text);
            Assert.equals("Westville", worker.organizations[0].address.lines[1].text);
            Assert.equals("Springfield", worker.organizations[0].address.lines[2].text);
            Assert.equals("Oregon", worker.organizations[0].address.lines[3].text);
            Assert.equals("SPR 009", worker.organizations[0].address.postCode);
            // IniTech
            Assert.equals("IniTech", worker.organizations[1].name);
            Assert.equals("/icons/orgs/initech.png", worker.organizations[1].icon.path);
            Assert.equals(3, worker.organizations[1].address.lines.length);
            Assert.equals("77 Daylene Drive", worker.organizations[1].address.lines[0].text);
            Assert.equals("Maybee", worker.organizations[1].address.lines[1].text);
            Assert.equals("Michigan", worker.organizations[1].address.lines[2].text);
            Assert.equals("MCG 834", worker.organizations[1].address.postCode);

            return Worker.findById(4); // find "jim"
        }).then(worker -> {
            Assert.equals("jim_jefferies", worker.username);
            Assert.equals("/icons/users/jim_jefferies.png", worker.icon.path);
            // address
            Assert.equals(2, worker.address.lines.length);
            Assert.equals("Nowhere avenue", worker.address.lines[0].text);
            Assert.equals("Moresville", worker.address.lines[1].text);
            Assert.equals("MOR 762", worker.address.postCode);
            // orgs
            Assert.equals(1, worker.organizations.length);
            // Massive Dynamic
            Assert.equals("Massive Dynamic", worker.organizations[0].name);
            Assert.equals("/icons/orgs/massive_dynamic.png", worker.organizations[0].icon.path);
            Assert.equals(3, worker.organizations[0].address.lines.length);
            Assert.equals("137 Tillman Station", worker.organizations[0].address.lines[0].text);
            Assert.equals("O'Fallon", worker.organizations[0].address.lines[1].text);
            Assert.equals("Connecticut", worker.organizations[0].address.lines[2].text);
            Assert.equals("MSV 001", worker.organizations[0].address.postCode);
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testBasicUpdate(async:Async) {
        var theWorker = null;
        Worker.findById(1).then(worker -> { // find "ian"
            theWorker = worker;
            theWorker.username += " - edited";
            theWorker.icon.path = "some_new_icon.png";
            theWorker.address.postCode += " - edited";
            theWorker.address.lines[0].text = "NEW LINE 000";
            theWorker.address.lines[2].text = "NEW LINE 222";
            return theWorker.update();
        }).then(success -> {
            // ensure fields are right
            Assert.equals("ian_harrigan - edited", theWorker.username);
            Assert.equals("some_new_icon.png", theWorker.icon.path);
            Assert.equals(3, theWorker.address.lines.length);
            Assert.equals("NEW LINE 000", theWorker.address.lines[0].text);
            Assert.equals("Some street", theWorker.address.lines[1].text);
            Assert.equals("NEW LINE 222", theWorker.address.lines[2].text);
            Assert.equals("SLM 001 - edited", theWorker.address.postCode);
            return Worker.findById(1); // reload from the database to make doubley sure (should happen automatically anyway)
        }).then(worker -> {
            theWorker = worker;
            Assert.equals("ian_harrigan - edited", theWorker.username);
            Assert.equals("some_new_icon.png", theWorker.icon.path);
            Assert.equals(3, theWorker.address.lines.length);
            Assert.equals("NEW LINE 000", theWorker.address.lines[0].text);
            Assert.equals("Some street", theWorker.address.lines[1].text);
            Assert.equals("NEW LINE 222", theWorker.address.lines[2].text);
            Assert.equals("SLM 001 - edited", theWorker.address.postCode);
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testSharedIconUpdate(async:Async) {
        var theIcon = null;
        Icon.findById(2).then(icon -> { // find "/icons/orgs/shared_icon.png"
            theIcon = icon;
            Assert.equals("/icons/orgs/shared_icon.png", theIcon.path);
            theIcon.path = "this_is_a_new_shared_icon.png";
            return icon.update();
        }).then(success -> {
            // ensure fields are right
            Assert.equals("this_is_a_new_shared_icon.png", theIcon.path);
            return Organization.findById(2); // find "Globex" (which uses the shared icon)
        }).then(org -> {
            Assert.equals("Globex", org.name);
            Assert.equals("this_is_a_new_shared_icon.png", org.icon.path);
            return Organization.findById(4); // find "Hooli" (which uses the shared icon)
        }).then(org -> {
            Assert.equals("Hooli", org.name);
            Assert.equals("this_is_a_new_shared_icon.png", org.icon.path);
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testSharedOrganizationUpdate(async:Async) {
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
            Assert.equals("ACME - edited 1", worker.organizations[0].name);
            Assert.equals("NEW ACME POSTCODE", worker.organizations[0].address.postCode);
            // Globex
            Assert.equals("Globex - edited 2", worker.organizations[1].name);
            Assert.equals("NEW GLOBTEX POSTCODE", worker.organizations[1].address.postCode);
            // Hooli
            Assert.equals("Hooli", worker.organizations[2].name);
            Assert.equals("ABC XYZ", worker.organizations[2].address.postCode);
            // Massive Dynamic
            Assert.equals("Massive Dynamic - edited 3", worker.organizations[3].name);
            Assert.equals("NEW MASSIVE DYNAMIC POSTCODE", worker.organizations[3].address.postCode);

            return Worker.findById(2); // find "bob"
        }).then(worker -> {
            Assert.equals("bob_barker", worker.username);
            // orgs
            Assert.equals(2, worker.organizations.length);
            // Globex
            Assert.equals("Globex - edited 2", worker.organizations[0].name);
            Assert.equals("NEW GLOBTEX POSTCODE", worker.organizations[0].address.postCode);
            // IniTech
            Assert.equals("IniTech", worker.organizations[1].name);
            Assert.equals("MCG 834", worker.organizations[1].address.postCode);

            return Worker.findById(4); // find "jim"
        }).then(worker -> {
            Assert.equals("jim_jefferies", worker.username);
            // orgs
            Assert.equals(1, worker.organizations.length);
            // Massive Dynamic
            Assert.equals("Massive Dynamic - edited 3", worker.organizations[0].name);
            Assert.equals("NEW MASSIVE DYNAMIC POSTCODE", worker.organizations[0].address.postCode);
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testChangeUserIconThatExists(async:Async) {
        var theWorker = null;
        Worker.findById(1).then(worker -> { // find "ian"
            Assert.equals("ian_harrigan", worker.username);
            Assert.equals("/icons/users/ian_harrigan.png", worker.icon.path);
            theWorker = worker;
            return Icon.findById(8); // find "/icons/users/jim_jefferies.png"
        }).then(icon -> {
            Assert.equals("/icons/users/jim_jefferies.png", icon.path);
            theWorker.icon = icon;
            return theWorker.update();
        }).then(success -> {
            Assert.equals("ian_harrigan", theWorker.username);
            Assert.equals("/icons/users/jim_jefferies.png", theWorker.icon.path);
            return Worker.findById(1); // find "ian" - lets make doubly sure
        }).then(worker -> {
            Assert.equals("ian_harrigan", worker.username);
            Assert.equals("/icons/users/jim_jefferies.png", worker.icon.path);
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testChangeUserIconToNewIcon(async:Async) {
        var theWorker = null;
        Worker.findById(1).then(worker -> { // find "ian"
            Assert.equals("ian_harrigan", worker.username);
            Assert.equals("/icons/users/ian_harrigan.png", worker.icon.path);
            theWorker = worker;
            
            var newIcon = new Icon();
            newIcon.path = "new_icon.png";
            theWorker.icon = newIcon;
            return theWorker.update();
        }).then(success -> {
            Assert.equals("ian_harrigan", theWorker.username);
            Assert.equals("new_icon.png", theWorker.icon.path);
            return Worker.findById(1); // find "ian" - lets make doubly sure
        }).then(worker -> {
            Assert.equals("ian_harrigan", worker.username);
            Assert.equals("new_icon.png", worker.icon.path);
            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testAddUserAddressLine(async:Async) {
        var theWorker = null;
        return Worker.findById(1).then(worker -> { // find "ian"
            Assert.equals("ian_harrigan", worker.username);
            theWorker = worker;

            Assert.equals(3, worker.address.lines.length);
            Assert.equals("52", worker.address.lines[0].text);
            Assert.equals("Some street", worker.address.lines[1].text);
            Assert.equals("Sliema", worker.address.lines[2].text);
            Assert.equals("SLM 001", worker.address.postCode);
            
            var newAddressLine = new AddressLine();
            newAddressLine.text = "this is a new address line";
            worker.address.lines.push(newAddressLine);

            return worker.update();
        }).then(success -> {
            Assert.equals(4, theWorker.address.lines.length);
            Assert.equals("52", theWorker.address.lines[0].text);
            Assert.equals("Some street", theWorker.address.lines[1].text);
            Assert.equals("Sliema", theWorker.address.lines[2].text);
            Assert.equals("this is a new address line", theWorker.address.lines[3].text);
            Assert.equals("SLM 001", theWorker.address.postCode);

            return Worker.findById(1); // find "ian", lets making doubley sure
        }).then(worker -> {
            Assert.equals(4, worker.address.lines.length);
            Assert.equals("52", worker.address.lines[0].text);
            Assert.equals("Some street", worker.address.lines[1].text);
            Assert.equals("Sliema", worker.address.lines[2].text);
            Assert.equals("this is a new address line", worker.address.lines[3].text);
            Assert.equals("SLM 001", worker.address.postCode);

            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testRemoveUserAddressLine(async:Async) {
        var theWorker = null;
        Worker.findById(1).then(worker -> { // find "ian"
            Assert.equals("ian_harrigan", worker.username);
            theWorker = worker;

            Assert.equals(3, worker.address.lines.length);
            Assert.equals("52", worker.address.lines[0].text);
            Assert.equals("Some street", worker.address.lines[1].text);
            Assert.equals("Sliema", worker.address.lines[2].text);
            Assert.equals("SLM 001", worker.address.postCode);
            
            var addressLine = worker.address.lines[1];
            worker.address.lines.remove(addressLine);

            return worker.update();
        }).then(success -> {
            Assert.equals(2, theWorker.address.lines.length);
            Assert.equals("52", theWorker.address.lines[0].text);
            Assert.equals("Sliema", theWorker.address.lines[1].text);
            Assert.equals("SLM 001", theWorker.address.postCode);

            return Worker.findById(1); // find "ian", lets making doubley sure
        }).then(worker -> {
            Assert.equals(2, worker.address.lines.length);
            Assert.equals("52", worker.address.lines[0].text);
            Assert.equals("Sliema", worker.address.lines[1].text);
            Assert.equals("SLM 001", worker.address.postCode);

            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testAddAndRemoveUserAddressLine(async:Async) {
        var theWorker = null;
        return Worker.findById(1).then(worker -> {  // find "ian"
            Assert.equals("ian_harrigan", worker.username);
            theWorker = worker;

            Assert.equals(3, worker.address.lines.length);
            Assert.equals("52", worker.address.lines[0].text);
            Assert.equals("Some street", worker.address.lines[1].text);
            Assert.equals("Sliema", worker.address.lines[2].text);
            Assert.equals("SLM 001", worker.address.postCode);
            
            var addressLine = worker.address.lines[1];
            worker.address.lines.remove(addressLine);

            var newAddressLine = new AddressLine();
            newAddressLine.text = "this is a new address line";
            worker.address.lines.push(newAddressLine);

            return worker.update();
        }).then(success -> {
            Assert.equals(3, theWorker.address.lines.length);
            Assert.equals("52", theWorker.address.lines[0].text);
            Assert.equals("Sliema", theWorker.address.lines[1].text);
            Assert.equals("this is a new address line", theWorker.address.lines[2].text);
            Assert.equals("SLM 001", theWorker.address.postCode);

            return Worker.findById(1); // find "ian", lets making doubley sure
        }).then(worker -> {
            Assert.equals(3, worker.address.lines.length);
            Assert.equals("52", worker.address.lines[0].text);
            Assert.equals("Sliema", worker.address.lines[1].text);
            Assert.equals("this is a new address line", worker.address.lines[2].text);
            Assert.equals("SLM 001", worker.address.postCode);

            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testAddThreeAndRemoveTwoUserAddressLines(async:Async) {
        var theWorker = null;
        Worker.findById(1).then(worker -> { // find "ian"
            Assert.equals("ian_harrigan", worker.username);
            theWorker = worker;

            Assert.equals(3, worker.address.lines.length);
            Assert.equals("52", worker.address.lines[0].text);
            Assert.equals("Some street", worker.address.lines[1].text);
            Assert.equals("Sliema", worker.address.lines[2].text);
            Assert.equals("SLM 001", worker.address.postCode);
            
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
        }).then(success -> {
            Assert.equals(4, theWorker.address.lines.length);
            Assert.equals("Sliema", theWorker.address.lines[0].text);
            Assert.equals("this is a new address line #1", theWorker.address.lines[1].text);
            Assert.equals("this is a new address line #2", theWorker.address.lines[2].text);
            Assert.equals("this is a new address line #3", theWorker.address.lines[3].text);
            Assert.equals("SLM 001", theWorker.address.postCode);

            return Worker.findById(1); // find "ian", lets making doubley sure
        }).then(worker -> {
            Assert.equals(4, worker.address.lines.length);
            Assert.equals("Sliema", worker.address.lines[0].text);
            Assert.equals("this is a new address line #1", worker.address.lines[1].text);
            Assert.equals("this is a new address line #2", worker.address.lines[2].text);
            Assert.equals("this is a new address line #3", worker.address.lines[3].text);
            Assert.equals("SLM 001", worker.address.postCode);

            async.done();
        }, error -> {
            trace(error);
        });
    }

    function testRemoveUserAddress(async:Async) {
        var theWorker = null;
        return Worker.findById(1).then(worker -> { // find "ian"
            Assert.equals("ian_harrigan", worker.username);
            theWorker = worker;

            Assert.equals(3, worker.address.lines.length);
            Assert.equals("52", worker.address.lines[0].text);
            Assert.equals("Some street", worker.address.lines[1].text);
            Assert.equals("Sliema", worker.address.lines[2].text);
            Assert.equals("SLM 001", worker.address.postCode);

            return worker.address.delete();
        }).then(success -> {
            Assert.equals(null, theWorker.address);
            return Worker.findById(1); // find "ian", lets making doubley sure
        }).then(worker -> {
            Assert.equals(null, worker.address);

            async.done();
        }, error -> {
            trace(error);
        });
    }
}