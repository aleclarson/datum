
# TODO: Finish mapping each value to a specific `ModelNode`.

assertType = require "assertType"
isType = require "isType"
OneOf = require "OneOf"
Event = require "eve"
Type = require "Type"
sync = require "sync"

ArrayNode = require "./ArrayNode"
Node = require "./Node"

type = Type "MapNode"

type.inherits Node

type.defineValues ->

  # A map of keys to `Node` instances. Does not contain nested nodes.
  _nodes: Object.create null

  # Converts a key (relative to this node) into an absolute path.
  _resolve: @_defaultResolve

  # The history of mutations to this node.
  _changes: []

type.defineGetters

  key: -> @_key

  _initialValue: -> {}

type.definePrototype

  _actions: require "./MapActions"

type.defineMethods

  get: (key) ->
    assertType key, String
    if 1 > key.lastIndexOf "."
    then @_nodes[key] or @_values[key]
    else @_tree.get @_key + "." + key

  set: (key, value) ->
    assertType key, String

    if 1 > dot = key.lastIndexOf "."
      return @_set key, value

    if node = @_getParent key
      return node._set key.slice(dot + 1), value

    throw Error "Invalid key has no parent: '#{key}'"

  delete: (key) ->
    assertType key, String
    @_tree._performAction this,
      name: "delete"
      args: [key]
      revertable: yes

  merge: (values) ->
    assertType values, Object
    @_tree._performAction this,
      name: "merge"
      args: [values]

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

  fromString: (json) ->
    @merge JSON.parse json

  convert: (models) ->
    assertType models, Object

    @_models ?= Object.create null

    for key, model of models

      if @_models[key] isnt undefined
        throw Error "Cannot convert the same key twice: '#{key}'"

      if node = @_nodes[key]
      then node.transform = model
      else @_models[key] = model

    return

  _defaultResolve: (key) ->
    return @_key + "." + key

  _getParent: (key) ->
    @_tree._getParent @_resolve key

  _get: (key) ->
    return @_nodes[key] or @_values[key]

  _set: (key, value) ->

    # if node = @_createModel key, value
    #   return @_attachModel key, node

    if @_transform isnt null
      value = @_transform value

    oldValue = @_values[key]
    return value if value is oldValue

    if node = @_nodes[key]
      @_tree._detachNode node
      delete @_nodes[key]

    # if node = @_createNode value, key
    #   @_attachNode key, node
    #   value = node._initialValue
    #   node.__attachValues value
    #   return node
    #
    # @_tree._performAction this,
    #   name: "set"
    #   args: [key, value]
    #   revertable: yes
    #
    # if node
    #   @_values[key] = node._values
    #   return node
    #
    # @_values[key] = value
    # return value

  _delete: (key) ->
    delete @_values[key]
    if node = @_nodes[key]
      @_tree._detachNode node
      delete @_nodes[key]
    return

  _createNode: (value, key) ->
    return ArrayNode value if isType value, Array
    return MapNode value if isType value, Object
    return null

  _attachNode: (key, node) ->
    @_nodes[key] = node
    @_tree._attachNode @_resolve(key), node
    return

  # _createModel: (key, value) ->
  #
  #   return unless @_models
  #   return unless createModel = @_models[key]
  #
  #   if node = @_nodes[key]
  #     @_tree._detachNode node
  #     delete @_nodes[key]
  #
  #   return if value is null
  #
  #   return createModel value, @_tree

  # _attachModel: (key, node) ->
  #
  #   event =
  #     if @_values[key] is undefined
  #     then "add"
  #     else "change"
  #
  #   @_attachNode key, node
  #   @_values[key] = node._values
  #
  #   @_pushChange {event, key, options: node._options}
  #   if action = node._initialAction
  #     @_performAction action
  #     node._initialAction = null
  #   return

  # _getRevertedValue: (change) ->
    # TODO: Implement finding the value before a specific change.

type.overrideMethods

  __revertAction: (name, args) ->

    if name is "set"
      throw Error "not implemented"
      return

    if name is "delete"
      throw Error "not implemented"
      return

  __onDetach: ->
    for key, node of @_nodes
      @_tree._detachNode node
    return

  __onReset: ->
    @_nodes = Object.create null
    return

module.exports = MapNode = type.build()
