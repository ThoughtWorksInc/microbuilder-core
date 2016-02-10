package com.thoughtworks.microbuilder.core;

import haxe.ds.Option;
import haxe.macro.Printer;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import com.thoughtworks.microbuilder.core.uriTemplate.UriTemplate;
import autoParser.StringBuffer;
import haxe.macro.PositionTools;
import haxe.macro.MacroStringTools;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
import autoParser.AutoFormatter;
import autoParser.AutoParser;
import autoParser.StringSource;
import hamu.Naming.*;
import hamu.ExprEvaluator;

using Lambda;

class RouteConfigurationFactory {

  static function generateUriParametersClassName(prefix:String, pack:Array<String>, className:String, methodName:String):String {
    var sb = new StringBuf();
    sb.add(prefix);
    sb.add("_UriParameters_");
    for (p in pack) {
      processName(sb, p);
      sb.add("_");
    }
    processName(sb, className);
    sb.add("_");
    processName(sb, methodName);
    return sb.toString();
  }

  static function parseMethodName(pack:Array<String>, name:String):String {
    var sb = new StringBuf();
    sb.add("parse_");
    for (p in pack) {
      processName(sb, p);
      sb.add("_");
    }
    processName(sb, name);
    return sb.toString();
  }

  static function formatMethodName(pack:Array<String>, name:String):String {
    var sb = new StringBuf();
    sb.add("format_");
    for (p in pack) {
      processName(sb, p);
      sb.add("_");
    }
    processName(sb, name);
    return sb.toString();
  }

  static function generatedMethodName(pack:Array<String>, name:String):String {
    var sb = new StringBuf();
    sb.add("routeConfiguration_");
    for (p in pack) {
      processName(sb, p);
      sb.add("_");
    }
    processName(sb, name);
    return sb.toString();
  }

  static function generatedFieldName(path:Array<String>):String {
    var sb = new StringBuf();
    sb.add("variable_");
    processName(sb, path[0]);
    for (i in 1...path.length) {
      sb.add("_");
      processName(sb, path[i]);
    }
    return sb.toString();
  }

#if macro

  static function generateFields(includeModules:Array<String>, factoryModule:String, className:String):Array<Field> return {
    var seed = 0;
    var parserModule = '${factoryModule}_UriParametersParser';
    var parserExpr = MacroStringTools.toFieldExpr(parserModule.split("."));
    var formatterModule = '${factoryModule}_UriParametersFormatter';
    var formatterExpr = MacroStringTools.toFieldExpr(formatterModule.split("."));
    var uriTemplatesModule = '${factoryModule}_UriParameters';
    var uriTemplatesModuleName = uriTemplatesModule.substring(uriTemplatesModule.lastIndexOf(".") + 1);
    var generatingPack = factoryModule.split(".");
    generatingPack.pop();
    var modulePath = MacroStringTools.toFieldExpr(factoryModule.split("."));
    var thisClassExpr = macro $modulePath.$className;
    var fields = [];
    var uriParametersDefinitions:Array<TypeDefinition> = [];
    var structuralFailureExpr:Expr;
    for (moduleName in includeModules) {
      for (rootType in Context.getModule(moduleName)) {
        switch (rootType) {
          case TInst(_.get() => classType, args) if (classType.isInterface): {
            structuralFailureExpr = switch classType.meta.extract(":structuralFailure") {
              case []:
                macro null;
              case [ { params: [ expr ] } ]:
                expr;
              case entries:
                throw Context.error("Expect @:structuralFailure(packageName.FailureClassName)", entries[0].pos);

            }
            var methodName = generatedMethodName(classType.pack, classType.name);
            var keyValues = [];
            for (field in classType.fields.get()) {
              switch field.kind {
                case FVar(_, _): {
                  continue;
                }
                case FMethod(_): {
                  var fieldName = field.name;
                  switch field.meta.extract(":route") {
                    case []: {
                      continue;
                    }
                    case [
                      {
                        params: [
                          (ExprEvaluator.evaluate(_):String) => httpMethod,
                          (ExprEvaluator.evaluate(_):String) => uriTemplateText
                        ]
                      }
                    ]: {
                      var requestContentType = switch field.meta.extract(":requestContentType") {
                        case []:
                          null;
                        case [ { params: [ (ExprEvaluator.evaluate(_):String) => contentType ] } ]:
                          contentType;
                        case entries:
                          throw Context.error("Expect @:requestContentType(\"some/mime.type\")", entries[0].pos);
                      }
                      var responseContentType = switch field.meta.extract(":responseContentType") {
                        case []:
                          null;
                        case [ { params: [ (ExprEvaluator.evaluate(_):String) => contentType ] } ]:
                          contentType;
                        case entries:
                          throw Context.error("Expect @:responseContentType(\"some/mime.type\")", entries[0].pos);
                      }
                      var source = new StringSource(uriTemplateText);
                      var variableMap = new VariableMap();
                      var requestHeaderMetas = field.meta.extract(":requestHeader");
                      var headersLength = requestHeaderMetas.length;
                      for (i in 0...requestHeaderMetas.length) {
                        switch requestHeaderMetas[i] {
                        case { params: [ { expr: EConst(CString(headerName)) }, { expr: EConst(CString(staticHeaderValue)) } ] }:
                          // macro __headers[$v{i}] = new com.thoughtworks.microbuilder.core.IRouteConfiguration.Header($v{headerName}, $v{staticHeaderValue});
                        case { params: [ { expr: EConst(CString(headerName)) }, expr ] }:
                          var headerPath = {
                            var buf = [];
                            function buildPlainName(expr:Expr):Void {
                              switch expr {
                              case { expr: EConst(CIdent(ident)) }:
                                buf.push(ident);
                              case { expr: EField(parent, field) }:
                                buildPlainName(parent);
                                buf.push(field);
                              default:
                                throw Context.error("Expect @:requestHeader(\"Your-Header-Name\", \"Your-Header-Value\") or @:requestHeader(\"Your-Header-Name\", yourParameterName)", expr.pos);
                              }
                            }
                            buildPlainName(expr);
                            buf;
                          }

                          var headerDeclaration = new HeaderDeclaration();
                          headerDeclaration.index = i;
                          headerDeclaration.name = headerName;

                          function insertToVariableMap(level:Int, map:VariableMap):Void {
                            var element = headerPath[level];
                            var nextLevel = level + 1;
                            var node = switch map.get(element) {
                              case null:
                                var newNode = new VariableNode();
                                map.set(element, newNode);
                                newNode;
                              case node:
                                node;
                            }
                            if (nextLevel < headerPath.length) {
                              insertToVariableMap(nextLevel, node.submap);
                            } else {
                              node.headers.push(headerDeclaration);
                            }
                          }
                          insertToVariableMap(0, variableMap);
                        case requestHeader:
                          throw Context.error("Expect @:requestHeader(\"Your-Header-Name\", \"Your-Header-Value\") or @:requestHeader(\"Your-Header-Name\", yourParameterName)", requestHeader.pos);
                        }
                      }

                      var uriTemplate:Array<LiteralsOrExpression> = UriTemplateParser.parse_com_thoughtworks_microbuilder_core_uriTemplate_UriTemplate(source);
                      var uriParameterName = generateUriParametersClassName(className, classType.pack, classType.name, fieldName);
                      var uriParameterFields:Array<Field> = [{
                        name: "new",
                        pos: PositionTools.here(),
                        access: [ APublic ],
                        kind: FFun(
                          {
                            args: [],
                            ret: null,
                            expr: macro {}
                          }
                        )
                      }
                      ];
                      for (i in 0...uriTemplate.length) {
                        switch uriTemplate[i] {
                          case LITERALS(literals):
                            uriParameterFields.push({
                              name: 'character_$i',
                              pos: PositionTools.here(),
                              access: [ APublic ],
                              kind: FProp("get", "set", macro : com.thoughtworks.microbuilder.core.uriTemplate.UriTemplate.Literals, null)
                            });
                            uriParameterFields.push({
                              name: 'set_character_$i',
                              pos: PositionTools.here(),
                              kind: FFun(
                                {
                                  args: [ { name: "value", type: macro : com.thoughtworks.microbuilder.core.uriTemplate.UriTemplate.Literals } ],
                                  ret: macro : com.thoughtworks.microbuilder.core.uriTemplate.UriTemplate.Literals,
                                  expr: macro return switch value {
                                    case $v{literals}: value;
                                    default: null;
                                  }
                                }
                              )
                            });
                            uriParameterFields.push({
                              name: 'get_character_$i',
                              pos: PositionTools.here(),
                              kind: FFun(
                                {
                                  args: [ ],
                                  ret: macro : com.thoughtworks.microbuilder.core.uriTemplate.UriTemplate.Literals,
                                  expr: macro return $v{literals}
                                }
                              )
                            });
                          case EXPRESSION(_, operator, variableList, _):
                            switch operator {
                              case null:
                                switch variableList.rest {
                                  case []:
                                    var varspec = variableList.first;

                                    if (varspec.modifierLevel4 != null) {
                                      // TODO: Level 4
                                      throw "Level 1-3 templates does not support modifiers.";
                                    }
                                    var buffer = new StringBuffer();
                                    UriTemplateFormatter.format_com_thoughtworks_microbuilder_core_uriTemplate_Varname(buffer, varspec.varname);
                                    var varname = buffer.toString();
                                    var variablePath = varname.split(".");
                                    var variablePlainName = '${generatedFieldName(variablePath)}_${seed++}';
                                    var variableDeclaration = new VariableDeclaration();
                                    variableDeclaration.plainName = variablePlainName;
                                    variableDeclaration.modifierLevel4 = varspec.modifierLevel4;
                                    function insertToVariableMap(level:Int, map:VariableMap):Void {
                                      var element = variablePath[level];
                                      var nextLevel = level + 1;
                                      var node = switch map.get(element) {
                                        case null:
                                          var newNode = new VariableNode();
                                          map.set(element, newNode);
                                          newNode;
                                        case node:
                                          node;
                                      }
                                      if (nextLevel < variablePath.length) {
                                        insertToVariableMap(nextLevel, node.submap);
                                      } else {
                                        node.values.push(variableDeclaration);
                                      }
                                    }
                                    insertToVariableMap(0, variableMap);
                                    uriParameterFields.push({
                                      access: [ APublic ],
                                      name: variablePlainName,
                                      pos: PositionTools.here(),
                                      kind: FVar(macro : com.thoughtworks.microbuilder.core.uriTemplate.UriTemplate.SimpleStringExpansion, null)
                                    });
                                    // TODO:
                                  default:
                                    // TODO: Level 3-4
                                    throw "Level 1-2 templates are limited to a single varspec per expression.";
                                }

                              default:
                                // TODO: Level 2-4
                                throw "Level 1 templates does not support operator: ${String.fromCharCode(operator)}";
                            }
                        }
                      }
                      var uriParameterDefinition:TypeDefinition = {
                        pack: generatingPack,
                        name: uriParameterName,
                        pos: PositionTools.here(),
                        kind: TDClass(),
                        meta: [ { pos: PositionTools.here(), name: ":dox", params: [ macro hide ] } ],
                        fields: uriParameterFields
                      }
                      uriParametersDefinitions.push(uriParameterDefinition);
                      //trace(new haxe.macro.Printer().printTypeDefinition(uriParameterDefinition));
                      var generatingFormatMethodName = formatMethodName(generatingPack, uriParameterName);
                      var generatingParseMethodName = parseMethodName(generatingPack, uriParameterName);
                      var uriParametersTypePath = {
                        pack: generatingPack,
                        name: uriTemplatesModuleName,
                        sub: uriParameterName
                      };
                      var args = switch field.type {
                        case TFun(args, _):
                          args;
                        default:
                          throw "Expect function";
                      }
                      var numberOfUriParameters = if (requestContentType == null) {
                        args.length;
                      } else {
                        args.length - 1;
                      }
                      function fillFromJsonStream(variableNode:Null<VariableNode>, uriParametersExpr:Expr, jsonStream:Expr):Expr return {
                        if (variableNode == null) {
                          macro jsonStream.JsonDeserializer.JsonDeserializerRuntime.skip($jsonStream);
                        } else {
                          var fillNull = if (variableNode.submap.empty()) {
                            var blockExprs = [
                              for (varspec in variableNode.values) {
                                if (varspec.modifierLevel4 != null) {
                                  throw "Level 1-3 templates do not support modifiers.";
                                } else {
                                  var variablePlainName = varspec.plainName;
                                  macro $uriParametersExpr.$variablePlainName = null;
                                }
                              }
                            ];
                            var headerExprs = [
                              for (header in variableNode.headers) {
                                var index = header.index;
                                var name = header.name;
                                macro {
                                  __headers[$v{index}] = new com.thoughtworks.microbuilder.core.IRouteConfiguration.Header($v{name}, null);
                                }
                              }
                            ];
                            macro {
                              {$a{blockExprs}};
                              {$a{headerExprs}};
                            }
                          } else {
                            macro throw "Expect OBJECT"; // TODO: Exception definition.
                          }
                          var fillString = if (variableNode.submap.empty()) {
                            var blockExprs = [
                              for (varspec in variableNode.values) {
                                if (varspec.modifierLevel4 != null) {
                                  throw "Level 1-3 templates do not support modifiers.";
                                } else {
                                  var variablePlainName = varspec.plainName;
                                  macro $uriParametersExpr.$variablePlainName = __stringValue;
                                }
                              }
                            ];
                            var headerExprs = [
                              for (header in variableNode.headers) {
                                var index = header.index;
                                var name = header.name;
                                macro {
                                  __headers[$v{index}] = new com.thoughtworks.microbuilder.core.IRouteConfiguration.Header($v{name}, __stringValue);
                                }
                              }
                            ];
                            macro {
                              {$a{blockExprs}};
                              {$a{headerExprs}};
                            }
                          } else {
                            macro throw "Expect OBJECT"; // TODO: Exception definition.
                          }
                          var fillPair = if (variableNode.submap.empty()) {

                            macro {
                              __commaSeparated.push(__pair.key);
                              __commaSeparated.push(switch (__pair.value) {
                                case STRING(__stringValue):
                                  __stringValue;
                                case ARRAY(__elements):
                                  throw "Expect String"; // TODO: Exception definition.
                                case OBJECT(__pairs):
                                  throw "Expect String"; // TODO: Exception definition.
                                case NUMBER(__numberValue):
                                  Std.string(__numberValue);
                                case TRUE:
                                  "true";
                                case FALSE:
                                  "false";
                                case NULL:
                                  null;
                                case INT32(__intValue):
                                  Std.string(__intValue);
                                case INT64(__high, __low):
                                  haxe.Int64.toStr(haxe.Int64.make(__high, __low));
                                case BINARY(__bytes):
                                  __bytes.toString();
                              });
                            }
                          } else {
                            macro throw "Expect OBJECT"; // TODO: Exception definition.
                          }
                          var fillElement = if (variableNode.submap.empty()) {
                            macro __commaSeparated.push(switch (__element) {
                                case STRING(__stringValue):
                                  __stringValue;
                                case ARRAY(__elements):
                                  throw "Expect String"; // TODO: Exception definition.
                                case OBJECT(__pairs):
                                  throw "Expect String"; // TODO: Exception definition.
                                case NUMBER(__numberValue):
                                  Std.string(__numberValue);
                                case TRUE:
                                  "true";
                                case FALSE:
                                  "false";
                                case NULL:
                                  null;
                                case INT32(__intValue):
                                  Std.string(__intValue);
                                case INT64(__high, __low):
                                  haxe.Int64.toStr(haxe.Int64.make(__high, __low));
                                case BINARY(__bytes):
                                  __bytes.toString();
                              });
                          } else {
                            macro throw "Expect OBJECT"; // TODO: Exception definition.
                          }
                          var optionalCommaSeparatedDefinition = if (variableNode.values.length > 0 || variableNode.headers.length > 0) {
                            macro var __commaSeparated = [];
                          } else {
                            macro null;
                          }
                          var optionalCommaSeparatedResult = if (variableNode.values.length > 0 || variableNode.headers.length > 0) {
                            var blockExprs = [
                              for (varspec in variableNode.values) {
                                if (varspec.modifierLevel4 != null) {
                                  throw "Level 1-3 templates do not support modifiers.";
                                } else {
                                  var variablePlainName = varspec.plainName;
                                  macro $uriParametersExpr.$variablePlainName = __commaSeparatedString;
                                }
                              }
                            ];
                            var headerExprs = [
                              for (header in variableNode.headers) {
                                var index = header.index;
                                var name = header.name;
                                macro {
                                  __headers[$v{index}] = new com.thoughtworks.microbuilder.core.IRouteConfiguration.Header($v{name}, __commaSeparatedString);
                                }
                              }
                            ];
                            macro {
                              var __commaSeparatedString = __commaSeparated.join(",");
                              {$a{blockExprs}};
                              {$a{headerExprs}};
                            }
                          } else {
                            macro null;
                          }
                          macro {
                            inline function __fillStringValue(__stringValue:String):Void {
                              $fillString;
                            }
                            switch ($jsonStream) {
                              case STRING(__stringValue):
                                __fillStringValue(__stringValue);
                              case ARRAY(__elements):
                                if (!__elements.hasNext()) {
                                  $fillNull;
                                } else {
                                  $optionalCommaSeparatedDefinition;
                                  for (__element in __elements) {
                                    $fillElement;
                                  }
                                  $optionalCommaSeparatedResult;
                                }
                              case OBJECT(__pairs):
                                if (!__pairs.hasNext()) {
                                  $fillNull;
                                } else {
                                  $optionalCommaSeparatedDefinition;
                                  for (__pair in __pairs) {
                                    $fillPair; // TODO: nested objects
                                  }
                                  $optionalCommaSeparatedResult;
                                }
                              case NUMBER(__numberValue):
                                __fillStringValue(Std.string(__numberValue));
                              case TRUE:
                                __fillStringValue("true");
                              case FALSE:
                                __fillStringValue("false");
                              case NULL:
                                $fillNull;
                              case INT32(__intValue):
                                __fillStringValue(Std.string(__intValue));
                              case INT64(__high, __low):
                                __fillStringValue(haxe.Int64.toStr(haxe.Int64.make(__high, __low)));
                              case BINARY(__bytes):
                                __fillStringValue(__bytes.toString());
                            }
                          }
                        }
                      }
                      var fillingUriParameterExprs = [
                        for (i in 0...numberOfUriParameters) {
                          var arg = args[i];
                          var fillingExpr = fillFromJsonStream(variableMap.get(arg.name), macro __uriParameters, macro __jsonStream);
                          macro {
                            var __jsonStream = __parameterIterators.next();
                            $fillingExpr;
                          }
                        }
                      ];
//                      trace(new Printer().printExpr(macro {$a{fillingUriParameterExprs}}));
                      function extractingToJsonStream(variableNode:Null<VariableNode>, uriParametersExpr:Expr, yieldExpr:Expr):ExprOf<jsonStream.JsonStream> return {
                        if (variableNode == null) {
                          macro null; // Skip parameters that does not appear in URI template
                        } else {
                          function extracting(currentNode:VariableNode):ExprOf<jsonStream.JsonStream> return {
                            // 纯 varspec（有*） - 用* varspec 遍历，用* varspec 生成每一项，用其他 varspec 检查
                            // submap + varspec（有*） - 声明__handledValues，用* varspec 遍历，用* varspec 生成每一项，用其他 varspec 和 submap 检查，保证submap用尽

                            // submap + varspec（无限长度，无*） - 前置检查varspec，声明__handledValues，用无限长度的 varspec 遍历，用无限长度 varspec 生成每一项，用 submap 检查，保证submap用尽
                            // submap + varspec（有限长度，无*） - 前置检查varspec，声明__handledValues，用最长的 varspec 遍历，用最长的 varspec 生成每一项，用 submap 检查，补加submap或者保证submap用尽

                            // 纯 varspec（无*） - 生成字符串
                            // 纯 submap - 直接遍历

                            var handledValuesName = '__handledValues_${seed++}';
                            var yieldPairName = '__yields_${seed++}';

                            var nonExplodeVarspecOption = {
                              var nonExplodeVarspecs = [
                                for (varspec in currentNode.values) {
                                  if (varspec.modifierLevel4 == null || varspec.modifierLevel4.match(PREFIX(_))) {
                                    varspec;
                                  }
                                }
                              ];
                              if (nonExplodeVarspecs.empty()) {
                                None;
                              } else {
                                nonExplodeVarspecs.sort(function(left:VariableDeclaration, right:VariableDeclaration) return {
                                  function modifierPriority(modifier) return {
                                    switch modifier {
                                      case null: 0;
                                      case PREFIX(limit): limit;
                                      default: throw "Expect null or PREFIX";
                                    }
                                  }
                                  var leftModifierPriority = modifierPriority(left.modifierLevel4);
                                  var rightModifierPriority = modifierPriority(right.modifierLevel4);
                                  if (leftModifierPriority != rightModifierPriority) {
                                    leftModifierPriority - rightModifierPriority;
                                  } else {
                                    Reflect.compare(left.plainName, right.plainName);
                                  }
                                });
                                var nameId = seed++;
                                var hasFixedLengthName = '__hasFixedLength_$nameId';
                                var extractingValueName = '__extractingValue_$nameId';
                                var pairsName = '__pairs_$nameId';

                                Some({
                                  check: function(key:Expr, value:Expr):Expr return {
                                    throw "TODO:";
                                  },
                                  lastPair: function():{key:Expr, value:Expr} return {
                                    key: macro $i{pairsName}[$i{pairsName}.length - 2],
                                    value: macro $i{pairsName}[$i{pairsName}.length - 1]
                                  },
                                  yieldPairs: function(check:Expr->Expr->Expr):Array<Expr> return {
                                    [
                                      (macro var $pairsName:Array<String> = ($i{extractingValueName}:String).split(",")),
                                      switch nonExplodeVarspecs[0].modifierLevel4 {
                                        case null:
                                          macro if ($i{pairsName}.length % 2 == 1) {
                                            throw "Expect even number of elements!"; // TODO: Exception definition
                                          }
                                        case PREFIX(limit):
                                          macro if ($i{pairsName}.length % 2 == 1) {
                                            if ($i{hasFixedLengthName}) {
                                              throw "Expect even number of elements!"; // TODO: Exception definition
                                            }
                                          }
                                        default: throw "Expect null or PREFIX";
                                      },
                                      {
                                        var indexName = '__index_$nameId';
                                        var keyName = '__key_$nameId';
                                        var valueName = '__value_$nameId';
                                        var checkExpr = check(macro $i{keyName}, macro $i{valueName});
                                        macro for ($i{indexName} in 0...cast $i{pairsName}.length / 2) {
                                          var $keyName = $i{pairsName}[$i{indexName} * 2];
                                          var $valueName = $i{pairsName}[$i{indexName} * 2 + 1];
                                          $checkExpr;
                                          $i{handledValuesName}.set($i{keyName}, true);
                                          @await $i{yieldPairName}(new jsonStream.JsonStream.JsonStreamPair(
                                            $i{keyName},
                                            jsonStream.JsonStream.STRING($i{valueName})
                                          ));
                                        }
                                      }
                                    ];
                                  },
                                  merge: function():Array<Expr> return {
                                    var firstPlainName = nonExplodeVarspecs[0].plainName;
                                    var mergeExprs = [
                                      (macro var $extractingValueName = $uriParametersExpr.$firstPlainName),
                                    ];
                                    switch nonExplodeVarspecs[0].modifierLevel4 {
                                      case null:
                                        for (i in 1...nonExplodeVarspecs.length) {
                                          var plainName = nonExplodeVarspecs[i].plainName;
                                          switch nonExplodeVarspecs[i].modifierLevel4 {
                                            case null:
                                              mergeExprs.push(macro if ($uriParametersExpr.$plainName != $i{extractingValueName}) {
                                                throw "Illegal data"; // TODO: exception definition
                                              });
                                            case PREFIX(limit):
                                              mergeExprs.push(macro if (
                                                $uriParametersExpr.plainName.length <= $v{limit} &&
                                                $uriParametersExpr.plainName == $i{extractingValueName} ||
                                                $uriParametersExpr.plainName.length == $v{limit} &&
                                                StringTools.startsWith($i{extractingValueName}, $uriParametersExpr.plainName)
                                              ) {
                                                // Pass the test and do nothing
                                              } else {
                                                throw "Illegal data"; // TODO: exception definition
                                              });
                                            default: throw "Expect null or PREFIX";
                                          }
                                        }
                                        mergeExprs;
                                      case PREFIX(limit):
                                        mergeExprs.push(macro var $hasFixedLengthName = $i{extractingValueName}.length < $v{limit});
                                        for (i in 1...nonExplodeVarspecs.length) {
                                          var plainName = nonExplodeVarspecs[i].plainName;
                                          switch nonExplodeVarspecs[i].modifierLevel4 {
                                            case PREFIX(limit):
                                              mergeExprs.push(macro if (
                                                $uriParametersExpr.$plainName.length <= $v{limit} &&
                                                $uriParametersExpr.$plainName == $i{extractingValueName} ||
                                                $uriParametersExpr.$plainName.length == $v{limit} &&
                                                StringTools.startsWith($i{extractingValueName}, $uriParametersExpr.$plainName)
                                              ) {
                                                // Pass the test and do nothing
                                              } else {
                                                throw "Illegal data"; // TODO: exception definition
                                              });
                                            default: throw "Expect PREFIX";
                                          }
                                        }
                                        mergeExprs;
                                      default: throw "Expect PREFIX";
                                    }
                                  },
                                  jsonString: function():Expr return {
                                    macro jsonStream.JsonStream.STRING($i{extractingValueName});
                                  },
                                  hasFixedLength: function():Expr return {
                                    if (nonExplodeVarspecs[0].modifierLevel4 == null) {
                                      macro true;
                                    } else {
                                      macro $i{hasFixedLengthName};
                                    }
                                  }
                                });

                              }
                            }
                            var explodeVarspecOption = {
                              var explodeVarspec = currentNode.values.find(function(varspec) return {
                                varspec.modifierLevel4 != null && varspec.modifierLevel4.match(EXPLODE(_));
                              });
                              if (explodeVarspec != null) {
                                Some({
                                  yieldPairs: function(check:Expr->Expr->Expr):Expr return {
                                    throw "TODO:";
                                  }
                                });
                              } else {
                                None;
                              }
                            }
                            var submapOption = {
                              if (currentNode.submap.empty()) {
                                None;
                              } else {
                                Some({
                                  yieldPairs: function():Expr return {
                                    var yieldExprs = [
                                      for (key in currentNode.submap.keys()) {
                                        var subnode = currentNode.submap.get(key);
                                        var valueExpr = extracting(subnode);
                                        macro @await $i{yieldPairName}(new jsonStream.JsonStream.JsonStreamPair($v{key}, $valueExpr));
                                      }
                                    ];
                                    macro {$a{yieldExprs}}
                                  },
                                  check: function(checkingKey:Expr, checkingValue:Expr):Expr return {
                                    var cases = [
                                      for (key in currentNode.submap.keys()) {
                                        values: [ macro $v{key} ],
                                        guard: null,
                                        expr: {
                                          var subnode = currentNode.submap.get(key);
                                          var valueExpr = extracting(subnode);
                                          macro switch ($valueExpr) {
                                            case jsonStream.JsonStream.STRING(__value) if (__value == $checkingValue):
                                            default:
                                              throw "Bad data!"; // TODO: Exception definition
                                          }
                                        }
                                      }
                                    ];
                                    {
                                      pos: PositionTools.here(),
                                      expr: ESwitch(
                                        checkingKey,
                                        cases,
                                        null
                                      )
                                    }
                                  },
                                  yieldMorePairs: function(lastKey:Expr, lastValue:Expr):Expr return {
                                    var cases = [
                                      for (key in currentNode.submap.keys()) {
                                        values: [ macro $v{key} ],
                                        guard: null,
                                        expr: {
                                          var subnode = currentNode.submap.get(key);
                                          var valueExpr = extracting(subnode);
                                          macro switch ($valueExpr) {
                                            case jsonStream.JsonStream.STRING(__value) if (StringTools.startsWith(__value, $lastValue)):
                                              $i{handledValuesName}.set($lastKey, true);
                                              @await $i{yieldPairName}(new jsonStream.JsonStream.JsonStreamPair($v{key}, $valueExpr));
                                            default:
                                              throw "Bad data!"; // TODO: Exception definition
                                          }
                                        }
                                      }
                                    ];
                                    var yieldMorePairsExpr = [
                                      for (key in currentNode.submap.keys()) {
                                        var subnode = currentNode.submap.get(key);
                                        var valueExpr = extracting(subnode);
                                        macro if (!$i{handledValuesName}.exists($v{key})) {
                                          @await $i{yieldPairName}(new jsonStream.JsonStream.JsonStreamPair($v{key}, $valueExpr));
                                        }
                                      }
                                    ];
                                    var switchLastKeyExpr = {
                                      pos: PositionTools.here(),
                                      expr: ESwitch(
                                        lastKey,
                                        cases,
                                        macro @await $i{yieldPairName}(new jsonStream.JsonStream.JsonStreamPair(
                                          $lastKey,
                                          jsonStream.JsonStream.STRING($lastValue)
                                        ))
                                      )
                                    }
                                    macro {
                                      if ($lastValue == null) {
                                        @await $i{yieldPairName}(new jsonStream.JsonStream.JsonStreamPair(
                                          $lastKey + " (incomplete)",
                                          jsonStream.JsonStream.NULL
                                        ));
                                      } else {
                                        $switchLastKeyExpr;
                                      }
                                      {$a{yieldMorePairsExpr}}
                                    }
                                  },
                                  ensureNoMorePairs: function():Expr return {
                                    var ensureNoMorePairsExprs = [
                                      for (key in currentNode.submap.keys()) {
                                        macro if (!$i{handledValuesName}.exists($v{key})) {
                                          throw "Bad data"; // TODO: Excpetion definition
                                        }
                                      }
                                    ];
                                    macro {$a{ensureNoMorePairsExprs}}
                                  }
                                });
                              }
                            }
                            function declareHandledValues():Expr return {
                              (macro var $handledValuesName = new haxe.ds.StringMap<Bool>());
                            }
                            function createJsonObject(yieldPairsExpr:Expr):Expr return {
                              macro jsonStream.JsonStream.OBJECT(
                                new com.dongxiguo.continuation.utils.Generator<jsonStream.JsonStream.JsonStreamPair>(
                                  com.dongxiguo.continuation.Continuation.cpsFunction(
                                    function ($yieldPairName:com.dongxiguo.continuation.utils.Generator.YieldFunction<jsonStream.JsonStream.JsonStreamPair>) {
                                      $yieldPairsExpr;
                                    }
                                  )
                                )
                              );
                            }

                            switch [nonExplodeVarspecOption, explodeVarspecOption, submapOption ] {
                              case [ None, None, None]:
                                macro jsonStream.JsonStream.NULL;
                              case [ Some(nonExplodeVarspecGenerator), None, None]:
                                // varspec without explode
                                var exprs = nonExplodeVarspecGenerator.merge().concat([
                                  nonExplodeVarspecGenerator.jsonString()
                                ]);
                                macro {$a{exprs}}
                              case [ nonExplodeVarspecOption, Some(explodeVarspecGenerator), None]:
                                // Only varspec with explode
                                var exprs = (switch nonExplodeVarspecOption {
                                  case Some(nonExplodeVarspecGenerator):
                                    nonExplodeVarspecGenerator.merge();
                                  case None:
                                    [];
                                }).concat([
                                  declareHandledValues(),
                                  explodeVarspecGenerator.yieldPairs(function(key:Expr, value:Expr) return {
                                    switch nonExplodeVarspecOption {
                                      case Some(nonExplodeVarspecGenerator):
                                        nonExplodeVarspecGenerator.check(key, value);
                                      case None:
                                        macro null;
                                    }
                                  })
                                ]);
                                createJsonObject(macro {$a{exprs}});
                              case [ nonExplodeVarspecOption, Some(explodeVarspecGenerator), Some(submapGenerator)]:
                                // submap + varspec with explode
                                var exprs = (switch nonExplodeVarspecOption {
                                  case Some(nonExplodeVarspecGenerator):
                                    nonExplodeVarspecGenerator.merge();
                                  case None:
                                    [];
                                }).concat([
                                  declareHandledValues(),
                                  explodeVarspecGenerator.yieldPairs(function(key, value) return {
                                    switch nonExplodeVarspecOption {
                                      case Some(nonExplodeVarspecGenerator):
                                        var check0Expr = submapGenerator.check(key, value);
                                        var check1Expr = nonExplodeVarspecGenerator.check(key, value);
                                        macro {
                                          $check0Expr;
                                          $check1Expr;
                                        }
                                      case None:
                                        submapGenerator.check(key, value);
                                    }
                                  }),
                                  submapGenerator.ensureNoMorePairs()
                                ]);
                                createJsonObject(macro {$a{exprs}});
                              case [ Some(nonExplodeVarspecGenerator), None, Some(submapGenerator)]:
                                // submap + varspec without explode
                                var declareExprs = nonExplodeVarspecGenerator.merge();
                                var hasFixedLengthExpr = nonExplodeVarspecGenerator.hasFixedLength();
                                var yieldMorePairsExpr = switch nonExplodeVarspecGenerator.lastPair() {
                                  case {key:key, value:value}:
                                    submapGenerator.yieldMorePairs(key, value);
                                }
                                var ensureNoMorePairsExpr = submapGenerator.ensureNoMorePairs();
                                var exprs = declareExprs.concat([
                                  declareHandledValues()
                                ]).concat(
                                  nonExplodeVarspecGenerator.yieldPairs(submapGenerator.check.bind())
                                ).concat([
                                  macro if ($hasFixedLengthExpr) {
                                    $ensureNoMorePairsExpr;
                                  } else {
                                    $yieldMorePairsExpr;
                                  }
                                ]);
                                createJsonObject(macro {$a{exprs}});
                              case [ None, None, Some(submapGenerator)]:
                                // Only submap
                                createJsonObject(submapGenerator.yieldPairs());
                            }
                          }
                          extracting(variableNode);
                        }
                      }
                      var yieldParameterName = '__yieldParameter_${seed++}';
                      var extractingUriParameterExprs = [
                        for (i in 0...numberOfUriParameters) {
                          var arg = args[i];
                          var parameterJsonStream = extractingToJsonStream(variableMap.get(arg.name), macro __uriParameters, macro __yield);
                          macro @await $i{yieldParameterName}($parameterJsonStream);
                        }
                      ];
//                      trace(new Printer().printExpr(macro {$a{extractingUriParameterExprs}}));
                      function exprStringMap(data:StringMap<String>):ExprOf<StringMap<String>> return {
                        if (data.empty()) {
                          macro new haxe.ds.StringMap<String>();
                        } else {
                          var keyValues = [
                            for (key in data.keys()) {
                              var value = data.get(key);
                              macro $v{key} => $v{value};
                            }
                          ];
                          macro [ $a{keyValues} ];
                        }
                      }
                      // var staticRequestHeadersExpr = exprStringMap(staticRequestHeaders);
                      // var dynamicRequestHeadersExpr = exprStringMap(dynamicRequestHeaders);
                      // TODO: request header


                      var fillingStaticHeaders = [
                        for (i in 0...requestHeaderMetas.length) {
                          switch requestHeaderMetas[i] {
                          case { params: [ { expr: EConst(CString(headerName)) }, { expr: EConst(CString(staticHeaderValue)) } ] }:
                            macro __headers[$v{i}] = new com.thoughtworks.microbuilder.core.IRouteConfiguration.Header($v{headerName}, $v{staticHeaderValue});
                          case { params: [ { expr: EConst(CString(headerName)) }, _ ] }:
                            macro null;
                          case requestHeader:
                            throw Context.error("Expect @:requestHeader(\"Your-Header-Name\", \"Your-Header-Value\") or @:requestHeader(\"Your-Header-Name\", yourParameterName)", requestHeader.pos);
                          }
                        }
                      ];

                      //
                      //
                      // var dynamicRequestHeaders = new StringMap<String>();
                      // var staticRequestHeaders = new StringMap<String>();
                      // for (requestHeader in field.meta.extract(":requestHeader")) {
                      //   switch requestHeader {
                      //   case { params: [ { expr: EConst(CString(headerName)) }, { expr: EConst(CString(staticHeaderValue)) } ] }:
                      //     staticRequestHeaders.set(headerName, staticHeaderValue);
                      //   case { params: [ { expr: EConst(CString(headerName)) }, { expr: EConst(CIdent(dynamicHeaderValue)) } ] }:
                      //     dynamicRequestHeaders.set(headerName, dynamicHeaderValue);
                      //   default:
                      //     throw Context.error("Expect @:requestHeader(\"Your-Header-Name\", \"Your-Header-Value\") or @:requestHeader(\"Your-Header-Name\", yourParameterName)", requestHeader.pos);
                      //   }
                      // }
                      var bodyExpr = if (requestContentType != null) {
                        macro __parameterIterators.next();
                      } else {
                        macro null;
                      }
                      keyValues.push(
                        macro $v{fieldName} =>
                        new com.thoughtworks.microbuilder.core.GeneratedRouteConfiguration.GeneratedRouteEntry(
                          $v{httpMethod},
                          function(__parameterIterators:Iterator<jsonStream.JsonStream>):com.thoughtworks.microbuilder.core.IRouteConfiguration.Request return {
                            var __headers = new haxe.ds.Vector<com.thoughtworks.microbuilder.core.IRouteConfiguration.Header>($v{headersLength});
                            var __uriParameters = new $uriParametersTypePath();
                            {$a{fillingUriParameterExprs}}
                            var __buffer = new autoParser.StringBuffer();
                            $formatterExpr.$generatingFormatMethodName(__buffer, __uriParameters);
                            {$a{fillingStaticHeaders}}
                            new com.thoughtworks.microbuilder.core.IRouteConfiguration.Request(
                              $v{httpMethod},
                              __buffer.toString(),
                              __headers,
                              $bodyExpr,
                              $v{requestContentType},
                              $v{responseContentType}
                            );
                          },
                          $v{requestContentType},
                          $v{responseContentType},
                          function(__uri:String):Null<com.thoughtworks.microbuilder.core.GeneratedRouteConfiguration.UriData> return {
                            var __source = new autoParser.StringSource(__uri);
                            var __uriParameters = $parserExpr.$generatingParseMethodName(__source);
                            if (__uriParameters == null || __source.position != __uri.length) {
                              null;
                            } else {
                              var __result = new com.thoughtworks.microbuilder.core.GeneratedRouteConfiguration.UriData();
                              __result.parameters = com.dongxiguo.continuation.Continuation.cpsFunction(
                                function($yieldParameterName:com.dongxiguo.continuation.utils.Generator.YieldFunction<jsonStream.JsonStream>) {$a{extractingUriParameterExprs}}
                              );
                              __result.methodName = $v{fieldName};
                              __result;
                            }
                          }
                        )
                      );
                    }
                    case [ metaEntry ]: {
                      throw Context.error("Expect @:route(\"httpMethod\", \"uriTemplate\")", metaEntry.pos);
                    }
                    case multipleEntries: {
                      throw Context.error("Expect only one @:route(\"httpMethod\", \"uriTemplate\")", multipleEntries[multipleEntries.length - 1].pos);
                    }
                  }
                }
              }
            }
            var mapExpr = if (keyValues.length == 0) {
              macro new haxe.ds.StringMap<com.thoughtworks.microbuilder.core.GeneratedRouteConfiguration.GeneratedRouteEntry>();
            } else {
              macro [ $a{keyValues} ];
            }
            fields.push({
              name: methodName,
              access: [APublic, AStatic],
              pos: PositionTools.here(),
              kind : FFun({
                args: [],
                ret: macro : com.thoughtworks.microbuilder.core.IRouteConfiguration,
                expr: macro return new com.thoughtworks.microbuilder.core.GeneratedRouteConfiguration(
                  $mapExpr,
                  com.thoughtworks.microbuilder.core.GeneratedRouteConfiguration.getTypeName($structuralFailureExpr))
              })
            });
          }
          case _: {
            continue;
          }
        }
      }
    }
    Context.defineModule(uriTemplatesModule, uriParametersDefinitions);
    AutoParser.BUILDER.lazyDefineClass(
      [ '${factoryModule}_UriParameters' ],
      parserModule,
      null,
      [
        {
          pos: PositionTools.here(),
          name: ":dox",
          params: [ macro hide ]
        }
      ]
    );
    AutoFormatter.BUILDER.lazyDefineClass(
      [ '${factoryModule}_UriParameters' ],
      formatterModule,
      null,
      [
        {
          pos: PositionTools.here(),
          name: ":dox",
          params: [ macro hide ]
        }
      ]
    );
    fields;
  }

#end

  @:noUsing
  macro public static function generateRouteConfigurationFactory(includeModules:Array<String>):Array<Field> return {
    var localClass = Context.getLocalClass().get();
    Context.getBuildFields().concat(generateFields(includeModules, localClass.module, localClass.name));
  }
}

private typedef VariableMap = StringMap<VariableNode>;

@:final
private class VariableDeclaration {
  public function new() {}

  public var plainName:String;

  public var modifierLevel4:Null<ModifierLevel4>;

}

@:final
private class HeaderDeclaration {

  public function new() {}

  public var index:Int;

  public var name:String;

}

private class VariableNode {

  public function new() {}

  public var submap:VariableMap = new VariableMap();

  public var values:Array<VariableDeclaration> = [];

  public var headers:Array<HeaderDeclaration> = [];

}
