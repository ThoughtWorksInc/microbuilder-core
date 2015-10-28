package com.thoughtworks.microbuilder.core;

import jsonStream.JsonStream;
import haxe.ds.Vector;

interface IRouteConfiguration {

  public function nameToUriTemplate(name:String):Null<IUriTemplate>;

  public var failureClassName(get, never):String;

  private function get_failureClassName():String;

  public function matchUri(method: String, uri: String, body: JsonStream, contentType: Null<String>):JsonStream;
}

/**
 *
 */
@:nativeGen
interface IUriTemplate {

  public var method(get, never):String;

  private function get_method():String;

  /**
   * 约定参数列表的无法被uri template消费的参数（应该是最后一个）作为请求体
   */
  public function render(parameters:Iterator<JsonStream>):String;

  public var requestContentType(get, never):Null<String>;

  private function get_requestContentType():Null<String>;

}
