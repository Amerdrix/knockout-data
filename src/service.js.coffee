class ko.Data.Service

  updateCollection: (collection, dataQuery) ->
    collection.loading(true)

    dataQuery
      .done (models) =>
        collection._insertItems(models, 0)
      .fail (data) =>
        collection.error(data)
      .always =>
        collection.loading(false)
