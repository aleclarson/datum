
assertType = require "assertType"
isDev = require "isDev"
Type = require "Type"
has = require "has"

Entity = require "./Entity"

type = Type "EntityRegistry"

type.defineValues ->

  _types: Object.create null

  _state: Object.create null

type.defineMethods

  get: (name) ->
    return @_types[name]

  set: (name, type) ->

    if isDev and has @_types, name
      throw Error "Entity type named '#{name}' already exists!"

    @_types[name] = type
    return

  # Get the values of any serialized keys.
  getState: (entity) ->
    assertType entity, Entity.Kind

    {name} = entity.constructor
    keys = Object.keys @_state[name]

    state = {_type: name}
    for key in keys
      value = entity[key]
      if value isnt undefined
        state[key] = value
    return state

  # Store the serialized keys of an entity.
  setState: (entity, state) ->
    assertType entity, Entity.Kind

    {name} = entity.constructor
    unless keys = @_state[name]
      @_state[name] = keys = Object.create null

    for key of state
      keys[key] = null
    return

module.exports = type.construct()
