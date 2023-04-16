package;

import utest.ui.common.HeaderDisplayMode;
import utest.ui.Report;
import utest.Runner;
import cases.*;

class TestAll {
    public static function main() {
        var runner = new Runner();

        runner.addCase(new TestBasic());
        runner.addCase(new TestMultipleCalls());
        runner.addCase(new TestBasicStructInit());
        runner.addCase(new TestFakeOrgEntities());
        runner.addCase(new TestBooks());

        Report.create(runner, SuccessResultsDisplayMode.AlwaysShowSuccessResults, HeaderDisplayMode.NeverShowHeader);
        runner.run();
    }
}