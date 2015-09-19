package com.thoughtworks.restRpc.core;

import com.thoughtworks.restRpc.core.IRouteConfiguration;
import com.qifun.jsonStream.JsonStream;
import haxe.ds.StringMap;

@:final
class GeneratedRouteConfiguration implements IRouteConfiguration {
  public function new(uriTemplateMap:StringMap<IUriTemplate>) {
    this.uriTemplateMap = uriTemplateMap;
  }

  var uriTemplateMap:StringMap<IUriTemplate>;

  public function nameToUriTemplate(name:String):Null<IUriTemplate> return {
    uriTemplateMap.get(name);
  }

    public function failureClassName():String {
        throw  "Not Implemented";
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

  private function get_method():String return {
    _method;
  }

  public function render(parameters:Iterator<JsonStream>):String return {
    renderFunction(parameters);
  }

}