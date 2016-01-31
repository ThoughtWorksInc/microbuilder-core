releaseProcess := {
  releaseProcess.value.patch(releaseProcess.value.indexOf(publishArtifacts), Seq[ReleaseStep](releaseStepTask(publish in Haxe)), 0)
}

releaseProcess := {
  releaseProcess.value.patch(releaseProcess.value.indexOf(pushChanges), Seq[ReleaseStep](releaseStepCommand("sonatypeRelease")), 0)
}

releaseProcess -= runClean

releaseProcess -= runTest
