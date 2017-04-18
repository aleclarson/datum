
assertType = require "assertType"
LazyVar = require "LazyVar"
hasKeys = require "hasKeys"
isType = require "isType"
Type = require "Type"
has = require "has"

NodeTree = LazyVar -> require "./NodeTree"
Node = require "./Node"

type = Type "MapNode"

type.inherits Node

type.createInstance (tree) ->
  return Node {}, tree

type.initInstance ->
  @_tree ?= NodeTree.call this
  return

type.defineMethods

  has: (key) ->
    @_values.hasOwnProperty key

  get: (key) ->
    assertType key, String
    if 1 > key.lastIndexOf "."
    then @_nodes[key] or @_values[key]
    else @_tree.get @_resolve(key)

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
    return unless hasKeys values
    @_startAction "merge", [values]
    @_set key, value for key, value of values
    @_finishAction()
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

#
# Internal
#

type.defineValues ->

  _nodes: Object.create null

  _refs: Object.create null

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
    if ref = @_refs[key]
    then @_tree._nodes[ref]
    else @_nodes[key] or @_values[key]

  _set: (key, value) ->

    if value is @_values[key]
      return value

    if has @_refs, key
      delete @_refs[key]

    else if node = @_nodes[key]
      @_tree.detach node
      delete @_nodes[key]

    if isType value, Object
      node = MapNode @_tree
      @_tree.attach @_resolve(key), node

      @_startAction "set", [key, node._initialValue]
      @_nodes[key] = node
      @_values[key] = node._values
      @_finishAction()

      node.merge value
      return node

    else if value instanceof Node
      node = value

      if @_tree isnt node._tree
        throw Error "Cannot attach a node unless in the same tree!"

      @_startAction "ref", [key, node._key]
      @_refs[key] = node._key
      @_finishAction()
      return node

    @_startAction "set", [key, value]
    @_values[key] = value
    @_finishAction()
    return value

  _delete: (key) ->
    @_startAction "delete", [key]

    if has @_refs, key
      delete @_refs[key]

    else if node = @_nodes[key]
      @_tree.detach node
      delete @_nodes[key]

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
