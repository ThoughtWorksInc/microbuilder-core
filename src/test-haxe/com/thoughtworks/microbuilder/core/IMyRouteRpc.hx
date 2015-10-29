package com.thoughtworks.microbuilder.core;

import jsonStream.rpc.Future;

class MyStructureFailure {}

@:structuralFailure(com.thoughtworks.microbuilder.core.IMyRouteRpc.MyStructureFailure)
interface IMyRouteRpc {

  @:requestContentType("text/plain")
  @:route("GET", "/my-method/{foo.id}/{id}/name/{foo.fooBar}/{foo.fooBar}")
  function myMethod(id:Int, foo:String, content:String):Future<String>;

  @:route("GET", "/my-method2/{foo}/id_should=/{foo.id}")
  function myMethod2(foo:String):Future<String>;

}