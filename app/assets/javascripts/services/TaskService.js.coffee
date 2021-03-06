angular.module('ToDo').factory 'Task', ($resource, $http) ->
  class Task
    constructor: (taskListId, errorHandler) ->
      @service = $resource('/api/l/:task_list_id/tasks/:id',
        {task_list_id: taskListId, id: '@id'},
        {update: {method: 'PATCH'}})
      @errorHandler = errorHandler

      defaults = $http.defaults.headers
      defaults.patch = defaults.patch || {}
      defaults.patch['Content-Type'] = 'application/json'

    create: (attrs) ->
      new @service(task: attrs).$save ((task) -> attrs.id = task.id), @errorHandler
      attrs

    delete: (task) ->
      new @service().$delete {id: task.id}, (-> null), @errorHandler

    update: (task, attrs) ->
      new @service(task: attrs).$update {id: task.id}, (-> null), @errorHandler

    all: ->
      @service.query((-> null), @errorHandler)
