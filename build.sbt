libraryDependencies += "com.qifun.sbt-haxe" %% "test-interface" % "0.1.1" % Test

for (c <- Seq(Compile, Test)) yield {
  haxeOptions in c ++= Seq("-dce", "no")
}