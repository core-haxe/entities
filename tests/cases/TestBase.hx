package cases;

import utest.Test;

class TestBase extends Test {
    private var timeStart:Float = 0;
    private var timeName:String;

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