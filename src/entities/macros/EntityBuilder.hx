package entities.macros;

import entities.EntityDefinition;
import haxe.Resource;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.io.Bytes;
import haxe.macro.ComplexTypeTools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;

using StringTools;

class EntityBuilder {
    private static var refs:Map<String, Array<String>> = [];

    macro static function build():Array<Field> {
        var fields = Context.getBuildFields();

        //Context.getLocalClass().get().meta.add("@:generic", [], Context.currentPos());
        var localClassName = Context.getLocalClass().toString();
        Sys.println("building entity " + Context.getLocalClass().get().name + " [" + localClassName + "]");

        refs.set(localClassName, []);
        var localClass = Context.getLocalClass().get();
        var tableName = localClass.name;
        var primaryKeyFieldName = toLowerFirstChar(tableName) + "Id";
        var entityDef:EntityDefinition = {
            tableName: tableName,
            primaryKeyName: primaryKeyFieldName,
            fields: [],
            className: localClassName
        }

        if (!hasField(fields, primaryKeyFieldName)) {
            fields.push({
                name: primaryKeyFieldName,
                access: [APublic],
                kind: FVar(macro: Null<Int>),
                pos: Context.currentPos()
            });
        }

        fields.push({
            name: "definition",
            access: [APrivate, AOverride],
            kind: FFun({
                args: [],
                ret: macro: entities.EntityDefinition,
                expr: macro {
                    return entityDefinition;
                }
            }),
            pos: Context.currentPos()
        });

        fields.push({
            name: "primaryKeyFieldName",
            access: [APrivate, AOverride],
            kind: FFun({
                args: [],
                ret: macro: String,
                expr: macro {
                    return $v{primaryKeyFieldName};
                }
            }),
            pos: Context.currentPos()
        });

        var setFieldExprs:Array<Expr> = [];
        var mapVars:Array<Field> = [];
        var getArrayExprs:Array<Expr> = [];
        var getMapExprs:Array<Expr> = [];
        var addArrayItemExprs:Array<Expr> = [];

        for (field in fields) {
            if (field.access.contains(AStatic)) {
                continue;
            }

            switch (field.kind) {
                case FVar(t, e):
                    switch (t) {
                        case TPath(p):
                            var typeName = ComplexTypeTools.toString(t);
                            if (typeName == "String") {
                                var options = [];
                                if (field.name == primaryKeyFieldName) {
                                    options = [EntityFieldOption.PrimaryKey];
                                }
                                entityDef.fields.push({
                                    name: field.name,
                                    type: entities.EntityFieldType.String,
                                    options: options
                                });
                                setFieldExprs.push(macro if (id == $v{field.name}) {
                                    return $i{field.name} = value;
                                });
                            } else if (typeName == "Int" || typeName == "Null<Int>") {
                                var options = [];
                                if (field.name == primaryKeyFieldName) {
                                    options = [EntityFieldOption.PrimaryKey];
                                }
                                entityDef.fields.push({
                                    name: field.name,
                                    type: entities.EntityFieldType.Integer,
                                    options: options
                                });
                                setFieldExprs.push(macro if (id == $v{field.name}) {
                                    return $i{field.name} = value;
                                });
                            } else if (typeName == "Array") {
                                switch(p.params[0]) {
                                    case TPType(t): 
                                        switch (t) {
                                            case TPath(pp):
                                                var foreignTable = pp.name;
                                                var foreignPrimaryKey = toLowerFirstChar(foreignTable) + "Id";
                                                var className = pp.name;
                                                if (pp.pack != null && pp.pack.length > 0) {
                                                    className = pp.pack.join(".") + "." + className;
                                                } else if (pp.pack == null || pp.pack.length == 0) {
                                                    if (localClass.pack != null && localClass.pack.length > 0) {
                                                        className = localClass.pack.join(".") + "." + className;
                                                    }
                                                }

                                                if (!refs.get(localClassName).contains(className)) {
                                                    refs.get(localClassName).push(className);
                                                }

                                                entityDef.fields.push({
                                                    name: field.name,
                                                    type: entities.EntityFieldType.Class(className, EntityFieldRelationship.OneToMany(tableName, primaryKeyFieldName, foreignTable, foreignPrimaryKey))
                                                });

                                                var arrayName = field.name;
                                                getArrayExprs.push(macro if (id == $v{field.name}) {
                                                    if ($i{arrayName} == null) {
                                                        $i{arrayName} = [];
                                                    }
                                                    return cast $i{arrayName};
                                                });

                                                var mapName = "_" + field.name + "Map";
                                                mapVars.push({
                                                    name: mapName,
                                                    access: [APrivate],
                                                    kind: FVar(macro: Map<Int, $t>),
                                                    pos: Context.currentPos()
                                                });

                                                getMapExprs.push(macro if (id == $v{field.name}) {
                                                    if ($i{mapName} == null) {
                                                        $i{mapName} = [];
                                                    }
                                                    return cast $i{mapName};
                                                });

                                                addArrayItemExprs.push(macro if (id == $v{field.name}) {
                                                    if ($i{arrayName} == null) {
                                                        $i{arrayName} = [];
                                                    }
                                                    if ($i{mapName} == null) {
                                                        $i{mapName} = [];
                                                    }

                                                    //$i{mapName}.set(primaryKey, cast(item, $t));
                                                    $i{arrayName}.push(cast(item, $t));
                                                });
                                            case _:    
                                        }
                                    case _:    
                                }
                            } else {
                                var foreignTable = p.name;
                                var foreignPrimaryKey = toLowerFirstChar(foreignTable) + "Id";
                                var className = p.name;
                                if (p.pack != null && p.pack.length > 0) {
                                    className = p.pack.join(".") + "." + className;
                                } else if (p.pack == null || p.pack.length == 0) {
                                    if (localClass.pack != null && localClass.pack.length > 0) {
                                        className = localClass.pack.join(".") + "." + className;
                                    }
                                }

                                if (!refs.get(localClassName).contains(className)) {
                                    refs.get(localClassName).push(className);
                                }

                                entityDef.fields.push({
                                    name: field.name,
                                    type: entities.EntityFieldType.Class(className, EntityFieldRelationship.OneToOne(tableName, primaryKeyFieldName, foreignTable, foreignPrimaryKey))
                                });
                                setFieldExprs.push(macro if (id == $v{field.name}) {
                                    return $i{field.name} = value;
                                });
                            }
                        case _:    
                    }
                case _:    
            }
        }

        fields.push({
            name: "entityDefinition",
            access: [APrivate, AStatic],
            kind: FVar(macro: entities.EntityDefinition, macro $v{entityDef}),
            pos: Context.currentPos()
        });

        if (setFieldExprs.length > 0) {
            fields.push({
                name: "setField",
                access: [APrivate, AOverride],
                kind: FFun({
                    args: [{
                        name: "id",
                        type: macro: String
                    }, {
                        name: "value",
                        type: macro: Any
                    }],
                    ret: macro: Any,
                    expr: macro { @:mergeBlock
                        $b{setFieldExprs}
                        return null;
                    }
                }),
                pos: Context.currentPos()
            });
        }

        if (getArrayExprs.length > 0) {
            fields.push({
                name: "getArray",
                access: [APrivate, AOverride],
                kind: FFun({
                    args: [{
                        name: "id",
                        type: macro: String
                    }],
                    ret: macro: Array<entities.IEntity<Any>>,
                    expr: macro { @:mergeBlock
                        $b{getArrayExprs}
                        return null;
                    }
                }),
                pos: Context.currentPos()
            });
        }

        if (getMapExprs.length > 0) {
            fields.push({
                name: "getMap",
                access: [APrivate, AOverride],
                kind: FFun({
                    args: [{
                        name: "id",
                        type: macro: String
                    }],
                    ret: macro: Map<Int, entities.IEntity<Any>>,
                    expr: macro { @:mergeBlock
                        $b{getMapExprs}
                        return null;
                    }
                }),
                pos: Context.currentPos()
            });
        }

        if (addArrayItemExprs.length > 0) {
            fields.push({
                name: "addArrayItem",
                access: [APrivate, AOverride],
                kind: FFun({
                    args: [{
                        name: "id",
                        type: macro: String
                    }, {
                        name: "primaryKey",
                        type: macro: Int
                    }, {
                        name: "item",
                        type: macro: entities.IEntity<Any>
                    }],
                    ret: null,
                    expr: macro { @:mergeBlock
                        $b{addArrayItemExprs}
                        return null;
                    }
                }),
                pos: Context.currentPos()
            });
        }

        if (mapVars.length > 0) {
            for (mv in mapVars) {
                fields.push(mv);
            }
        }

        writeEntityDef(entityDef);

        return fields;
    }

    private static function hasField(fields:Array<Field>, name:String):Bool {
        for (field in fields) {
            if (field.name == name) {
                return true;
            }
        }
        return false;
    }

    #if macro 
    private static function toLowerFirstChar(s:String):String {
        return s.substr(0, 1).toLowerCase() + s.substr(1);
    }

    private static function writeEntityDef(def:EntityDefinition) {
        var defsString = Resource.getString("entity-definitions");
        var defs:Array<EntityDefinition> = null;
        if (defsString == null) {
            defs = [];
        } else {
            defs = Unserializer.run(defsString);
        }
        defs.push(def);
        for (def in defs) {
            def.order = calcOrder(def.className, refs);
        }
        defs.sort((e1, e2) -> {
            return e1.order - e2.order;
        });
        defsString = Serializer.run(defs);
        Context.addResource("entity-definitions", Bytes.ofString(defsString));
    }

    private static function calcOrder(className:String, refs:Map<String, Array<String>>):Int {
        var n = 0;
        var done = false;
        var ref = className;
        while (done == false) {
            for (key in refs.keys()) {
                var list = refs.get(key);
                if (list.contains(ref)) {
                    n++;
                    ref = key;
                    done = false;
                } else {
                    done = true;
                }
            }
        }
        return n;
    }
    #end
}