package com.thoughtworks.restRpc.core;

enum Failure {
    TEXT_APPLICATION_FAILURE(message:String);
    STRUCTURAL_APPLICATION_FAILURE(message:Dynamic);
    NATIVE_FAILURE(message:String);
}