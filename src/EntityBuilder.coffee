
assertType = require "assertType"
sliceArray = require "sliceArray"
setProto = require "setProto"
isType = require "isType"
Type = require "Type"
sync = require "sync"

MapNode = require "./MapNode"
Action = require "./Action"
Entity = require "./Entity"

type = Type "EntityBuilder"

type.inherits Type.Builder

type.defineValues ->

  _actions: Object.create null

  _loadable: Object.create null

type.definePrototype

  _defaultKind: Entity

  _defaultBaseCreator: -> Entity()

type.defineMethods

  # Takes a map of functions, where each (1) mutates the tree and/or (2) performs more actions.
  # All performed actions can be reverted or replayed.
  defineActions: (actions) ->
    assertType actions, Object
    Object.assign @_actions, actions
    @defineMethods do ->
      sync.map actions, (action, name) ->
        action = Action name, action
        return -> action.apply this, arguments

  # Takes a map of functions, where each loads one or more keys.
  # Either a `Loader` instance or a `Promise` must be returned.
  defineLoaders: (loadable) ->
    assertType loadable, Object
    Object.assign @_loadable, loadable
    return

type.overrideMethods

  defineValues: (config) ->
    assertType config, Object.or Function

    createValues =
      if isType config, Object
      then -> config
      else config

    @initInstance ->
      values = createValues.apply this, arguments
      Object.assign @_values, values
    return

  __willBuild: ->

    exposeValue = (key) ->
      Object.defineProperty this, key,
        get: -> @_get key
        set: (value) ->
          @_set key, value

    @initInstance ->
      for key of @_values
        exposeValue.call this, key
      return

    inherited = @_kind.prototype
    if inherited instanceof Entity
      setProto @_actions, inherited._actions
      setProto @_loadable, inherited._loadable

    @definePrototype
      _actions: @_actions
      _loadable: @_loadable
    return

module.exports = type.build()
