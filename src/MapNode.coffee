
# TODO: Finish mapping each value to a specific `ModelNode`.

assertType = require "assertType"
isType = require "isType"
OneOf = require "OneOf"
Event = require "eve"
Type = require "Type"
sync = require "sync"

ArrayNode = require "./ArrayNode"
NodeTree = require "./NodeTree"
Node = require "./Node"

type = Type "MapNode"

type.inherits Node

type.createInstance (values) ->
  assertType values, Object.Maybe
  return Node values or {}

type.defineValues ->

  # A map of keys to `Node` instances. Does not contain nested nodes.
  _nodes: Object.create null

type.defineGetters

  key: -> @_key

  _initialValue: -> Object.assign {}, @_values

type.definePrototype

  _revertable: ["set", "delete"]

type.defineMethods

  get: (key) ->
    assertType key, String
    if 1 > key.lastIndexOf "."
    then @_get key
    else @_tree.get @_resolve key

  observe: (key, callback) ->

    if arguments.length is 1
      assertType callback = key, Function
      return @_tree.observe this, callback

    assertType key, String
    assertType callback, Function
    @_getParent key
    .on "set", (event) ->
      if key is event.args[0]
        callback event.args[1]
      return

  set: (key, value) ->
    assertType key, String

    if 1 > dot = key.lastIndexOf "."
      return @_set key, value

    if node = @_getParent key
      return node._set key.slice(dot + 1), value

    throw Error "Invalid key has no parent: '#{key}'"

  delete: (key) ->
    assertType key, String

    if 1 > dot = key.lastIndexOf "."
      return @_delete key

    if node = @_getParent key
      return node._delete key.slice(dot + 1)

    throw Error "Invalid key has no parent: '#{key}'"

  merge: (values) ->
    assertType values, Object
    action = @_startAction "merge", [values]
    @_set key, value for key, value of values
    @_finishAction action
    return

  forEach: (iterator) ->
    nodes = @_nodes
    for key, value of @_values
      iterator nodes[key] or value, key
    return

  filter: (iterator) ->
    nodes = @_nodes
    values = {}
    for key, value of @_values
      value = node if node = nodes[key]
      values[key] = value if iterator value, key
    return values

  map: (iterator) ->
    nodes = @_nodes
    values = {}
    for key, value of @_values
      values[key] = iterator nodes[key] or value
    return values

  toString: ->
    JSON.stringify @_values

  _resolve: (key) ->
    if @_key
    then @_key + "." + key
    else key

  _get: (key) ->
    @_nodes[key] or @_values[key]

  _getParent: (key) ->
    @_tree.getParent @_resolve key

  _set: (key, value) ->

    oldValue = @_values[key]
    return value if value is oldValue

    action = @_startAction "set", [key, value]

    if node = @_nodes[key]
      @_tree.detach node
      delete @_nodes[key]

    @_tree ?= NodeTree this

    if value instanceof Node
      node = value

    else if isType value, Object
      node = MapNode value

    else if isType value, Array
      node = ArrayNode value

    if node isnt undefined
      @_nodes[key] = node
      @_tree.attach @_resolve(key), node
      action.args[1] = node._initialValue

    @_values[key] =
      if node
      then node._values
      else value

    @_finishAction action
    return node or value

  _delete: (key) ->
    action = @_startAction "delete", [key]

    if node = @_nodes[key]
      @_tree.detach node
      delete @_nodes[key]

    delete @_values[key]
    @_finishAction action
    return

type.overrideMethods

  __revertAction: (name, args) ->

    if name is "set"
      throw Error "not implemented"
      return

    if name is "delete"
      throw Error "not implemented"
      return

  __replayAction: (name, args) ->

    if name is "set"
      throw Error "not implemented"
      return

    if name is "delete"
      throw Error "not implemented"
      return

  __onDetach: ->
    for key, node of @_nodes
      @_tree.detach node
    return

module.exports = MapNode = type.build()
