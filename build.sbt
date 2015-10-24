enablePlugins(AllHaxePlugins)

organization := "com.thoughtworks.microbuilder"

name := "microbuilder-core"

libraryDependencies ++= Seq("com.qifun.sbt-haxe" %% "test-interface" % "0.1.1" % Test)

for (c <- AllHaxeConfigurations) yield {
  libraryDependencies += "com.thoughtworks.microbuilder" % "hamu" % "0.2.0" % c classifier c.name
}

for (c <- AllHaxeConfigurations) yield {
  libraryDependencies += "com.thoughtworks.microbuilder" % "auto-parser" % "0.2.0" % c classifier c.name
}

haxelibDependencies += "auto-parser" -> DependencyVersion.SpecificVersion("0.2.0")

for (c <- AllHaxeConfigurations) yield {
  libraryDependencies += "com.thoughtworks.microbuilder" %% "json-stream" % "2.0.0" % c classifier c.name
}

haxelibDependencies += "json-stream" -> DependencyVersion.SpecificVersion("2.0.0")

libraryDependencies += "com.thoughtworks.microbuilder" %% "json-stream" % "2.0.0" % Provided

for (c <- AllTargetConfigurations ++ AllTestTargetConfigurations) yield {
  haxeOptions in c += (baseDirectory.value / "build.hxml").getAbsolutePath
}

for (c <- AllTargetConfigurations) yield {
  haxeMacros in c += """autoParser.AutoParser.BUILDER.defineClass([ "com.thoughtworks.microbuilder.core.UriTemplate" ], "com.thoughtworks.microbuilder.core.UriTemplateParser")"""
}

for (c <- AllTargetConfigurations) yield {
  haxeMacros in c += """autoParser.AutoFormatter.BUILDER.defineClass([ "com.thoughtworks.microbuilder.core.UriTemplate" ], "com.thoughtworks.microbuilder.core.UriTemplateFormatter")"""
}


for (c <- AllTestTargetConfigurations) yield {
  haxeMacros in c += """autoParser.AutoParser.BUILDER.defineMacroClass([ "com.thoughtworks.microbuilder.core.UriTemplate" ], "com.thoughtworks.microbuilder.core.UriTemplateParser")"""
}

for (c <- AllTestTargetConfigurations) yield {
  haxeMacros in c += """autoParser.AutoFormatter.BUILDER.defineMacroClass([ "com.thoughtworks.microbuilder.core.UriTemplate" ], "com.thoughtworks.microbuilder.core.UriTemplateFormatter")"""
}


val haxelibs = Map(
  "continuation" -> DependencyVersion.SpecificVersion("1.3.2"),
  "microbuilder-HUGS" -> DependencyVersion.SpecificVersion("2.0.0")
)

haxelibDependencies ++= haxelibs

for (c <- AllTargetConfigurations ++ AllTestTargetConfigurations) yield {
  haxeOptions in c ++= haxelibOptions(haxelibs)
}