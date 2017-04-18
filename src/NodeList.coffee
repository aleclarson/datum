
assertType = require "assertType"
isDev = require "isDev"
Type = require "Type"

Node = require "./Node"

type = Type "NodeList"

type.inherits Node

type.createInstance (tree) ->
  return Node [], tree

type.defineGetters

  length: -> @_values.length

type.defineMethods

  get: (index) ->
    assertType index, Number
    ref = @_values[index]
    if ref isnt undefined
      return @_tree._refs[ref]

  append: (node) ->
    assertType node, Node.Kind

    if isDev and node._tree isnt @_tree
      throw Error "Nodes must be attached to the same tree!"

    @_startAction "append", [node._key]
    @_values.push node._key
    @_finishAction()
    return node

  prepend: (node) ->
    assertType node, Node.Kind

    if isDev and node._tree isnt @_tree
      throw Error "Nodes must be attached to the same tree!"

    @_startAction "prepend", [node._key]
    @_values.unshift node._key
    @_finishAction()
    return node

  remove: (node) ->
    assertType node, Node.Kind
    position = @_values.indexOf node._key
    if position >= 0
      @_startAction "remove", [node._key]
      @_values.splice position, 1
      @_finishAction()
      return

  move: (node, index) ->
    assertType node, Node.Kind
    assertType index, Number

    position = @_values.indexOf node._key
    if position < 0
      throw Error "The given node is not contained in this list!"

    @_startAction "move", [position, index]
    @_values.splice position, 1
    @_values.splice index, 0, node._key
    @_finishAction()
    return

  forEach: (iterator) ->
    refs = @_tree._refs
    for key, index in @_values
      iterator refs[key], index
    return

  toArray: ->
    refs = @_tree._refs
    return @_values.map (key) ->
      return refs[key]

#
# Internal
#

type.defineGetters

  _initialValue: -> []

type.definePrototype

  _revertable: Object.create
    constructor: null
    append: 1
    prepend: 1
    remove: 1
    move: 1

module.exports = type.build()
