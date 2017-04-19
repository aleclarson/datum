
assertType = require "assertType"
Type = require "Type"

Node = require "./Node"

type = Type "NodeList"

type.inherits Node

type.createInstance ->
  return Node []

type.defineGetters

  length: -> @_values.length

type.defineMethods

  get: (index) ->
    assertType index, Number
    key = @_values[index]
    if key isnt undefined
      return @_tree._nodes[key]

  append: (node) ->
    assertType node, Node.Kind

    unless node._key
      throw Error "Cannot append a node with no key!"

    @_startAction "append", [node._key]
    @_values.push node._key
    @_finishAction()
    return node

  prepend: (node) ->
    assertType node, Node.Kind

    unless node._key
      throw Error "Cannot prepend a node with no key!"

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
    nodes = @_tree._nodes
    for key, index in @_values
      iterator nodes[key], index
    return

  toArray: ->
    nodes = @_tree._nodes
    return @_values.map (key) ->
      return nodes[key]

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
