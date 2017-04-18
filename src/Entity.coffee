
emptyFunction = require "emptyFunction"
Type = require "Type"

ActionStack = require "./ActionStack"
MapNode = require "./MapNode"
Node = require "./Node"

type = Type "Entity"

type.inherits Node

type.createInstance ->
  return Node {}

type.defineMethods

  # TODO: Implement key-loading.
  load: (key, options) ->
  #
  #   if loader = @_loaders[key]
  #     return loader.load options
  #
  #   if load = @_loadable[key]
  #     if isType
  #
  #   throw Error "Cannot load the '#{key}' key!"

#
# Internal
#

type.defineValues ->

  _nodes: Object.create null

  _refs: Object.create null

type.initInstance ->

  unless action = ActionStack.current
    throw Error "Must construct within an action!"

  @_tree = action.tree
  return

type.defineGetters

  # TODO: Should this be a deep clone?
  _initialValue: -> Object.assign {}, @_values

type.definePrototype

  _revertable: MapNode::_revertable

type.defineMethods

  _get: MapNode::_get

  _set: MapNode::_set

type.overrideMethods

  __initialize: emptyFunction

  __onDetach: MapNode::__onDetach

module.exports = type.build()
