package cases.simple;

class DBCreator extends DBCreatorBase {

    public override function resetEntities() {
        super.resetEntities();
        @:privateAccess A._checkedTables = false;
        @:privateAccess B._checkedTables = false;
        @:privateAccess C._checkedTables = false;
    }
    
    public function new() {
        super();
        sqliteFilename = "simple.db";
    }
}