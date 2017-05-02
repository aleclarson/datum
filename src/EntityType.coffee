
emptyFunction = require "emptyFunction"
assertType = require "assertType"
sliceArray = require "sliceArray"
setKind = require "setKind"
isDev = require "isDev"
Type = require "Type"
sync = require "sync"

EntityRegistry = require "./EntityRegistry"
ActionHistory = require "./ActionHistory"
EntityState = require "./EntityState"
Action = require "./Action"
Entity = require "./Entity"

encode = require "./utils/encode"
decode = require "./utils/decode"

{defineStatics} = Type.Builder.prototype

type = Type "EntityType"

type.inherits Type.Builder

type.defineValues ->

  _state: EntityState()

  _getState: null

  _saveState: null

type.initInstance ->

  # Always expose the state to its instance.
  @defineValues emptyFunction.thatReturnsArgument

type.definePrototype

  _defaultKind: Entity

type.overrideMethods

  defineArgs: (args) ->
    @_state.defineArgs args
    return

  defineMethods: (methods) ->
    @_state.defineMethods methods
    return

  definePrototype: (prototype) ->
    @_state.definePrototype prototype
    return

  defineStatics: (statics) ->
    @_state.defineStatics statics
    return

  __willBuild: ->
    getState = @_getState or emptyFunction.thatReturns {}
    saveState = @_saveState

    if isDev and saveState and not @_loadState
      throw Error "Cannot define `saveState` without defining `loadState`!"

    @defineMethods

      _getState: ->
        state = EntityRegistry.getState this
        return Object.assign state, getState.call this

      saveState: if saveState then ->
        return saveState.call this, encode @_getState()

  build: ->

    type = @_state.build @__super()
    setKind type, @_kind

    EntityRegistry.set @_name, type
    return type

type.defineMethods

  createState: (callback) ->
    @_state.createState callback

  getState: (callback) ->
    assertType callback, Function

    if isDev and @_getState
      throw Error "Cannot call `getState` more than once!"

    @_getState = callback
    return

  saveState: (callback) ->
    assertType callback, Function

    if isDev and @_saveState
      throw Error "Cannot call `saveState` more than once!"

    @_saveState = callback
    return

  loadState: (callback) ->
    @_state.loadState callback

  revertActions: (callbacks) ->
    assertType callbacks, Object
    # TODO: Implement this.

  defineActions: (callbacks) ->
    assertType callbacks, Object
    actions = sync.map callbacks, (callback, name) -> () ->

      if arguments.length
        args = sliceArray arguments

      action = Action name, args
      @_actions.start action
      result = callback.apply this, args
      @_actions.finish action
      return result

    @_state.defineMethods actions
    return

module.exports = type.build()
