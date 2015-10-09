package com.thoughtworks.restRpc.core;

import haxe.unit.TestCase;

class RouteConfigurationFactoryTest extends TestCase {
}

@:build(com.thoughtworks.restRpc.core.RouteConfigurationFactory.generateRouteConfigurationFactory([
  "com.thoughtworks.restRpc.core.IMyRouteRpc"
]))
class RouteConfigurationTestFactory {}
