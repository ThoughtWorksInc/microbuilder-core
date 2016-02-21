import scala.util.parsing.json.JSONFormat

enablePlugins(AllHaxePlugins)

organization := "com.thoughtworks.microbuilder"

name := "microbuilder-core"

haxelibReleaseNote := "Remove default user agent when sending requests"

haxelibTags ++= Seq(
  "cross", "cpp", "cs", "flash", "java", "javascript", "js", "neko", "php", "python", "nme",
  "macro", "utility", "rpc", "rest", "micro-service"
)

developers := List(
  Developer(
    "Atry",
    "杨博 (Yang Bo)",
    "pop.atry@gmail.com",
    url("https://github.com/Atry")
  )
)

resolvers += "Sonatype Public" at "https://oss.sonatype.org/content/groups/public"

libraryDependencies ++= Seq("com.qifun.sbt-haxe" %% "test-interface" % "0.1.1" % Test)

for (c <- AllHaxeConfigurations) yield {
  libraryDependencies += "com.thoughtworks.microbuilder" % "hamu" % "1.0.0" % c classifier c.name
}

for (c <- AllHaxeConfigurations) yield {
  libraryDependencies += "com.thoughtworks.microbuilder" % "auto-parser" % "1.0.0" % c classifier c.name
}

haxelibDependencies += "auto-parser" -> DependencyVersion.SpecificVersion("1.0.0")

for (c <- AllHaxeConfigurations) yield {
  libraryDependencies += "com.thoughtworks.microbuilder" % "json-stream-core" % "3.0.3" % c classifier c.name
}

haxelibDependencies += "json-stream-core" -> DependencyVersion.SpecificVersion("3.0.3")

libraryDependencies += "com.thoughtworks.microbuilder" % "json-stream-core" % "3.0.3" % Provided

for (c <- AllTargetConfigurations ++ AllTestTargetConfigurations) yield {
  haxeOptions in c += (baseDirectory.value / "build.hxml").getAbsolutePath
}

haxeOptions in TestCpp += "--no-opt" // Workaround for https://github.com/HaxeFoundation/haxe/issues/4844

for (c <- AllTestTargetConfigurations) yield {
  haxeMacros in c += """autoParser.AutoParser.BUILDER.lazyDefineClass([ "com.thoughtworks.microbuilder.core.uriTemplate.UriTemplate" ], "com.thoughtworks.microbuilder.core.UriTemplateParser")"""
}

for (c <- AllTestTargetConfigurations) yield {
  haxeMacros in c += """autoParser.AutoFormatter.BUILDER.lazyDefineClass([ "com.thoughtworks.microbuilder.core.uriTemplate.UriTemplate" ], "com.thoughtworks.microbuilder.core.UriTemplateFormatter")"""
}

val haxelibs = Map(
  "mconsole" -> DependencyVersion.LastVersion,
  "mockatoo" -> DependencyVersion.GitVersion("https://github.com/Atry/mockatoo.git", "patch-1", "src"),
  "continuation" -> DependencyVersion.SpecificVersion("1.3.2"),
  "microbuilder-HUGS" -> DependencyVersion.SpecificVersion("2.0.1")
)

haxelibDependencies ++= haxelibs

for (c <- AllTargetConfigurations ++ AllTestTargetConfigurations) yield {
  haxeOptions in c ++= haxelibOptions(haxelibs)
}

homepage := Some(url(s"https://github.com/ThoughtWorksInc/${name.value}"))

startYear := Some(2015)

autoScalaLibrary := false

crossPaths := false

releasePublishArtifactsAction := PgpKeys.publishSigned.value

import ReleaseTransformations._

releaseUseGlobalVersion := false

releaseCrossBuild := false

scmInfo := Some(ScmInfo(
  url(s"https://github.com/ThoughtWorksInc/${name.value}"),
  s"scm:git:git://github.com/ThoughtWorksInc/${name.value}.git",
  Some(s"scm:git:git@github.com:ThoughtWorksInc/${name.value}.git")))

licenses += "Apache" -> url("http://www.apache.org/licenses/LICENSE-2.0")

releaseProcess := {
  releaseProcess.value.patch(releaseProcess.value.indexOf(publishArtifacts), Seq[ReleaseStep](releaseStepTask(publish in Haxe)), 0)
}

releaseProcess := {
  releaseProcess.value.patch(releaseProcess.value.indexOf(pushChanges), Seq[ReleaseStep](releaseStepCommand("sonatypeRelease")), 0)
}

releaseProcess -= runClean

releaseProcess -= runTest

haxeExtraParams += "--macro hamu.ExprEvaluator.parseAndEvaluate('autoParser.AutoFormatter.BUILDER.lazyDefineMacroClass([\"com.thoughtworks.microbuilder.core.uriTemplate.UriTemplate\"],\"com.thoughtworks.microbuilder.core.UriTemplateFormatter\")')"

haxeExtraParams += "--macro hamu.ExprEvaluator.parseAndEvaluate('autoParser.AutoParser.BUILDER.lazyDefineMacroClass([\"com.thoughtworks.microbuilder.core.uriTemplate.UriTemplate\"],\"com.thoughtworks.microbuilder.core.UriTemplateParser\")')"

doc in Compile <<= doc in Haxe
