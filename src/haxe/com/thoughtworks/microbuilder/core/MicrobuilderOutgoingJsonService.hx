package com.thoughtworks.microbuilder.core;

import com.dongxiguo.continuation.Continuation;
import com.dongxiguo.continuation.utils.Generator;
import jsonStream.rpc.IJsonService;
import jsonStream.JsonSerializer;
import jsonStream.JsonStream;
import jsonStream.io.TextParser;
import jsonStream.io.PrettyTextPrinter;
import Type;

@:abstract
class MicrobuilderOutgoingJsonService implements IJsonService {

  var urlPrefix:String;
  var routeConfiguration:IRouteConfiguration;

  public function new(urlPrefix: String, routeConfiguration:IRouteConfiguration) {
    this.urlPrefix = urlPrefix;
    this.routeConfiguration = routeConfiguration;
  }

  function generator1<A>(a:A):Generator<A> return {
    new Generator<A>(Continuation.cpsFunction(function(yield:YieldFunction<A>) {
      @await yield(a);
    }));
  }

  @:abstract
  public function send(url:String, httpMethod:String, requestContentType:String, requestBody: String, ?responseHandler:Null<Dynamic>->?Int->?String->Void):Void {
    throw "Not implemented!";
  }

  public function push(data:JsonStream):Void {
    switch data {
      case OBJECT(pairs):
        if (pairs.hasNext()) {
          var pair = pairs.next();
          if (pairs.hasNext()) {
            throw "request should contain one key/value pair";
          } else {
            switch pair.value {
              case ARRAY(parameters):
                var routeEntry = routeConfiguration.nameToUriTemplate(pair.key);
                var request = routeEntry.render(parameters);
                var url = '$urlPrefix${request.uri}';
                var requestBody = if (request.body != null) {
                  PrettyTextPrinter.toString(request.body);
                } else {
                  null;
                }
                // TODO: send custom headers
                send(url, request.httpMethod, request.contentType, requestBody);
              default:
                throw "parameter should be a JSON array";
            }
          }
        } else {
          throw "request should contain one key/value pair";
        }
      default:
        throw "request should be a JSON object";
    }
  }

  public function apply(requestJson:JsonStream, responseHandler:IJsonResponseHandler):Void {
    switch requestJson {
      case OBJECT(pairs):
        if (pairs.hasNext()) {
          var pair = pairs.next();
          if (pairs.hasNext()) {
            throw "request should contain one key/value pair";
          } else {
            switch pair.value {
              case ARRAY(parameters):
                var routeEntry = routeConfiguration.nameToUriTemplate(pair.key);
                var request = routeEntry.render(parameters);
                var url = '$urlPrefix${request.uri}';
                var requestBody = if (request.body != null) {
                  PrettyTextPrinter.toString(request.body);
                } else {
                  null;
                }
                // TODO: send custom headers
                send(url, request.httpMethod, request.contentType, requestBody, function(error, ?status, ?responseBody) {
                  if (error == null) {
                    if (status >= 200 && status < 400) {
                      try {
                        responseHandler.onSuccess(TextParser.parseString(responseBody));
                      } catch (e:TextParserError) {
                        var serializationFailure = CoreSerializer.dynamicSerialize(
                          ValueType.TEnum(Failure),
                          Failure.SERIALIZATION_FAILURE("Wrong JSON format: " + responseBody)
                        );
                        responseHandler.onFailure(JsonStream.OBJECT(generator1(serializationFailure)));
                      }
                    } else {
                      if (routeConfiguration.failureClassName == null) {
                        var textFailure = CoreSerializer.dynamicSerialize(
                          ValueType.TEnum(Failure),
                          Failure.TEXT_APPLICATION_FAILURE(responseBody, status));
                        responseHandler.onFailure(JsonStream.OBJECT(generator1(textFailure)));
                      } else {
                        try {
                          responseHandler.onFailure(
                            JsonStream.OBJECT(
                              generator1(
                                new JsonStreamPair(
                                  "com.thoughtworks.microbuilder.core.Failure", JsonStream.OBJECT(
                                    generator1(
                                      new JsonStreamPair(
                                        "STRUCTURAL_APPLICATION_FAILURE", JsonStream.OBJECT(
                                          new Generator<JsonStreamPair>(
                                            Continuation.cpsFunction(
                                              function(yield:YieldFunction<JsonStreamPair>) {
                                                @await yield(new JsonStreamPair(
                                                  "failure",
                                                  JsonStream.OBJECT(
                                                    generator1(new JsonStreamPair(routeConfiguration.failureClassName, TextParser.parseString(responseBody)))
                                                  )
                                                ));
                                                @await yield(new JsonStreamPair(
                                                  "status", JsonStream.INT32(status)
                                                ));
                                              }
                                            )
                                          )
                                        )
                                      )
                                    )
                                  )
                                )
                              )
                            )
                          );
                        } catch (e:TextParserError) {
                          var serializationFailure = CoreSerializer.dynamicSerialize(
                            ValueType.TEnum(Failure),
                            Failure.SERIALIZATION_FAILURE("Wrong JSON format: " + responseBody)
                          );
                          responseHandler.onFailure(JsonStream.OBJECT(generator1(serializationFailure)));
                        }
                      }
                    }
                  } else {
                    var nativeFalure = CoreSerializer.dynamicSerialize(ValueType.TEnum(Failure), Failure.NATIVE_FAILURE(Std.string(error)));
                    responseHandler.onFailure(JsonStream.OBJECT(generator1(nativeFalure)));
                  }
                });
              default:
                throw "parameter should be a JSON array";
            }
          }
        } else {
          throw "request should contain one key/value pair";
        }
      default:
        throw "request should be a JSON object";
    }
  }
}
