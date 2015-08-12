package com.thoughtworks.restRpc.core;

class RouteConfiguration {
    private var nameToUriTemplate: Map<String, UriTemplate>;
}

class UriTemplate {
    private var template:String;
    public function new(template:String) {
        this.template = template;
    }

    public function render(context: Dynamic):String{
        return new haxe.Template(template).execute(context);
    }
}