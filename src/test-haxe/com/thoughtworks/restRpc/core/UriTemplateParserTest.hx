package com.thoughtworks.restRpc.core;

import com.dongxiguo.autoParser.ISource;
import haxe.unit.TestCase;
import haxe.ds.Vector;
using Lambda;
class UriTemplateParserTest extends TestCase {

  public static function main(arguments:Vector<String>) {
    var template = UriTemplateParser.parse_com_thoughtworks_restRpc_core_UriTemplate(cast new StringSource("xxx{?yy,asb}z"));
    trace(template);
  }

  public function test1() {
    var data = "xxx{yy}z";
    var source = new StringSource(data);
    var template = UriTemplateParser.parse_com_thoughtworks_restRpc_core_UriTemplate(source);
    assertEquals(data.length, source.position);
  }

  public function test2() {
    var data = "xxx{yy} z";
    var source = new StringSource(data);
    var template = UriTemplateParser.parse_com_thoughtworks_restRpc_core_UriTemplate(source);
    assertEquals(data.length - 2, source.position);
  }

  public function test3() {
    var data = "xxx{/yy} z";
    var source = new StringSource(data);
    var template = UriTemplateParser.parse_com_thoughtworks_restRpc_core_UriTemplate(source);
    assertEquals(data.length - 2, source.position);
  }


  public function test4() {
    var data = "xxx{/yasdf.y,sadf,3}z";
    var source = new StringSource(data);
    var template = UriTemplateParser.parse_com_thoughtworks_restRpc_core_UriTemplate(source);
    assertEquals(data.length, source.position);
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