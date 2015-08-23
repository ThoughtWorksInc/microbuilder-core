package com.thoughtworks.restRpc.core;

import com.qifun.jsonStream.JsonStream;

class RouteConfiguration {
    public var nameToUriTemplate: Map<String, IUriTemplate> = new Map<String, IUriTemplate>();
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
