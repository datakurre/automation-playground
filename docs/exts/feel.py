from pygments.lexer import Lexer
from pygments.token import Token

import json
import subprocess

# https://github.com/pygments/pygments/blob/cc1d176c1e607a57c9c19baa3db22a8f5a67aafb/pygments/token.py#L123

RESERVED_WORDS = [
    "and",
    "between",
    "else",
    "every",
    "false",
    "for",
    "if",
    "in",
    "instance",
    "null",
    "of Any",
    "of boolean",
    "of context",
    "of date time",
    "of date",
    "of day-month-duration",
    "of day-time-duration",
    "of function",
    "of list",
    "of number",
    "of string",
    "of time",
    "or",
    "return",
    "satisfies",
    "some",
    "then",
    "true",
    "xor",
]

FUNCTION_NAMES = [
    "abs",
    "after",
    "all",
    "and",
    "any",
    "append",
    "avg",
    "before",
    "ceiling",
    "coincides",
    "concatenate",
    "contains",
    "context",
    "count",
    "date and time",
    "date",
    "day of week",
    "day of year",
    "days-between",
    "decimal",
    "distinct values",
    "duration",
    "during",
    "ends with",
    "even",
    "exp",
    "extract",
    "finished by",
    "finishes",
    "flatten",
    "floor",
    "get entries",
    "get value",
    "includes",
    "index of",
    "insert before",
    "is defined",
    "length",
    "list contains",
    "log",
    "lower case",
    "lower",
    "matches",
    "max",
    "mean",
    "median",
    "meets",
    "met by",
    "min",
    "mode",
    "modulo",
    "month of year",
    "months-between",
    "not",
    "now",
    "now",
    "number",
    "odd",
    "or",
    "overlaps after",
    "overlaps before",
    "overlaps",
    "product",
    "put all",
    "put",
    "remove",
    "replaces",
    "reverse",
    "round down",
    "round half down",
    "round half up",
    "round up",
    "sort",
    "split",
    "sqrt",
    "started by",
    "starts with",
    "starts",
    "stddev",
    "string join",
    "string length",
    "string",
    "sublist",
    "substring after",
    "substring before",
    "substring",
    "sum",
    "time",
    "today",
    "union",
    "upper case",
    "upper",
    "week of year",
    "years and months duration",
    "years-between",
]

PUNCTUATIONS = [
    "(",
    ")",
    ",",
    ".",
    "..",
    "...",
    ":",
    ";",
    "[",
    "]",
    "{",
    "}",
]


class FeelLexer(Lexer):
    name = "Feel"
    aliases = ["feel"]
    filenames = ["*.feel"]

    token_map = {
        "text": Token.Text,
        "operator": Token.Operator,
        "number": Token.Number,
    }

    def __init__(self, **options):
        super().__init__(**options)

    def get_tokens_unprocessed(self, text):
        result = subprocess.run(
            ["feel-tokenizer"],
            input=text.encode("utf-8").strip(),
            stdout=subprocess.PIPE,
        )
        tree = json.loads(result.stdout.decode())
        def walk(children, token_type=Token.Text):
            for token in children:
                if "value" in token:
                    if token_type is Token.Text:
                        if token["value"].strip().startswith('"'):
                            token_type = Token.String
                        elif token["value"].strip() in RESERVED_WORDS:
                            token_type = Token.Keyword.Reserved
                        elif token["value"].strip() in FUNCTION_NAMES:
                            token_type = Token.Name.Function
                        elif token["value"].strip() in PUNCTUATIONS:
                            token_type = Token.Punctuation
                    # print(token["index"], token_type, token["value"], token)
                    yield token["index"], token_type, token["value"]
                if "children" in token:
                    yield from walk(
                        token["children"], self.token_map.get(token["type"], Token.Text)
                    )
        yield from walk(tree)

    def __call__(self, *args, **kwargkwargss):
        return self
