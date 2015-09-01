package com.thoughtworks.restRpc.core;

@:atom
abstract Alpha(Int) {
  public static inline function accept(c:Int):Bool return {
    (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);
  }
}

@:atom
abstract Digit(Int) {
  public static inline function accept(c:Int):Bool return {
    (c >= 0x30 && c <= 0x39);
  }
}

@:atom
abstract HexDig(Int) {
  public static inline function accept(c:Int):Bool return {
    Digit.accept(c) || switch c {
      case "A".code, "B".code, "C".code, "D".code, "E".code, "F".code: true;
      default: false;
    }
  }
}

@:enum
abstract Percent(Int) {
  var CHARACTER = "%".code;
}

@:atom
abstract Unreserved(Int) {
  public static inline function accept(c:Int):Bool return {
    switch c {
      case c if (Alpha.accept(c)): true;
      case c if (Digit.accept(c)): true;
      case "-".code, ".".code, "_".code, "~".code: true;
      default: false;
    }
  }
}

@:atom
abstract Reserved(Int) {
  public static inline function accept(c:Int):Bool return {
    GenDelims.accept(c) || SubDelims.accept(c);
  }
}

@:atom
abstract GenDelims(Int) {
  public static inline function accept(c:Int):Bool return {
    switch c {
      case ":".code, "/".code, "?".code, "#".code, "[".code, "]".code, "@".code: true;
      default: false;
    }
  }
}

@:atom
abstract SubDelims(Int) {
  public static inline function accept(c:Int):Bool return {
    switch c {
      case "!".code, "$".code, "&".code, "'".code, "(".code, ")".code,
      "*".code, "+".code, ",".code, ";".code, "=".code: true;
      default: false;
    }
  }
}

enum Literals {
  RESERVED(reserved:Reserved);
  UNRESERVED(unreserved:Unreserved);
  PCT_ENCODED(percent:Percent, hexDig0:HexDig, hexDig1:HexDig);
  UCSCHAR(ucschar:Ucschar);
  IPRIVATE(iprivate:Iprivate);
}

@:enum
abstract ExpressionBegin(Int) {
  var CHARACTER = "{".code;
}

@:enum
abstract ExpressionEnd(Int) {
  var CHARACTER = "}".code;
}

@:enum
abstract Comma(Int) {
  var CHARACTER = ",".code;
}

@:enum
abstract Dot(Int) {
  var CHARACTER = ".".code;
}

@:enum
abstract Underscore(Int) {
  var CHARACTER = "_".code;
}

enum Varchar {
  ALPHA(alpha:Alpha);
  DIGIT(digit:Digit);
  UNDERSCORE(underscore:Underscore);
  PCT_ENCODED(percent:Percent, hexDig0:HexDig, hexDig1:HexDig);
}

enum DotVarchar {
  DOT_VARCHAR(?dot:Dot, varchar:Varchar);
}

@:repeat(0)
abstract RestVarchar(Array<DotVarchar>) {}

enum Varname {
  VARNAME(first:Varchar, rest:RestVarchar);
}

@:enum
abstract Colon(Int) {
  var CHARACTER = ":".code;
}

@:atom
abstract NonZeroDigit(Int) {
  public static inline function accept(c:Int):Bool return {
    c >= "1".code && c <= "9".code;
  }
}

@:repeat(0, 3)
abstract NoMoreThanThreeDigit(Array<Digit>) {}

enum MaxLength {
  MAX_LENGTH(first:NonZeroDigit, rest:NoMoreThanThreeDigit);
}

enum Prefix {
  PREFIX(colon:Colon, maxLength:MaxLength);
}

@:enum
abstract Explode(Int) {
  var CHARACTER = "*".code;
}

enum ModifierLevel4 {
  PREFIX(prefix:Prefix);
  EXPLODE(explode:Explode);
}

enum Varspec {
  VARSPEC(varname:Varname, ?modifierLevel4:ModifierLevel4);
}

enum CommaVarchar {
  COMMA_VARSPEC(comma:Comma, varspec:Varspec);
}

@:repeat(0)
abstract RestVarspec(Array<CommaVarchar>) {}

enum VariableList {
  VARIABLE_LIST(first:Varspec, rest:RestVarspec);
}

@:enum
abstract OpLevel2(Int) {
  var PLUS = "+".code;
  var HASH = "#".code;
}


@:enum
abstract OpLevel3(Int) {
  var DOT = ".".code;
  var SLASH = "/".code;
  var SEMICOLON = ";".code;
  var QUESTION_MARK = "?".code;
  var AMPERSAND = "&".code;
}

@:enum
abstract OpReserve(Int) {

  var EQUALS = "=".code;
  var COMMA = ",".code;
  var EXCLAMATION = "!".code;
  var AT = "@".code;
  var PIPE = "|".code;
}


enum Operator {
  OP_LEVEL2(opLevel2:OpLevel2);
  OP_LEVEL3(opLevel3:OpLevel3);
  OP_RESERVE(opReserve:OpReserve);
}

enum LiteralsOrExpression {
  LITERALS(literals:Literals);
  EXPRESSION(begin:ExpressionBegin, ?operator:Operator, variableList:VariableList, end:ExpressionEnd);
}

@:repeat(0)
abstract UriTemplate(Array<LiteralsOrExpression>) {}

@:atom
abstract LiteralSingleChar(Int) {
  public static inline function accept(c:Int):Bool return switch (c) {
    case 0x21, 0x23, 0x24, 0x26: true;
    case c if (c >= 0x28 && c <= 0x3B): true;
    case 0x3D: true;
    case c if (c >= 0x3F && c <= 0x5B): true;
    case 0x5D: true;
    case 0x5F: true;
    case c if (c >= 0x61 && c <= 0x7A): true;
    case 0x7E: true;
    case c if (Ucschar.accept(c)): true;
    case c if (Iprivate.accept(c)): true;
    default: false;
  }
}

@:atom
abstract Ucschar(Int) {
  public static inline function accept(c:Int):Bool return switch (c) {
    case c if (c >= 0xA0 && c <= 0xD7FF): true;
    case c if (c >= 0xF900 && c <= 0xFDCF): true;
    case c if (c >= 0xFDF0 && c <= 0xFFFE): true;
    case c if (c >= 0x10000 && c <= 0x1FFFD): true;
    case c if (c >= 0x20000 && c <= 0x2FFFD): true;
    case c if (c >= 0x30000 && c <= 0x3FFFD): true;
    case c if (c >= 0x40000 && c <= 0x4FFFD): true;
    case c if (c >= 0x50000 && c <= 0x5FFFD): true;
    case c if (c >= 0x60000 && c <= 0x6FFFD): true;
    case c if (c >= 0x70000 && c <= 0x7FFFD): true;
    case c if (c >= 0x80000 && c <= 0x8FFFD): true;
    case c if (c >= 0x90000 && c <= 0x9FFFD): true;
    case c if (c >= 0xA0000 && c <= 0xAFFFD): true;
    case c if (c >= 0xB0000 && c <= 0xBFFFD): true;
    case c if (c >= 0xC0000 && c <= 0xCFFFD): true;
    case c if (c >= 0xD0000 && c <= 0xDFFFD): true;
    case c if (c >= 0xE0000 && c <= 0xEFFFD): true;
    default: false;
  }
}

@:atom
abstract Iprivate(Int) {
  public static inline function accept(c:Int):Bool return switch (c) {
    case c if (c >= 0xE000 && c <= 0xF8FF): true;
    case c if (c >= 0xF0000 && c <= 0xFFFFD): true;
    case c if (c >= 0x100000 && c <= 0x10FFFD): true;
    default: false;
  }
}