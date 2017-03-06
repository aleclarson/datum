// Generated by CoffeeScript 1.12.4
var Event, LazyVar, NodeTree, OneOf, Type, assertType, emptyFunction, inArray, sliceArray, type;

emptyFunction = require("emptyFunction");

assertType = require("assertType");

sliceArray = require("sliceArray");

LazyVar = require("LazyVar");

inArray = require("in-array");

OneOf = require("OneOf");

Event = require("eve");

Type = require("Type");

NodeTree = LazyVar(function() {
  return require("./NodeTree");
});

type = Type("Node");

type.inherits(null);

type.defineValues(function(values) {
  return {
    _key: null,
    _tree: null,
    _values: values,
    _events: Event.Map(),
    _changes: []
  };
});

type.definePrototype({
  tree: {
    get: function() {
      return this._tree;
    }
  },
  _actions: Object.create(null),
  _revertable: []
});

type.defineMethods({
  on: function(event, callback) {
    return this._events.on(event, callback);
  },
  once: function(event, callback) {
    return this._events.once(event, callback);
  },
  _startAction: function(name, args) {
    var action;
    assertType(name, String);
    assertType(args, Array.Maybe);
    action = {
      target: this._key,
      name: name
    };
    if (args) {
      action.args = args;
    }
    return this._tree.startAction(action);
  },
  _finishAction: function(action) {
    if (inArray(this._revertable, action.name)) {
      this._changes.push(action);
    }
    this._tree.finishAction(action);
    this._events.emit(action.name, action);
  }
});

type.defineHooks({
  __revertAction: function() {
    throw Error("Failed to revert action!");
  },
  __replayAction: function() {
    throw Error("Failed to replay action!");
  },
  __onAttach: emptyFunction,
  __onDetach: emptyFunction
});

module.exports = type.build();