
emptyFunction = require "emptyFunction"
assertType = require "assertType"
setKind = require "setKind"
setType = require "setType"
isDev = require "isDev"
Type = require "Type"

EntityRegistry = require "./EntityRegistry"
Converter = require "./Converter"

{convertState} = Converter

type = Type "EntityState"

type.inherits Type.Builder

type.defineValues

  _innerType: null

  _createState: null

  _loadState: null

type.defineMethods

  createState: (callback) ->
    assertType callback, Function

    if isDev and @_createState
      throw Error "Cannot call `createState` more than once!"

    @_createState = callback
    return

  loadState: (callback) ->
    assertType callback, Function

    if isDev and @_loadState
      throw Error "Cannot call `loadState` more than once!"

    @_loadState = callback
    return

type.overrideMethods

  build: (innerType) ->

    # The `_innerType` must exist before building.
    @_innerType = innerType
    @_name = innerType.name

    type = @__super()

    # The `_innerType` can use our prototype.
    setKind innerType, type

    # Creates an instance from cached state.
    type.create = (state) ->
      state and convertState state
      entity = innerType state
      state and EntityRegistry.setState entity, state
      return setType entity, outerType

    return type

  __createInstanceBuilder: ->
    innerType = @_innerType
    loadState = @_loadState or emptyFunction
    createState = @_createState or emptyFunction
    return (type, args, context) ->

      if state = loadState()
        state = decode state

      else if state = createState.apply context, args
        convertState state

      entity = innerType state
      state and EntityRegistry.setState entity, state
      return setType entity, type

module.exports = type.build()
