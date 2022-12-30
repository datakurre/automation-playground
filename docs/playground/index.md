# Playground introduction

Open automation playground desktop is a fully preconfigured virtual desktop environment for testing and learning how Robot Framework could be used to implement business process automation with Camunda Platform.


```{figure} ./desktop-full.png
:name: Desktop screenshot

Automation playground desktop with preconfigured shortcuts.
```

## Keyboard configuration

```{figure} ./desktop-kbd.png
:alt: kbd UI desktop icon
:align: left
```

The first thing you want to do after launching the playground, is to configure your playground's keyboard configuration to match your real keyboard.

```{rst-class} clear-both
```

```{figure} ./window-kbd.png
:alt:

At first, disable **Use system defaults**. Then **add** your own keyboard layout and **remove** all the other to make sure that yours stay always active.
```

Technically, the playground desktop is a NixOS based Xfce Desktop Environment, configured to look minimal and simple. To make it easier to ease focus on learning.

```{note}

Do not try to manually update the applications on the playround, or install new ones. Take it as a managed environment.
```


## Camunda Modeler

```{figure} ./desktop-modeler.png
:alt: Camunda Modeler desktop icon
:align: left
```

**Camunda Modeler** is the open source BPMN, DMN (and user task form) modeling tool made available for free by Camunda. The playground version comes also with Token Simulation plugin preinstalled.

```{figure} ./window-modeler.png
:alt:

Camunda Modeler can also deploy and start processes at the Zeebe running on the playground (at `http://localhost:26500/` without authentication). 
```


## Robocorp Code

```{figure} ./desktop-code.png
:alt: Robocorp Code desktop icon
:align: left
```

**Robocorp Code** is the open source Robot Framework development extension for VSCode (or VSCodium) made available for free by Robocorp. Together with Robot Framework LSP extension, it provides the best available Robot Framework based automation development experience.

```{figure} ./window-code.png
:alt:

Robocorp Code and Robot Framework LSP extensions together allow to debug Robot Framework automation packages with example data and visual breakpoints.
```

```{note}
Due to the setup of the playground, browser locator picker in Robocorp Code is not fully functional.
```


## RCC integration

```{figure} ./desktop-rcc.png
:alt: RCC integration desktop icon
:align: left
```

**RCC** icon launches a new terminal window with **parrot-rcc** Zeebe worker integration. It delegates Zeebe jobs and their variables to their respective Robot Framework automation packages, and submits responses back to Zeebe.

RCC is an open source tool by Robocorp for executing Robot Framework or Python automation packages (while implicitly also managing their dependencies). **parrot-rcc** is a bridge between RCC style "robots" using RPA Framework work items and Zeebe-run BPMN processes.

```{figure} ./window-rcc.png
:alt:

RCC integration is not run automatically, but can be started from the desktop when RCC execution is needed. It is run with debug logging for more insight how it works, and to ease access to the Robot Framework log files it creates.
```


## Zeebe Simple Monitor

```{figure} ./desktop-monitor.png
:alt: Zeebe Simple Monitor desktop icon
:align: left
```

**Zeebe Simple Monitor** is an open source web application for observing the running and completed processes on Zeebe engine. It is mainly intented for developer use, but it could be used as a starter for building for monitoring small production deployments [^footnote1]. *(Zeebe Simple Monitor is a Camunda Community project and its use is not officially supported by Camunda.)*

[^footnote1]: **Zeebe Simple Monitor** is [neither developed nor tested for production use](https://github.com/camunda-community-hub/zeebe-simple-monitor/issues/237), but thanks to the architecture of Zeebe, it cannot do any harm to production deployments. That said, as long as it supports only in-memory Hazelcast ring buffer for importing data from Zeebe, Zeebe Simple Monitor may not being able to receive all Zeebe data during high load.

```{figure} ./window-monitor.png
:alt:

**Zeebe Simple Monitor** is mostly read-only user-interface for observing processes. Yet, it does support creating new process instances and resolving incidents. *(Zeebe Play is a Camunda Community project and its use is not supported by Camunda.)*
```


## Zeebe Play

```{figure} ./desktop-play.png
:alt: Zeebe Play desktop icon
:align: left
```

**Zeebe Play** is an open source developer tool for playing with and learning how BPMN processes are being executed by Zeebe. Lately, Play has been getting more love from its developers than Simple Monitor, and is currently the recommended open source user interface for learning process automation and orchestration with Zeebe. *(Zeebe Simple Monitor is a Camunda Community project and its use is not officially supported by Camunda.)*

```{figure} ./window-play.png
:alt:

Zeebe Play allows to interact with the running processes with completing their service tasks, triggering timers and publishing BPMN messages directly from its user interface.
```


## DMN simulator

```{figure} ./desktop-dmn.png
:alt: DMN simulator desktop icon
:align: left
```

**DMN simulator** is a free to use web service from Camunda to try out how DMN tables get executed. After execution, it uses DMN table itself to visualize the effective rows.

```{figure} ./window-dmn.png
:name: DMN simulator icon

Unfortunately, there is no open source alternative for Camunda DMN simulator yet.
```


## FEEL repl

```{figure} ./desktop-feel.png
:alt: FEEL repl desktop icon
:align: left
```

**FEEL** icon launches a new terminal window with FEEL
repl (Read-Eval-Print-Loop) to help in learning FEEL
Friendly Enough Expression Language). It is a simple
functional expression language defined in DMN
specification, and is the only built-in expression
language supported by Zeebe.

```{figure} ./window-feel.png
:alt:

FEEL repl helps to test out FEEL expressions, before using them in BPMN or DMN.
```


## Mailhog

```{figure} ./desktop-mailhog.png
:alt: Mailhog desktop icon
:align: left
```

**Mailhog** is an open source development email service with both SMTP and HTTP API, and also nice web user interface for reading the mail. Traditional email is still in widely used, and sending email is popular way to communicate information in business processes. Mailhog make is possible to test out email tasks on the playground.

```{figure} ./window-mailhog.png
:alt:

On the playground, Mailhog waits for email at SMTP port is `1025`, and the web service is available at `http://localhost:8025/`.

```

## MinIO

```{figure} ./desktop-minio.png
:alt: MinIO desktop icon
:align: left
```
**MinIO** is a S3 compatible open source file storage. On the playground MinIO is used to store and manage Robot Framework execution logs and RPA Framework work item files. While MinIO is used transparently by the RCC integration (parrot-rcc), MinIO user interface could be used to access the files outside the processes, or clean up the storage.

```{figure} ./window-minio.png
:name: MinIO icon

Both the username and password for accessing MinIO on the playground is simply `minioadmin`. The playground comes with two buckets: *rcc* for Robot Framework execution logs and *zeebe* to store RPA Framework work item files by their related business processes.
```

## Vault

```{figure} ./desktop-vault.png
:alt: Vault UI desktop icon
:align: left
```

Hashicorp **Vault** is a popular open source secret management service. It is also a one possible option to provide secrets for Robot Framework automation run by RCC integration.

```{figure} ./window-vault.png
:name: Vault icon

The most simple Vault feature static key value style secret management. On the playground, the admin token to enter Vault is simply `secret`.
```

## Public folder

```{figure} ./desktop-public.png
:alt: Public-folder shortcut icon
:align: left
```

The playground, when run at Google Computing Engine, serves the folder at Public-folder shortcut at https://ipv4-address/pub/ to make it easier to export your work from the playground. Simply drag files here and they become downloadable to your local machine.

```{rst-class} clear-both
```

## Robots folder

```{figure} ./desktop-robots.png
:alt: Robots-folder shorcut icon
:align: left
```

Robots-folder icon a shortcut to the workspace shared with both Robocorp Code and RCC to develop and discover Robot Framework code packages.


```{rst-class} clear-both
```


## Tips and tricks

For known common use cases...

### Open command line

```{figure} ./tricks-shell.png

You may open command line terminal at the desktop or the open folder by selecting **Open Terminal Here** from the context menu (usually opened with a right click on mouse or track pad).
```

### Reset Zeebe

```{figure} ./tricks-reset.png

By typing **reset-zeebe** on terminal window command line, you'll be able to reset Zeebe, Zeebe Simple Monitor and Zeebe Play back to their clean initial states.
```

### Wrap folders for export

```{figure} ./tricks-zip.png
To make it easier to export your work from *Public** folder, you should archive them first into single easily downloadable files. This can be done by selecting the folders and files to be exported and then by selecting **Create Archive...** from the context menu (usually opened with a right click on mouse or track pad).
```

### More applications

It is possible to search for applications not included on the playground by opening a terminal and typing `nix search nixpkgs application` and, when lucky, run it by typing `nix run nixpkgs#application`. For example `nix run nixpkgs#gimp` or `nix run nixpkgs#libreoffice`. The first runs for these commands will take some time.

### Upgrading playground

If the playground upstream configuration has been updated, it is possible to do in-place upgrade for the playground virtual machine.

On Vagrant, open a new terminal window and type:
```shell
sudo nixos-rebuild switch --flake github:datakurre/automation-playground/main#vagrant
```

On Google Computing engine, open a new terminal window and type:
```shell
sudo nixos-rebuild switch --flake github:datakurre/automation-playground/main#gce
```
