
assertType = require "assertType"
hasKeys = require "hasKeys"
isType = require "isType"
isDev = require "isDev"
Type = require "Type"

Node = require "./Node"

type = Type "MapNode"

type.inherits Node

type.createInstance ->
  return Node {}

type.defineMethods

  has: (key) ->
    @_values.hasOwnProperty key

  get: (key) ->
    assertType key, String
    if 0 < key.indexOf "."
      return @_follow key
    return @_get key

  set: (key, value) ->
    assertType key, String
    if 0 < dot = key.lastIndexOf "."
      node = @_getParent key
      key = key.slice dot + 1
      return node._set key, value
    return @_set key, value

  delete: (key) ->
    assertType key, String
    if 0 < dot = key.lastIndexOf "."
      node = @_getParent key
      key = key.slice dot + 1
      return node._delete key
    return @_delete key

  merge: (values) ->
    assertType values, Object
    return unless hasKeys values
    @_startAction "merge", [values]
    @_set key, value for key, value of values
    @_finishAction()
    return

  # TODO: Support refs in `forEach`.
  forEach: (iterator) ->
    nodes = @_nodes
    for key, value of @_values
      iterator nodes[key] or value, key
    return

  # TODO: Support refs in `filter`.
  filter: (iterator) ->
    nodes = @_nodes
    values = {}
    for key, value of @_values
      value = node if node = nodes[key]
      values[key] = value if iterator value, key
    return values

  # TODO: Support refs in `map`.
  map: (iterator) ->
    nodes = @_nodes
    values = {}
    for key, value of @_values
      values[key] = iterator nodes[key] or value
    return values

#
# Internal
#

type.defineValues ->

  _nodes: Object.create null

type.defineGetters

  _initialValue: -> {}

type.definePrototype

  _revertable: Object.create
    constructor: null
    ref: 1
    set: 1
    delete: 1

type.defineMethods

  _get: (key) ->
    @_nodes[key] or @_values[key]

  _follow: (path) ->
    assertType path, String

    path = path.split "."
    refs = @_tree._refs

    key = @_key
    if key is null
      key = path.shift()
      key = ref if ref = refs[key]

    while path.length > 1
      key += "." + path.shift()
      key = ref if ref = refs[key]

    if node = @_tree._nodes[key]
      return node._get path[0]

  _set: (key, value) ->

    if node = @_nodes[key]
      delete @_nodes[key]
      if node._key is @_resolve key
        @_tree.detach node

    else if value is @_values[key]
      return value

    if isType value, Object
      node = MapNode()

    else if value instanceof Node
      node = value
      value = null

      if isDev and node is this
        throw Error "Cannot attach a node to itself!"

      if node._key

        if node._tree isnt @_tree
          throw Error "Cannot ref a node from another tree!"

        @_startAction "ref", [key, node._key]
        @_nodes[key] = node
        @_values[key] = node._key
        @_tree.attachRef @_resolve(key), node
        @_finishAction()
        return node

    if node
      @_startAction "set", [key, node._initialValue]
      @_nodes[key] = node
      @_values[key] = node._values
      @_tree.attach @_resolve(key), node
      @_finishAction()

      node.merge value if value
      return node

    @_startAction "set", [key, value]
    @_values[key] = value
    @_finishAction()
    return value

  _delete: (key) ->

    if node = @_nodes[key]
      delete @_nodes[key]
      if node._key is @_resolve key
        @_tree.detach node

    @_startAction "delete", [key]
    delete @_values[key]
    @_finishAction()
    return

type.overrideMethods

  __initialize: (values) ->
    if isType values, Object
      @merge values
      return

  __revertAction: (name, args) ->

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
