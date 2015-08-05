import org.specs2.Specification

class RpcCoreSpec extends Specification {
  def is = s2"""

   This is a specification for the RpcCore

   The RpcCore should
     have identity                             $e1
                                                       """

  def e1 = RpcCore.identity must beEqualTo("rest-rpc-core")
}