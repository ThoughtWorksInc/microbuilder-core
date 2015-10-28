package com.thoughtworks.microbuilder.core;

import com.thoughtworks.microbuilder.core.IRouteConfiguration;
import jsonStream.JsonStream;
import haxe.ds.StringMap;
import haxe.ds.Vector;

@:final
@:dox(hidden)
class GeneratedRouteConfiguration implements IRouteConfiguration {
  public function new(uriTemplateMap:StringMap<IUriTemplate>, failureClassName:String) {
    this.uriTemplateMap = uriTemplateMap;
    _failureClassName = failureClassName;
  }

  var uriTemplateMap:StringMap<IUriTemplate>;

  public function nameToUriTemplate(name:String):Null<IUriTemplate> return {
    uriTemplateMap.get(name);
  }

  private var _failureClassName:String;

  public var failureClassName(get, never):String;

  public function get_failureClassName():String return _failureClassName;

  public static inline function getTypeName(?classType:Class<Dynamic>, ?enumType:Enum<Dynamic>):String return {
    if (classType != null) {
      Type.getClassName(classType);
    } else if (enumType != null){
      Type.getEnumName(enumType);
    } else {
      null;
    }
  }

  public function matchUri(method: String, uri: String, body: JsonStream, contentType: Null<String>):JsonStream return {
    throw "TODO:";
  }
}

@:final
class GeneratedUriTemplate implements IUriTemplate {

  public var requestContentType(get, never):Null<String>;

  private function get_requestContentType():Null<String> return {
    throw "TODO";
  }

  public function parseUri(uri:String):Null<Vector<JsonStream>> return {
    throw "TODO";
  }

  public function new(method:String, renderFunction:Iterator<JsonStream> -> String) {
    this._method = method;
    this.renderFunction = renderFunction;
  }

  var _method:String;

  var renderFunction:Iterator<JsonStream> -> String;

  public var method(get, never):String;

  private function get_method():String return _method;

  public function render(parameters:Iterator<JsonStream>):String return {
    renderFunction(parameters);
  }

}