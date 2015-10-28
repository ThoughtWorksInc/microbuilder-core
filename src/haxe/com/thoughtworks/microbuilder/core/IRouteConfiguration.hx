package com.thoughtworks.microbuilder.core;

import jsonStream.JsonStream;
import haxe.ds.Vector;

interface IRouteConfiguration {

  public function nameToUriTemplate(name:String):Null<IRouteEntry>;

  public var failureClassName(get, never):String;

  private function get_failureClassName():String;

  /**
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
   *
   * Returns null if no RPC method matched.
   **/
  public function matchUri(method: String, uri: String, body: Null<JsonStream>, contentType: Null<String>):Null<JsonStream>;
}

/**
 *
 */
@:nativeGen
interface IRouteEntry {

  public var method(get, never):String;

  private function get_method():String;

  /**
   * 约定参数列表的无法被uri template消费的参数（应该是最后一个）作为请求体
   */
  public function render(parameters:Iterator<JsonStream>):String;

  public var requestContentType(get, never):Null<String>;

  private function get_requestContentType():Null<String>;

}
