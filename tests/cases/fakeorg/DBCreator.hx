package cases.fakeorg;

import haxe.io.Bytes;
import db.DatabaseFactory;
import db.IDatabase;
import entities.EntityManager;
import promises.Promise;
import promises.PromiseUtils;
import sys.io.File;

using StringTools;

class DBCreator {
    public var db:IDatabase;
    public var filename:String = "fakeorg.db";

    public function new() {
        
    }

    public function clear() {
        return new Promise((resolve, reject) -> {
            File.saveContent(filename, "");
            resolve(true);
        });
    }

    public function create() {
        return new Promise((resolve, reject) -> {
            clear().then(_ -> {
                File.saveContent(filename, "");
                var db = DatabaseFactory.instance.createDatabase("sqlite", {
                    filename: filename
                });
                this.db = db;
                return db.connect();
            }).then(_ -> {
                EntityManager.instance.database = db;
                return createDummyData();
            }).then(_ -> {
                resolve(true);                
            }, error -> {
                reject(error);
            });
        });
    }

    public function createDummyData() {
        return new Promise((resolve, reject) -> {
            var list:Array<() -> promises.Promise<Any>> = [];

            var sharedIcon = icon("/icons/orgs/shared_icon.png");

            var acme = organization("ACME", ["1 Roadrunner Road", "Arizona", "ACM ARZ"]);
            var globex = organization("Globex", ["27 Marge Avenue", "Westville", "Springfield", "Oregon", "SPR 009"], sharedIcon);
            var initech = organization("IniTech", ["77 Daylene Drive", "Maybee", "Michigan", "MCG 834"]);
            var hooli = organization("Hooli", ["2624 Mill Street", "ABC XYZ"], sharedIcon);
            var massive = organization("Massive Dynamic", ["137 Tillman Station", "O'Fallon", "Connecticut", "MSV 001"]);

            var ian = worker("ian_harrigan", ["52", "Some street", "Sliema", "SLM 001"], [acme, globex, hooli, massive], new Date(2000, 11, 14, 0, 0, 0), Bytes.ofString("this is ians contract document"));
            var bob = worker("bob_barker", ["POBOX 15", "112 335"], [globex, initech], new Date(2020, 8, 4, 0, 0, 0));
            var tim = worker("tim_taylor", ["49 Foo Lane", "Theresville", "Someplace", "SMP 485"], [acme, initech], new Date(1990, 3, 25, 0, 0, 0));
            var jim = worker("jim_jefferies", ["Nowhere avenue", "Moresville", "MOR 762"], [massive], new Date(2010, 6, 18, 0, 0, 0));

            list.push(acme.add);
            list.push(globex.add);
            list.push(initech.add);
            list.push(hooli.add);
            list.push(massive.add);

            list.push(ian.add);
            list.push(bob.add);
            list.push(tim.add);
            list.push(jim.add);
            PromiseUtils.runSequentially(list).then(result -> {
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }

    private function worker(username:String, addressLines:Array<String>, orgs:Array<Organization>, startDate:Date, contractDocument:Bytes = null):Worker {
        var work = new Worker();
        work.username = username;
        work.address = address(addressLines);
        var icon = new Icon();
        icon.path = "/icons/users/" + username.toLowerCase().replace(" ", "_") + ".png";
        work.icon = icon;
        work.organizations = orgs;
        work.startDate = startDate;
        work.contractDocument = contractDocument;
        return work;
    }

    private function organization(name:String, addressLines:Array<String>, icon:Icon = null):Organization {
        var org = new Organization();
        org.name = name;
        org.address = address(addressLines);
        if (icon == null) {
            icon = new Icon();
            icon.path = "/icons/orgs/" + name.toLowerCase().replace(" ", "_") + ".png";
        }
        org.icon = icon;
        return org;
    }

    private function address(lines:Array<String>) {
        var add = new Address();
        add.postCode = lines.pop();
        add.lines = [];
        for (lineText in lines) {
            var line = new AddressLine();
            line.text = lineText;
            add.lines.push(line);
        }
        return add;
    }

    private function icon(path:String):Icon {
        var icon = new Icon();
        icon.path = path;
        return icon;
    }
}