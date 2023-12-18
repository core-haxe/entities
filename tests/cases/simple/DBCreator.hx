package cases.simple;

class DBCreator extends DBCreatorBase {
    public function new() {
        super();
        sqliteFilename = "simple.db";
    }
}