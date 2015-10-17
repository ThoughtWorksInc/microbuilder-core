package com.thoughtworks.microbuilder.core;

import com.thoughtworks.microbuilder.core.UriTemplate;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
import com.dongxiguo.autoParser.StringSource;
import haxe.unit.TestCase;
import haxe.ds.Vector;
import com.qifun.jsonStream.testUtil.JsonTestCase;
using Lambda;

class UriTemplateParserTest extends JsonTestCase {

  public function test1() {
    var data = "xxx{yy}z";
    var source = new StringSource(data);
    var template = UriTemplateParser.parse_com_thoughtworks_microbuilder_core_UriTemplate(source);
    assertEquals(data.length, source.position);
    this.assertMatch(
      (_:Array<LiteralsOrExpression>) =>
      [
        LITERALS(UNRESERVED(120)), LITERALS(UNRESERVED(120)), LITERALS(UNRESERVED(120)),
        EXPRESSION(
          123,
          null,
          {
            first: { varname: { first: ALPHA(121), rest: (_:Array<DotVarchar>) =>[DOT_VARCHAR(null, ALPHA(121))] } },
            rest: (_:Array<CommaVarchar>) =>[]
          },
          125
        ),
        LITERALS(UNRESERVED(122))
      ], template
    );
  }

  public function test2() {
    var data = "xxx{yy} z";
    var source = new StringSource(data);
    var template = UriTemplateParser.parse_com_thoughtworks_microbuilder_core_UriTemplate(source);
    assertEquals(data.length - 2, source.position);
    this.assertMatch(
      (_:Array<LiteralsOrExpression>) =>
      [
        LITERALS(UNRESERVED(120)), LITERALS(UNRESERVED(120)), LITERALS(UNRESERVED(120)),
        EXPRESSION(
          123,
          null,
          {
            first: { varname: { first: ALPHA(121), rest: (_:Array<DotVarchar>) =>[DOT_VARCHAR(null, ALPHA(121))] } },
            rest: (_:Array<CommaVarchar>) =>[]
          },
          125
        )
      ],
      template
    );
  }

  public function test3() {
    var data = "xxx{/yy} z";
    var source = new StringSource(data);
    var template = UriTemplateParser.parse_com_thoughtworks_microbuilder_core_UriTemplate(source);
    assertEquals(data.length - 2, source.position);
    this.assertMatch(
      (_:Array<LiteralsOrExpression>) =>
      [
        LITERALS(UNRESERVED(120)), LITERALS(UNRESERVED(120)), LITERALS(UNRESERVED(120)),
        EXPRESSION(
          123,
          OP_LEVEL3(47),
          {
            first: { varname: { first: ALPHA(121), rest: (_:Array<DotVarchar>) =>[DOT_VARCHAR(null, ALPHA(121))] } },
            rest: (_:Array<CommaVarchar>) =>[]
          },
          125
        )
      ],
      template
    );
  }


  public function test4() {
    var data = "a{/b.c}d";
    var source = new StringSource(data);
    var template = UriTemplateParser.parse_com_thoughtworks_microbuilder_core_UriTemplate(source);
    assertEquals(data.length, source.position);
    this.assertMatch(
      (_:Array<LiteralsOrExpression>) =>
      [
        LITERALS(UNRESERVED(97)),
        EXPRESSION(
          123,
          OP_LEVEL3(47),
          {
            first: { varname: { first: ALPHA(98), rest: (_:Array<DotVarchar>) =>[DOT_VARCHAR(46, ALPHA(99))] } },
            rest: (_:Array<CommaVarchar>) =>[]
          },
          125
        ),
        LITERALS(UNRESERVED(100))
      ],
      template
    );
  }

  public function test5() {
    var data = "a{/b.c,d,efg,1}3";
    var source = new StringSource(data);
    var template = UriTemplateParser.parse_com_thoughtworks_microbuilder_core_UriTemplate(source);
    assertEquals(data.length, source.position);
    this.assertMatch(
      (_:Array<LiteralsOrExpression>) =>
      [
        LITERALS(UNRESERVED(97)),
        EXPRESSION(
          123,
          OP_LEVEL3(47),
          {
            first: { varname: { first: ALPHA(98), rest: (_:Array<DotVarchar>) =>[DOT_VARCHAR(46, ALPHA(99))] } },
            rest: (_:Array<CommaVarchar>) =>[
              COMMA_VARSPEC(44, { varname: { first: ALPHA(100), rest: (_:Array<DotVarchar>) =>[] }}),
              COMMA_VARSPEC(44, {
                varname: {
                  first: ALPHA(101),
                  rest: (_:Array<DotVarchar>) =>[
                    DOT_VARCHAR(null, ALPHA(102)),
                    DOT_VARCHAR(null, ALPHA(103))
                  ]
                }
              }),
              COMMA_VARSPEC(44, { varname: { first: DIGIT(49), rest: (_:Array<DotVarchar>) =>[] }}),
            ]
          },
          125
        ),
        LITERALS(UNRESERVED(51))]
      ,
      template
    );
  }

}