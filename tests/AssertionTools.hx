package;

class AssertionTools {
    public static function shouldContain(expectedToContain:Dynamic, array:Array<Dynamic>) {
        doesContain(expectedToContain, array, true);
    }

    public static function shouldMatch(expectedToMatch:Dynamic, object:Dynamic) {
        doesMatch(expectedToMatch, object, false, true);
    }

    private static function doesContain(expectedToContain:Dynamic, array:Array<Dynamic>, throwException:Bool):Bool {
        var found = false;
        for (item in array) {
            if (doesMatch(expectedToContain, item, false, false)) {
                found = true;
                break;
            }
        }

        if (!found) {
            if (throwException) {
                throw 'not found in array!';
            } else {
                //trace('not found in array!');
            }
        }

        return found;
    }

    private static function doesMatch(expectedToMatch:Dynamic, object:Dynamic, strict:Bool, throwException:Bool):Bool {
        for (f in Reflect.fields(expectedToMatch)) {
            if (!hasField(object, f)) {
                if (throwException) {
                    throw 'couldnt find field "${f}"';
                } else {
                    trace('couldnt find field "${f}"');
                }
                return false;
            }
            var objectValue:Dynamic = Reflect.getProperty(object, f);
            var expectedValue:Dynamic = Reflect.field(expectedToMatch, f);
            switch (Type.typeof(expectedValue)) {
                case TObject:
                    var r = doesMatch(expectedValue, objectValue, strict, throwException);
                    if (!r) {
                        return r;
                    }
                case TClass(Array):
                    var expectedArray:Array<Dynamic> = expectedValue;
                    var objectArray:Array<Dynamic> = objectValue;
                    /*
                    if (expectedArray.length != objectArray.length) {
                        if (throwException) {
                            throw 'array fields are not of the same length ${f} (${objectArray.length} != ${expectedArray.length})';
                        } else {
                            trace('array fields are not of the same length ${f} (${objectArray.length} != ${expectedArray.length})');
                        }
                        return false;
                    }
                        */
                    for (i in 0...expectedArray.length) {
                        var expectedItem = expectedArray[i];
                        var objectItem = objectArray[i];
                        var r = false;
                        if (strict) {
                            r = doesMatch(expectedItem, objectItem, strict, throwException);
                        } else {
                            r = doesContain(expectedItem, objectArray, throwException);
                        }
                        if (!r) {
                            return r;
                        }
                    }
                case _:    
                    if (objectValue != expectedValue) {
                        if (throwException) {
                            throw 'field mismatch on "${f}" (${objectValue} != ${expectedValue})';
                        } else {
                            //trace('field mismatch on "${f}" (${objectValue} != ${expectedValue})');
                        }
                        return false;
                    }
            }
        }

        return true;
    }

    private static function hasField(object:Dynamic, field:String) {
        if (Reflect.hasField(object, field)) {
            return true;
        }

        var fields = Type.getInstanceFields(Type.getClass(object));
        return fields.contains(field);
    }
}