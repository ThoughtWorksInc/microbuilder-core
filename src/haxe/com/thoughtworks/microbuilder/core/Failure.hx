package com.thoughtworks.microbuilder.core;

//TODO:add status code
//TODO:500 特殊处理一下
enum Failure {
    TEXT_APPLICATION_FAILURE(message:String);
    STRUCTURAL_APPLICATION_FAILURE(failure:Dynamic);
    NATIVE_FAILURE(message:String);
    SERIALIZATION_FAILURE(reason:String);
}
