enablePlugins(AllHaxePlugins)

organization := "com.thoughtworks.microbuilder"

name := "microbuilder-core"

libraryDependencies ++= Seq("com.qifun.sbt-haxe" %% "test-interface" % "0.1.1" % Test)

libraryDependencies += "com.qifun" %% "json-stream" % "0.2.3" % HaxeJava classifier HaxeJava.name

libraryDependencies += "com.qifun" %% "json-stream" % "0.2.3" % HaxeCSharp classifier HaxeCSharp.name

libraryDependencies += "com.qifun" %% "json-stream" % "0.2.3" % Provided

for (c <- AllTargetConfigurations ++ AllTestTargetConfigurations) yield {
  haxeOptions in c += (baseDirectory.value / "build.hxml").getAbsolutePath
}

for (c <- AllTargetConfigurations) yield {
  haxeMacros in c += """com.dongxiguo.autoParser.AutoParser.BUILDER.defineClass([ "com.thoughtworks.microbuilder.core.UriTemplate" ], "com.thoughtworks.microbuilder.core.UriTemplateParser")"""
}

for (c <- AllTargetConfigurations) yield {
  haxeMacros in c += """com.dongxiguo.autoParser.AutoFormatter.BUILDER.defineClass([ "com.thoughtworks.microbuilder.core.UriTemplate" ], "com.thoughtworks.microbuilder.core.UriTemplateFormatter")"""
}


for (c <- AllTestTargetConfigurations) yield {
  haxeMacros in c += """com.dongxiguo.autoParser.AutoParser.BUILDER.defineMacroClass([ "com.thoughtworks.microbuilder.core.UriTemplate" ], "com.thoughtworks.microbuilder.core.UriTemplateParser")"""
}

for (c <- AllTestTargetConfigurations) yield {
  haxeMacros in c += """com.dongxiguo.autoParser.AutoFormatter.BUILDER.defineMacroClass([ "com.thoughtworks.microbuilder.core.UriTemplate" ], "com.thoughtworks.microbuilder.core.UriTemplateFormatter")"""
}


val haxelibs = Map(
  "continuation" -> DependencyVersion.SpecificVersion("1.3.2"),
  "microbuilder-HUGS" -> DependencyVersion.SpecificVersion("2.0.0"),
  "json-stream" -> DependencyVersion.SpecificVersion("2.0.0")
)

haxelibDependencies ++= haxelibs

for (c <- AllTargetConfigurations ++ AllTestTargetConfigurations) yield {
  haxeOptions in c ++= haxelibOptions(haxelibs)
}