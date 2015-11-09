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

  function testMatchUriUnescape():Void {
    var matchResult = routeConfiguration.matchUri("GET", "/simple-method/%580,%20%59%0D%0A", null, null);
    var rpcJson:Dynamic = JsonDeserializer.deserializeRaw(matchResult.rpcData);
    assertEquals(1, rpcJson.simpleMethod.length);
    assertEquals("X0, Y\r\n", rpcJson.simpleMethod[0]);
  }

  function testEscape():Void {
    var uri = "/simple-method/%0A,%20,%0D";
    var matchResult = routeConfiguration.matchUri("GET", uri, null, null);
    switch matchResult.rpcData {
      case OBJECT(methodIterator):
        assertTrue(methodIterator.hasNext());
        switch methodIterator.next() {
          case { key:methodName, value:ARRAY(parameters) }:
            assertEquals(uri, routeConfiguration.nameToUriTemplate(methodName).render(parameters));
          default:
            throw "Expect ARRAY";
        }
        assertFalse(methodIterator.hasNext());
      default:
        throw "Expect OBJECT, actrually " + matchResult.rpcData;
    }
  }

  function testMatchUri():Void {
    var matchResult = routeConfiguration.matchUri("GET", "/my-method/aaa/4/name/xxx/xxx", JsonStream.STRING("content"), "text/plain");
    var rpcJson:Dynamic = JsonDeserializer.deserializeRaw(matchResult.rpcData);
    assertEquals(3, rpcJson.myMethod.length);
    assertEquals("4", rpcJson.myMethod[0]);
    assertEquals("aaa", rpcJson.myMethod[1].id);
    assertEquals("xxx", rpcJson.myMethod[1].fooBar);
  }

  function testMatchUriWithIncorrectRequestContentType():Void {
    var matchResult = routeConfiguration.matchUri("GET", "/my-method/aaa/4/name/xxx/xxx", JsonStream.STRING("content"), "application/json+incorrect-content-type");
    assertEquals(null, matchResult);
  }

  function testMatchUriWithIncorrectMethod():Void {
    var matchResult = routeConfiguration.matchUri("POST", "/my-method/aaa/4/name/xxx/xxx", JsonStream.STRING("content"), "text/plain");
    assertEquals(null, matchResult);
  }

  function testMatchUriWithUnmatchedUri():Void {
    var matchResult = routeConfiguration.matchUri("GET", "/my-method/aaa/4/name/xxx/xxx/-unmatched", JsonStream.STRING("content"), "text/plain");
    assertEquals(null, matchResult);
  }

  function testMatchUriWithIncorrectUri():Void {
    var matchResult = routeConfiguration.matchUri("GET", "/my-method/aaa/4/name/xxx/xxx-incorrect", JsonStream.STRING("content"), "text/plain");
    try {
      JsonDeserializer.deserializeRaw(matchResult.rpcData);
      throw "Should not reach this line of code.";
    } catch(e:Dynamic) {
      assertTrue(e != null);
    }
  }


  function testMatchUriForOverridenVariable():Void {
    var matchResult = routeConfiguration.matchUri("GET", "/my-method2/id,a/id_should=a", null, null);
    var rpcJson:Dynamic = JsonDeserializer.deserializeRaw(matchResult.rpcData);
    assertEquals(1, rpcJson.myMethod2.length);
    assertEquals("a", rpcJson.myMethod2[0].id);
  }

  function testMatchUriForUnmatchedOverridenVariable():Void {
    var matchResult = routeConfiguration.matchUri("GET", "/my-method2/id,a/id_should=b", null, null);
    try {
      JsonDeserializer.deserializeRaw(matchResult.rpcData);
      throw "Should not reach this line of code.";
    } catch(e:Dynamic) {
      assertTrue(e != null);
    }
  }


  function testMatchUriForComplexOverridenVariable1():Void {
    var uri = "/my-method3/id,foo,name,bar/id_should=foo/name_should=bar";
    var matchResult = routeConfiguration.matchUri("GET", uri, null, null);
    var rpcJson:Dynamic = JsonDeserializer.deserializeRaw(matchResult.rpcData);
    assertEquals(1, rpcJson.myMethod3.length);
    assertEquals("foo", rpcJson.myMethod3[0].id);
    assertEquals("bar", rpcJson.myMethod3[0].name);
  }

  function testMatchUriForComplexOverridenVariable2():Void {
    var uri = "/my-method3/name,bar,id,foo/id_should=foo/name_should=bar";
    var matchResult = routeConfiguration.matchUri("GET", uri, null, null);
    var rpcJson:Dynamic = JsonDeserializer.deserializeRaw(matchResult.rpcData);
    assertEquals(1, rpcJson.myMethod3.length);
    assertEquals("foo", rpcJson.myMethod3[0].id);
    assertEquals("bar", rpcJson.myMethod3[0].name);
  }

  function testMatchUriForComplexOverridenVariable3():Void {
    var uri = "/my-method3/name,bar,id,foo,moreKey1,moreValue1,moreKey2,moreValue2/id_should=foo/name_should=bar";
    var matchResult = routeConfiguration.matchUri("GET", uri, null, null);
    var rpcJson:Dynamic = JsonDeserializer.deserializeRaw(matchResult.rpcData);
    assertEquals(1, rpcJson.myMethod3.length);
    assertEquals("foo", rpcJson.myMethod3[0].id);
    assertEquals("bar", rpcJson.myMethod3[0].name);
    assertEquals("moreValue2", rpcJson.myMethod3[0].moreKey2);
    assertEquals("moreValue1", rpcJson.myMethod3[0].moreKey1);
  }


  function testMatchUriForUnmatchedComplexOverridenVariable():Void {
    var matchResult = routeConfiguration.matchUri("GET", "/my-method3/name,bar,id,foo/id_should=foo/name_should=baz", null, null);
    try {
      JsonDeserializer.deserializeRaw(matchResult.rpcData);
      throw "Should not reach this line of code.";
    } catch(e:Dynamic) {
      assertTrue(e != null);
    }
  }

  /* // Does not support render complex parameter yet, disable this test currently
  function testRestore() {
    var uri = "/my-method3/name,bar,id,foo,moreKey1,moreValue1,moreKey2,moreValue2/id_should=foo/name_should=bar";
    var rpcJsonStream = routeConfiguration.matchUri("GET", uri, null, null);
    switch rpcJsonStream {
      case OBJECT(methodIterator):
        assertTrue(methodIterator.hasNext());
        switch methodIterator.next() {
          case { key:methodName, value:ARRAY(parameters) }:
            assertEquals(uri, routeConfiguration.nameToUriTemplate(methodName).render(parameters));
          default:
            throw "Expect ARRAY";
        }
        assertFalse(methodIterator.hasNext());
      default:
        throw "Expect OBJECT, actrually " + rpcJsonStream;
    }
  }
  */

}

@:build(com.thoughtworks.microbuilder.core.RouteConfigurationFactory.generateRouteConfigurationFactory([
  "com.thoughtworks.microbuilder.core.IMyRouteRpc"
]))
class RouteConfigurationTestFactory {}
