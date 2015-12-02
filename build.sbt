import scala.util.parsing.json.JSONFormat

enablePlugins(AllHaxePlugins)

organization := "com.thoughtworks.microbuilder"

name := "microbuilder-core"

haxelibReleaseNote := "Initial release"

haxelibTags ++= Seq(
  "cross", "cpp", "cs", "flash", "java", "javascript", "js", "neko", "php", "python", "nme",
  "macro", "utility"
)

developers := List(
  Developer(
    "Atry",
    "杨博 (Yang Bo)",
    "pop.atry@gmail.com",
    url("https://github.com/Atry")
  )
)

crossScalaVersions := Seq("2.10.6", "2.11.7")

libraryDependencies ++= Seq("com.qifun.sbt-haxe" %% "test-interface" % "0.1.1" % Test)

for (c <- AllHaxeConfigurations) yield {
  libraryDependencies += "com.thoughtworks.microbuilder" % "hamu" % "0.2.0" % c classifier c.name
}

for (c <- AllHaxeConfigurations) yield {
  libraryDependencies += "com.thoughtworks.microbuilder" % "auto-parser" % "0.2.0" % c classifier c.name
}

haxelibDependencies += "auto-parser" -> DependencyVersion.SpecificVersion("0.2.0")

for (c <- AllHaxeConfigurations) yield {
  libraryDependencies += "com.thoughtworks.microbuilder" %% "json-stream" % "2.0.3" % c classifier c.name
}

haxelibDependencies += "json-stream" -> DependencyVersion.SpecificVersion("2.0.3")

libraryDependencies += "com.thoughtworks.microbuilder" %% "json-stream" % "2.0.3" % Provided

for (c <- AllTargetConfigurations ++ AllTestTargetConfigurations) yield {
  haxeOptions in c += (baseDirectory.value / "build.hxml").getAbsolutePath
}

for (c <- AllTestTargetConfigurations) yield {
  haxeMacros in c += """autoParser.AutoParser.BUILDER.defineClass([ "com.thoughtworks.microbuilder.core.UriTemplate" ], "com.thoughtworks.microbuilder.core.UriTemplateParser")"""
}

for (c <- AllTestTargetConfigurations) yield {
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
  "microbuilder-HUGS" -> DependencyVersion.SpecificVersion("2.0.1")
)

haxelibDependencies ++= haxelibs

for (c <- AllTargetConfigurations ++ AllTestTargetConfigurations) yield {
  haxeOptions in c ++= haxelibOptions(haxelibs)
}

homepage := Some(url(s"https://github.com/ThoughtWorksInc/${name.value}"))

startYear := Some(2015)

releasePublishArtifactsAction := PgpKeys.publishSigned.value

import ReleaseTransformations._

releaseProcess := Seq[ReleaseStep](
  checkSnapshotDependencies,
  inquireVersions,
  runClean,
  runTest,
  setReleaseVersion,
  commitReleaseVersion,
  tagRelease,
  releaseStepTask(publish in Haxe),
  publishArtifacts,
  setNextVersion,
  commitNextVersion,
  releaseStepCommand("sonatypeRelease"),
  pushChanges
)

releaseUseGlobalVersion := false

releaseCrossBuild := true

scmInfo := Some(ScmInfo(
  url(s"https://github.com/ThoughtWorksInc/${name.value}"),
  s"scm:git:git://github.com/ThoughtWorksInc/${name.value}.git",
  Some(s"scm:git:git@github.com:ThoughtWorksInc/${name.value}.git")))

licenses += "Apache" -> url("http://www.apache.org/licenses/LICENSE-2.0")
