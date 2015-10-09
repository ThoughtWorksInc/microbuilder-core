package com.thoughtworks.restRpc.core;
import haxe.macro.Printer;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import com.thoughtworks.restRpc.core.UriTemplate;
import com.dongxiguo.autoParser.StringBuffer;
import haxe.macro.PositionTools;
import haxe.macro.MacroStringTools;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
import com.dongxiguo.autoParser.AutoFormatter;
import com.dongxiguo.autoParser.AutoParser;
import com.dongxiguo.autoParser.StringSource;
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

  static function fields(includeModules:Array<String>, factoryModule:String, className:String):Array<Field> return {
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
                      var contentType = switch field.meta.extract(":contentType") {
                        case []:
                          null;
                        case [ { params: [ (ExprEvaluator.evaluate(_):String) => contentType ] } ]:
                          contentType;
                        case entries:
                          throw Context.error("Expect @:contentType(\"some/mime.type\")", entries[0].pos);
                      }
                      var source = new StringSource(uriTemplateText);
                      var variableMap = new VariableMap();
                      var uriTemplate:Array<LiteralsOrExpression> = UriTemplateParser.parse_com_thoughtworks_restRpc_core_UriTemplate(source);
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
                              kind: FProp("get", "set", macro : com.thoughtworks.restRpc.core.UriTemplate.Literals, null)
                            });
                            uriParameterFields.push({
                              name: 'set_character_$i',
                              pos: PositionTools.here(),
                              kind: FFun(
                                {
                                  args: [ { name: "value", type: macro : com.thoughtworks.restRpc.core.UriTemplate.Literals } ],
                                  ret: macro : com.thoughtworks.restRpc.core.UriTemplate.Literals,
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
                                  ret: macro : com.thoughtworks.restRpc.core.UriTemplate.Literals,
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
                                    UriTemplateFormatter.format_com_thoughtworks_restRpc_core_Varname(buffer, varspec.varname);
                                    var varname = buffer.toString();
                                    var variablePath = varname.split(".");
                                    var variableFieldName = generatedFieldName(variablePath);
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
                                        node.values.push(varspec);
                                      }
                                    }
                                    insertToVariableMap(0, variableMap);
                                    uriParameterFields.push({
                                      access: [ APublic ],
                                      name: variableFieldName,
                                      pos: PositionTools.here(),
                                      kind: FVar(macro : com.thoughtworks.restRpc.core.UriTemplate.SimpleStringExpansion, null)
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
                        fields: uriParameterFields
                      }
                      uriParametersDefinitions.push(uriParameterDefinition);
                      //trace(new haxe.macro.Printer().printTypeDefinition(uriParameterDefinition));
                      var generatingFormatMethodName = formatMethodName(generatingPack, uriParameterName);
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
                      var numberOfUriParameters = if (contentType == null) {
                        args.length;
                      } else {
                        args.length - 1;
                      }
                      function fillFromJsonStream(variableNode:Null<VariableNode>, jsonStream:Expr):Expr return {
                        if (variableNode == null) {
                          macro com.qifun.jsonStream.JsonDeserializer.JsonDeserializerRuntime.skip($jsonStream);
                        } else {
                          function generatedVariableFieldName(varnameAst:Varname):String return {
                            var buffer = new StringBuffer();
                            UriTemplateFormatter.format_com_thoughtworks_restRpc_core_Varname(buffer, varnameAst);
                            var varname = buffer.toString();
                            var variablePath = varname.split(".");
                            generatedFieldName(variablePath);
                          }
                          var fillNull = if (variableNode.submap.empty()) {
                            var blockExprs = [
                              for (varspec in variableNode.values) {
                                if (varspec.modifierLevel4 != null) {
                                  throw "Level 1-3 templates do not support modifiers.";
                                } else {
                                  var variableFieldName = generatedVariableFieldName(varspec.varname);
                                  macro __uriParameters.$variableFieldName = null;
                                }
                              }
                            ];
                            macro {$a{blockExprs}}; // TODO
                          } else {
                            macro throw "Expect OBJECT"; // TODO: Exception definition.
                          }
                          var fillString = if (variableNode.submap.empty()) {
                            var blockExprs = [
                              for (varspec in variableNode.values) {
                                if (varspec.modifierLevel4 != null) {
                                  throw "Level 1-3 templates do not support modifiers.";
                                } else {
                                  var variableFieldName = generatedVariableFieldName(varspec.varname);
                                  macro __uriParameters.$variableFieldName = __stringValue;
                                }
                              }
                            ];
                            macro {$a{blockExprs}}; // TODO
                          } else {
                            macro throw "Expect OBJECT"; // TODO: Exception definition.
                          }
                          var fillPair = if (variableNode.submap.empty()) {
                            var blockExprs = [
                              for (varspec in variableNode.values) {
                                if (varspec.modifierLevel4 != null) {
                                  throw "Level 1-3 templates do not support modifiers.";
                                } else {
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
                                        $fillNull;
                                      case INT32(__intValue):
                                        Std.string(__intValue);
                                      case INT64(__high, __low):
                                        haxe.Int64.toStr(haxe.Int64.make(__high, __low));
                                      case BINARY(__bytes):
                                        __bytes.toString();
                                    });
                                  }
                                }
                              }
                            ];
                            macro {$a{blockExprs}}; // TODO
                          } else {
                            macro throw "Expect OBJECT"; // TODO: Exception definition.
                          }
                          var fillElement = if (variableNode.submap.empty()) {
                            var blockExprs = [
                              for (varspec in variableNode.values) {
                                if (varspec.modifierLevel4 != null) {
                                  throw "Level 1-3 templates do not support modifiers.";
                                } else {
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
                                        $fillNull;
                                      case INT32(__intValue):
                                        Std.string(__intValue);
                                      case INT64(__high, __low):
                                        haxe.Int64.toStr(haxe.Int64.make(__high, __low));
                                      case BINARY(__bytes):
                                        __bytes.toString();
                                    });
                                }
                              }
                            ];
                            macro {$a{blockExprs}}; // TODO
                          } else {
                            macro throw "Expect OBJECT"; // TODO: Exception definition.
                          }
                          var optionalCommaSeparatedResult = if (variableNode.values.length > 0) {
                            macro var __commaSeparated = [];
                          } else {
                            macro null;
                          }
                          var optionalCommaSeparatedDefinition = if (variableNode.values.length > 0) {
                            macro var __commaSeparated = [];
                          } else {
                            macro null;
                          }
                          var optionalCommaSeparatedResult = if (variableNode.values.length > 0) {
                            var blockExprs = [
                              for (varspec in variableNode.values) {
                                if (varspec.modifierLevel4 != null) {
                                  throw "Level 1-3 templates do not support modifiers.";
                                } else {
                                  var variableFieldName = generatedVariableFieldName(varspec.varname);
                                  macro __uriParameters.$variableFieldName = __commaSeparated.join(",");
                                }
                              }
                            ];
                            macro {$a{blockExprs}}; // TODO
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
                                    $fillPair;
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
                      var fillingExprs = [
                        for (i in 0...numberOfUriParameters) {
                          var arg = args[i];
                          var fillingExpr = fillFromJsonStream(variableMap.get(arg.name), macro __jsonStream);
                          macro {
                            var __jsonStream = __parameterIterators.next();
                            $fillingExpr;
                          }
                        }
                      ];
//                      trace(new Printer().printExpr(macro {$a{fillingExprs}}));
                      keyValues.push(
                        macro $v{fieldName} =>
                        (
                          new com.thoughtworks.restRpc.core.GeneratedRouteConfiguration.GeneratedUriTemplate(
                            $v{httpMethod},
                            function(__parameterIterators:Iterator<com.qifun.jsonStream.JsonStream>):String return {
                              var __uriParameters = new $uriParametersTypePath();
                              {$a{fillingExprs}}
                              var __buffer = new com.dongxiguo.autoParser.StringBuffer();
                              $formatterExpr.$generatingFormatMethodName(__buffer, __uriParameters);
                              __buffer.toString();
                            }
                          ) : com.thoughtworks.restRpc.core.IRouteConfiguration.IUriTemplate
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
              macro new haxe.ds.StringMap<com.thoughtworks.restRpc.core.IRouteConfiguration.IUriTemplate>();
            } else {
              macro [ $a{keyValues} ];
            }
            fields.push({
              name: methodName,
              access: [APublic, AStatic],
              pos: PositionTools.here(),
              kind : FFun({
                args: [],
                ret: macro : com.thoughtworks.restRpc.core.IRouteConfiguration,
                expr: macro return new com.thoughtworks.restRpc.core.GeneratedRouteConfiguration(
                  $mapExpr,
                  com.thoughtworks.restRpc.core.GeneratedRouteConfiguration.getTypeName($structuralFailureExpr))
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
    AutoParser.BUILDER.defineClass(
      [ '${factoryModule}_UriParameters' ],
      parserModule
    );
    AutoFormatter.BUILDER.defineClass(
      [ '${factoryModule}_UriParameters' ],
      formatterModule
    );
    fields;
  }

#end

  @:noUsing
  macro public static function generateRouteConfigurationFactory(includeModules:Array<String>):Array<Field> return {
    var localClass = Context.getLocalClass().get();
    Context.getBuildFields().concat(fields(includeModules, localClass.module, localClass.name));
  }
}

private typedef VariableMap = StringMap<VariableNode>;

private class VariableNode {

  public function new() {}

  public var submap:VariableMap = new VariableMap();

  public var values:Array<Varspec> = [];

}
