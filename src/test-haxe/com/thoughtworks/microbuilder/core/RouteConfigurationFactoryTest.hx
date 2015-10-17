package com.thoughtworks.microbuilder.core;

import haxe.unit.TestCase;

class RouteConfigurationFactoryTest extends TestCase {
}

@:build(com.thoughtworks.microbuilder.core.RouteConfigurationFactory.generateRouteConfigurationFactory([
  "com.thoughtworks.microbuilder.core.IMyRouteRpc"
]))
class RouteConfigurationTestFactory {}
