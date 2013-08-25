class ko.Data.Object
  @isSuperOf = (klass) ->
    klass

    while klass
      return true if klass == this
      klass = klass.__super__?.constructor
    false

  isSubclassOf: (klass) ->
    myClass = @constructor

    while myClass
      return true if myClass == klass
      myClass = myClass.__super__?.constructor
    false

  type: ->
    @constructor
