organization := "com.thoughtworks"

name := "rest-rpc-core"

libraryDependencies ++=
  Seq(
    "org.specs2" %% "specs2-core" % "3.6.4" % Test,
    "com.qifun.sbt-haxe" %% "test-interface" % "0.1.1" % Test
  )

for (c <- Seq(Compile, Test)) yield {
  haxeOptions in c ++= Seq("-dce", "no")
}