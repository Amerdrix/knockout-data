class ko.Data.Factory extends ko.Data.Object
  @singular = null
  @plural = null

  constructor: () ->

  create: (json) ->
    ko.Data.Cache.cacheFor(@model).insert_or_update_and_aquire json.id, (existing) =>
      model = existing || new @model()

      model.id = json.id
      _(@model.attributes()).each (attr) =>

        switch attr.macro
          when ko.Data.Model.ATTR_KEY
            @_applyAttribute(attr, model, json)
          when ko.Data.Model.HAS_MANY_KEY
            @_applyHasMany(attr, model, json)

      model.loading(false)
      model

  _applyAttribute: (attribute, model, json) ->
    model[attribute.name](json[attribute.name])

  _applyHasMany: (attribute, model, json) ->

    if attribute.type?
      factory = ko.Data.__factories[attribute.type]
    else
      factory = ko.Data.__factories[attribute.name]

    # if the resource is nested in the data
    if json.hasOwnProperty(attribute.name)
      collection = factory.create(json[attribute.name])

    # the resource may be a list of id's
    else
      ids_name = factory.singular + attribute.id_suffix

      cache = ko.Data.Cache.cacheFor(factory.model)

      collection = json[ids_name].map (id) ->
        cache.aquire_or_insert(id, -> new factory.model(id))

    model[attribute.name](collection)
