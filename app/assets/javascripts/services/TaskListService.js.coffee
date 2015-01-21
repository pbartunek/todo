angular.module('ToDo').factory 'TaskList', ($resource, $http) ->
  class TaskList
    constructor: (errorHandler) ->
      @service = $resource('/api/l/:id', {id: '@id'}, {update: {method: 'PATCH'}})
      @errorHandler = errorHandler

    create: (attrs, successHandler) ->
      new @service(list: attrs).$save ((list) -> successHandler(list)), @errorHandler

    delete: (list) ->
      new @service().$delete { id: list.id}, (-> null), @errorHandler

    update: (list, attrs) ->
      new @service(list: attrs).$update {id: list.id}, (-> null), @errorHandler

    all: ->
      @service.query((-> null), @errorHandler)

    find: (id, successHandler) ->
      @service.get(id: id, ((list) ->
        successHandler?(list)
        list),
        @errorHandler)
