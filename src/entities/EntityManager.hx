package entities;

import db.ColumnOptions;
import db.DatabaseError;
import db.IDatabase;
import db.Query;
import db.Record;
import db.TableSchema;
import haxe.Constraints.Constructible;
import haxe.Resource;
import haxe.Unserializer;
import promises.Promise;
import promises.PromiseUtils;

@:access(entities.Entity)
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
    public var db:IDatabase;

    private var entityDefinitions:Array<EntityDefinition> = [];
    private function new() {
        extractDefs();
    }

    private function extractDefs() {
        var defsString = Resource.getString("entity-definitions");
        if (defsString != null) {
            entityDefinitions = Unserializer.run(defsString);
        }
    }

    @:generic
    public function get<T:Constructible<Void->Void> & Entity<T>>(id:Int, entityClass:Class<T>):Promise<T> {
        return new Promise((resolve, reject) -> {
            connect().then(result -> {
                var entity = new T();
                entity.db = this.db;
                return entity.load(id);
            }).then(entity -> {
                if (!entity._populated) {
                    resolve(null);
                    return;
                }
                resolve(entity);
            }, error -> {
                reject(error);
            });
        });
    }

    @:generic
    public function find<T:Constructible<Void->Void> & Entity<T>>(query:QueryExpr, entityClass:Class<T>):Promise<T> {
        return new Promise((resolve, reject) -> {
            connect().then(result -> {
                var entity = new T();
                entity.db = this.db;
                return entity.find(query);
            }).then(entity -> {
                if (!entity._populated) {
                    resolve(null);
                    return;
                }
                resolve(entity);
            }, error -> {
                reject(error);
            });
        });
    }

    @:generic
    public function all<T:Constructible<Void->Void> & Entity<T>>(entityClass:Class<T>):Promise<Array<T>> {
        return new Promise((resolve, reject) -> {
            var temp = new T();
            var tableName = temp.definition().tableName;
            var primaryKeyName = temp.definition().primaryKeyName;

            connect().then(result -> {
                return db.table(tableName);
            }).then(result -> {
                return result.table.all();
            }).then(result -> {
                var recordMap:Map<Int, Array<Record>> =  [];
                var prefix = tableName;
                for (record in result.data) {
                    var primaryKeyValue = record.field('${prefix}.${primaryKeyName}');
                    if (primaryKeyValue == null) {
                        primaryKeyValue = record.field('${primaryKeyName}');
                        prefix = null;
                    }
                    var records = recordMap.get(primaryKeyValue);
                    if (records == null) {
                        records = [];
                        recordMap.set(primaryKeyValue, records);
                    }
                    records.push(record);
                }
                var entities:Array<T> = [];
                for (primaryKeyValue in recordMap.keys()) {
                    var records = recordMap.get(primaryKeyValue);
                    var entity = new T();
                    entity.fromData(records, prefix);
                    entities.push(entity);
                }

                resolve(entities);
            }, error -> {
                reject(error);
            });
        });
    }

    @:generic
    public function add<T:Constructible<Void->Void> & Entity<T>>(entity:T):Promise<T> {
        return new Promise((resolve, reject) -> {
            var tableName = entity.definition().tableName;
            var primaryKeyName = entity.definition().primaryKeyName;
            var primaryKeyValue = Reflect.field(entity, primaryKeyName);

            connect().then(result -> {
                return db.table(tableName);
            }).then(result -> {
                var record = entity.toRecord();
                return result.table.add(record);
            }).then(result -> {
                var insertedId:Int = result.data.field("_insertedId");
                Reflect.setField(entity, primaryKeyName, insertedId);
                resolve(entity);
            }, error -> {
                reject(error);
            });
        });
    }

    @:generic
    public function update<T:Constructible<Void->Void> & Entity<T>>(entity:T):Promise<T> {
        return new Promise((resolve, reject) -> {
            var tableName = entity.definition().tableName;
            var primaryKeyName = entity.definition().primaryKeyName;
            var primaryKeyValue = Reflect.field(entity, primaryKeyName);

            connect().then(result -> {
                return db.table(tableName);
            }).then(result -> {
                var record = entity.toRecord();
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
                resolve(entity);
            }, error -> {
                reject(error);
            });
        });
    }

    private var _connected:Bool = false;
    private function connect():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            if (_connected == true) {
                resolve(true);
                return;
            }

            db.connect().then(result -> {
                _connected = true;
                return checkTables();
            }).then(entity -> {
                defineRelationships();
                resolve(true);
            }, (error:DatabaseError) -> {
                reject(error);
            });
        });
    }

    private function checkTables():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var tableSchemas:Map<String, TableSchema> = buildTableSchemas();
            var promises = [];
            for (key in tableSchemas.keys()) {
                var tableSchema = tableSchemas.get(key);
                promises.push(checkTable.bind(tableSchema));
            }
            PromiseUtils.runAll(promises).then(results -> {
                resolve(true);
            }, error -> {
                reject(error);
            });
        });
    }

    private function checkTable(tableSchema:TableSchema):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            db.table(tableSchema.name).then(result -> {
                if (result.table.exists) {
                    resolve(true);
                    return null;
                }
                db.createTable(tableSchema.name, tableSchema.columns).then(result -> {
                    resolve(true);
                    return null;
                }, error -> {
                    reject(error);
                });
            }, error -> {
                reject(error);
            });
        });
    }

    private function buildTableSchemas():Map<String, TableSchema> {
        var linkTables:Map<String, String> = [];
        var tableSchemas:Map<String, TableSchema> = [];
        for (entityDefinition in entityDefinitions) {
            for (f in entityDefinition.fields) {
                switch (f.type) {
                    case Class(type, relationship):
                        switch (relationship) {
                            case OneToMany(table1, field1, table2, field2):
                                var linkTable = '${table1}_${table2}';
                                linkTables.set('${table2}_${table1}', linkTable);
                                if (linkTables.exists(linkTable)) {
                                    continue;
                                }
                                var table1PK = entityPrimaryKeyFieldName(table1);
                                var table2PK = entityPrimaryKeyFieldName(table2);

                                if (tableSchemas.get(linkTable) == null) {
                                    tableSchemas.set(linkTable, { name: linkTable, columns: []});
                                }
                                tableSchemas.get(linkTable).columns.push({
                                    name: '${table1}_${table1PK}',
                                    type: Number,
                                });
                                tableSchemas.get(linkTable).columns.push({
                                    name: '${table2}_${table2PK}',
                                    type: Number,
                                });

                            case OneToOne(table1, field1, table2, field2):    
                                if (tableSchemas.get(table1) == null) {
                                    tableSchemas.set(table1, { name: table1, columns: []});
                                }
                                tableSchemas.get(table1).columns.push({
                                    name: field2,
                                    type: Number,
                                });
                        }
                    case Integer:
                        if (tableSchemas.get(entityDefinition.tableName) == null) {
                            tableSchemas.set(entityDefinition.tableName, { name: entityDefinition.tableName, columns: []});
                        }

                        if (f.name == entityDefinition.primaryKeyName) {
                            tableSchemas.get(entityDefinition.tableName).columns.insert(0, {
                                name: f.name,
                                type: Number,
                                options: [ColumnOptions.PrimaryKey, ColumnOptions.AutoIncrement]
                            });
                        } else {
                            tableSchemas.get(entityDefinition.tableName).columns.push({
                                name: f.name,
                                type: Number
                            });
                        }
                    case String:    
                        if (tableSchemas.get(entityDefinition.tableName) == null) {
                            tableSchemas.set(entityDefinition.tableName, { name: entityDefinition.tableName, columns: []});
                        }
                        tableSchemas.get(entityDefinition.tableName).columns.push({
                            name: f.name,
                            type: Text(75),
                        });
                }
            }
        }
        
        return tableSchemas;
    }

    private var _relationshipsDefined:Bool = false;
    private function defineRelationships() {
        if (_relationshipsDefined == true) {
            return;
        }

        _relationshipsDefined = true;
        var orderedRelationships:Map<String, Array<{from:String, to:String}>> = [];
        var linkTables:Map<String, String> = [];
        for (entityDefinition in entityDefinitions) {
            for (f in entityDefinition.fields) {
                switch (f.type) {
                    case Class(type, relationship):
                        switch (relationship) {
                            case OneToMany(table1, field1, table2, field2):
                                var linkTable = '${table1}_${table2}';
                                linkTables.set('${table2}_${table1}', linkTable);
                                if (linkTables.exists(linkTable)) {
                                    continue;
                                }
                                var table1PK = entityPrimaryKeyFieldName(table1);
                                var table2PK = entityPrimaryKeyFieldName(table2);

                                if (!orderedRelationships.exists(table1)) {
                                    orderedRelationships.set(table1, []);
                                }
                                orderedRelationships.get(table1).push({from: '${table1}.${table1PK}', to: '${linkTable}.${table1}_${table1PK}'});

                                if (!orderedRelationships.exists(table2)) {
                                    orderedRelationships.set(table2, []);
                                }
                                orderedRelationships.get(table2).push({from: '${table2}.${table2PK}', to: '${linkTable}.${table2}_${table2PK}'});
                            case _:    
                        }
                    case _:   
                }
            }
        }

        for (entityDefinition in entityDefinitions) {
            for (f in entityDefinition.fields) {
                switch (f.type) {
                    case Class(type, relationship):
                        switch (relationship) {
                            case OneToOne(table1, field1, table2, field2):
                                if (!orderedRelationships.exists(table1)) {
                                    orderedRelationships.set(table1, []);
                                }
                                orderedRelationships.get(table1).push({from: '${table1}.${field2}', to: '${table2}.${field2}'});
                            case _:
                        }
                    case _:   
                }
            }
        }

        for (k in orderedRelationships.keys()) {
            var a = orderedRelationships.get(k);
            for (x in a) {
                db.defineTableRelationship(x.from, x.to);
            }
        }
    }

    private function entityPrimaryKeyFieldName(tableName:String) {
        for (entityDefinition in entityDefinitions) {
            if (entityDefinition.tableName == tableName) {
                return entityDefinition.primaryKeyName;
            }
        }
        return null;
    }
}
