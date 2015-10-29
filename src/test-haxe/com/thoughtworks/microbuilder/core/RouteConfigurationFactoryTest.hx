package com.thoughtworks.microbuilder.core;

import haxe.unit.TestCase;
import jsonStream.JsonSerializer;
import jsonStream.JsonDeserializer;
import jsonStream.JsonStream;
import jsonStream.testUtil.JsonTestCase;
import jsonStream.io.TextParser;

class RouteConfigurationFactoryTest extends JsonTestCase {
  var routeConfiguration = RouteConfigurationTestFactory.routeConfiguration_com_thoughtworks_microbuilder_core_IMyRouteRpc();

  function testRequestContentType():Void {
    assertEquals("text/plain", routeConfiguration.nameToUriTemplate("myMethod").requestContentType);
  }

  function testMatchUri():Void {
    var rpcJsonStream = routeConfiguration.matchUri("GET", "/my-method/aaa/4/name/xxx/xxx", JsonStream.STRING("content"), "text/plain");
    var rpcJson:Dynamic = JsonDeserializer.deserializeRaw(rpcJsonStream);
    assertEquals(3, rpcJson.myMethod.length);
    assertEquals("4", rpcJson.myMethod[0]);
    assertEquals("aaa", rpcJson.myMethod[1].id);
    assertEquals("xxx", rpcJson.myMethod[1].fooBar);
  }

  function testMatchUriWithIncorrectRequestContentType():Void {
    var rpcJsonStream = routeConfiguration.matchUri("GET", "/my-method/aaa/4/name/xxx/xxx", JsonStream.STRING("content"), "application/json+incorrect-content-type");
    assertEquals(null, rpcJsonStream);
  }

  function testMatchUriWithIncorrectMethod():Void {
    var rpcJsonStream = routeConfiguration.matchUri("POST", "/my-method/aaa/4/name/xxx/xxx", JsonStream.STRING("content"), "text/plain");
    assertEquals(null, rpcJsonStream);
  }

  function testMatchUriWithUnmatchedUri():Void {
    var rpcJsonStream = routeConfiguration.matchUri("GET", "/my-method/aaa/4/name/xxx/xxx/-unmatched", JsonStream.STRING("content"), "text/plain");
    assertEquals(null, rpcJsonStream);
  }

  function testMatchUriWithIncorrectUri():Void {
    var rpcJsonStream = routeConfiguration.matchUri("GET", "/my-method/aaa/4/name/xxx/xxx-incorrect", JsonStream.STRING("content"), "text/plain");
    try {
      JsonDeserializer.deserializeRaw(rpcJsonStream);
      throw "Should not reach this line of code.";
    } catch(e:Dynamic) {
      assertTrue(e != null);
    }
  }


  function testMatchUriForOverridenVariable():Void {
    var rpcJsonStream = routeConfiguration.matchUri("GET", "/my-method2/id,a/id_should=/a", null, null);
    var rpcJson:Dynamic = JsonDeserializer.deserializeRaw(rpcJsonStream);
    assertEquals(1, rpcJson.myMethod2.length);
    assertEquals("a", rpcJson.myMethod2[0].id);
  }

  function testMatchUriForUnmatchedOverridenVariable():Void {
    var rpcJsonStream = routeConfiguration.matchUri("GET", "/my-method2/id,a/id_should=/b", null, null);
    try {
      JsonDeserializer.deserializeRaw(rpcJsonStream);
      throw "Should not reach this line of code.";
    } catch(e:Dynamic) {
      assertTrue(e != null);
    }
  }

}

@:build(com.thoughtworks.microbuilder.core.RouteConfigurationFactory.generateRouteConfigurationFactory([
  "com.thoughtworks.microbuilder.core.IMyRouteRpc"
]))
class RouteConfigurationTestFactory {}
