package com.thoughtworks.microbuilder.core;

//TODO:add status code
enum Failure {
    TEXT_APPLICATION_FAILURE(message:String, code:Int);
    STRUCTURAL_APPLICATION_FAILURE(failure:Dynamic, code:Int);
    NATIVE_FAILURE(message:String);
    SERIALIZATION_FAILURE(reason:String);
}
