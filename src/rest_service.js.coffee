#= require './service'

class ko.Data.RESTService extends ko.Data.Service

  update: (model) ->
    uri = @_pathForSingularResource(model)
    @_requestAndProcess(uri)

  query: (modelType, options) ->
    uri = @_pathForResourceCollection(modelType)
    request = @_requestAndProcess(uri, options)
    request.then(
      ((data) -> data[modelType.plural]),
      ((error) -> error.responseText)
    )

  _buildUri: (path) ->
    format = '.json' unless ko.Data.RESTService.appendFormat is false
    root = ko.Data.RESTService.root || ''
    root + "/" + path + format

  _pathForSingularResource: (model) ->
    "#{model.type().plural}/#{ model.id}"

  _pathForResourceCollection: (type) ->
    type.plural

  _pathForHasOneAssosiation: (assosiation) ->

  _pathForHasManyAssosiation: (assosiation) ->

  _requestAndProcess: (path, data={}, opt={}) ->
    opt.url = @_buildUri(path)
    opt.data = data

    request = $.ajax(opt)

    request.then (data) ->
      result = {}
      _(data).each (data, key) ->
        factory = ko.Data.__factories[key]
        result[key] = factory.create(data) if factory?

      result
