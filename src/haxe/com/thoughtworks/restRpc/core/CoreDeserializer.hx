package com.thoughtworks.restRpc.core;

using com.qifun.jsonStream.Plugins;

@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer([
  "com.thoughtworks.restRpc.core.Failure"
]))
class CoreDeserializer {}