class ko.Data.Collection

  constructor: (@_modelType) ->
    @items = ko.observableArray()
    @_items = @items()
    @loading = ko.observable()
    @error = ko.observable()

    ko.utils.extend(@items, _.omit(this))
    return @items

  # Internal: Inserts items into the collection, if there is already an object at the
  # position, it is replaced.
  _insertItems: (items, offset) ->
    _(items).each (item, index) =>
      index = index + offset

      if @_items[index]?
        @_items[index] = item
      else
        this.push(item)
