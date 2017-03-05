
assertType = require "assertType"
LazyVar = require "LazyVar"
isType = require "isType"
OneOf = require "OneOf"
Event = require "eve"
Type = require "Type"

ArrayNode = require "./ArrayNode"
NodeTree = LazyVar -> require "./NodeTree"
Node = require "./Node"

type = Type "MapNode"

type.inherits Node

type.createInstance ->
  return Node {}

type.defineArgs [Object.Maybe]

type.defineValues ->

  # Contains a Node for each object or array.
  # Does not include nested keys.
  _nodes: Object.create null

type.initInstance (values, tree) ->
  @_tree = tree or NodeTree.call this
  @_initialize values if values
  return

type.defineGetters

  key: -> @_key

  _initialValue: -> Object.assign {}, @_values

type.definePrototype

  _revertable: ["set", "delete"]

type.defineMethods

  has: (key) ->
    undefined isnt @get key

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

  _initialize: (values) ->
    for key, value of values

      if node = @_createNode value
        @_nodes[key] = node
        @_tree.attach @_resolve(key), node
        value = node._values

      @_values[key] = value
    return

  _resolve: (key) ->
    return key unless @_key
    return @_key + "." + key

  _get: (key) ->
    @_nodes[key] or @_values[key]

  _getParent: (key) ->
    @_tree.getParent @_resolve key

  _createNode: (value) ->
    return MapNode value, @_tree if isType value, Object
    return ArrayNode value if isType value, Array
    return value if value instanceof Node
    return null

  _set: (key, value) ->

    if value is @_values[key]
      return value

    action = @_startAction "set", [key, value]

    if node = @_nodes[key]
      @_tree.detach node
      delete @_nodes[key]

    if node = @_createNode value
      @_nodes[key] = node
      @_tree.attach @_resolve(key), node
      action.args[1] = node._initialValue
      value = node._values

    @_values[key] = value
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
