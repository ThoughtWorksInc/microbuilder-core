package com.thoughtworks.microbuilder.core;

using com.qifun.jsonStream.Plugins;

@:build(com.qifun.jsonStream.JsonSerializer.generateSerializer([
  "com.thoughtworks.microbuilder.core.Failure"
]))
class CoreSerializer {}
