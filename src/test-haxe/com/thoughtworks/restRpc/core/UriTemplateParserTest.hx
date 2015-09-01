package com.thoughtworks.restRpc.core;

import com.dongxiguo.autoParser.ISource;
import haxe.unit.TestCase;
import haxe.ds.Vector;
using Lambda;
class UriTemplateParserTest extends TestCase {

  public function test1() {
    var data = "xxx{yy}z";
    var source = new StringSource(data);
    var template = UriTemplateParser.parse_com_thoughtworks_restRpc_core_UriTemplate(source);
    assertEquals(data.length, source.position);
    assertEquals("[LITERALS(UNRESERVED(120)),LITERALS(UNRESERVED(120)),LITERALS(UNRESERVED(120)),EXPRESSION(123,null,VARIABLE_LIST(VARSPEC(VARNAME(ALPHA(121),[DOT_VARCHAR(null,ALPHA(121))]),null),[]),125),LITERALS(UNRESERVED(122))]", Std.string(template));
  }

  public function test2() {
    var data = "xxx{yy} z";
    var source = new StringSource(data);
    var template = UriTemplateParser.parse_com_thoughtworks_restRpc_core_UriTemplate(source);
    assertEquals(data.length - 2, source.position);
    assertEquals("[LITERALS(UNRESERVED(120)),LITERALS(UNRESERVED(120)),LITERALS(UNRESERVED(120)),EXPRESSION(123,null,VARIABLE_LIST(VARSPEC(VARNAME(ALPHA(121),[DOT_VARCHAR(null,ALPHA(121))]),null),[]),125)]", Std.string(template));
  }

  public function test3() {
    var data = "xxx{/yy} z";
    var source = new StringSource(data);
    var template = UriTemplateParser.parse_com_thoughtworks_restRpc_core_UriTemplate(source);
    assertEquals(data.length - 2, source.position);
    assertEquals("[LITERALS(UNRESERVED(120)),LITERALS(UNRESERVED(120)),LITERALS(UNRESERVED(120)),EXPRESSION(123,OP_LEVEL3(47),VARIABLE_LIST(VARSPEC(VARNAME(ALPHA(121),[DOT_VARCHAR(null,ALPHA(121))]),null),[]),125)]", Std.string(template));
  }


  public function test4() {
    var data = "a{/b.c}d";
    var source = new StringSource(data);
    var template = UriTemplateParser.parse_com_thoughtworks_restRpc_core_UriTemplate(source);
    assertEquals(data.length, source.position);
    assertEquals("[LITERALS(UNRESERVED(97)),EXPRESSION(123,OP_LEVEL3(47),VARIABLE_LIST(VARSPEC(VARNAME(ALPHA(98),[DOT_VARCHAR(46,ALPHA(99))]),null),[]),125),LITERALS(UNRESERVED(100))]", Std.string(template));
  }

  public function test5() {
    var data = "a{/b.c,d,efg,1}3";
    var source = new StringSource(data);
    var template = UriTemplateParser.parse_com_thoughtworks_restRpc_core_UriTemplate(source);
    assertEquals(data.length, source.position);
    assertEquals("[LITERALS(UNRESERVED(97)),EXPRESSION(123,OP_LEVEL3(47),VARIABLE_LIST(VARSPEC(VARNAME(ALPHA(98),[DOT_VARCHAR(46,ALPHA(99))]),null),[COMMA_VARSPEC(44,VARSPEC(VARNAME(ALPHA(100),[]),null)),COMMA_VARSPEC(44,VARSPEC(VARNAME(ALPHA(101),[DOT_VARCHAR(null,ALPHA(102)),DOT_VARCHAR(null,ALPHA(103))]),null)),COMMA_VARSPEC(44,VARSPEC(VARNAME(DIGIT(49),[]),null))]),125),LITERALS(UNRESERVED(51))]", Std.string(template));
  }

}

@:final
@:nativeGen
class StringSource implements ISource<Int, Int> {
  var data:String;
  var index:Int;

  public function next():Void {
    index += 1;
  }

  public function get_current():Null<Int> {
    if (index < data.length) {
      return data.charCodeAt(index);
    } else {
      return null;
    }
  }

  public var current(get, never):Null<Int>;

  public var position(get, set):Int;

  public function get_position():Dynamic {
    return index;
  }

  public function set_position(value:Int):Int {
    return this.index = value;
  }

  public function new(s:String) {
    data = s;
    index = 0;
  }

}