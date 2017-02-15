
Tree = require "../js/Tree"
MapNode = require "../js/MapNode"
ArrayNode = require "../js/ArrayNode"
ModelNode = require "../js/ModelNode"

describe "Tree", ->

  it "is backed by a MapNode", ->
    tree = Tree()
    expect tree._root instanceof MapNode
      .toBe yes

  describe "tree.set()", ->

    it "can set a new key", ->

      tree = Tree()
      tree.set "foo", 1

      expect tree._get "foo"
        .toBe 1

    it "supports objects as values", ->

      tree = Tree()
      tree.set "foo", input = {a: 1}
      output = tree._get "foo"

      expect output
        .toEqual input

      expect output
        .not.toBe input

    it "supports arrays as values", ->

      tree = Tree()
      tree.set "foo", input = [1]
      output = tree._get "foo"

      expect output
        .toEqual input

      expect output
        .not.toBe input

  describe "tree.get()", ->

    it "returns the value for primitives", ->

      tree = Tree()
      tree.set "foo", 1

      expect tree.get "foo"
        .toBe 1

    it "returns a `MapNode` for objects", ->

      tree = Tree()
      tree.set "foo", {}
      node = tree.get "foo"

      expect node instanceof MapNode
        .toBe yes

    it "returns an `ArrayNode` for arrays", ->

      tree = Tree()
      tree.set "foo", []
      node = tree.get "foo"

      expect node instanceof ArrayNode
        .toBe yes

    it "supports keys with dot-notation", ->

      tree = Tree()
      tree.set "foo", {bar: 1}
      value = tree.get "foo.bar"

      expect value
        .toBe 1

  describe "tree.delete()", ->

    it "can remove a primitive value", ->

      tree = Tree()
      tree.set "foo", 1
      tree.delete "foo"

      expect tree.get "foo"
        .toBe undefined

    it "can remove a nested value", ->

      tree = Tree()
      tree.set "foo", {bar: 1}
      tree.delete "foo.bar"

      expect tree.get "foo.bar"
        .toBe undefined

      unless node = tree.get "foo"
        return fail "Expected 'foo' to exist."

      expect node._values
        .toEqual {}

    it "can remove a MapNode", ->

      tree = Tree()
      tree.set "foo", {bar: 1}
      tree.delete "foo"

      expect tree.get "foo"
        .toBe undefined

      expect tree._nodes["foo"]
        .toBe undefined

    it "can remove an ArrayNode", ->

      tree = Tree()
      tree.set "foo", [1]
      tree.delete "foo"

      expect tree.get "foo"
        .toBe undefined

      expect tree._nodes["foo"]
        .toBe undefined

  xdescribe "tree.merge()", ->

  xdescribe "tree.forEach()", ->

  xdescribe "tree.filter()", ->

  xdescribe "tree.map()", ->

  describe "tree.changes", ->

    it "tracks `tree.set`", ->

      tree = Tree()
      tree.set "a", 1
      tree.set "a", 2

      expect tree.changes[0]
        .toEqual {change: {key: "a", event: "add", value: 1}}

      expect tree.changes[1]
        .toEqual {change: {key: "a", event: "change", value: 2}}

    it "tracks `tree.delete`", ->

      tree = Tree()
      tree.set "a", 1
      tree.delete "a"

      expect tree.changes[1]
        .toEqual {change: {key: "a", event: "delete"}}

  describe "tree.on('add')", ->

    it "emits when a value is added to the tree", ->

      tree = Tree()
      tree.on "add", spy = jasmine.createSpy()
      tree.set "a", 1

      expect spy.calls.argsFor 0
        .toEqual [change: {event: "add", key: "a", value: 1}]

  describe "tree.on('change')", ->

    it "emits when a value is replaced in the tree", ->

      tree = Tree()
      tree.on "change", spy = jasmine.createSpy()
      tree.set "a", 1
      tree.set "a", 2

      expect spy.calls.count()
        .toBe 1

      expect spy.calls.argsFor 0
        .toEqual [change: {event: "change", key: "a", value: 2}]

  describe "tree.on('delete')", ->

    it "emits when a value is removed from the tree", ->

      tree = Tree()
      tree.on "delete", spy = jasmine.createSpy()
      tree.set "a", 1
      tree.delete "a"

      expect spy.calls.count()
        .toBe 1

      expect spy.calls.argsFor 0
        .toEqual [change: {event: "delete", key: "a"}]

  xdescribe "tree.on('all')", ->

    it "is called for any change to the entire tree", ->

describe "ArrayNode", ->

  it "is created when an array is passed to `Tree::set`", ->

    tree = Tree()
    tree.set "a", []
    node = tree.get "a"

    expect node instanceof ArrayNode
      .toBe yes

  it "is created when an array is passed to `MapNode::set`", ->

    tree = Tree()
    tree.set "a", b: []
    node = tree.get "a.b"

    expect node instanceof ArrayNode
      .toBe yes

  describe "array.push()", ->

    it "adds an item to the end of the array", ->

      tree = Tree()
      node = tree.set "a", []
      node.push 1
      node.push 2

      expect node._values
        .toEqual [1, 2]

  describe "array.pushAll()", ->

    it "adds an array of items to the end of the array", ->

      tree = Tree()
      node = tree.set "a", []
      node.pushAll [1, 2]
      node.pushAll [3, 4]

      expect node._values
        .toEqual [1, 2, 3, 4]

  describe "array.unshift()", ->

    it "adds an item to the start of the array", ->

      tree = Tree()
      node = tree.set "a", []
      node.unshift 1
      node.unshift 2

      expect node._values
        .toEqual [2, 1]

  describe "array.unshiftAll()", ->

    it "adds an array of items to the start of the array", ->

      tree = Tree()
      node = tree.set "a", []
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

xdescribe "ModelNode", ->

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
      tree = Tree()
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
