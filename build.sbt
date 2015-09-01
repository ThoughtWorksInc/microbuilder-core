enablePlugins(HaxeJavaPlugin)

enablePlugins(HaxeCSharpPlugin)

organization := "com.thoughtworks"

name := "rest-rpc-core"

libraryDependencies ++= Seq("com.qifun.sbt-haxe" %% "test-interface" % "0.1.1" % Test)

libraryDependencies += "com.qifun" %% "json-stream" % "0.2.3" % HaxeJava classifier "haxe-java"

libraryDependencies += "com.qifun" %% "json-stream" % "0.2.3" % HaxeCSharp classifier "haxe-csharp"

libraryDependencies += "com.qifun" %% "json-stream" % "0.2.3" % Provided

for (c <- Seq(Compile, Test)) yield {
  haxeOptions in c += (baseDirectory.value / "build.hxml").getAbsolutePath
}

for (c <- Seq(Compile, CSharp)) yield {
  haxeOptions in c ++= Seq("--macro", """com.dongxiguo.autoParser.AutoParser.defineParser([ "com.thoughtworks.restRpc.core.UriTemplate" ], "com.thoughtworks.restRpc.core.UriTemplateParser")""")
}
