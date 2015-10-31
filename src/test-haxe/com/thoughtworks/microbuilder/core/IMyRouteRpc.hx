package com.thoughtworks.microbuilder.core;

import jsonStream.rpc.Future;
import jsonStream.RawJson;

class MyStructureFailure {}

@:structuralFailure(com.thoughtworks.microbuilder.core.IMyRouteRpc.MyStructureFailure)
interface IMyRouteRpc {

  @:route("GET", "/simple-method/{simpleJson}")
  function simpleMethod(simpleJson:RawJson):Future<String>;

  @:requestContentType("text/plain")
  @:route("GET", "/my-method/{foo.id}/{id}/name/{foo.fooBar}/{foo.fooBar}")
  function myMethod(id:Int, foo:RawJson, content:String):Future<String>;

  @:route("GET", "/my-method2/{foo}/id_should={foo.id}")
  function myMethod2(foo:RawJson):Future<String>;

  @:route("GET", "/my-method3/{foo}/id_should={foo.id}/name_should={foo.name}")
  function myMethod3(foo:RawJson):Future<String>;

}