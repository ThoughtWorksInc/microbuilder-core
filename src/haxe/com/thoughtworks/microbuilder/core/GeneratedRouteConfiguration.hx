package com.thoughtworks.microbuilder.core;

import com.thoughtworks.microbuilder.core.IRouteConfiguration;
import jsonStream.JsonStream;
import haxe.ds.StringMap;
import haxe.ds.Vector;
import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;

@:dox(hide)
@:final
class GeneratedRouteConfiguration implements IRouteConfiguration {

  public function new(
    routeEntries:StringMap<GeneratedRouteEntry>,
    failureClassName:String) {
    this.routeEntries = routeEntries;
    _failureClassName = failureClassName;
  }

  var routeEntries:StringMap<GeneratedRouteEntry>;

  public function nameToUriTemplate(name:String):Null<IRouteEntry> return {
    routeEntries.get(name);
  }

  public var failureResponseContentType(get, never):Null<String>;

  // TODO: generate this method
  private function get_failureResponseContentType():Null<String> return "application/json";

  private var _failureClassName:String;

  public var failureClassName(get, never):String;

  public function get_failureClassName():String return _failureClassName;

  public static inline function getTypeName(?classType:Class<Dynamic>, ?enumType:Enum<Dynamic>):String return {
    if (classType != null) {
      Type.getClassName(classType);
    } else if (enumType != null) {
      Type.getEnumName(enumType);
    } else {
      null;
    }
  }

  public function matchUri(request:Request):Null<MatchResult> return {
    for (entry in routeEntries) {
      if (request.httpMethod == entry.method && request.contentType == entry.requestContentType) {
        var matchedData = entry.parseUri(request.uri);
        if (matchedData != null) {
          return new MatchResult(
            entry,
            JsonStream.OBJECT(new Generator<JsonStreamPair>(Continuation.cpsFunction(
              function(yield) {
                @await yield(new JsonStreamPair(matchedData.methodName, JsonStream.ARRAY(new Generator<JsonStream>(Continuation.cpsFunction(
                  function(yieldParameter) {
                    @await matchedData.parameters(yieldParameter);
                    if (request.contentType != null) {
                      @await yieldParameter(request.body);
                    }
                  }
                )))));
              }
            )))
          );
        }
      }
    }
    null;
  }

}

@:dox(hide)
@:final
class UriData {
  public var methodName:String;
  public var parameters:RunFunction<JsonStream>;
  public function new() {}
}

@:dox(hide)
@:final
class GeneratedRouteEntry implements IRouteEntry {

  public var parseUri:String -> Null<UriData>;

  public var responseContentType(get, never):Null<String>;

  public var requestContentType(get, never):Null<String>;

  private var _requestContentType:Null<String>;
  private var _responseContentType:Null<String>;

  // TODO: generate this method
  private function get_responseContentType():Null<String> return _responseContentType;

  private function get_requestContentType():Null<String> return _requestContentType;

  public function new(
    method:String,
    renderFunction:Iterator<JsonStream> -> Request,
    requestContentType:Null<String>,
    responseContentType:Null<String>,
    parseUri:String -> Null<UriData>) {
    this._method = method;
    this.renderFunction = renderFunction;
    this._requestContentType = requestContentType;
    this._responseContentType = responseContentType;
    this.parseUri = parseUri;
  }

  var _method:String;

  var renderFunction:Iterator<JsonStream> -> Request;

  public var method(get, never):String;

  private function get_method():String return _method;

  public function render(parameters:Iterator<JsonStream>):Request return {
    renderFunction(parameters);
  }

}
