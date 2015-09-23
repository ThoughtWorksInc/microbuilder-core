package com.thoughtworks.restRpc.core;

using com.qifun.jsonStream.Plugins;

@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer([
  "com.thoughtworks.restRpc.core.Failure"
]))
class CoreSerializer {}
