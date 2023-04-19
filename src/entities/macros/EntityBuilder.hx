package entities.macros;

import db.ColumnOptions;
import db.ColumnType;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;

class EntityBuilder {
    macro static function build():Array<Field> {
        var fields = Context.getBuildFields();
        var localClass = Context.getLocalClass().get();
        localClass.meta.add(":access", [macro entities.EntityManager], Context.currentPos());

        var localClassName = Context.getLocalClass().toString();
        Sys.println("building entity " + localClass.name + " [" + localClassName + "]");

        var s = localClassName;
        var parts = s.split(".");
        s = parts.pop();

        var entityClassType:TypePath = {
            pack: parts,
            name: s
        };

        var entityDefinition:EntityDefinition = {
            tableName: extractTableName(localClass),
            fields: [],
            primaryKeyFieldName: null,
            primaryKeyFieldType: null
        }
        checkForPrimaryKeys(entityDefinition, fields);

        for (field in fields) {
            if (field.access.contains(AStatic)) {
                continue;
            }

            var fieldName = field.name;
            var fieldOptions:Array<EntityFieldOption> = [];
            if (hasMeta(field.meta, ":primaryKey")) {
                fieldOptions.push(EntityFieldOption.PrimaryKey);
            }
            if (hasMeta(field.meta, ":increment")) {
                fieldOptions.push(EntityFieldOption.AutoIncrement);
            }

            switch (field.kind) {
                case FVar(t, e):
                    switch (t) {
                        case TPath(p):
                            var typeName = p.name;
                            if (typeName == "Null" && p.params.length == 1) {
                                switch (p.params[0]) {
                                    case TPType(TPath(p)):
                                        typeName = p.name;
                                    case _:    
                                }
                            }
                            field.meta.push({name: ":optional", pos: Context.currentPos()});
                            switch (typeName) {
                                case "Bool":
                                    entityDefinition.fields.push({
                                        name: fieldName,
                                        options: fieldOptions,
                                        type: EntityFieldType.Boolean
                                    });
                                case "Int":
                                    entityDefinition.fields.push({
                                        name: fieldName,
                                        options: fieldOptions,
                                        type: EntityFieldType.Number
                                    });
                                case "Float":
                                    entityDefinition.fields.push({
                                        name: fieldName,
                                        options: fieldOptions,
                                        type: EntityFieldType.Number
                                    });
                                case "String":
                                    entityDefinition.fields.push({
                                        name: fieldName,
                                        options: fieldOptions,
                                        type: EntityFieldType.Text
                                    });
                                case "Date":
                                    entityDefinition.fields.push({
                                        name: fieldName,
                                        options: fieldOptions,
                                        type: EntityFieldType.Date
                                    });
                                case "Array":
                                    var resolvedType = Context.resolveType(t, Context.currentPos());
                                    switch (resolvedType) {
                                        case TInst(_, [TInst(resolvedInstance, params)]):
                                            var isEntity = false;
                                            for (i in resolvedInstance.get().interfaces) {
                                                if (i.t.toString() == "entities.IEntity") {
                                                    isEntity = true;
                                                    break;
                                                }
                                            }
                                            if (isEntity) {
                                                buildOneToManyField(field, t, entityDefinition, fields);
                                            } else {
                                                Sys.println("    - field '" + field.name + "' not entity, skipping");
                                            }
                                        case _:
                                            Sys.println("    - array field not supported for field '" + field.name + "', skipping");
                                    }            
                                case _:
                                    var resolvedType = Context.resolveType(t, Context.currentPos());
                                    switch (resolvedType) {
                                        case TInst(_.toString() => "haxe.io.Bytes",_):
                                            entityDefinition.fields.push({
                                                name: fieldName,
                                                options: fieldOptions,
                                                type: EntityFieldType.Binary
                                            });
                                        case TInst(resolvedInstance, params):
                                            var isEntity = false;
                                            for (i in resolvedInstance.get().interfaces) {
                                                if (i.t.toString() == "entities.IEntity") {
                                                    isEntity = true;
                                                    break;
                                                }
                                            }
                                            if (isEntity) {
                                                buildOneToOneField(field, t, entityDefinition, fields);
                                            } else {
                                                Sys.println("    - field '" + field.name + "' not entity, skipping");
                                            }
                                        case _:
                                            Sys.println("    - type '" + p.name + "' not supported for field '" + field.name + "', skipping");
                                    }
                            }
                        case _:   
                    }
                case _:    
            }
        }

        if (!hasMeta(localClass.meta.get(), ":structInit")) {
            buildConstructor(fields);
        }
        buildToRecord(entityDefinition, fields);
        buildFromRecords(entityDefinition, fields);
        buildTableSchema(entityDefinition, fields);
        buildConnect(fields);
        buildCheckTables(entityDefinition, fields);
        buildEntityDefinition(entityDefinition, fields);
        buildPrimaryKeyQuery(entityDefinition, fields);
        buildNotifiers(entityDefinition, fields);

        buildExists(entityDefinition, fields);
        buildAdd(entityClassType, entityDefinition, fields);
        buildUpdate(entityClassType, entityDefinition, fields);
        buildDelete(entityClassType, entityDefinition, fields);
        buildFind(entityClassType, entityDefinition, fields);
        buildFindById(entityClassType, entityDefinition, fields);
        buildFindInternal(entityClassType, entityDefinition, fields);
        buildRefresh(entityClassType, entityDefinition, fields);
        buildAll(entityClassType, entityDefinition, fields);
        
        return fields;
    }

    #if macro

    static function buildOneToManyField(field:Field, type:ComplexType, entityDefinition:EntityDefinition, fields:Array<Field>) {
        var localClass = Context.getLocalClass().get();

        var resolvedType = Context.resolveType(type, Context.currentPos());
        switch (resolvedType) {
            case TInst(_, [TInst(resolvedInstance, params)]):
                var resolveClassString = resolvedInstance.toString();
                localClass.meta.add(":access", [macro $p{resolveClassString.split(".")}], Context.currentPos());

                var resolvedTableName = extractTableName(resolvedInstance.get());
                var primaryFieldName = null;
                var linkTableName = entityDefinition.tableName + "_" + field.name.toLowerCase();
                var fieldOptions = [];
                if (hasMeta(field.meta, ":cascade")) {
                    fieldOptions.push(EntityFieldOption.CascadeDeletions);
                }
                for (resolvedField in resolvedInstance.get().fields.get()) {
                    if (hasMeta(resolvedField.meta.get(), ":primaryKey")) {
                        var resolvedFieldType = TypeTools.toComplexType(resolvedField.type);
                        // TODO: might want to prefix the field with resolvedTableName var so we can have multiple instance of the same type
                        var resolvedFieldName = resolvedField.name;
                        primaryFieldName = resolvedFieldName;
                        entityDefinition.fields.push({
                            name: field.name,
                            type: EntityFieldType.Class(resolvedInstance.toString(), EntityFieldRelationship.OneToMany(entityDefinition.tableName, entityDefinition.primaryKeyFieldName, resolvedTableName, resolvedFieldName), haxeTypeToEntityFieldType(resolvedFieldType)),
                            options: fieldOptions
                        });
                        break;
                    }
                }
                defineTableRelationship(entityDefinition.tableName + "." + entityDefinition.primaryKeyFieldName, linkTableName + "." + entityDefinition.primaryKeyFieldName);
                defineTableRelationship(linkTableName + "." + primaryFieldName, resolvedTableName + "." + primaryFieldName);

            case _:
        }
    }

    static function buildOneToOneField(field:Field, type:ComplexType, entityDefinition:EntityDefinition, fields:Array<Field>) {
        var localClass = Context.getLocalClass().get();
        
        var resolvedType = Context.resolveType(type, Context.currentPos());
        switch (resolvedType) {
            case TInst(resolvedInstance, params):
                var resolveClassString = resolvedInstance.toString();
                localClass.meta.add(":access", [macro $p{resolveClassString.split(".")}], Context.currentPos());

                var resolvedTableName = extractTableName(resolvedInstance.get());
                var primaryFieldName = null;
                var fieldOptions = [];
                if (hasMeta(field.meta, ":cascade")) {
                    fieldOptions.push(EntityFieldOption.CascadeDeletions);
                }
                for (resolvedField in resolvedInstance.get().fields.get()) {
                    if (hasMeta(resolvedField.meta.get(), ":primaryKey")) {
                        var resolvedFieldType = TypeTools.toComplexType(resolvedField.type);
                        // TODO: might want to prefix the field with resolvedTableName var so we can have multiple instance of the same type
                        var resolvedFieldName = resolvedField.name;
                        primaryFieldName = resolvedFieldName;
                        entityDefinition.fields.push({
                            name: field.name,
                            type: EntityFieldType.Class(resolvedInstance.toString(), EntityFieldRelationship.OneToOne(entityDefinition.tableName, resolvedFieldName, resolvedTableName, resolvedFieldName), haxeTypeToEntityFieldType(resolvedFieldType)),
                            options: fieldOptions
                        });
                        break;
                    }
                }
                defineTableRelationship(entityDefinition.tableName + "." + primaryFieldName, resolvedTableName + "." + primaryFieldName);
            case _:
        }
    }

    static function extractTableName(classType:ClassType) {
        var tableName = classType.name.toLowerCase();
        var tableMeta = classType.meta.extract(":table");
        if (tableMeta != null && tableMeta.length > 0) {
            tableName = ExprTools.toString(tableMeta[0].params[0]);
        }
        return tableName;
    }

    static function buildConstructor(fields:Array<Field>) {
        var ctor:Field = null;
        for (field in fields) {
            if (field.name == "new") {
                ctor = field;
            }
        }

        if (ctor == null) {
            ctor = {
                name: "new",
                access: [APublic],
                kind: FFun({
                    args: [],
                    expr: macro {
                    }
                }),
                pos: Context.currentPos()
            }
            fields.push(ctor);
        }
    }
    
    static function checkForPrimaryKeys(entityDefinition:EntityDefinition, fields:Array<Field>) {
        var hasPrimaryKey = false;
        for (field in fields) {
            if (hasMeta(field.meta, ":primaryKey")) {
                hasPrimaryKey = true;
                entityDefinition.primaryKeyFieldName = field.name;
                switch (field.kind) {
                    case FVar(t, e):
                        entityDefinition.primaryKeyFieldType = haxeTypeToEntityFieldType(t);
                        entityDefinition.primarayKeyFieldAutoIncrement = hasMeta(field.meta, ":increment");
                    case _:    
                }
                break;
            }
        }

        if (!hasPrimaryKey) {
            var exposeId:Bool = hasMeta(Context.getLocalClass().get().meta.get(), ":exposeId");
            var meta = [{name: ":primaryKey", pos: Context.currentPos()}, {name: ":increment", pos: Context.currentPos()}, {name: ":jignored", pos: Context.currentPos()}, {name: ":noCompletion", pos: Context.currentPos()}, {name: ":optional", pos: Context.currentPos()}];
            if (exposeId) {
                meta = [{name: ":primaryKey", pos: Context.currentPos()}, {name: ":increment", pos: Context.currentPos()}, {name: ":optional", pos: Context.currentPos()}];                
            }
            var access = [APrivate];
            if (exposeId) {
                access = [APublic];
            }
            var primaryKeyName = toLowerFirstChar(entityDefinition.tableName) + "Id";
            fields.insert(0, {
                name: primaryKeyName,
                access: access,
                kind: FVar(macro: Null<Int>),
                meta: meta,
                pos: Context.currentPos()
            });
            entityDefinition.primaryKeyFieldName = primaryKeyName;
            entityDefinition.primaryKeyFieldType = EntityFieldType.Number;
            entityDefinition.primarayKeyFieldAutoIncrement = true;
            if (exposeId) {
                var isJsonToObjectParsable = false;

                // special case for exposeId and when the entity implements IJson2ObjectParsable
                // the reason is that the primary key field might not have been created by the time
                // the json2object macro has build its field data, this appends the newly created
                // field to the parse method (may need revision)
                for (i in Context.getLocalClass().get().interfaces) {
                    if (i.t.toString() == "rest.IJson2ObjectParsable") {
                        isJsonToObjectParsable = true;
                        break;
                    }
                }
                if (isJsonToObjectParsable) {
                    for (field in fields) {
                        if (field.name == "parse") {
                            switch (field.kind) {
                                case FFun(f):
                                    switch (f.expr.expr) {
                                        case EBlock(exprs): {
                                            exprs.push(macro this.$primaryKeyName = data.$primaryKeyName);
                                        }
                                        case _:
                                    }
                                case _:   
                            }
                        }
                    }
                }
            }
        }
    }

    static function buildToRecord(entityDefinition:EntityDefinition, fields:Array<Field>) {
        var exprs:Array<Expr> = [];
        for (fieldDef in entityDefinition.fields) {
            switch (fieldDef.type) {
                case EntityFieldType.Boolean:
                    exprs.push(macro record.field($v{fieldDef.name}, $i{fieldDef.name} == true ? 1 : 0));
                case EntityFieldType.Number | EntityFieldType.Text:
                    exprs.push(macro record.field($v{fieldDef.name}, $i{fieldDef.name}));
                case EntityFieldType.Date:
                    exprs.push(macro record.field($v{fieldDef.name}, entities.EntityUtils.dateToIso8601($i{fieldDef.name})));
                case EntityFieldType.Binary:
                    exprs.push(macro record.field($v{fieldDef.name}, $i{fieldDef.name}));
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToOne(table1, field1, table2, field2), type):
                    exprs.push(macro @:privateAccess if ($i{fieldDef.name} != null) record.field($v{field1}, $i{fieldDef.name}.$field2) );
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToMany(table1, field1, table2, field2), type):
            }
        }
        fields.push({
            name: "toRecord",
            access: [APrivate],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [],
                ret: macro: db.Record,
                expr: macro {
                    var record = new db.Record();
                    $b{exprs};
                    return record;
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function buildFromRecords(entityDefinition:EntityDefinition, fields:Array<Field>) {
        var simpleExprs:Array<Expr> = [];
        var loopExprs:Array<Expr> = [];
        
        for (fieldDef in entityDefinition.fields) {
            var varName = fieldDef.name;
            var fieldName = fieldDef.name;
            switch (fieldDef.type) {
                case EntityFieldType.Boolean:
                    simpleExprs.push(macro var fieldName = $v{fieldName});
                    simpleExprs.push(macro if (fieldPrefix != null && fieldPrefix.length > 0) fieldName = fieldPrefix + "." + fieldName);
                    simpleExprs.push(macro var value = records[0].field(fieldName));
                    simpleExprs.push(macro if (value != null) {
                        this.$varName = (value == 1) ? true : false;
                        this._hasData = true;
                    });
                case EntityFieldType.Number | EntityFieldType.Text:
                    simpleExprs.push(macro var fieldName = $v{fieldName});
                    simpleExprs.push(macro if (fieldPrefix != null && fieldPrefix.length > 0) fieldName = fieldPrefix + "." + fieldName);
                    simpleExprs.push(macro var value = records[0].field(fieldName));
                    simpleExprs.push(macro if (value != null) {
                        this.$varName = value;
                        this._hasData = true;
                    });
                case EntityFieldType.Date:    
                    simpleExprs.push(macro var fieldName = $v{fieldName});
                    simpleExprs.push(macro if (fieldPrefix != null && fieldPrefix.length > 0) fieldName = fieldPrefix + "." + fieldName);
                    simpleExprs.push(macro var value = records[0].field(fieldName));
                    simpleExprs.push(macro if (value != null) {
                        this.$varName = entities.EntityUtils.iso8601ToDate(value);
                        this._hasData = true;
                    });
                case EntityFieldType.Binary:    
                    simpleExprs.push(macro var fieldName = $v{fieldName});
                    simpleExprs.push(macro if (fieldPrefix != null && fieldPrefix.length > 0) fieldName = fieldPrefix + "." + fieldName);
                    simpleExprs.push(macro var value = records[0].field(fieldName));
                    simpleExprs.push(macro if (value != null) {
                        this.$varName = value;
                        this._hasData = true;
                    });
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToOne(table1, field1, table2, field2), type):
                    var parts = className.split(".");
                    var name = parts.pop();
                    var classType = {
                        name: name,
                        pack: parts
                    };

                    var classComplexType = TPath(classType);
                    var resolvedType = Context.resolveType(classComplexType, Context.currentPos());
                    var structInit = switch (resolvedType) {
                        case TInst(resolvedInstance, params): hasMeta(resolvedInstance.get().meta.get(), ":structInit");
                        case _: false; 
                    }

                    var functionName = varName + "_deleted";

                    simpleExprs.push(macro if (this.$varName != null) @:privateAccess this.$varName.unregisterNotificationListener(entities.EntityNotificationType.Deleted, $i{functionName}));
                    if (structInit) {
                        simpleExprs.push(macro this.$varName = {});
                    } else {
                        simpleExprs.push(macro this.$varName = new $classType());
                    }
                    simpleExprs.push(macro @:privateAccess this.$varName.fromRecords(records, fieldPrefix + "." + $v{table2}));
                    simpleExprs.push(macro if (@:privateAccess this.$varName._hasData == false) this.$varName = null; else this._hasData = true);
                    simpleExprs.push(macro if (this.$varName != null) @:privateAccess this.$varName.registerNotificationListener(entities.EntityNotificationType.Deleted, $i{functionName}));

                    fields.push({
                        name: functionName,
                        access: [APrivate],
                        meta: [{name: ":noCompletion", pos: Context.currentPos()}],
                        kind: FFun({
                            args: [{
                                name: "entity",
                                type: macro: entities.IEntity
                            }],
                            expr: macro {
                                if (this.$varName != null) {
                                    @:privateAccess this.$varName.unregisterNotificationListener(entities.EntityNotificationType.Deleted, $i{functionName});
                                }
                                this.$varName = null;
                            }
                        }),
                        pos: Context.currentPos()
                    });
            
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToMany(table1, field1, table2, field2), type):
                    var varName = fieldDef.name;
                    var fieldName = fieldDef.name;
                    var linkTableName = table1 + "_" + fieldDef.name.toLowerCase();

                    var functionName = varName + "_item_deleted";
                    simpleExprs.push(macro if (this.$varName != null) {
                        for (item in this.$varName) {
                            @:privateAccess item.unregisterNotificationListener(entities.EntityNotificationType.Deleted, $i{functionName});
                        }
                    });
                    simpleExprs.push(macro this.$varName = []);

                    var parts = className.split(".");
                    var name = parts.pop();
                    var classType = {
                        name: name,
                        pack: parts
                    };
                    var classComplexType = TPath(classType);
                    var resolvedType = Context.resolveType(classComplexType, Context.currentPos());
                    var structInit = switch (resolvedType) {
                        case TInst(resolvedInstance, params): hasMeta(resolvedInstance.get().meta.get(), ":structInit");
                        case _: false; 
                    }
                    var createEntityExpr = macro new $classType();
                    if (structInit) {
                        createEntityExpr = macro {};
                    }

                    loopExprs.push(macro var tempId = record.field(fieldPrefix + "." + $v{linkTableName} + "." + $v{table2} + "." + $v{field2}));
                    loopExprs.push(macro var cacheKey = $v{varName} + "_" + tempId);
                    loopExprs.push(macro if (!cacheMap.exists(cacheKey)) {
                        var item:$classComplexType = $createEntityExpr;
                        var filteredRecords = records.filter(item -> {
                            return tempId == item.field(fieldPrefix + "." + $v{linkTableName} + "." + $v{table2} + "." + $v{field2});
                        });
                        @:privateAccess item.fromRecords(filteredRecords, fieldPrefix + "." + $v{linkTableName} + "." + $v{table2});
                        if (@:privateAccess item._hasData == true) {
                            this.$varName.push(item);
                            cacheMap.set(cacheKey, true);
                            this._hasData = true;
                            @:privateAccess item.registerNotificationListener(entities.EntityNotificationType.Deleted, $i{functionName});
                        }
                    });

                    fields.push({
                        name: functionName,
                        access: [APrivate],
                        meta: [{name: ":noCompletion", pos: Context.currentPos()}],
                        kind: FFun({
                            args: [{
                                name: "entity",
                                type: macro: entities.IEntity
                            }],
                            expr: macro {
                                var index = this.$varName.indexOf(cast entity);
                                if (index != -1) {
                                    @:privateAccess this.$varName[index].registerNotificationListener(entities.EntityNotificationType.Deleted, $i{functionName});
                                    this.$varName.remove(cast entity);
                                }
                            }
                        }),
                        pos: Context.currentPos()
                    });
            }
        }
        
        fields.push({
            name: "_hasData",
            access: [APrivate],
            kind: FVar(macro: Bool, macro false),
            meta: [{name: ":jignored", pos: Context.currentPos()}, {name: ":noCompletion", pos: Context.currentPos()}, {name: ":optional", pos: Context.currentPos()}],
            pos: Context.currentPos()
        });

        fields.push({
            name: "fromRecords",
            access: [APrivate],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [{
                    name: "records",
                    type: macro: Array<db.Record>
                }, {
                    name: "fieldPrefix",
                    type: macro: String
                }],
                expr: macro {
                    if (records == null || records.length < 1) {
                        return;
                    }
                    $b{simpleExprs}
                    var cacheMap:Map<String, Bool> = [];
                    for (record in records) {
                        $b{loopExprs}
                    }
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function buildTableSchema(entityDefinition:EntityDefinition, fields:Array<Field>) {
        var exprs:Array<Expr> = [];
        var linkExprs:Array<Expr> = [];
        for (fieldDef in entityDefinition.fields) {
            switch (fieldDef.type) {
                case EntityFieldType.Number | EntityFieldType.Text | EntityFieldType.Boolean | EntityFieldType.Date | EntityFieldType.Binary:
                    exprs.push(macro schema.columns.push({
                        name: $v{fieldDef.name},
                        type: $v{entityFieldTypeToColumnType(fieldDef.type)},
                        options: $v{entityFieldOptionsToColumnOptions(fieldDef.options)}
                    }));
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToOne(table1, field1, table2, field2), type):
                    exprs.push(macro schema.columns.push({
                        name: $v{field1},
                        type: $v{entityFieldTypeToColumnType(type)},
                        options: []
                    }));
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToMany(table1, field1, table2, field2), type):
                    var linkTableName = table1 + "_" + fieldDef.name.toLowerCase();
                    var linkField1 = field1;
                    var linkField2 = field2;
                    linkExprs.push(macro if (map == null) map = []);
                    linkExprs.push(macro var schema:db.TableSchema = {name: $v{linkTableName}, columns: []});
                    linkExprs.push(macro schema.columns.push({name: $v{linkField1}, type: $v{entityFieldTypeToColumnType(type)}, options: []}));
                    linkExprs.push(macro schema.columns.push({name: $v{linkField2}, type: $v{entityFieldTypeToColumnType(type)}, options: []}));
                    linkExprs.push(macro map.set($v{linkTableName}, schema));
            }
        }

        fields.push({
            name: "TableSchema",
            access: [APrivate, AStatic],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [],
                ret: macro: db.TableSchema,
                expr: macro {
                    var schema:db.TableSchema = {
                        name: $v{entityDefinition.tableName},
                        columns: []
                    }
                    $b{exprs};
                    return schema;
                }
            }),
            pos: Context.currentPos()
        });

        fields.push({
            name: "LinkTableSchemas",
            access: [APrivate, AStatic],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [],
                ret: macro: Map<String, db.TableSchema>,
                expr: macro {
                    var map:Map<String, db.TableSchema> = null;
                    $b{linkExprs};
                    return map;
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function buildCheckTables(entityDefinition:EntityDefinition, fields:Array<Field>) {
        var exprs:Array<Expr> = [];
        var linkExprs:Array<Expr> = [];
        for (fieldDef in entityDefinition.fields) {
            switch (fieldDef.type) {
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToOne(table1, field1, table2, field2), type):
                    var parts = className.split(".");
                    exprs.push(macro list.push(@:privateAccess $p{parts}.CheckTables));
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToMany(table1, field1, table2, field2), type):
                    var parts = className.split(".");
                    exprs.push(macro list.push(@:privateAccess $p{parts}.CheckTables));
                case _:    
            }
        }

        fields.push({
            name: "CheckTables",
            access: [APrivate, AStatic],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [],
                ret: macro: promises.Promise<Bool>,
                expr: macro {
                    return new promises.Promise((resolve, reject) -> {
                        if (_checkingTables) {
                            _deferredCheckTablesPromises.push({resolve: resolve, reject: reject});
                            return;
                        }
                        _checkingTables = true;
                        CheckTableSchema(TableSchema()).then(result -> {
                            return CheckLinkTables();
                        }).then(entity -> {
                            var list:Array<() -> promises.Promise<Any>> = [];
                            $b{exprs};
                            return promises.PromiseUtils.runSequentially(list);
                        }).then(entity -> {
                            resolve(true);
                            while (_deferredCheckTablesPromises.length > 0) {
                                _deferredCheckTablesPromises.pop().resolve(true);
                            }
                            _checkingTables = false;
                            return null;
                        }, error -> {
                            reject(error);
                            while (_deferredCheckTablesPromises.length > 0) {
                                _deferredCheckTablesPromises.pop().reject(error);
                            }
                            _checkingTables = false;
                        });
                    });
                }
            }),
            pos: Context.currentPos()
        });

        fields.push({
            name: "CheckLinkTables",
            access: [APrivate, AStatic],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [],
                ret: macro: promises.Promise<Bool>,
                expr: macro {
                    return new promises.Promise((resolve, reject) -> {
                        var list:Array<() -> promises.Promise<Any>> = [];
                        var linkSchemas = LinkTableSchemas();
                        if (linkSchemas != null) {
                            for (k in linkSchemas.keys()) {
                                list.push(CheckTableSchema.bind(linkSchemas.get(k)));
                            }
                        }
                        promises.PromiseUtils.runSequentially(list).then(success -> {
                            resolve(true);
                        }, error -> {
                            reject(error);
                        });
                    });
                }
            }),
            pos: Context.currentPos()
        });

        fields.push({
            name: "CheckTableSchema",
            access: [APrivate, AStatic],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [{name: "schema", type: macro: db.TableSchema}],
                ret: macro: promises.Promise<Bool>,
                expr: macro {
                    return new promises.Promise((resolve, reject) -> {
                        entities.EntityManager.instance.database.table(schema.name).then(result -> {
                            if (result.table.exists) {
                                resolve(true);
                                return null;
                            }
                            entities.EntityManager.instance.database.createTable(schema.name, schema.columns).then(result -> {
                                resolve(true);
                            }, error -> {
                                reject(error);
                            });
                        }, error -> {
                            reject(error);
                        });
                    });
                }
            }),
            pos: Context.currentPos()
        });

        fields.push({
            name: "_checkingTables",
            access: [APrivate, AStatic],
            kind: FVar(macro: Bool, macro false),
            meta: [{name: ":jignored", pos: Context.currentPos()}, {name: ":noCompletion", pos: Context.currentPos()}, {name: ":optional", pos: Context.currentPos()}],
            pos: Context.currentPos()
        });

        fields.push({
            name: "_deferredCheckTablesPromises",
            access: [APrivate, AStatic],
            kind: FVar(macro: Array<{resolve: Bool->Void, reject: Any->Void}>, macro []),
            meta: [{name: ":jignored", pos: Context.currentPos()}, {name: ":noCompletion", pos: Context.currentPos()}, {name: ":optional", pos: Context.currentPos()}],
            pos: Context.currentPos()
        });
    }

    static function buildConnect(fields:Array<Field>) {
        fields.push({
            name: "connect",
            access: [APrivate],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [],
                ret: macro: promises.Promise<Bool>,
                expr: macro {
                    return new promises.Promise((resolve, reject) -> {
                        entities.EntityManager.instance.connect().then(success -> {
                            this.database = entities.EntityManager.instance.database;
                            return CheckTables();
                        }).then(entity -> {
                            resolve(true);
                        }, error -> {
                            reject(error);
                        });
                    });
                }
            }),
            pos: Context.currentPos()
        });

        fields.push({
            name: "database",
            access: [APrivate],
            kind: FVar(macro: db.IDatabase, macro null),
            meta: [{name: ":jignored", pos: Context.currentPos()}, {name: ":noCompletion", pos: Context.currentPos()}, {name: ":optional", pos: Context.currentPos()}],
            pos: Context.currentPos()
        });
    }

    static function buildEntityDefinition(entityDefinition:EntityDefinition, fields:Array<Field>) {
        fields.push({
            name: "EntityDefinition",
            access: [APrivate, AStatic],
            kind: FVar(macro: entities.EntityDefinition, macro $v{entityDefinition}),
            meta: [{name: ":jignored", pos: Context.currentPos()}, {name: ":noCompletion", pos: Context.currentPos()}],
            pos: Context.currentPos()
        });

        fields.push({
            name: "definition",
            access: [APrivate],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [],
                ret: macro: entities.EntityDefinition,
                expr: macro {
                    return EntityDefinition;
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function buildPrimaryKeyQuery(entityDefinition:EntityDefinition, fields:Array<Field>) {
        var primaryKeyFieldName = entityDefinition.primaryKeyFieldName;
        var primaryKeyType = macro: Int;
        switch (entityDefinition.primaryKeyFieldType) {
            case EntityFieldType.Number:
                primaryKeyType = macro: Int;
            case EntityFieldType.Text:
                primaryKeyType = macro: String;
            case _:    
        }

        fields.push({
            name: "primaryKeyQuery",
            access: [APrivate],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [{
                    name: "primaryKey",
                    type: primaryKeyType
                }],
                ret: macro: Query.QueryExpr,
                expr: macro {
                    var q = Query.query(Query.field($v{primaryKeyFieldName}) = primaryKey);
                    return q;
                }
            }),
            pos: Context.currentPos()
        });

        fields.push({
            name: "primaryKeyQueryStatic",
            access: [AStatic],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [{
                    name: "primaryKey",
                    type: primaryKeyType
                }],
                ret: macro: Query.QueryExpr,
                expr: macro {
                    var q = Query.query(Query.field($v{primaryKeyFieldName}) = primaryKey);
                    return q;
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function buildNotifiers(entityDefinition:EntityDefinition, fields:Array<Field>) {
        fields.push({
            name: "_notificationListeners",
            access: [APrivate],
            kind: FVar(macro: Map<entities.EntityNotificationType, Array<entities.IEntity->Void>>, macro []),
            meta: [{name: ":jignored", pos: Context.currentPos()}, {name: ":noCompletion", pos: Context.currentPos()}, {name: ":optional", pos: Context.currentPos()}],
            pos: Context.currentPos()
        });

        fields.push({
            name: "notify",
            access: [APrivate],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [{
                    name: "type",
                    type: macro: entities.EntityNotificationType
                }],
                expr: macro {
                    var list = _notificationListeners.get(type);
                    if (list != null) {
                        for (l in list) {
                            l(this);
                        }
                    }
                }
            }),
            pos: Context.currentPos()
        });

        fields.push({
            name: "registerNotificationListener",
            access: [APrivate],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [{
                    name: "type",
                    type: macro: entities.EntityNotificationType
                }, {
                    name: "listener",
                    type: macro: entities.IEntity->Void
                }],
                expr: macro {
                    var list = _notificationListeners.get(type);
                    if (list == null) {
                        list = [];
                        _notificationListeners.set(type, list);
                    }
                    list.push(listener);
                }
            }),
            pos: Context.currentPos()
        });

        fields.push({
            name: "unregisterNotificationListener",
            access: [APrivate],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [{
                    name: "type",
                    type: macro: entities.EntityNotificationType
                }, {
                    name: "listener",
                    type: macro: entities.IEntity->Void
                }],
                expr: macro {
                    var list = _notificationListeners.get(type);
                    if (list != null) {
                        list.remove(listener);
                        if (list.length == 0) {
                            _notificationListeners.remove(type);
                        }
                    }
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function buildExists(entityDefinition:EntityDefinition, fields:Array<Field>) {
        var primaryKeyFieldName = entityDefinition.primaryKeyFieldName;
        fields.push({
            name: "exists",
            access: [APrivate],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [],
                ret: macro: promises.Promise<Bool>,
                expr: macro {
                    return new promises.Promise((resolve, reject) -> {
                        connect().then(success -> {
                            return database.table(definition().tableName);
                        }).then(result -> {
                            return result.table.find(primaryKeyQuery($i{primaryKeyFieldName}), false);
                        }).then(result -> {
                            if (result.data == null || result.data.length == 0) {
                                resolve(false);
                            } else {
                                if (result.data.length != 1) {
                                    trace("WARNING: more than one record with id found when checking if exists");
                                }
                                resolve(true);
                            }
                        }, error -> {
                            reject(error);
                        });
                    });
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function buildAdd(entityClassType:TypePath, entityDefinition:EntityDefinition, fields:Array<Field>) {
        var entityComplexType = TPath(entityClassType);

        var exprs:Array<Expr> = [];
        var linkExprs:Array<Expr> = [];
        
        for (fieldDef in entityDefinition.fields) {
            switch (fieldDef.type) {
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToOne(table1, field1, table2, field2), type):
                    exprs.push(macro if ($i{fieldDef.name} != null) list.push(@:privateAccess $i{fieldDef.name}.add));
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToMany(table1, field1, table2, field2), type):
                    var linkTableName = table1 + "_" + fieldDef.name.toLowerCase();
                    var linkField1 = field1;
                    var linkField2 = field2;

                    exprs.push(macro if ($i{fieldDef.name} != null) {
                        for (item in $i{fieldDef.name}) {
                            list.push(@:privateAccess item.add);
                        }
                    });
                    linkExprs.push(macro var linkRecords = []);
                    linkExprs.push(macro if ($i{fieldDef.name} != null) {
                        for (item in $i{fieldDef.name}) {
                            var linkRecord = new db.Record();
                            linkRecord.field($v{linkField1}, this.$field1);
                            linkRecord.field($v{linkField2}, @:privateAccess item.$field2);
                            linkRecords.push(linkRecord);
                        }
                    });
                    linkExprs.push(macro list.push(addLinks.bind($v{linkTableName}, linkRecords)));
                case _:    
            }
        }

        var primaryKeyFieldName = entityDefinition.primaryKeyFieldName;
        var primarayKeyFieldAutoIncrement = entityDefinition.primarayKeyFieldAutoIncrement;
        var assignmentExpr:Expr = macro null;
        if (primaryKeyFieldName != null && primarayKeyFieldAutoIncrement) {
            assignmentExpr = macro {
                var insertedId:Int = result.data.field("_insertedId");
                this.$primaryKeyFieldName = insertedId;
            }
        }

        fields.push({
            name: "add",
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro: promises.Promise<$entityComplexType>,
                expr: macro {
                    return new promises.Promise((resolve, reject) -> {
                        connect().then(success -> {
                            var list:Array<() -> promises.Promise<Any>> = [];
                            $b{exprs};
                            return promises.PromiseUtils.runSequentially(list);
                        }).then(result -> {
                            return database.table(definition().tableName);
                        }).then(result -> {
                            exists().then(alreadyExists -> {
                                if (alreadyExists) {
                                    return null;
                                } else {
                                    var record = this.toRecord();
                                    return result.table.add(record);
                                }
                            });
                        }).then(result -> {
                            var list:Array<() -> promises.Promise<Any>> = [];
                            if (result != null) {
                                $e{assignmentExpr};
                                $b{linkExprs};
                            }
                            return promises.PromiseUtils.runSequentially(list);
                        }).then(result -> {
                            resolve(this);
                        }, error -> {
                            reject(error);
                        });
                    });
                }
            }),
            pos: Context.currentPos()
        });

        fields.push({
            name: "addLinks",
            access: [APrivate],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [{name: "tableName", type: macro: String}, {name: "records", type: macro: Array<db.Record>}],
                ret: macro: promises.Promise<Bool>,
                expr: macro {
                    return new promises.Promise((resolve, reject) -> {
                        connect().then(success -> {
                            return database.table(tableName);
                        }).then(result -> {
                            var list:Array<() -> promises.Promise<Any>> = [];
                            for (record in records) {
                                list.push(result.table.add.bind(record));
                            }
                            return promises.PromiseUtils.runSequentially(list);
                        }).then(result -> {
                            resolve(true);
                        }, error -> {
                            reject(error);
                        });
                    });
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function buildUpdate(entityClassType:TypePath, entityDefinition:EntityDefinition, fields:Array<Field>) {
        var entityComplexType = TPath(entityClassType);
        var primaryKeyFieldName = entityDefinition.primaryKeyFieldName;

        var exprs:Array<Expr> = [];
        var updateLinksExprs:Array<Expr> = [];
        for (fieldDef in entityDefinition.fields) {
            switch (fieldDef.type) {
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToOne(table1, field1, table2, field2), type):
                    exprs.push(macro if ($i{fieldDef.name} != null) list.push(@:privateAccess $i{fieldDef.name}.update));
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToMany(table1, field1, table2, field2), type):
                    var fieldName = fieldDef.name;
                    var functionName = "update_" + fieldDef.name;
                    var linkTableName = table1 + "_" + fieldDef.name.toLowerCase();
                    var linkField1 = field1;
                    var linkField2 = field2;
                    
                    var parts = className.split(".");
                    var name = parts.pop();
                    var classType = {
                        name: name,
                        pack: parts
                    };
                    var classComplexType = TPath(classType);
                    var resolvedClass = Context.resolveType(classComplexType, Context.currentPos());
                    var resolvedPrimaryKeyType = macro: Any;
                    switch (resolvedClass) {
                        case TInst(t, params):
                            for (resolvedClassField in t.get().fields.get()) {
                                if (hasMeta(resolvedClassField.meta.get(), ":primaryKey")) {
                                    resolvedPrimaryKeyType = TypeTools.toComplexType(resolvedClassField.type);
                                    break;
                                }
                            }
                        case _:
                    }

                    fields.push({
                        name: functionName,
                        access: [APrivate],
                        meta: [{name: ":noCompletion", pos: Context.currentPos()}],
                        kind: FFun({
                            args: [],
                            ret: macro: promises.Promise<Bool>,
                            expr: macro {
                                return new promises.Promise((resolve, reject) -> {
                                    var array = [];
                                    connect().then(success -> {
                                        return database.table($v{linkTableName});
                                    }).then(result -> {
                                        var q = Query.query(Query.field($v{linkField1}) = $i{primaryKeyFieldName});
                                        return result.table.find(q);
                                    }).then(result -> {
                                        var dbMap:Map<$resolvedPrimaryKeyType, Bool> = [];
                                        for (record in result.data) {
                                            var foreignKey = record.field($v{linkTableName} + "." + $v{linkField2});
                                            if (foreignKey != null) {
                                                dbMap.set(foreignKey, true);
                                            }
                                        }

                                        var existingMap:Map<$resolvedPrimaryKeyType, $classComplexType> = [];
                                        var creations = [];
                                        if (this.$fieldName != null) {
                                            for (item in this.$fieldName) {
                                                var v = @:privateAccess item.$linkField2;
                                                if (v == null) {
                                                    creations.push(item);
                                                    continue;
                                                }
                                                existingMap.set(v, item);
                                            }
                                        }

                                        var deletions = [];
                                        var updates = [];
                                        var additions = [];
                                        for (key in existingMap.keys()) {
                                            if (dbMap.exists(key)) {
                                                updates.push(existingMap.get(key));
                                            } else {
                                                additions.push(existingMap.get(key));
                                            }
                                        }
                                        for (key in dbMap.keys()) {
                                            if (!existingMap.exists(key)) {
                                                deletions.push(key);
                                            }
                                        }

                                        var createPromise = function(item:$classComplexType) {
                                            return new promises.Promise((resolve, reject) -> {
                                                item.add().then(result -> {
                                                    var linkRecord = new db.Record();
                                                    linkRecord.field($v{linkField1}, this.$field1);
                                                    linkRecord.field($v{linkField2}, @:privateAccess item.$field2);
                                                    return this.addLinks($v{linkTableName}, [linkRecord]);
                                                }).then(result -> {
                                                    resolve(true);
                                                }, error -> {
                                                    reject(error);
                                                });
                                            });
                                        }

                                        var addPromise = function(item:$classComplexType) {
                                            var linkRecord = new db.Record();
                                            linkRecord.field($v{linkField1}, this.$field1);
                                            linkRecord.field($v{linkField2}, @:privateAccess item.$field2);
                                            return this.addLinks($v{linkTableName}, [linkRecord]);
                                        }

                                        var deletePromise = function(tableName:String, key1:Any, key2:Any) {
                                            return new promises.Promise((resolve, reject) -> {
                                                connect().then(success -> {
                                                    return database.table(tableName);
                                                }).then(result -> {
                                                    var q = Query.query(Query.field($v{linkField1}) = key1 && Query.field($v{linkField2}) = key2);
                                                    return result.table.deleteAll(q);
                                                }).then(result -> {
                                                    resolve(true);
                                                }, error -> {
                                                    reject(error);
                                                });
                                            });
                                        }

                                        var list:Array<() -> promises.Promise<Any>> = [];
                                        for (creation in creations) {
                                            list.push(createPromise.bind(creation));
                                        }
                                        for (addition in additions) {
                                            list.push(addPromise.bind(addition));
                                        }
                                        for (update in updates) {
                                            list.push(update.update);
                                        }
                                        // TODO: need to cascade _some_ deletions (based on metadata)
                                        for (deletion in deletions) {
                                            var key1 = this.$field1;
                                            var key2 = deletion;
                                            list.push(deletePromise.bind($v{linkTableName}, key1, key2));
                                        }

                                        return promises.PromiseUtils.runSequentially(list);
                                    }).then(result -> {
                                        findInternal(primaryKeyQuery(this.$primaryKeyFieldName)).then(result -> {
                                            resolve(true);
                                        }, error -> {
                                            reject(error);
                                            return null;
                                        });
                                    }, error -> {
                                        reject(error);
                                    });
                                });
                            }
                        }),
                        pos: Context.currentPos()
                    });
                    updateLinksExprs.push(macro list.push($i{functionName}));
                case _:    
            }
        }

        fields.push({
            name: "update",
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro: promises.Promise<$entityComplexType>,
                expr: macro {
                    return new promises.Promise((resolve, reject) -> {
                        connect().then(success -> {
                            var list:Array<() -> promises.Promise<Any>> = [];
                            $b{exprs};
                            return promises.PromiseUtils.runSequentially(list);
                        }).then(result -> {
                            return database.table(definition().tableName);
                        }).then(result -> {
                            exists().then(alreadyExists -> {
                                if (alreadyExists) {
                                    return new promises.Promise((resolve, reject) -> {
                                        var record = this.toRecord();
                                        result.table.update(primaryKeyQuery(record.field($v{primaryKeyFieldName})), record).then(result -> {
                                            resolve(this);
                                        }, error -> {
                                            reject(error);
                                        });
                                    });
                                } else {
                                    return add();
                                }
                            });
                        }).then(result -> {
                            return updateLinks();
                        }).then(result -> {
                            resolve(this);
                        }, error -> {
                            reject(error);
                        });
                    });
                }
            }),
            pos: Context.currentPos()
        });

        fields.push({
            name: "updateLinks",
            access: [APrivate],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [],
                ret: macro: promises.Promise<Bool>,
                expr: macro {
                    return new promises.Promise((resolve, reject) -> {
                        connect().then(success -> {
                            var list:Array<() -> promises.Promise<Any>> = [];
                            $b{updateLinksExprs};
                            return promises.PromiseUtils.runSequentially(list);
                        }).then(result -> {
                            resolve(true);
                        }, error -> {
                            reject(error);
                        });
                    });
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function buildDelete(entityClassType:TypePath, entityDefinition:EntityDefinition, fields:Array<Field>) {
        var entityComplexType = TPath(entityClassType);
        var primaryKeyFieldName = entityDefinition.primaryKeyFieldName;
        
        var exprs:Array<Expr> = [];
        var linkExprs:Array<Expr> = [];
        for (fieldDef in entityDefinition.fields) {
            switch (fieldDef.type) {
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToOne(table1, field1, table2, field2), type):
                    if (fieldDef.options.contains(EntityFieldOption.CascadeDeletions)) {
                        exprs.push(macro if ($i{fieldDef.name} != null) list.push($i{fieldDef.name}.delete));
                    }
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToMany(table1, field1, table2, field2), type):
                    if (fieldDef.options.contains(EntityFieldOption.CascadeDeletions)) {
                        var fieldName = fieldDef.name;
                        var functionName = "delete_" + fieldDef.name;
                        var linkTableName = table1 + "_" + table2;
                        var linkField1 = field1;
                        var linkField2 = field2;
                        
                        fields.push({
                            name: functionName,
                            access: [APrivate],
                            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
                            kind: FFun({
                                args: [],
                                ret: macro: promises.Promise<$entityComplexType>,
                                expr: macro {
                                    return new promises.Promise((resolve, reject) -> {
                                        var list:Array<() -> promises.Promise<Any>> = [];
                                        for (item in this.$fieldName) {
                                            list.push(item.delete);
                                        }
                                        promises.PromiseUtils.runSequentially(list).then(result -> {
                                            var deletePromise = function() {
                                                return new promises.Promise((resolve, reject) -> {
                                                    resolve(this);
                                                });
                                            }
                                            var list:Array<() -> promises.Promise<Any>> = [];
                                            return promises.PromiseUtils.runSequentially(list);
                                        }).then(result -> {
                                            resolve(this);
                                        }, error -> {
                                            reject(error);
                                        });
                                    });
                                }
                            }),
                            pos: Context.currentPos()
                        });
                        exprs.push(macro list.push($i{functionName}));
                    }
                    case _:
                }
        }

        fields.push({
            name: "delete",
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro: promises.Promise<Bool>,
                expr: macro {
                    return new promises.Promise((resolve, reject) -> {
                        connect().then(success -> {
                            return database.table(definition().tableName);
                        }).then(result -> {
                            return result.table.deleteAll(primaryKeyQuery(this.$primaryKeyFieldName));
                        }).then(result -> {
                            var list:Array<() -> promises.Promise<Any>> = [];
                            $b{exprs};
                            return promises.PromiseUtils.runSequentially(list);
                        }).then(result -> {
                            var list:Array<() -> promises.Promise<Any>> = [];
                            var deleteLinkPromise = function(linkTable:String, linkField:String, linkValue:Any) {
                                return new promises.Promise((resolve, reject) -> {
                                    database.table(linkTable).then(result -> {
                                        var q = Query.query(linkField = linkValue);
                                        return result.table.deleteAll(q);
                                    }).then(result -> {
                                        resolve(true);
                                    }, error -> {
                                        reject(error);
                                    });
                                });
                            }
                            var nullifyOneToOnePromise = function(sourceTable:String, sourceField:String, sourceValue:Any) {
                                return new promises.Promise((resolve, reject) -> {
                                    database.table(sourceTable).then(result -> {
                                        var q = Query.query(sourceField = sourceValue);
                                        var record = new db.Record();
                                        record.empty(sourceField);
                                        return result.table.update(q, record);
                                    }).then(result -> {
                                        resolve(true);
                                    }, error -> {
                                        reject(error);
                                    });
                                });
                            }
                            for (relationship in this.findOneToManyRelationships()) {
                                list.push(deleteLinkPromise.bind(relationship.table2, relationship.field2, this.$primaryKeyFieldName));
                            }
                            for (relationship in this.findOneToOneRelationships()) {
                                list.push(nullifyOneToOnePromise.bind(relationship.table1, relationship.field1, this.$primaryKeyFieldName));
                            }
                            return promises.PromiseUtils.runSequentially(list);
                        }).then(result -> {
                            this.notify(entities.EntityNotificationType.Deleted);
                            resolve(true);
                        }, error -> {
                            reject(error);
                        });
                    });
                }
            }),
            pos: Context.currentPos()
        });

        fields.push({
            name: "findOneToManyRelationships",
            access: [APrivate],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [],
                ret: macro: Array<db.RelationshipDefinition>,
                expr: macro {
                    var tableName = this.definition().tableName;
                    var primaryKeyFieldName = this.definition().primaryKeyFieldName;
                    var relationships = database.definedTableRelationships();
                    if (relationships == null) {
                        return [];
                    }
                    var list = [];
                    for (relationship in relationships.all()) {
                        if (relationship.table1 == tableName && relationship.field1 == primaryKeyFieldName) {
                            list.push(relationship);
                        }
                    }
                    return list;
                }
            }),
            pos: Context.currentPos()
        });

        fields.push({
            name: "findOneToOneRelationships",
            access: [APrivate],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [],
                ret: macro: Array<db.RelationshipDefinition>,
                expr: macro {
                    var tableName = this.definition().tableName;
                    var primaryKeyFieldName = this.definition().primaryKeyFieldName;
                    var relationships = database.definedTableRelationships();
                    if (relationships == null) {
                        return [];
                    }
                    var list = [];
                    for (relationship in relationships.all()) {
                        if (relationship.table2 == tableName && relationship.field2 == primaryKeyFieldName) {
                            list.push(relationship);
                        }
                    }
                    return list;
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function buildRefresh(entityClassType:TypePath, entityDefinition:EntityDefinition, fields:Array<Field>) {
        var entityComplexType = TPath(entityClassType);
        var primaryKeyFieldName = entityDefinition.primaryKeyFieldName;
        
        fields.push({
            name: "refresh",
            access: [APublic],
            kind: FFun({
                args: [],
                ret: macro: promises.Promise<$entityComplexType>,
                expr: macro {
                    return new promises.Promise((resolve, reject) -> {
                        var id = this.$primaryKeyFieldName;
                        findInternal(primaryKeyQuery(id)).then(success -> {
                            if (success) {
                                resolve(this);
                            } else {
                                resolve(null);
                            }
                        }, error -> {
                            reject(error);
                        });
                    });
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function buildFindInternal(entityClassType:TypePath, entityDefinition:EntityDefinition, fields:Array<Field>) {
        fields.push({
            name: "findInternal",
            access: [APrivate],
            meta: [{name: ":noCompletion", pos: Context.currentPos()}],
            kind: FFun({
                args: [{
                    name: "query",
                    type: macro: Query.QueryExpr
                }],
                ret: macro: promises.Promise<Bool>,
                expr: macro {
                    return new promises.Promise((resolve, reject) -> {
                        connect().then(success -> {
                            return database.table(definition().tableName);
                        }).then(result -> {
                            return result.table.find(query);
                        }).then(result -> {
                            if (result.data == null || result.data.length == 0) {
                            } else {
                                fromRecords(result.data, definition().tableName);
                            }
                            return null;
                        }).then(result -> {
                            resolve(true);
                        }, error -> {
                            reject(error);
                        });
                    });
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function buildAll(entityClassType:TypePath, entityDefinition:EntityDefinition, fields:Array<Field>) {
        var entityComplexType = TPath(entityClassType);
        var primaryKeyFieldName = entityDefinition.primaryKeyFieldName;
        primaryKeyFieldName = entityDefinition.tableName + "." + primaryKeyFieldName;

        var createEntityExpr = macro new $entityClassType();
        var resolvedType = Context.resolveType(entityComplexType, Context.currentPos());
        var structInit = switch (resolvedType) {
            case TInst(resolvedInstance, params): hasMeta(resolvedInstance.get().meta.get(), ":structInit");
            case _: false; 
        }
        if (structInit) {
            createEntityExpr = macro {};
        }

        fields.push({
            name: "all",
            access: [APublic, AStatic],
            kind: FFun({
                args: [{
                    name: "query",
                    type: macro: Query.QueryExpr,
                    opt: true,
                    value: macro null
                }],
                ret: macro: promises.Promise<Array<$entityComplexType>>,
                expr: macro {
                    return new promises.Promise((resolve, reject) -> {
                        var entity:$entityComplexType = $createEntityExpr;
                        var array:Array<$entityComplexType> = [];
                        entity.connect().then(success -> {
                            return entity.database.table(entity.definition().tableName);
                        }).then(result -> {
                            return result.table.find(query);
                        }).then(result -> {
                            if (result.data != null || result.data.length != 0) {
                                var map:Map<String, Array<db.Record>> = [];
                                var mapKeys:Array<String> = [];
                                for (record in result.data) {
                                    var fieldValue = Std.string(record.field($v{primaryKeyFieldName}));
                                    var list = map.get(fieldValue);
                                    if (list == null) {
                                        list = [];
                                        map.set(fieldValue, list);
                                        mapKeys.push(fieldValue);
                                    }
                                    list.push(record);
                                }
                                for (key in mapKeys) {
                                    var entity:$entityComplexType = $createEntityExpr;
                                    entity.fromRecords(map.get(key), entity.definition().tableName);
                                    if (@:privateAccess entity._hasData) {
                                        array.push(entity);
                                    }
                                }
                            }
                            return null;
                        }).then(result -> {
                            resolve(array);
                        }, error -> {
                            reject(error);
                        });
                    });
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function buildFind(entityClassType:TypePath, entityDefinition:EntityDefinition, fields:Array<Field>) {
        var entityComplexType = TPath(entityClassType);
        var primaryKeyFieldName = entityDefinition.primaryKeyFieldName;
        
        var exprs:Array<Expr> = [];
        for (fieldDef in entityDefinition.fields) {
            switch (fieldDef.type) {
                case EntityFieldType.Number | EntityFieldType.Text | EntityFieldType.Boolean | EntityFieldType.Date | EntityFieldType.Binary:
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToOne(table1, field1, table2, field2), type):
                case EntityFieldType.Class(className, EntityFieldRelationship.OneToMany(table1, field1, table2, field2), type):
            }
        }

        var createEntityExpr = macro new $entityClassType();
        var resolvedType = Context.resolveType(entityComplexType, Context.currentPos());
        var structInit = switch (resolvedType) {
            case TInst(resolvedInstance, params): hasMeta(resolvedInstance.get().meta.get(), ":structInit");
            case _: false; 
        }
        if (structInit) {
            createEntityExpr = macro {};
        }

        fields.push({
            name: "find",
            access: [APublic, AStatic],
            kind: FFun({
                args: [{
                    name: "query",
                    type: macro: Query.QueryExpr
                }],
                ret: macro: promises.Promise<$entityComplexType>,
                expr: macro {
                    return new promises.Promise((resolve, reject) -> {
                        var entity:$entityComplexType = $createEntityExpr;
                        entity.connect().then(success -> {
                            return entity.database.table(entity.definition().tableName);
                        }).then(result -> {
                            return result.table.find(query);
                        }).then(result -> {
                            if (result.data == null || result.data.length == 0) {
                                entity = null;
                            } else {
                                entity.fromRecords(result.data, entity.definition().tableName);
                            }
                            return null;
                        }).then(result -> {
                            resolve(entity);
                        }, error -> {
                            reject(error);
                        });
                    });
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function buildFindById(entityClassType:TypePath, entityDefinition:EntityDefinition, fields:Array<Field>) {
        var entityComplexType = TPath(entityClassType);
        var primaryKeyFieldName = entityDefinition.primaryKeyFieldName;
        var primaryKeyType = macro: Int;
        switch (entityDefinition.primaryKeyFieldType) {
            case EntityFieldType.Number:
                primaryKeyType = macro: Int;
            case EntityFieldType.Text:
                primaryKeyType = macro: String;
            case _:    
        }
        
        fields.push({
            name: "findById",
            access: [APublic, AStatic],
            kind: FFun({
                args: [{
                    name: "id",
                    type: primaryKeyType
                }],
                ret: macro: promises.Promise<$entityComplexType>,
                expr: macro {
                    return find(primaryKeyQueryStatic(id));
                }
            }),
            pos: Context.currentPos()
        });
    }

    static function hasField(fields:Array<Field>, name:String):Bool {
        for (field in fields) {
            if (field.name == name) {
                return true;
            }
        }
        return false;
    }

    static function hasMeta(meta:Metadata, name:String):Bool {
        if (meta == null) {
            return false;
        }
        for (m in meta) {
            if (m.name == name) {
                return true;
            }
        }
        return false;
    }

    static function toLowerFirstChar(s:String):String {
        return s.substr(0, 1).toLowerCase() + s.substr(1);
    }

    static function entityFieldTypeToColumnType(entityType:EntityFieldType):ColumnType {
        return switch (entityType) {
            case EntityFieldType.Boolean:
                ColumnType.Number;
            case EntityFieldType.Number:
                ColumnType.Number;
            case EntityFieldType.Text:
                ColumnType.Memo;
            case EntityFieldType.Date:
                ColumnType.Text(27);
            case EntityFieldType.Binary:
                ColumnType.Binary;
            case _:    
                null;
        }
    }

    static function entityFieldOptionsToColumnOptions(entityOptions:Array<EntityFieldOption>):Array<ColumnOptions> {
        var columnOptions = [];
        for (entityOption in entityOptions) {
            switch (entityOption) {
                case EntityFieldOption.PrimaryKey:
                    columnOptions.push(ColumnOptions.PrimaryKey);
                    columnOptions.push(ColumnOptions.NotNull);
                case EntityFieldOption.AutoIncrement:
                    columnOptions.push(ColumnOptions.AutoIncrement);
                case _:
            }
        }
        return columnOptions;
    }

    static function haxeTypeToEntityFieldType(ct:ComplexType) {
        switch (ct) {
            case TPath(p):
                switch (p.name) {
                    case "Int":
                        return EntityFieldType.Number;
                    case "String":
                        return EntityFieldType.Text;
                }
            case _:
        }
        return EntityFieldType.Number;
    }

    static function defineTableRelationship(field1:String, field2:String) {
        var relationshipsString = haxe.Resource.getString("entity-table-relationships");
        var relationships:Array<String> = null;
        if (relationshipsString == null) {
            relationships = [];
        } else {
            relationships = haxe.Unserializer.run(relationshipsString);
        }
        relationships.push(field1 + "|" + field2);
        relationshipsString = haxe.Serializer.run(relationships);
        Context.addResource("entity-table-relationships", haxe.io.Bytes.ofString(relationshipsString));
    }

    static function readTableRelationships():Array<String> {
        var relationshipsString = haxe.Resource.getString("entity-table-relationships");
        if (relationshipsString == null) {
            return [];
        }
        var relationships:Array<String> = haxe.Unserializer.run(relationshipsString);
        return relationships;
    }

    #end
}