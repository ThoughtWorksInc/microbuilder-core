package com.thoughtworks.microbuilder.core;

import jsonStream.rpc.Future;

class MyStructureFailure {}

@:structuralFailure(com.thoughtworks.microbuilder.core.IMyRouteRpc.MyStructureFailure)
interface IMyRouteRpc {
  @:requestcContentType("text/plain")
  @:route("GET", "/my-method/{foo.id}/{id}/name/{foo.foo-bar}/{foo.foo-bar}")
  function myMethod(id:Int, foo:String, content:String):Future<String>; // Future1   apply
}