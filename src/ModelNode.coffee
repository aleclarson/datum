
# TODO: Combine the `options` into a single "init" action.

mergeDefaults = require "mergeDefaults"
assertType = require "assertType"
setProto = require "setProto"
isType = require "isType"
Type = require "Type"
sync = require "sync"

MapNode = require "./MapNode"
Node = require "./Node"

type = Type "ModelNode"

type.inherits MapNode

type.defineArgs [Object.Maybe]

type.defineValues (options) ->

  _options: options

  _loaders: Object.create null

type.defineMethods

  load: (key, options) ->
    if loader = @_loaders[key]
      return loader.load options
    throw Error "Cannot load the '#{key}' key!"

type.defineStatics

  Type: (name) ->
    return Builder name

module.exports = ModelNode = type.build()

#
# ModelNode.Type
#

notImpl = -> throw Error "not implemented"

Builder = do ->

  type = Type "ModelNode_Builder"

  type.inherits Type.Builder

  type.defineValues

    _actions: null

    _loaders: null

  type.definePrototype

    _defaultKind: ModelNode

    _defaultBaseCreator: -> ModelNode()

  type.defineMethods

    # Defines the keys that are serialized.
    # Also creates a getter & setter for each key.
    # The values provided are types to be validated.
    # Pass `null` to not validate a specific key.
    defineModel: (types) ->
      assertType types, Object

      values = {}
      values._types = {value: types}
      sync.each types, (type, key) ->
        values[key] =
          get: -> @_get key
          set: (value) ->
            assertType value, type, key
            @_set key, value
        return

      @definePrototype values
      return

    # Takes a map of functions, where each (1) mutates the tree or (2) performs more actions.
    # All performed actions can be reversed or replayed.
    defineActions: (actions) ->
      assertType actions, Object
      @_actions ?= Object.create @_kind::_actions
      Object.assign @_actions, actions
      return

    # Takes a map of functions, where each loads one or more keys.
    # Either a `Loader` instance or a `Promise` must be returned.
    defineLoaders: (loaders) ->
      assertType loaders, Object
      @_loaders ?= Object.create @_kind::_loaders
      Object.assign @_loaders, loaders
      return

  type.overrideMethods

    createInstance: notImpl

    defineFunction: notImpl

    __didBuild: (type) ->
      proto = {}
      proto._actions = {value: @_actions} if @_actions
      proto._loaders = {value: @_loaders} if @_loaders
      Object.assign type.prototype, proto

  return type.build()
