class ko.Data.Model extends ko.Data.Object
  @ATTR_KEY = ATTR_KEY =  'a'
  @HAS_MANY_KEY = HAS_MANY_KEY = 'hm'
  @HAS_ONE_KEY = HAS_ONE_KEY = 'ho'

  @attributes = ->
    @_attributes ||= {}

  @attr = (name, type) ->
    @attributes()[name] = {name: name, macro: ATTR_KEY, type: type}

  @hasMany = (name, type) ->
    @attributes()[name] =
      name: name
      macro: HAS_MANY_KEY
      type: type
      id_suffix:  "_ids"


  # Queries the data service for a single item.
  #
  # id: the ID of the model to return
  # options: A set of options to configure how the query is performed
  #   service - The service to get the data from
  #
  # Returns an instance of the model, posibily without querying the service
  @find = (id, options = {}) ->
    return null unless id?

    id = Number(id)
    service = options.service || ko.Data.__defaultService
    type = this
    cache = ko.Data.Cache.cacheFor(this)
    cache.aquire_or_insert id, ->
      model = new type(id)
      service.update(model)
      model

  # Queries the data service for a collection of items.
  #
  # queryOptions: Options which will be passed to the datastore to shape resulting data
  # options: A set of options to configure how the query is performed
  #   into - The collection which to place results, and return
  #   service - The service to get the data from
  #
  # Returns a new collection, or the collection passed to insert. This collection will be
  # populated (posibly asyncronously) by the data service.
  @query = (queryOptions = {}, options={}) ->
    collection = options.into || new ko.Data.Collection(this)
    service = options.service || ko.Data.__defaultService

    if collection._modelType != this
      throw "Cannot insert #{this} into collection of #{collection._modelType}"

    return collection if collection.loading()

    dataQuery = service.query(this, queryOptions)
    service.updateCollection(collection, dataQuery)

    collection

  @hasOne = (name, type) ->
    @attributes()[name] = {name: name, macro: HAS_ONE_KEY, type: type}

  constructor: (id)->
    @id = id
    @_buildAttributes()

  _buildAttributes: ->
    @loading = ko.observable(true)

    _(@type().attributes()).each (attr, name) =>
      switch attr.macro
        when ATTR_KEY
          this[name] = @_buildAttribute(attr)
        when HAS_ONE_KEY
          this[name] = @_buildHasOne(attr)
        when HAS_MANY_KEY
          this[name] = @_buildHasMany(attr)
        else
          throw "Unknow attribute type: #{attr.macro}"

  _buildAttribute: ->
    ko.observable()

  _buildHasOne: ->
    ko.observable()

  _buildHasMany: ->
    ko.observableArray()

