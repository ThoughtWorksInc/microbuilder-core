package com.thoughtworks.restRpc.core;

class RouteConfiguration {
    public var nameToUriTemplate: Map<String, UriTemplate>;
}

class UriTemplate {
    private var template: String;
    private var verb: String;

    public function new(template:String) {
        this.template = template;
    }

    public function render(context: Dynamic):String{
        return new haxe.Template(template).execute(context);
    }
}