package com.thoughtworks.microbuilder.core;

enum Allow {
  U;
  U_R;
}

class OperatorDefinition {

  public static var DEFINITIONS_BY_OPERATOR = [
    "" => {
      first: "",
      sep: ",",
      named: false,
      ifemp: "",
      allow: Allow.U
    },
    "+" => {
      first: "",
      sep: ",",
      named: false,
      ifemp: "",
      allow: Allow.U_R
    },
    "." =>{
      first: "",
      sep: ".",
      named: false,
      ifemp: "",
      allow: Allow.U
    },
    "/" => {
      first: "",
      sep: "/",
      named: false,
      ifemp: "",
      allow: Allow.U
    },
    ";" => {
      first: "",
      sep: ";",
      named: true,
      ifemp: "",
      allow: Allow.U
    },
    "?" => {
      first: "",
      sep: "&",
      named: true,
      ifemp: "=",
      allow: Allow.U
    },
    "&" => {
      first: "",
      sep: "&",
      named: true,
      ifemp: "=",
      allow: Allow.U_R
    },
    "#" => {
      first: "",
      sep: ",",
      named: false,
      ifemp: "",
      allow: Allow.U
    }
  ];

}