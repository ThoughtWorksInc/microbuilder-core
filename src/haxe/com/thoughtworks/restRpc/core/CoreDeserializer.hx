package com.thoughtworks.microbuilder.core;

using com.qifun.jsonStream.Plugins;

@:build(com.qifun.jsonStream.JsonDeserializer.generateDeserializer([
  "com.thoughtworks.microbuilder.core.Failure"
]))
class CoreDeserializer {}
