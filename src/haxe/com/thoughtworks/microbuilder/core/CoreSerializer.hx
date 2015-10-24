package com.thoughtworks.microbuilder.core;

using jsonStream.Plugins;

@:build(jsonStream.JsonSerializer.generateSerializer([
  "com.thoughtworks.microbuilder.core.Failure"
]))
class CoreSerializer {}
