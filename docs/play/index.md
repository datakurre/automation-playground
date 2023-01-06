# Camunda execution exercises

As you  learned in [Camunda basics for execution](../execution/index), **Zeebe Play** makes it possible to execute and complete BPMN processes with {bpmn}`../bpmn/robot-task` service tasks even before those tasks have been implemented. Practice more of that to become truly familiar with

* {bpmn}`../bpmn/robot-task` service task configuration
* input and output mapping expressions
* exclusive gateway path condition expressions
* process deployments
* process instances
* completing processes using Zeebe Play.

Eventually you'll iterate enough to also learn configuration of **multi-instance** tasks.

## Sole service task

Let's start with simple:

1. Model a process with just a single {bpmn}`../bpmn/robot-task` service task.
2. Give the process **Name** and **ID** that you can recognize from **Zeebe Play** user interface.
3. Deploy process to **Zeebe**, start an instance of it and complete its {bpmn}`../bpmn/robot-task` service task as shown in the chapter [Execute with Zeebe Play](../execution/index.md#execute-with-zeebe-play).

```{bpmn-figure} sole-robot-task
{download}`sole-robot-task.bpmn`
```

## Add exclusive gateway

And then dive straight to the deep end...

1. Re-use the model from the previous exercise.
2. Add {bpmn}`../bpmn/exclusive-gateway` **exclusive gateway** after the sole {bpmn}`../bpmn/robot-task` service task and split the flow with a path to an alternative {bpmn}`../bpmn/end-event` end event: *Work not completed*.
3. Add local variable `completed` with FEEL expression `false` into {bpmn}`../bpmn/robot-task` service task **Inputs**.
4. Add process variable `workCompleted` with FEEL expression `completed` into {bpmn}`../bpmn/robot-task` service task **Outputs**. (You may check chapter [Feel expressions](../execution/index.md#feel-expressions) on how it evaluates local variable back into process scope.)
5. Add FEEL expression `workCompleted` as **condition** for the path from the {bpmn}`../bpmn/exclusive-gateway` exclusive gateway to the original {bpmn}`../bpmn/end-event` end event.
6. From the element context modeling palette, make the new path to the new {bpmn}`../bpmn/end-event` end event the *Default Flow*.
7. Deploy process to **Zeebe**, start two instances of it and complete their {bpmn}`../bpmn/robot-task` service tasks properly **with variables** as shown in the chapter [Execute with Zeebe Play](../execution/index.md#execute-with-zeebe-play) to reach both {bpmn}`../bpmn/end-event` end events (in separate instances, of course).

```{bpmn-figure} add-exclusive-gateway
{download}`add-exclusive-gateway.bpmn`
```

## Handle BPMN error

Let's then refactor a little and add a new feature:

```{figure} ../execution/play-throw-error-menu.png
:alt:
:align: right
```

1. Re-use the model from the previous exercise.
2. Remove {bpmn}`../bpmn/end-event` end event *Work not completed* and route the path to path back to the {bpmn}`../bpmn/robot-task` service task instead.
3. Add a {bpmn}`../bpmn/bpmn-error-boundary-event` error boundary event to {bpmn}`../bpmn/robot-task` service task with a path to a new {bpmn}`../bpmn/end-event` *Work abandoned*.
4. Configure the {bpmn}`../bpmn/bpmn-error-boundary-event` error boundary event to expect error with some specific error code.
5. Deploy process to **Zeebe**, start an instance of it and **Throw Error** with the code you just configured on its {bpmn}`../bpmn/robot-task` service task to reach the new {bpmn}`../bpmn/end-event` end event *Work abandoned*.

```{bpmn-figure} add-boundary-error
{download}`add-boundary-error.bpmn`
```

## Embedded sub-process wrapping

This iteration should not change any behavior of the process, but would make the model ready for **multi-instance**:

1. Re-use the model from the previous exercise.
2. Add **Expanded SubProcess** and drag everything else in the process inside it.
3. Add new {bpmn}`../bpmn/start-event` start event *Work requested* to lead the flow into the sub-process.
4. Add new {bpmn}`../bpmn/end-event` end event *Request completed* to end the process after sub-process.
5. Deploy process to **Zeebe** and start enough instances of it to test with **Zeebe Play** that all the previous features of the process remain.

```{bpmn-figure} wrap-with-subprocess
{download}`wrap-with-subprocess.bpmn`
```

## Multi-instance sub-process

Work often comes in batches, and BPMN supports that with multi-instance. An single BPMN element or even a complete embedded sub-process can be configured to be multi-instance, causing every item in a collection to be given its own instance of the element or sub-process. Let's make your freshly refactored sub-process to work over a collection:

1. Re-use the model from the previous exercise.
2. Add new {bpmn}`../bpmn/robot-task` service task *Get work items* between the main {bpmn}`../bpmn/start-event` start event and the sub-process.
3. Add local variable `results` with FEEL expression `[]` into {bpmn}`../bpmn/robot-task` service task **Inputs** and process variable `workItems` with FEEL expression `results` into {bpmn}`../bpmn/robot-task` service task **Outputs**.
4. [Toggle sequential multi-instance on the embedded sub-process](#toggle-element-multi-instance)
5. [Configure multi-instance properties](#configure-multi-instance-properties) on the sub-process as following:
   * Input collection: `workItems`
   * Input element: `workItem`
   * Output collection: `workItemsCompleted`
   * Output element: `workCompleted`
6. Add local variable `ẁorkCompleted` with FEEL expression `false` into the sub-process' **Inputs** to ensure it remain in sub-process' scope.
7. Deploy process to **Zeebe**, start an instances of it, open it at **Zeebe Play**, complete the first {bpmn}`../bpmn/robot-task` service task **with variables** `{"results": [null, null, null]}`, continue to complete the process and, eventually, confirm that it ends with `workItemsCompleted` process variable having meaningful result.

```{bpmn-figure} multi-instance-subprocess
{download}`multi-instance-subprocess.bpmn`
```

{download}`multi-instance-subprocess-with-timer.bpmn`

### Toggle element multi-instance

```{figure} modeler-multi-instance-menu.png
:alt:
:width: 100%
```

### Configure multi-instance properties

```{figure} modeler-multi-instance.png
:alt:
:width: 100%
```
