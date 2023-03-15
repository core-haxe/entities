package entities;

import db.DatabaseError;
import db.IDatabase;
import db.Query;
import db.Record;
import promises.Promise;

@:access(entities.EntityManager)
@:autoBuild(entities.macros.EntityBuilder.build())
class Entity<T> implements IEntity<T> {
    @:jignored
	public var db:IDatabase;

    @:jignored @:noCompletion
    private var _populated:Bool = false;

    public function new() {
    }

	public function load(id:Int):Promise<T> {
        var field = primaryKeyFieldName();
        var q = Query.query($field = id);
        // TODO: find a nicer way to do this
        switch (q) {
            case QueryBinop(op, _, e2):
                q = QueryBinop(op, QueryConstant(QIdent(field)), e2);
            case _:    
        }
        return find(q);
	}

    public function find(query:QueryExpr):Promise<T> {
        return new Promise((resolve, reject) -> {
            var tableName = definition().tableName;
            db.table(tableName).then(result -> {
                return result.table.find(query);
            }).then(result -> {
                if (result.data == null || result.data.length == 0) {
                    resolve(cast this);    
                    return;
                }
                var fieldPrefix = tableName;
                if (db.definedTableRelationships() == null || db.definedTableRelationships().get(tableName) == null) {
                    fieldPrefix = "";
                }
                fromData(result.data, fieldPrefix);
                this._populated = true;
                resolve(cast this);
            }, (error:DatabaseError) -> {
                reject(error);
            });
        });
    }

    public function add():Promise<T> {
        return new Promise((resolve, reject) -> {
            var tableName = this.definition().tableName;
            var primaryKeyName = this.definition().primaryKeyName;
            var primaryKeyValue = Reflect.field(this, primaryKeyName);
            
            connect().then(result -> {
                return db.table(tableName);
            }).then(result -> {
                var record = this.toRecord();
                return result.table.add(record);
            }).then(result -> {
                var insertedId:Int = result.data.field("_insertedId");
                Reflect.setField(this, primaryKeyName, insertedId);
                resolve(cast this);
            }, error -> {
                reject(error);
            });
        });
    }

    public function update():Promise<T> {
        return new Promise((resolve, reject) -> {
            var tableName = this.definition().tableName;
            var primaryKeyName = this.definition().primaryKeyName;
            var primaryKeyValue = Reflect.field(this, primaryKeyName);

            connect().then(result -> {
                return db.table(tableName);
            }).then(result -> {
                var record = this.toRecord();
                var field = primaryKeyName;
                var q = Query.query($field = primaryKeyValue);
                // TODO: find a nicer way to do this
                switch (q) {
                    case QueryBinop(op, _, e2):
                        q = QueryBinop(op, QueryConstant(QIdent(field)), e2);
                    case _:    
                }
                return result.table.update(q, record);
            }).then(result -> {
                resolve(cast this);
            }, error -> {
                reject(error);
            });
        });
    }

    private function primaryKeyFieldName():String {
        throw new haxe.exceptions.NotImplementedException();
    }

	private function definition():EntityDefinition {
		throw new haxe.exceptions.NotImplementedException();
	}

    private function fromData(records:Array<Record>, fieldPrefix:String = null, depth:Int = 0) {
        if (fieldPrefix == null || fieldPrefix.length == 0) {
            fieldPrefix = "";
        } else {
            fieldPrefix = fieldPrefix + ".";
        }

        for (record in records) {
            for (entityFieldDef in definition().fields) {
                switch (entityFieldDef.type) {
                    case Integer | String:
                        setField(entityFieldDef.name, records[0].field('${fieldPrefix}${entityFieldDef.name}'));
                    case Class(type, OneToOne(table1, field1, table2, field2)): 
                        if (depth < 5) {
                            var entity:IEntity<Any> = Type.createInstance(Type.resolveClass(type), []);
                            entity.fromData(records, '${fieldPrefix}${table2}');
                            setField(entityFieldDef.name, entity);
                        }
                    case Class(type, OneToMany(table1, field1, table2, field2)):  
                        if (depth < 5) {
                            var map = getMap(entityFieldDef.name);
                            var primaryKey = record.field('${table2}.${field2}');
                            if (primaryKey != null) {
                                if (!map.exists(primaryKey)) {
                                    var entity:IEntity<Any> = null;
                                    entity = cast Type.createInstance(Type.resolveClass(type), []);
                                    entity.fromData([record], table2, depth + 1);
                                    map.set(primaryKey, cast entity);
                                    addArrayItem(entityFieldDef.name, primaryKey, entity);
                                } else {
                                    map.get(primaryKey).fromData([record], table2, depth + 1);
                                }
                            }
                        }
                }
            }
        }
    }

    private function toRecord():Record {
        return null;
    }

    private function setField(id:String, value:Any):Any {
        return null;
    }

    private function getArray(id:String):Array<IEntity<Any>> {
        return null;
    }

    private function getMap(id:String):Map<Int, IEntity<Any>> {
        return null;
    }

    private function addArrayItem(id:String, primaryKey:Int, item:IEntity<Any>) {

    }

    private function connect():Promise<Bool> {
        this.db = EntityManager.instance.db;
        return EntityManager.instance.connect();
    }
}
