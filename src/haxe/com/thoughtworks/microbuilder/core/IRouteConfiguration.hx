package com.thoughtworks.microbuilder.core;

import jsonStream.JsonStream;
import haxe.ds.StringMap;
import haxe.ds.Vector;

interface IRouteConfiguration {

  public var failureResponseContentType(get, never):Null<String>;

  public var failureClassName(get, never):String;

  /**
   * Returns null if no RPC method matched.
   **/
  public function matchUri(request:Request):Null<MatchResult>;

  public function nameToUriTemplate(name:String):Null<IRouteEntry>;
}

@:final
class Request {
  public function new(httpMethod:String, uri:String, headers:Vector<Header>, body:Null<JsonStream>, contentType:Null<String>, accept:Null<String>) {
    this.httpMethod = httpMethod;
    this.uri = uri;
    this.headers = headers;
    this.body = body;
    this.contentType = contentType;
    this.accept = accept;
  }
  public var httpMethod(default, null):String;
  public var uri(default, null):String;
  public var headers(default, null):Vector<Header>;
  public var body(default, null):Null<JsonStream>;
  public var contentType(default, null):Null<String>;
  public var accept(default, null):Null<String>;
}

@:final
class Header {
  public function new(name:String, value:String) {
    this.name = name;
    this.value = value;
  }
  public var name(default, null):String;
  public var value(default, null):String;
}

@:final
class MatchResult {
  public function new(routeEntry:IRouteEntry, rpcData:JsonStream) {
    this.routeEntry = routeEntry;
    this.rpcData = rpcData;
  }
  public var routeEntry(default, null):IRouteEntry;

  /*
   * Returns a JsonStream that represents the RPC, for example:
   *
   * ```
   * {
   *   "methodName" :
   *   [
   *     "parameter1, a string",
   *     [
   *       "parameter2 is an array, and I am the first element in the array",
   *       "the second element in the array"
   *     ]
   *   ]
   * }
   * ```
   */
  public var rpcData(default, null):JsonStream;
}

/**
 *
 */
@:nativeGen
interface IRouteEntry {

  /**
   * 约定参数列表的无法被uri template消费的参数（应该是最后一个）作为请求体
   */
  public function render(parameters:Iterator<JsonStream>):Request;

  public var responseContentType(get, never):Null<String>;

}
