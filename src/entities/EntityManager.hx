package entities;

import db.DatabaseError;
import db.IDatabase;
import promises.Promise;

class EntityManager {
    private static var _instance:EntityManager = null;
    public static var instance(get, null):EntityManager;
    private static function get_instance():EntityManager {
        if (_instance == null) {
            _instance = new EntityManager();
        }
        return _instance;
    }

    //////////////////////////////////////////////////////////////////////////////
    public var database:IDatabase;
    
    private function new() {
    }

    private var _relationshipsApplied:Bool = false;
    private function applyTableRelationships() {
        if (_relationshipsApplied) {
            return;
        }

        _relationshipsApplied = true;

        var relationshipsString = haxe.Resource.getString("entity-table-relationships");
        if (relationshipsString != null) {
            var relationships:Array<String> = haxe.Unserializer.run(relationshipsString);
            for (r in relationships) {
                var parts = r.split("|");
                database.defineTableRelationship(parts[0], parts[1]);
            }
        }
    }

    private var _propertiesApplied:Bool = false;
    private function applyProperties() {
        if (_propertiesApplied == true) {
            return;
        }

        _propertiesApplied = true;
        database.setProperty("alwaysAliasResultFields", true);
        database.setProperty("complexRelationships", true);
    }

    private var _connected:Bool = false;
    private function connect():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            if (_connected == true) {
                resolve(true);
                return;
            }

            applyProperties();
            applyTableRelationships();
            database.connect().then(result -> {
                return database.create();
            }).then(_ -> {
                _connected = true;
                resolve(true);
            }, (error:DatabaseError) -> {
                reject(error);
            });
        });
    }

    public function reset():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            database.disconnect().then(_ -> {
                database = null;
                _connected = false;
                _propertiesApplied = false;
                _relationshipsApplied = false;
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }
}