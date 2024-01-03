module uim.cake.consoles.exceptions.console;

import uim.cake;

@safe:

// Exception class for Console libraries. This exception will be thrown from Console library classes when they encounter an error.
class ConsoleException : UimException {
    protected int _defaultCode = ICommand::CODE_ERROR;
}
