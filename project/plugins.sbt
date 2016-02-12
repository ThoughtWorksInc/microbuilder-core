resolvers += "Sonatype Public" at "https://oss.sonatype.org/content/groups/public"

addSbtPlugin("com.jsuereth" % "sbt-pgp" % "1.0.0")

addSbtPlugin("org.xerial.sbt" % "sbt-sonatype" % "0.5.0")

addSbtPlugin("com.thoughtworks.microbuilder" % "sbt-haxe" % "3.0.11")

addSbtPlugin("com.github.gseitz" % "sbt-release" % "1.0.2")
