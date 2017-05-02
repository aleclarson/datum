
assertType = require "assertType"
sync = require "sync"
has = require "has"

Entity = require "../Entity"
Node = require "../Node"

module.exports = (state) ->
  assertType state, Object

  nodes = Object.create null

  currentNode = null
  currentNodes = []

  encodeNode = (node, key) ->
    id = node._id

    if has nodes, id
      return {_ref: id}

    nodes[id] =
      if currentNode
      then currentNode + "." + key
      else key

    currentNodes.push currentNode
    currentNode = id

    values = sync.map node._getState(), encodeValue

    currentNode = currentNodes.pop()
    return values

  encodeValue = (value, key) ->

    if value is null
      return null

    if value instanceof Node
      return encodeNode value, key

    return value

  state = sync.map state, encodeValue
  state._nodes = nodes
  return state
