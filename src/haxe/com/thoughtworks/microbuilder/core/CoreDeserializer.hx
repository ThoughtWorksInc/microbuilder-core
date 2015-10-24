package com.thoughtworks.microbuilder.core;

using jsonStream.Plugins;

@:build(jsonStream.JsonDeserializer.generateDeserializer([
  "com.thoughtworks.microbuilder.core.Failure"
]))
class CoreDeserializer {}
