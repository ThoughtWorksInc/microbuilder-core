package com.thoughtworks.restRpc.core;

import scala.collection.Iterator;
import com.qifun.jsonStream.JsonStream;

interface IRouteConfiguration {
    public function nameToUriTemplate(name: String) : Null<IUriTemplate>;
    public function failureClassName():String;
}

/**
 *
 **/
@:nativeGen
interface IUriTemplate {

    public var method(get, never): String;

    private function get_method():String;

    /**
     *约定参数列表的无法被uri template消费的参数（应该是最后一个）作为请求体
     **/
    public function render(parameters: Iterator<JsonStream>):String;

}
