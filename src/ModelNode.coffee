
{mutable, frozen} = require "Property"

assertType = require "assertType"
sliceArray = require "sliceArray"
isType = require "isType"
Type = require "Type"
sync = require "sync"

MapNode = require "./MapNode"

type = Type "ModelNode"

type.inherits MapNode

type.createInstance ->
  return MapNode {}

type.definePrototype

  _loaders: Object.create null

type.defineMethods

  load: (key, options) ->
    if loader = @_loaders[key]
      return loader.load options
    throw Error "Cannot load the '#{key}' key!"

type.overrideMethods

  __onAttach: ->
    @_tree._modelNodes[@_key] = @constructor.name
    return

  __onDetach: ->
    delete @_tree._modelNodes[@_key]
    @__super arguments

type.defineStatics

  Type: (name) ->
    return Builder name

module.exports = ModelNode = type.build()

#
# ModelNode.Type
#

notImpl = ->
  throw Error "not implemented"

Builder = do ->

  type = Type "ModelNode_Builder"

  type.inherits Type.Builder

  type.defineValues

    _actions: null

    _loaders: null

    _selectors: null

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

      methods = {}
      sync.each actions, (_, name) ->
        methods[name] = ->
          args = if arguments.length then sliceArray arguments else null
          action = @_startAction name, args
          result = @_actions[name].apply this, args
          @_finishAction action
          return result
        return

      @_actions ?= Object.create @_kind::_actions or null
      Object.assign @_actions, actions
      return

    # Takes a map of functions, where each loads one or more keys.
    # Either a `Loader` instance or a `Promise` must be returned.
    defineLoaders: (loadable) ->
      assertType loadable, Object
      @_loadable ?= Object.create @_kind::_loadable or null
      Object.assign @_loadable, loadable
      return

    # Takes a map of functions, where each key depends on reactive data.
    # Selectors are used for model references and computed variables.
    # defineSelectors: (selectors) ->
    #   assertType selectors, Object
    #   @initInstance (options) ->
    #
    #     mutable.define this, "_selectors",
    #       value: values = Object.create null
    #
    #     for key, selector of selectors
    #       values[key] = Tracker.autorun
    #     return

  type.overrideMethods

    createInstance: notImpl

    defineFunction: notImpl

    defineValues: (config) ->
      assertType config, Object.or Function

      createValues =
        if isType config, Object
        then -> config
        else config

      @initInstance (options) ->
        types = @_types
        values = createValues.call this, options
        for key, value of values
          if type = types[key]
            assertType value, type, key
            @_values[key] = value
          else
            mutable.define this, key, {value}
        return

    __didBuild: (type) ->

      defineProto = (key, value) ->
        if value isnt undefined
          frozen.define type.prototype, key, {value}
        return

      defineProto "_actions", @_actions
      defineProto "_loadable", @_loadable
      return

  return type.build()
