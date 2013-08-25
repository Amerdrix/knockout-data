class ko.Data.CollectionFactory

  constructor: (@_proxy) ->

  create: (data) ->
    _(data).map (object) =>
      @_proxy.create(object)
