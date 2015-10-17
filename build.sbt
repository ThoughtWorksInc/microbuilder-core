enablePlugins(HaxeJavaPlugin)

enablePlugins(HaxeCSharpPlugin)

enablePlugins(HaxeCppPlugin)

enablePlugins(HaxeFlashPlugin)

enablePlugins(HaxeAs3Plugin)

enablePlugins(HaxePythonPlugin)

enablePlugins(HaxeNekoPlugin)

enablePlugins(HaxePhpPlugin)

enablePlugins(HaxeJsPlugin)

organization := "com.thoughtworks"

name := "microbuilder-core"

libraryDependencies ++= Seq("com.qifun.sbt-haxe" %% "test-interface" % "0.1.1" % Test)

libraryDependencies += "com.qifun" %% "json-stream" % "0.2.3" % HaxeJava classifier HaxeJava.name

libraryDependencies += "com.qifun" %% "json-stream" % "0.2.3" % HaxeCSharp classifier HaxeCSharp.name

libraryDependencies += "com.qifun" %% "json-stream" % "0.2.3" % Provided

for (c <- AllTargetConfigurations ++ AllTestTargetConfigurations) yield {
  haxeOptions in c += (baseDirectory.value / "build.hxml").getAbsolutePath
}

for (c <- AllTargetConfigurations) yield {
  haxeMacros in c += """com.dongxiguo.autoParser.AutoParser.BUILDER.defineClass([ "com.thoughtworks.restRpc.core.UriTemplate" ], "com.thoughtworks.restRpc.core.UriTemplateParser")"""
}

for (c <- AllTargetConfigurations) yield {
  haxeMacros in c += """com.dongxiguo.autoParser.AutoFormatter.BUILDER.defineClass([ "com.thoughtworks.restRpc.core.UriTemplate" ], "com.thoughtworks.restRpc.core.UriTemplateFormatter")"""
}


for (c <- AllTestTargetConfigurations) yield {
  haxeMacros in c += """com.dongxiguo.autoParser.AutoParser.BUILDER.defineMacroClass([ "com.thoughtworks.restRpc.core.UriTemplate" ], "com.thoughtworks.restRpc.core.UriTemplateParser")"""
}

for (c <- AllTestTargetConfigurations) yield {
  haxeMacros in c += """com.dongxiguo.autoParser.AutoFormatter.BUILDER.defineMacroClass([ "com.thoughtworks.restRpc.core.UriTemplate" ], "com.thoughtworks.restRpc.core.UriTemplateFormatter")"""
}

for (c <- Seq(CSharp, TestCSharp)) yield {
  haxeOptions in c ++= Seq("-lib", "HUGS")
}
