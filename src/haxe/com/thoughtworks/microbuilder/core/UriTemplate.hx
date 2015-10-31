package com.thoughtworks.microbuilder.core;

import haxe.io.BytesOutput;
import haxe.io.Eof;
import haxe.io.StringInput;
@:atom
abstract Alpha(Int) from Int to Int {
  public static inline function accept(c:Int):Bool return {
    (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);
  }
}

@:atom
abstract Digit(Int) from Int to Int {
  public static inline function accept(c:Int):Bool return {
    (c >= 0x30 && c <= 0x39);
  }
}

@:atom
abstract HexDig(Int) from Int to Int {

  public static function toInt(digit:HexDig):Int return {
    if ((digit:Int) >= "0".code && (digit:Int) <= "9".code) {
      (digit:Int) - "0".code;
    } else if ((digit:Int) >= "A".code && (digit:Int) <= "F".code) {
      (digit:Int) - "A".code + 0xA;
    } else {
      throw "Expect [0-9A-F]";
    }
  }

  public static function fromInt(i:Int):HexDig return {
    if (i < 0) {
      throw "Expect [0, 16)";
    } else if (i <= 9) {
      "0".code + i;
    } else if (i <= 0xF) {
      "A".code + (i - 0xA);
    } else {
      throw "Expect [0, 16)";
    }
  }

  public static inline function accept(c:Int):Bool return {
    Digit.accept(c) || switch c {
      case "A".code, "B".code, "C".code, "D".code, "E".code, "F".code: true;
      default: false;
    }
  }
}

@:enum
abstract Percent(Int) from Int to Int {
  var CHARACTER = "%".code;
}

@:atom
abstract Unreserved(Int) from Int to Int {
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
abstract Reserved(Int) from Int to Int {
  public static inline function accept(c:Int):Bool return {
    GenDelims.accept(c) || SubDelims.accept(c);
  }
}

@:atom
abstract GenDelims(Int) from Int to Int {
  public static inline function accept(c:Int):Bool return {
    switch c {
      case ":".code, "/".code, "?".code, "#".code, "[".code, "]".code, "@".code: true;
      default: false;
    }
  }
}

@:atom
abstract SubDelims(Int) from Int to Int {
  public static inline function accept(c:Int):Bool return {
    switch c {
      case "!".code, "$".code, "&".code, "'".code, "(".code, ")".code,
      "*".code, "+".code, ",".code, ";".code, "=".code: true;
      default: false;
    }
  }
}

@:repeat(0)
abstract UnreservedCaptured(Array<UnreservedCharacter>) from Array<UnreservedCharacter> to Array<UnreservedCharacter> {}

enum UnreservedCharacter {
  COMMA(comma:Comma);
  UNRESERVED(unreserved:Unreserved);
  PCT_ENCODED(percent:Percent, hexDig0:HexDig, hexDig1:HexDig);
}

@:rewrite
abstract SimpleStringExpansion(String) from String to String {

  public static function rewriteTo(self:SimpleStringExpansion):UnreservedCaptured return {
    if (self == null) {
      [];
    } else {
      var input = new StringInput(self);
      var output = [];
      try {
        while (true) {
          var b = input.readByte();
          switch b {
            case Comma.CHARACTER:
              output.push(UnreservedCharacter.COMMA(b));
            default:
              if (Unreserved.accept(b)) {
                output.push(UnreservedCharacter.UNRESERVED(b));
              } else {
                output.push(UnreservedCharacter.PCT_ENCODED(Percent.CHARACTER, HexDig.fromInt(b >>> 4), HexDig.fromInt(b & 0xF)));
              }
          }
        }
      } catch(e:Eof) {
        // Break the while loop and do nothing.
      }
      output;
    }
  }

  public static function rewriteFrom(from:UnreservedCaptured):SimpleStringExpansion return {
    var buffer = new BytesOutput(); // TODO:
    for (c in (from:Array<UnreservedCharacter>)) {
      switch c {
        case COMMA(b):
          buffer.writeByte(b);
        case UNRESERVED(b):
          buffer.writeByte(b);
        case PCT_ENCODED(_, high, low):
          buffer.writeByte((HexDig.toInt(high) << 4) | HexDig.toInt(low));
      }
    }
    buffer.getBytes().toString();
  }

}

@:repeat(0)
abstract ReservedCaptured(Array<Literals>) from Array<Literals> to Array<Literals> {}

@:rewrite
abstract ReservedExpansion(String) from String to String {
  public static function rewriteTo(self:ReservedExpansion):ReservedCaptured return {
    if (self == null) {
      [];
    } else {
      var input = new StringInput(self);
      var output = [];
      try {
        while (true) {
          var b = input.readByte();
          if (Unreserved.accept(b)) {
            output.push(Literals.UNRESERVED(b));
          } else if (Reserved.accept(b)) {
            output.push(Literals.RESERVED(b));
          } else {
            output.push(Literals.PCT_ENCODED(Percent.CHARACTER, HexDig.fromInt(b >>> 4), HexDig.fromInt(b & 0xF)));
          }
        }
      } catch(e:Eof) {
        // Break the while loop and do nothing.
      }
      output;
    }
  }
  public static function rewriteFrom(from:ReservedCaptured):ReservedExpansion return {
    var buffer = new BytesOutput(); // TODO:
    for (c in (from:Array<Literals>)) {
      switch c {
        case UNRESERVED(b):
          buffer.writeByte(b);
        case RESERVED(b):
          buffer.writeByte(b);
        case UCSCHAR(b):
          buffer.writeByte(b);
        case IPRIVATE(b):
          buffer.writeByte(b);
        case PCT_ENCODED(_, high, low):
          buffer.writeByte((HexDig.toInt(high) << 4) | HexDig.toInt(low));
      }
    }
    buffer.getBytes().toString();
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
abstract ExpressionBegin(Int) from Int to Int {
  var CHARACTER = "{".code;
}

@:enum
abstract ExpressionEnd(Int) from Int to Int {
  var CHARACTER = "}".code;
}

@:enum
abstract Comma(Int) from Int to Int {
  var CHARACTER = ",".code;
}

@:enum
abstract Dot(Int) from Int to Int {
  var CHARACTER = ".".code;
}

@:enum
abstract Underscore(Int) from Int to Int {
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
abstract RestVarchar(Array<DotVarchar>) to Array<DotVarchar> from Array<DotVarchar> {}

@:final
class Varname {

  public function new() {}

  public var first:Varchar;

  public var rest:RestVarchar;

}

@:enum
abstract Colon(Int) from Int to Int {
  var CHARACTER = ":".code;
}

@:atom
abstract NonZeroDigit(Int) from Int to Int {
  public static inline function accept(c:Int):Bool return {
    c >= "1".code && c <= "9".code;
  }
}

@:repeat(0, 3)
abstract NoMoreThanThreeDigit(Array<Digit>) from Array<Digit> to Array<Digit> {}

@:final
class MaxLength {

  public function new() {}

  public var first:NonZeroDigit;

  public var rest:NoMoreThanThreeDigit;
}

@:rewrite
abstract Limit(Int) from Int to Int {

  public static function rewriteFrom(prefix:Prefix):Limit return {
    var sb = new StringBuf();
    sb.addChar(prefix.maxLength.first);
    for (c in (prefix.maxLength.rest:Array<Digit>)) {
      sb.addChar(c);
    }
    Std.parseInt(sb.toString());
  }

  public static function rewriteTo(limit:Limit):Prefix return {
    var s = Std.string(limit);
    var ml = new MaxLength();
    ml.first = s.charCodeAt(0);
    ml.rest = [];
    for (i in 1...s.length) {
      ml.rest[i - 1] = s.charCodeAt(i);
    }
    var p = new Prefix();
    p.maxLength = ml;
    p;
  }

}

@:final
class Prefix {

  public function new() {}

  public var colon(get, set):Null<Colon>;

  inline function set_colon(value:Null<Colon>):Null<Colon> return value;

  inline function get_colon():Null<Colon> return cast ":".code;

  public var maxLength:MaxLength;
}

@:enum
abstract Explode(Int) from Int to Int {
  var CHARACTER = "*".code;
}

enum ModifierLevel4 {
  PREFIX(limit:Limit);
  EXPLODE(explode:Explode);
}


@:final
class Varspec {

  public function new() {}

  public var varname:Varname;

  @:optional
  public var modifierLevel4:Null<ModifierLevel4>;

}

enum CommaVarchar {
  COMMA_VARSPEC(comma:Comma, varspec:Varspec);
}

@:repeat(0)
abstract RestVarspec(Array<CommaVarchar>) to Array<CommaVarchar> {}

@:final
class VariableList {

  public function new() {}

  public var first:Varspec;

  public var rest:RestVarspec;

}

@:enum
abstract OpLevel2(Int) from Int to Int {
  var PLUS = "+".code;
  var HASH = "#".code;
}


@:enum
abstract OpLevel3(Int) from Int to Int {
  var DOT = ".".code;
  var SLASH = "/".code;
  var SEMICOLON = ";".code;
  var QUESTION_MARK = "?".code;
  var AMPERSAND = "&".code;
}

@:enum
abstract OpReserve(Int) from Int to Int {

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
abstract UriTemplate(Array<LiteralsOrExpression>) to Array<LiteralsOrExpression> {}

@:atom
abstract LiteralSingleChar(Int) from Int to Int {
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
abstract Ucschar(Int) from Int to Int {
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
abstract Iprivate(Int) from Int to Int {
  public static inline function accept(c:Int):Bool return switch (c) {
    case c if (c >= 0xE000 && c <= 0xF8FF): true;
    case c if (c >= 0xF0000 && c <= 0xFFFFD): true;
    case c if (c >= 0x100000 && c <= 0x10FFFD): true;
    default: false;
  }
}