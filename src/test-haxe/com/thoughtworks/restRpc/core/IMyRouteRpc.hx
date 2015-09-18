package com.thoughtworks.restRpc.core;

import com.qifun.jsonStream.rpc.Future;

interface IMyRouteRpc {
  @:requestcContentType("text/plain")
  @:route("GET", "/my-method/{foo.id}/{id}/name/{foo.foo-bar}/{foo.foo-bar}")
  function myMethod(id:Int, foo:String, content:String):Future<String>; // Future1   apply
}