
MapNode = require "../js/MapNode"
ArrayNode = require "../js/ArrayNode"
ModelNode = require "../js/ModelNode"

fdescribe "MapNode", ->

  describe "map.set()", ->

    it "can set a new key", ->

      map = MapNode()
      map.set "foo", 1

      expect map._values.foo
        .toBe 1

    it "supports objects as values", ->

      map = MapNode()
      map.set "foo", input = {a: 1}

      expect map._values.foo
        .toBe input

    it "supports arrays as values", ->

      map = MapNode()
      map.set "foo", input = [1]

      expect map._values.foo
        .toBe input

  describe "map.get()", ->

    it "returns the value for primitives", ->

      map = MapNode()
      map.set "foo", 1

      expect map.get "foo"
        .toBe 1

    it "returns a `MapNode` for objects", ->

      map = MapNode()
      map.set "foo", {}
      node = map.get "foo"

      expect node instanceof MapNode
        .toBe yes

    it "returns an `ArrayNode` for arrays", ->

      map = MapNode()
      map.set "foo", []
      node = map.get "foo"

      expect node instanceof ArrayNode
        .toBe yes

    it "supports keys with dot-notation", ->

      map = MapNode()
      map.set "foo", {bar: 1}
      value = map.get "foo.bar"

      expect value
        .toBe 1

  describe "map.delete()", ->

    it "can remove a primitive value", ->

      map = MapNode()
      map.set "foo", 1
      map.delete "foo"

      expect map.get "foo"
        .toBe undefined

    it "can remove a nested value", ->

      map = MapNode()
      map.set "foo", {bar: 1}
      map.delete "foo.bar"

      expect map.get "foo.bar"
        .toBe undefined

      unless node = map.get "foo"
        return fail "Expected 'foo' to exist."

      expect node._values
        .toEqual {}

    it "can remove a MapNode", ->

      map = MapNode()
      map.set "foo", {bar: 1}
      map.delete "foo"

      expect map.get "foo"
        .toBe undefined

      expect map._nodes["foo"]
        .toBe undefined

    it "can remove an ArrayNode", ->

      map = MapNode()
      map.set "foo", [1]
      map.delete "foo"

      expect map.get "foo"
        .toBe undefined

      expect map._nodes["foo"]
        .toBe undefined

  xdescribe "map.merge()", ->

  xdescribe "map.forEach()", ->

  xdescribe "map.filter()", ->

  xdescribe "map.map()", ->

  xdescribe "map.changes", ->

    xit "tracks `map.set`", ->

      map = MapNode()
      map.set "a", 1
      map.set "a", 2

      expect map.changes[0]
        .toEqual {change: {key: "a", event: "add", value: 1}}

      expect map.changes[1]
        .toEqual {change: {key: "a", event: "change", value: 2}}

    xit "tracks `map.delete`", ->

      map = MapNode()
      map.set "a", 1
      map.delete "a"

      expect map.changes[1]
        .toEqual {change: {key: "a", event: "delete"}}

  xdescribe "map.on('change')", ->

    it "emits when a value is added or changed", ->

      map = MapNode()
      map.on "change", spy = jasmine.createSpy()
      map.set "a", 1
      map.set "a", 2

      expect spy.calls.count()
        .toBe 1

      expect spy.calls.argsFor 0
        .toEqual [change: {event: "change", key: "a", value: 2}]

  xdescribe "map.on('delete')", ->

    it "emits when a value is removed", ->

      map = MapNode()
      map.on "delete", spy = jasmine.createSpy()
      map.set "a", 1
      map.delete "a"

      expect spy.calls.count()
        .toBe 1

      expect spy.calls.argsFor 0
        .toEqual [change: {event: "delete", key: "a"}]

describe "ArrayNode", ->

  it "is created when an array is passed to `MapNode::set`", ->

    map = MapNode()
    map.set "a", []
    node = map.get "a"

    expect node instanceof ArrayNode
      .toBe yes

  it "is created when an array is passed to `MapNode::set`", ->

    map = MapNode()
    map.set "a", b: []
    node = map.get "a.b"

    expect node instanceof ArrayNode
      .toBe yes

  describe "array.push()", ->

    it "adds an item to the end of the array", ->

      map = MapNode()
      node = map.set "a", []
      node.push 1
      node.push 2

      expect node._values
        .toEqual [1, 2]

  describe "array.pushAll()", ->

    it "adds an array of items to the end of the array", ->

      map = MapNode()
      node = map.set "a", []
      node.pushAll [1, 2]
      node.pushAll [3, 4]

      expect node._values
        .toEqual [1, 2, 3, 4]

  describe "array.unshift()", ->

    it "adds an item to the start of the array", ->

      map = MapNode()
      node = map.set "a", []
      node.unshift 1
      node.unshift 2

      expect node._values
        .toEqual [2, 1]

  describe "array.unshiftAll()", ->

    it "adds an array of items to the start of the array", ->

      map = MapNode()
      node = map.set "a", []
      node.unshiftAll [1, 2]
      node.unshiftAll [3, 4]

      expect node._values
        .toEqual [3, 4, 1, 2]

  xdescribe "array.slice()", ->

  xdescribe "array.sort()", ->

  xdescribe "array.sortBy()", ->

  xdescribe "array.forEach()", ->

  xdescribe "array.filter()", ->

  xdescribe "array.map()", ->

  xdescribe "array.on('add')", ->

    it "emits when an item is added to the array", ->

  xdescribe "array.on('change')", ->

    it "emits when an item is replaced in the array", ->

  xdescribe "array.on('delete')", ->

    it "emits when an item is removed from the array", ->

fdescribe "ModelNode", ->

  User = null
  beforeAll ->
    User = do ->
      type = ModelNode.Type "User"
      type.defineModel {id: String, name: String}
      type.defineValues (options) -> options
      return type.build()

  it "is constructed by the user", ->
    map = MapNode()
    map.set "user", user = User {id: "0", name: "Alec"}
    expect map.get "user"
      .toBe user
    debugger

  it "validates its options", ->
    user = User {id: "0", name: "Alec"}
    expect -> user.id = 1
      .toThrowError "'id' must be a String!"

  describe "model.toString()", ->

    it "can stringify a new model", ->
      user = User {id: "0", name: "Alec"}
      expect user.toString()
        .toBe JSON.stringify {id: "0", name: "Alec"}

    it "can stringify nested models", ->
      user = User {id: "0", name: "Alec"}


xdescribe "ModelNode.Type", ->

  it "creates a model builder", ->
    Type = require "Type"
    type = ModelNode.Type()
    expect type instanceof Type.Builder
      .toBe yes

  describe "type.defineModel()", ->

    it "sets which keys should persist beyond reloads", ->

      model = do ->
        type = ModelNode.Type()
        type.defineModel {a: Number}
        return type.construct()

      # The model throws if not attached to a tree.
      tree = MapNode()
      tree._attachModel "foo", model

      # Persisted keys are validated when set.
      expect -> model.a = yes
        .not.toThrow()

      # This value is persisted.
      model.a = 1

      # This value is not.
      model.c = 1

      expect model._values
        .toEqual {a: 1}

      expect tree._values
        .toEqual {foo: {a: 1}}

  xdescribe "type.defineValues()", ->

  xdescribe "type.defineLoaders()", ->
