
actions = Object.create null

actions.set = (key, value) ->
  @_values[key] = value
  return

actions.delete = (key) ->
  delete @_values[key]
  return

  if 1 > dot = key.lastIndexOf "."
    return @_delete key

  if node = @_getParent key
    return node._delete key.slice(dot + 1)

  throw Error "Invalid key has no parent: '#{key}'"

actions.merge = (values) ->
  for key, value of values
    @set key, value
  return

module.exports = actions
