package cases.user;

import entities.IEntity;

class User implements IEntity {
    public var username:String;
    public var properties:Array<Property>;

    public function addProperty(name:String, value:Any) {
        var type = "string";
        switch (Type.typeof(value)) {
            case TInt:
                type = "int";
            case TFloat:
                type = "float";
            case TBool:
                type = "bool";
            case _:            
        }

        var property = new Property();
        property.name = name;
        property.value = Std.string(value);
        property.type = type;
        if (properties == null) {
            properties = [];
        }
        properties.push(property);
    }

    public function getProperty(name:String):Any {
        if (properties != null) {
            for (p in properties) {
                if (p.name == name) {
                    switch (p.type) {
                        case "int":
                            return Std.parseInt(p.value);
                        case "float":
                            return Std.parseFloat(p.value);
                        case "bool":
                            return p.value == "true";
                        case _:    
                            return p.value;
                    }
                }
            }
        }

        return null;
    }
}