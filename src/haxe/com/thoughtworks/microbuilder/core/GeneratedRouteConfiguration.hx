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
  public function matchUri(method:String, uri:String, bodyJsonStream:JsonStream, contentType:String):JsonStream return{
    throw "Unimplemented";
  }
  public static inline function getTypeName(?classType:Class<Dynamic>, ?enumType:Enum<Dynamic>):String return {
    if (classType != null) {
      Type.getClassName(classType);
    } else if (enumType != null){
      Type.getEnumName(enumType);
    } else {
      null;
    }
  }

}

@:final
class GeneratedUriTemplate implements IUriTemplate {

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


  public function parseUri(uri: String): Vector<JsonStream> return{
    throw "not implemented";
  }

  public function get_requestContentType(): String return{
    throw "not implemented";
  }

}