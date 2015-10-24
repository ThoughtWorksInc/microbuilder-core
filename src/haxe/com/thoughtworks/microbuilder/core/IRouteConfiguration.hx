package com.thoughtworks.microbuilder.core;

import jsonStream.JsonStream;
import haxe.ds.Vector;

interface IRouteConfiguration {

  public function nameToUriTemplate(name:String):Null<IUriTemplate>;

  public var failureClassName(get, never):String;

  private function get_failureClassName():String;

  public function matchUri(method:String, uri:String, bodyJsonStream:JsonStream, contentType:String): JsonStream;
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

  public function parseUri(uri: String): Vector<JsonStream>;

  public function get_requestContentType(): String;
}
