class ko.Data.Cache

  @cacheFor = (object) ->
    @_caches ||= {}
    @_caches[object] ||= new this()

  constructor: ->
    @_map = {}

  aquire_or_insert: (key, method) ->
    container = @_map[key]
    unless container?
      container = {}
      container.item = method()
      container.count = 0
      @_map[key] = container

    container.count += 1
    container.item

  insert_or_update_and_aquire: (key, method) ->
    container = @_map[key]
    unless container?
      container = {}
      container.count = 0
      @_map[key] = container

    container.item = method(container.item)
    container.count += 1
    container.item

  release: (key) ->
    container = @_map[key]

    if container?
      container.count -= 1

    if container.count is 0
      @_map.delete(key)
