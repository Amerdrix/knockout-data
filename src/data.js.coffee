modelNameTransform = (name) ->  name.match("^(.+?)(Model)?$")[1]
factoryNameTransform = (name) -> name.match("^(.+?)(Factory)?$")[1]

findClasses = (namespace, targetClass, nameTransform, depth = 1) ->
  result = []

  _(namespace).each (type, name) ->
    if targetClass.isSuperOf(type)

      name = nameTransform(name) if nameTransform?
      result.push({name: name, type: type})

    if depth > 0

      $.merge(result, findClasses(type, targetClass, nameTransform, depth - 1))

  result

createModel = (modelMeta) ->

  # Inflect the name model
  lowerModelName = modelMeta.name.toLocaleLowerCase()
  modelMeta.type.singular ||= lowerModelName
  modelMeta.type.plural ||= "#{lowerModelName}s"

createFactory = (factoryMeta) ->
  # Get the Model class
  modelType = factoryMeta.model || ko.Data.__modelsMeta[factoryMeta.name].type

  # Inflect the name model
  singular = factoryMeta.type.singular || modelType.singular
  plural = factoryMeta.type.plural || modelType.plural

  # create the new factories
  fatory = new factoryMeta.type()
  collection_factory = new ko.Data.CollectionFactory(fatory)

  # Configure factory properties
  collection_factory.model = fatory.model = modelType
  collection_factory.plural = fatory.plural = plural
  collection_factory.singular = fatory.singular = singular

  # Create mapping to factory
  ko.Data.__factories[modelType] = fatory
  ko.Data.__factories[singular] = fatory
  ko.Data.__factories[plural] = collection_factory

ko.Data.init = (root) ->
  models = findClasses(root, ko.Data.Model, modelNameTransform)
  factories = findClasses(root, ko.Data.Factory, factoryNameTransform)

  # create a mapping between classes / names and model metadata.
  # this allows us to find metadata for a model either by the
  # class, or the name.
  ko.Data.__modelsMeta = _.object(_(models).map((m) -> m.type), models)
  $.extend(ko.Data.__modelsMeta, _.object(_(models).map((m) -> m.name), models))

  _(models).each(createModel)

  # Create factories which are explititly defined
  _(factories).each(createFactory)

  # Create an implicit factory for all other models
  _(models).chain()
    .reject (m) ->
      ko.Data.__factories[m.type]
    .each (model) ->
      createFactory(type: ko.Data.Factory, model: model.type)

  ko.Data.__defaultService = new ko.Data.RESTService()
