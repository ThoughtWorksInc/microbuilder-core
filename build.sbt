organization := "com.thoughtworks"

name := "rest-rpc-core"

libraryDependencies ++= Seq("com.qifun.sbt-haxe" %% "test-interface" % "0.1.1" % Test)

libraryDependencies += "com.qifun" %% "json-stream" % "0.2.3" % HaxeJava classifier HaxeJava.name

libraryDependencies += "com.qifun" %% "json-stream" % "0.2.3" % HaxeCSharp classifier HaxeCSharp.name

libraryDependencies += "com.qifun" %% "json-stream" % "0.2.3" % Provided

for (c <- Seq(Compile, Test)) yield {
  haxeOptions in c ++= Seq("-dce", "no")
}