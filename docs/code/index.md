# Robocorp Code in action

It's now time to write our first Zeebe orchestrated Robot Framework automation. In [a previous exercise](../speech/index.md) we had {bpmn}`../bpmn/user-task` user task for just throwing a dice. Let's implement automation for a process with similar task:

```{bpmn-figure} speech-request
{download}`speech-request.bpmn`
```

We can also reuse the same DMN:<br/>
{download}`../speech/pick-a-sentence.dmn`{download}`../speech/pick-a-sentence.html`


## Launch Robocorp Code

```{figure} ../playground/desktop-code.png
:alt:
```

## Create a new robot

```{figure} code-create.png
:alt:
:width: 100%
```

### Create as child folder

```{figure} code-child.png
:alt:
:width: 100%
```

### Choose standard robot

```{figure} code-standard.png
:alt:
:width: 100%
```

### Give robot name

```{figure} code-dice.png
:alt:
:width: 100%
```

## Implement robot tasks

```{figure} code-tasks.png
:alt:
:width: 100%
```

### tasks.robot

```robotframework
*** Settings ***

Library    RPA.Robocorp.WorkItems
Library    random

*** Tasks ***

Throw D20
    ${min}=    Convert To Number    1
    ${max}=    Convert To Number    20
    ${result}    Randint    ${min}    ${max}

    Create Output Work Item
    Set Work Item Variable    result    ${result}
    Save Work Item
```

## Configure robot tasks

```{figure} code-robot.png
:alt:
:width: 100%
```

### robot.yaml

```yaml
# For more details on the format and content:
# https://github.com/robocorp/rcc/blob/master/docs/recipes.md#what-is-in-robotyaml

tasks:
  # Task names here are used when executing the bots, so renaming these is recommended.
  Throw D20:
    robotTaskName: Throw D20

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
```

## Dry run robot

```{figure} code-dryrun.png
:alt:
:width: 100%
```

## Wrap robot package

```{figure} code-wrap.png
:alt:
:width: 100%
```

## Launch RCC integration

```{figure} ../playground/desktop-rcc.png
:alt:
```

### RCC loads robots

```{figure} rcc-start.png
:alt:
:width: 100%
```

### RCC debug logging

```{figure} rcc-running.png
:alt:
:width: 100%
```

### RCC logs at S3

```{figure} rcc-log.png
:alt:
:width: 100%
```

## Launch Zeebe Play

```{figure} ../playground/desktop-play.png
:alt:
```

## Process completed

```{figure} play-speech.png
:alt:
:width: 100%
```

## Resource summary

{download}`speech-request.bpmn`<br/>
{download}`../speech/pick-a-sentence.dmn`{download}`../speech/pick-a-sentence.html`<br/>
&nbsp;{bpmn}`../bpmn/robot-task`&nbsp; {download}`dice.zip`


