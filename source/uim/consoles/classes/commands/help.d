module source.uim.consoles.classes.commands.help;

import uim.cake;

@safe:

// Print out command list
class HelpCommand : BaseCommand, ICommandCollectionAware {
    // The command collection to get help on.
    protected CommandCollection _commands;

    void setCommandCollection(CommandCollection newCommands) {
        _commands = newCommands;
    }
    
    // Main auto Prints out the list of commands.
    int execute(Arguments commandArguments, ConsoleIo aConsoleIo) {
        auto myCommands = this.commands.getIterator();
        if (cast(ArrayIterator)myCommands) {
            myCommands.ksort();
        }
        if (commandArguments.getOption("xml")) {
            this.asXml(aConsoleIo, myCommands);

            return CODE_SUCCESS;
        }
        this.asText(aConsoleIo, myCommands);

        return CODE_SUCCESS;
    }
    
    /**
     * Output text.
     * @param iterable<string, string|object> $commands The command collection to output.
     */
    protected void asText(ConsoleIo aConsoleIo, iterable $commands) {
        auto myInvert = [];
        foreach ($name, className; $commands) {
            if (isObject(className)) {
                 className = className::class;
            }
            if (!isSet(myInvert[className])) {
                myInvert[className] = [];
            }
            myInvert[className] ~= $name;
        }
        
        auto anGrouped = [];
        auto $plugins = Plugin::loaded();
        foreach (className: $names; myInvert) {
            preg_match("/^(.+)\\\\Command\\\\/",  className, $matches);
            // Probably not a useful class
            if ($matches.isEmpty) {
                continue;
            }
            $namespace = str_replace("\\", "/", $matches[1]);
            $prefix = "App";
            if ($namespace == "Cake") {
                $prefix = "UIM";
            } elseif (in_array($namespace, $plugins, true)) {
                $prefix = $namespace;
            }
            $shortestName = this.getShortestName($names);
            if (str_contains($shortestName, ".")) {
                [, $shortestName] = split(".", $shortestName, 2);
            }
             anGrouped[$prefix] ~= [
                "name": $shortestName,
                "description": isSubclass_of(className, BaseCommand.class) ?  className.getDescription(): "",
            ];
        }
        ksort(anGrouped);

        this.outputPaths(aConsoleIo);
         aConsoleIo.out("<info>Available Commands:</info>", 2);

        foreach ($prefix: $names;  anGrouped) {
             aConsoleIo.out("<info>{$prefix}</info>:");
            sort($names);
            foreach (someData; $names) {
                 aConsoleIo.out(" - " ~ someData["name"]);
                if (someData["description"]) {
                     aConsoleIo.info(str_pad(" \u{2514}", 13, "\u{2500}") ~ " " ~ someData["description"]);
                }
            }
             aConsoleIo.out("");
        }
        $root = this.getRootName();

        aConsoleIo.out("To run a command, type <info>`{$root} command_name [args|options]`</info>");
        aConsoleIo.out("To get help on a specific command, type <info>`{$root} command_name --help`</info>", 2);
    }
    
    // Output relevant paths if defined
    protected void outputPaths(ConsoleIo aConsoleIo) {
        STRINGAA myPaths;
        if (Configure::check("App.dir")) {
            string appPath = rtrim(Configure::read("App.dir"), DIRECTORY_SEPARATOR) ~ DIRECTORY_SEPARATOR;
            // Extra space is to align output
            myPaths["app"] = " " ~ appPath;
        }
        if (defined("ROOT")) {
            myPaths["root"] = rtrim(ROOT, DIRECTORY_SEPARATOR) ~ DIRECTORY_SEPARATOR;
        }
        if (defined("CORE_PATH")) {
            myPaths["core"] = rtrim(CORE_PATH, DIRECTORY_SEPARATOR) ~ DIRECTORY_SEPARATOR;
        }
        if (!count(myPaths)) {
            return;
        }
         aConsoleIo.out("<info>Current Paths:</info>", 2);
        myPaths.each!(kv => aConsoleIo.out("* %s: %s".format(kv.key, kv.value)));
         aConsoleIo.out("");
    }
    
    // @param string[] $names Names
    protected string getShortestName(array $names) {
        if (count($names) <= 1) {
            return (string)array_shift($names);
        }
        usort($names, auto ($a, $b) {
            return strlen($a) - strlen($b);
        });

        return array_shift($names);
    }
    
    /**
     * Output as XML
     * Params:
     * \UIM\Console\ConsoleIo aConsoleIo The console io
     * @param iterable<string, string|object> $commands The command collection to output
     */
    protected void asXml(ConsoleIo aConsoleIo, iterable $commands) {
        $shells = new SimpleXMLElement("<shells></shells>");
        foreach ($name:  className; $commands) {
            if (isObject(className)) {
                 className = className::class;
            }
            $shell = $shells.addChild("shell");
            $shell.addAttribute("name", $name);
            $shell.addAttribute("call_as", $name);
            $shell.addAttribute("provider",  className);
            $shell.addAttribute("help", $name ~ " -h");
        }
         aConsoleIo.setOutputAs(ConsoleOutput::RAW);
         aConsoleIo.out((string)$shells.saveXML());
    }
    
    // Gets the option parser instance and configures it.
    protected ConsoleOptionParser buildOptionParser(ConsoleOptionParser parserToBuild) {
        parserToBuild.description("Get the list of available commands for this application.");

        auto addOption = Json.emptyObject;
        addOption["help"] = "Get the listing as XML.";
        addOption["boolean"] = true; 
        parserToBuild.addOption("xml", addOption);

        return parserToBuild;
    }
}
