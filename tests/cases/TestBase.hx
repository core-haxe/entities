package cases;

import utest.ITest;

class TestBase implements ITest {
    private var timeStart:Float = 0;
    private var timeName:String;

    public function new() {
    }

    private function start(name:String) {
        timeStart = Sys.time();
        timeName = name;
        Sys.println(timeName);
    }

    private function check(message:String) {
        var diff = Sys.time() - timeStart;
        Sys.println("  " + StringTools.rpad(message, " ", 30) + ": " + diff + "s");
    }

    private function complete() {
        check("complete");
    }
}