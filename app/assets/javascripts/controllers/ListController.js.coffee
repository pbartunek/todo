angular.module('ToDo').controller "ListController", ($scope, $timeout, $routeParams, Task, TaskList) ->

  $scope.init = () ->
    @taskService = new Task($routeParams.list_id, serverErrorHandler)
    @listService = new TaskList(serverErrorHandler)
    $scope.list = @listService.find $routeParams.list_id

  $scope.addTask = ->
    if $scope.taskDescription and $scope.taskDescription != 'later'
      task = @taskService.create(description: $scope.taskDescription)
      task.position = 1
      $scope.list.tasks.unshift(task)
      $scope.taskDescription = ''
    else
      alert('Invalid task description')

  $scope.deleteTask = (task) ->
    @taskService.delete(task)
    $scope.list.tasks.splice($scope.list.tasks.indexOf(task), 1)

  $scope.compleateTask = (task) ->
    @taskService.update(task, done: true, position: $scope.list.tasks.length)
    $scope.list.tasks.splice($scope.list.tasks.indexOf(task), 1)

  $scope.taskEdited = (task) ->
    @taskService.update(task, description: task.description)

  $scope.listEdited = (list) ->
    @listService.update(list, name: list.name)

  $scope.moveToTheTop = (task) ->
    task.position = 1
    $scope.positionChanged(task)
    $scope.list.tasks.splice($scope.list.tasks.indexOf(task), 1)
    $scope.list.tasks.unshift(task)

  $scope.moveToTheBottom = (task) ->
    task.position = $scope.list.tasks.length
    $scope.positionChanged(task)
    $scope.list.tasks.splice($scope.list.tasks.indexOf(task), 1)
    $scope.list.tasks.push(task)

  $scope.positionChanged = (task) ->
    @taskService.update(task, position: task.position)

  $scope.sortableOptions =
    stop: (e, ui) ->
      task = ui.item.scope().task

      newPosition = ui.item.index() + 1
      task.position = newPosition

      $scope.positionChanged(task)

  serverErrorHandler = ->
    alert("There was a server error, please reload the page and try again.")
