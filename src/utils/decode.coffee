
assertType = require "assertType"
steal = require "steal"
sync = require "sync"
has = require "has"

EntityRegistry = require "../EntityRegistry"
ArrayNode = require "../ArrayNode"
MapNode = require "../MapNode"

module.exports = (state) ->
  assertType state, Object

  nodes = steal state, "_nodes"
  console.log JSON.stringify nodes
  return state

  # decodeNode = (node) ->
  #
  #   id = node._id
  #   if has nodes, id
  #     return nodes[id]
  #
  #   if node._type
  #     type = types[node._type]
  #     values = node._values
  #   else
  #     type = types[node.constructor.name]
  #     values = node
  #
  #   values = sync.map values, decodeValue
  #   options = type::__createOptions values
  #   node = type options
  #   if values = node.__createValues values
  #     Object.assign node, values
  #
  #   nodes[id] = node
  #   return node
  #
  # decodeValue = (value) ->
  #
  #   if value is null
  #     return null
  #
  #   if value instanceof Array
  #     return decodeNode value
  #
  #   if value instanceof Object
  #     return decodeNode value
  #
  #   return value
  #
  # return sync.map state, decodeValue
