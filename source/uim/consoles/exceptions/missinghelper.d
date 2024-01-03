module uim.cake.consoles.exceptions.missinghelper;

import uim.cake;

@safe:

// Used when a Helper cannot be found.
class MissingHelperException : ConsoleException {
    protected string _messageTemplate = "Helper class '%s' could not be found.";
}
