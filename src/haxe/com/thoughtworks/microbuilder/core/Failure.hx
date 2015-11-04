package com.thoughtworks.microbuilder.core;

//TODO:add status code
enum Failure {
    TEXT_APPLICATION_FAILURE(message:String, status:Int);
    STRUCTURAL_APPLICATION_FAILURE(failure:Dynamic, status:Int);
    NATIVE_FAILURE(message:String);
    SERIALIZATION_FAILURE(reason:String);
}
