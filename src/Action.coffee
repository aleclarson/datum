
isDev = require "isDev"
Type = require "Type"

type = Type "Action"

type.defineArgs [String, Array.Maybe]

type.defineFrozenValues (name, args) ->

  name: name

  args: args or undefined

type.defineMethods

  track: ->

    if isDev and @_tracked
      throw Error "Already tracking this action!"

    @_tracked = yes
    return

  revert: ->

    if isDev and not @_tracked
      throw Error "Cannot revert this action!"

    if isDev and @_reverted
      throw Error "This action was already reverted!"

    result = @_target.__revertAction @name, @args
    return if result is no

    @_reverted = yes
    @_target._actions.remove this
    return

  replay: ->
    # TODO: Implement this.

#
# Internal
#

type.defineValues

  _target: null

  _tracked: no

  _reverted: no

module.exports = type.build()
