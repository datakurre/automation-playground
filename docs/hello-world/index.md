# Summary: Hello World

*It's often the first, but it also works as the last.*

Let's summarize from the very beginning, how to build and execute a minimal dummy BPMN process where Zeebe is used to orchestrate Robot Framework.

```{bpmn-figure} hello-world
It's the time for Hello World!

Process: {download}`hello-world.bpmn`</br>
Robot: {download}`hello-world.zip`
```

## Start Camunda Modeler

![](../playground/desktop-modeler.png)

## Choose Camunda 8 BPMN

![](./hello-world-modeler-01.png)

## Draw minimal process flow

![](./hello-world-modeler-02.png)

## Configure the service task

![](./hello-world-modeler-03.png)

## Deploy model definition

The playground Zeebe matches *Camunda Platform 8 Self-Managed* with Cluster endpoint `http://localhost:26500` and *Authentication: None*.

![](./hello-world-modeler-04.png)

## Start new process instance

![](./hello-world-modeler-05.png)

## Open Zeebe Play

![](../playground/desktop-play.png)

## Choose deployments

![](./hello-world-play-01.png)

## Choose your deployment

![](./hello-world-play-02.png)

## Choose the started instance

![](./hello-world-play-03.png)

## See how task is waiting

![](./hello-world-play-04.png)

## Open Robocorp Code

![](../playground/desktop-code.png)

## On the first run, wait...

![](./hello-world-code-01.png)

## Create new robot

![](./hello-world-code-02.png)

## Choose standard template

![](./hello-world-code-03.png)

## Confirm children in workspace

![](./hello-world-code-04.png)

## Give robot a name

![](./hello-world-code-05.png)

## Align robot.yml with BPMN

![](./hello-world-code-06.png)

Update `tasks:` to have a task with your service task definition type `Hello World` and map it to the default task in the standard template in its tasks.robot with `robotTaskName: Minimal task`.

```yaml
tasks:
  # Task names here are used when executing the bots, so renaming these is recommended.
  Hello World:
    robotTaskName: Minimal task

condaConfigFile: conda.yaml

environmentConfigs:
  - environment_windows_amd64_freeze.yaml
  - environment_linux_amd64_freeze.yaml
  - environment_darwin_amd64_freeze.yaml
  - conda.yaml

artifactsDir: output  

PATH:
  - .
PYTHONPATH:
  - .

ignoreFiles:
  - .gitignore

# For more details on the format and content:

# https://github.com/robocorp/rcc/blob/master/docs/recipes.md#what-is-in-robotyaml
```

## Wrap robot

With **Open Robot Terminal** and typing `wrap`, the playground alias for `rcc robot wrap`.

![](./hello-world-code-07.png)

## Start RCC

![](../playground/desktop-rcc.png)

## Watch RCC warming up

![](./hello-world-rcc-01.png)

## Watch RCC working

![](./hello-world-rcc-02.png)

## Open the log file link

![](./hello-world-rcc-03.png)

## Return to Zeebe Play

![](./hello-world-play-05.png)

That's all! It's time to congratulate yourself!

