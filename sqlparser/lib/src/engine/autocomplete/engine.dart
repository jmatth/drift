import 'package:collection/collection.dart';
import 'package:sqlparser/src/reader/tokenizer/token.dart';

part 'descriptions/description.dart';
part 'descriptions/static.dart';

part 'suggestion.dart';

/// Helper to provide context aware auto-complete suggestions inside a sql
/// query.
///
/// While parsing a query, the parser will yield a bunch of [Hint]s that are
/// specific to a specific location. Each hint contains the current position and
/// a [HintDescription] of what can appear behind that position.
/// To obtain suggestions for a specific cursor position, we then go back from
/// that position to the last [Hint] found and populate it.
class AutoCompleteEngine {
  /// The found hints.
  UnmodifiableListView<Hint> get foundHints => _hintsView;
  // hints are always sorted by their offset
  final List<Hint> _hints = [];
  UnmodifiableListView<Hint> _hintsView;

  final List<Token> _tokens;

  void addHint(Hint hint) {
    if (_hints.isEmpty) {
      _hints.add(hint);
    } else {
      // ensure that the hints list stays sorted by offset
      final position = _lastHintBefore(hint.offset);
      _hints.insert(position + 1, hint);
    }
  }

  AutoCompleteEngine(this._tokens) {
    _hintsView = UnmodifiableListView(_hints);
  }

  /// Suggest completions at a specific position.
  ///
  /// This api will change in the future.
  ComputedSuggestions suggestCompletions(int offset) {
    if (_hints.isEmpty) {
      return ComputedSuggestions(-1, -1, []);
    }

    final hint = foundHints[_lastHintBefore(offset)];

    final suggestions = hint.description.suggest(CalculationRequest()).toList();

    // when calculating the offset, respect whitespace that comes after the
    // last hint.
    final lastToken = hint.before;
    final nextToken =
        lastToken != null ? _tokens[lastToken.index + 1] : _tokens.first;

    final hintOffset = nextToken.span.start.offset;
    final length = offset - hintOffset;

    return ComputedSuggestions(hintOffset, length, suggestions);
  }

  /// find the last hint that appears before [offset]
  int _lastHintBefore(int offset) {
    var min = 0;
    var max = foundHints.length - 1;

    while (min < max) {
      final mid = min + ((max - min) >> 1);
      final hint = _hints[mid];

      final offsetOfMid = hint.offset;

      if (offsetOfMid == offset) {
        return mid;
      } else {
        final offsetOfNext = _hints[mid + 1].offset;

        if (offsetOfMid < offset) {
          if (offsetOfNext > offset) {
            // next one is too late, so this must be the correct one
            return mid;
          }
          min = mid + 1;
        } else {
          max = mid - 1;
        }
      }
    }

    return min;
  }
}

class Hint {
  /// The token that appears just before this hint, or `null` if the hint
  /// appears at the beginning of the file.
  final Token before;

  int get offset => before?.span?.end?.offset ?? 0;

  final HintDescription description;

  Hint(this.before, this.description);
}

class CalculationRequest {}
