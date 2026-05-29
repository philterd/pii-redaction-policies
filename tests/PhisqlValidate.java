/*
 * Compiles every .phisql policy passed as an argument using the PhiSQL
 * reference compiler (ai.philterd:phisql). Exits non-zero if any file fails to
 * parse or compile. Used by the GitHub Actions workflow to validate that the
 * PhiSQL policies in this repo are well-formed and compile to Phileas JSON.
 */
import ai.philterd.phisql.Compiler;

import java.nio.file.Files;
import java.nio.file.Path;

public class PhisqlValidate {

    public static void main(String[] args) throws Exception {
        if (args.length == 0) {
            System.out.println("No .phisql files to validate.");
            return;
        }

        int failures = 0;
        for (String arg : args) {
            final Path file = Path.of(arg);
            try {
                final String source = Files.readString(file);
                new Compiler().compile(source);
                System.out.println("OK   " + arg);
            } catch (final Exception e) {
                failures++;
                System.out.println("FAIL " + arg + ": " + e.getMessage());
            }
        }

        System.out.println();
        System.out.println("Validated " + args.length + " PhiSQL file(s), " + failures + " failure(s).");
        if (failures > 0) {
            System.exit(1);
        }
    }
}
