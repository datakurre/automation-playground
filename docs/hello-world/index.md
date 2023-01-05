# Summary: Hello World

*It's often the first, but it also works as the last.*

Let's summarize from the very beginning, how to build and execute a minimal dummy BPMN process where Zeebe is used to orchestrate Robot Framework.

```{bpmn-figure} hello-world
It's the time for Hello World!

Process: {download}`hello-world.bpmn`</br>
Robot: {download}`hello-world.zip`
```

## Start Camunda Modeler

![Camunda Modeler desktop icon](../playground/desktop-modeler.png)

## Choose Camunda 8 BPMN

```{figure} hello-world-modeler-01.png
:alt:
:width: 100%
```

## Draw minimal process flow

```{figure} hello-world-modeler-02.png
:alt:
:width: 100%
```

## Configure the service task

```{figure} hello-world-modeler-03.png
:alt:
:width: 100%
```

## Deploy model definition

The playground Zeebe matches *Camunda Platform 8 Self-Managed* with Cluster endpoint `http://localhost:26500` and *Authentication: None*.

```{figure} hello-world-modeler-04.png
:alt:
:width: 100%
```

## Start new process instance

```{figure} hello-world-modeler-05.png
:alt:
:width: 100%
```

## Open Zeebe Play

l![Zeebe Play desktop icon](../playground/desktop-play.png)

## Choose deployments

```{figure} hello-world-play-01.png
:alt:
:width: 100%
```

## Choose your deployment

```{figure} hello-world-play-02.png
:alt:
:width: 100%
```

## Choose the started instance

```{figure} hello-world-play-03.png
:alt:
:width: 100%
```

## See how task is waiting

```{figure} hello-world-play-04.png
:alt:
:width: 100%
```

## Open Robocorp Code

![Robocorp Code desktop icon](../playground/desktop-code.png)

## On the first run, wait...

```{figure} hello-world-code-01.png
:alt:
:width: 100%
```

## Create new robot

```{figure} hello-world-code-02.png
:alt:
:width: 100%
```

## Choose standard template

```{figure} hello-world-code-03.png
:alt:
:width: 100%
```

## Confirm children in workspace

```{figure} hello-world-code-04.png
:alt:
:width: 100%
```

## Give robot a name

```{figure} hello-world-code-05.png
:alt:
:width: 100%
```

## Align robot.yml with BPMN

```{figure} hello-world-code-06.png
:alt:
:width: 100%
```

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

```{figure} hello-world-code-07.png
:alt:
:width: 100%
```

## Start RCC

![RCC integration desktop icon](../playground/desktop-rcc.png)

## Watch RCC warming up

```{figure} hello-world-rcc-01.png
:alt:
:width: 100%
```

## Watch RCC working

```{figure} hello-world-rcc-02.png
:alt:
:width: 100%
```

## Open the log file link

```{figure} hello-world-rcc-03.png
:alt:
:width: 100%
```

## Return to Zeebe Play

```{figure} hello-world-play-05.png
:alt:
:width: 100%
```

That's all! It's time to congratulate yourself!

