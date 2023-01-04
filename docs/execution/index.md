# Camunda basics for execution

After learning [modeling with Camunda Modeler](../modeling/index), you are only few steps away from modeling also for execution. Before you start, please, **open the properties panel of Camunda Modeler**, either by clicking its handle on the right side of the modeler window or choosing *Window -> Toggle Properties Panel* from the menu bar.

```{figure} modeler-empty.png
:alt:
:width: 100%
```

Let's now learn the minimum requirements for configuring a BPMN model to be ready for execution.

## Process name and ID

Every BPMN model (process definition) for executable processes should have descriptive display **Name** and unique definition **ID** set, and **Executable** option checked. These are available on the properties panel when no element selected.

```{figure} modeler-properties-process.png
:alt:
:width: 100%
```

## Service task configuration

At first, use element **context modeling palette** to turn a plain task into a **Service task**. Once you see service task's properties panel, the only really required property there is the service task **Type** on **Task definition**. This is the identifier you'll be giving to your automation code executing the task later. The type should be unique on your environment, and it is up to you to guard that.

```{figure} modeler-properties-task.png
:alt:
:width: 100%
```

The Name and ID of the task has no effect on the execution. Choose a **Name** that describes the task work with verb in the domain language of the process. Having a naming policy for **ID** would help to identify service tasks from your logs. In addition, the playground has a feature to show a Robot Framework logo for service tasks with `robot` in their ID. (The feature is case insensitive.)

## Inputs and outputs

Input and output mappings on the properties panel allow to adapt domain specific process to more generic task implementations. All Camunda BPMN engines implement **nested variable scopes** by BPMN elements: 

* Element may have local variables not propagated back to process level.
* Variables introduced in **Inputs**, are only available within the element.
* Variables introduced in **Inputs**, and set as local by task implementation (*job worker*), are only propagated back to process through **Outputs**.
* For Zeebe, variable assignment values on Inputs and Outputs must be valid FEEL expressions.

```{figure} modeler-properties-inputs.png
:alt:
:width: 100%

In our example, at service task, we use **Inputs** to set local variable `completed` with value `false`, expect the service task worker to update it, and then map its final using Outputs as variable `workCompleted` having the value of executed FEEL expression `completed` (which evaluates to the value of that local task variable during output mapping).
```

## Gateway paths

How do {bpmn}`../bpmn/exclusive-gateway` exclusive gateways know which path should the token be directed to? Well, you have to tell them, how to.

At first, one of the outgoing paths from an exclusive gateway, could be configured as the **default** path from the element **context modeling palette of the path**. The rest of the paths should have **condition** expression defined.

```{figure} modeler-properties-gateway.png
:alt:
:width: 100%

In our example, the exclusive gateway has two ongoing paths. The default path with label **No** goes back join the main flow just before the service task. The other path with label **Yes** is followed when FEEL expression `workCompleted` evaluates to `true`. That happen when the process variable `workCompleted` has value `true`.
```

```{warning}
If expression for more than one path on a exclusive gateway results in *true*, a runtime incident will be raised.
```

## Feel expressions

What are those FEEL expressions required for service task inputs, service task outputs and exclusive gateway conditions?

FEEL stands for *Friendly Enough Expression Language*. It is a pretty simple functional expression language for manipulating or testing process variables. With Camunda tools we use [Camunda FEEL implementation](https://camunda.github.io/feel-scala/docs/reference/). That said, unofficial [FEEL playground](https://nikku.github.io/feel-playground/) is still probably the easiest place to learn how to use FEEL expressions to map or test process variables.

```{raw} html
<iframe src="../_static/feel/?e=user.name&c={%0A++%22completed%22%3A+true%2C%0A++%22user%22%3A+{%0A++++%22name%22%3A+%22Jane+Doe%22%2C%0A++++%22email%22%3A+%22jane.doe%40example.com%22%2C%0A++++%22consent%22%3A+true%0A++}%0A}&t=expression" width="100%" height="400"></iframe>
<p style="margin-top: 1em">
Use the embedded playground above to practice, how to access task variable
<code class="docutils literal notranslate"><span class="pre">completed</span></code>,
then add it into <stong>Variables</strong> as
<code class="docutils literal notranslate"><span class="pre">workCompleted</span></code>
and access it again. You have now implemented the expressions used in our example.
</p>
```

## Executable process

Before deploying a model, it must be saved and given a filename. This is the model we've been building so far:

```{bpmn-figure} request-work
{download}`request-work.bpmn`
```

## Deploy to Zeebe

The bottom toolbar of the modeler, has a dedicated *Rocket button* for deploying a model diagram to Zeebe engine. The playground Zeebe matches *Camunda Platform 8 Self-Managed* with Cluster endpoint `http://localhost:26500` and *Authentication: None*.

```{figure} modeler-deploy.png
:alt:
:width: 100%

Just press **Deploy**.
```

## Start a new instance

There a are many ways to start a new process instance from deployed definition. A production solution being usually a custom user-interface or by a microservice through an API. While stil llearning, however, it is very convenient start the process directly from Modeler, from **Play button** on the bottom toolbar.

```{figure} modeler-start.png
:alt:
:width: 100%

Just press **Start**.
```

## Execute with Zeebe Play

[Zeebe Play](https://github.com/camunda-community-hub/zeebe-play) is an open source web application for [Zeebe](https://camunda.com/platform/zeebe/) to play with processes while developing them. On the playground, Zeebe Play is opened from the **Play** desktop shortcut.

![](../playground/desktop-play.png)


### Zeebe Welcome

Next, find your process by choosing **deployments** from Zeebe Play welcome screen.

```{figure} play-welcome.png
:alt:
:width: 100%
```

### Choosing deployment

Whenever you deploy a model diagram with an existing process definition id, it will become a new version of the existing process. Zeebe Play lists every deployment and its version on separate rows. To continue, try to find the latest one of the process you were developing.

```{figure} play-deployments.png
:alt:
:width: 100%
```

### Choosing instance

Once you've find the deployment, Zeebe Play lists every instance it knows on the chosen deployment, whether active, completed or manually terminated. Choose an active instance or start a new instance directly from Zeebe Play.

```{figure} play-instances.png
:alt:
:width: 100%
```

### Complete task

```{figure} play-complete.png
:alt:
:align: right
```

Zeebe Play show executed paths as green. Whenever there is a token alive on actionable element, it will show **action buttons** on top of the elements for completing them.

```{figure} play-instance.png
:alt:
:width: 100%

Simply click the blue button with white checkmark on the left corner of the active service task to complete it.
```

### Refresh for results

```{figure} play-reload.png
:alt:
:align: right
```

Currently Zeebe Play may not yet update the instance view automatically, but you need to manually click the highlighted button *You may need to reload the page manually* to see the changes.

```{figure} play-instance-redo.png
:alt:
:width: 100%

Because the task *Work* on the example process was completed without payload to update task variables with, the variable `completed` remained `false` and process was routed back to the task.
```

### Complete with variables

```{figure} play-with-variables-menu.png
:alt:
:align: right
```

Just clicking the Zeebe action button on service tasks completes the tasks without payload. Fortunately, the dropdown on Zeebe Play action buttons, also offer to complete **with Variables**. Select it to complete the task (*Complete job* for the task) with the following variables (JSON):

```json
{"completed": true}
```

```{figure} play-with-variables.png
:alt:
:width: 100%
```


### Process completed

Finally, refresh the Zeebe Play view on process instance for one more time and observe the process being completed.

```{figure} play-completed.png
:alt:
:width: 100%
```

That's how Zeebe Play allows us to play with the process and manually confirm that we have modeled its execution properly (without really implementing any of its service tasks yet).

