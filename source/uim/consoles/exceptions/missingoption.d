module uim.cake.consoles.exceptions.missingoption;

import uim.cake;

@safe:

// Exception raised with suggestions
class MissingOptionException : ConsoleException {
  // The requested thing that was not found.
  protected string _requested = "";

  // The valid suggestions.
  protected string[] _suggestions;

  /**
     * Constructor.
     * Params:
     * string amessage The string message.
     * @param string arequested The requested value.
     * @param string[] $suggestions The list of potential values that were valid.
     * @param int $code The exception code if relevant.
     * @param \Throwable|null $previous the previous exception.
     */
  this(
    string mymessage,
    string requestedValue,
    string[] newSuggestions = null,
    int exceptionCode = 0,
    Throwable previousException = null
  ) {
    _suggestions = newSuggestions;
    _requested = requestedValue;
    super($message, exceptionCode, previousException);
  }

  // Get the message with suggestions
  string getFullMessage() {
    auto result  = this.getMessage();
    auto $bestGuess = this.findClosestItem(this.requested, this.suggestions);
    if ($bestGuess) {
      result  ~= "\nDid you mean: `{$bestGuess}`?";
    }
    
    auto $good = [];
    foreach ($option; this.suggestions) {
      if (levenshtein($option, this.requested) < 8) {
        $good ~= "- " ~ $option;
      }
    }
    if ($good) {
      result  ~= "\n\nOther valid choices:\n\n" ~ join("\n", $good);
    }
    return result ;
  }

  /**
     * Find the best match for requested in suggestions
     * Params:
     * string aneedle Unknown option name trying to be used.
     * @param string[] $haystack Suggestions to look through.
     */
  protected string findClosestItem(string myneedle, string[] haystack) {
    $bestGuess = null;
    foreach (anItem; $haystack) {
      if (str_starts_with(anItem, $needle)) {
        return  anItem;
      }
    }
    $bestScore = 4;
    foreach (anItem; $haystack) {
      $score = levenshtein($needle,  anItem);

      if ($score < $bestScore) {
        $bestScore = $score;
        $bestGuess =  anItem;
      }
    }
    return $bestGuess;
  }
}
