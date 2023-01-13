# DMN, user tasks and forms

Until now, we have focused on only one BPMN activity type: {bpmn}`../bpmn/robot-task` *service task*. But there are more. Let's forget service tasks for the next example, and dive into {bpmn}`../bpmn/business-rule-task` **business rule task** and {bpmn}`../bpmn/user-task` **user task** instead. They play well together.


## Collect facts, make decisions

Here's an imaginary process for selling bus tickets:

1. Driver looks into passenger to collect facts about them. Passenger may show some proofs to be eligble for discount.
2. Based on the collected facts, driver decides, into which price group the passenger belongs to.
3. Driver charges the passenger and delivers the ticket.

```{bpmn-figure} bus-ticket-sale
In this naive interpretation of the bus ticket sale process, **fact collection** is modeled as {bpmn}`../bpmn/user-task` **user task** and the **decision** made from the facts as {bpmn}`../bpmn/business-rule-task` **business-rule-task**. The rest of the tasks are left {bpmn}`../bpmn/manual-task` manual for now.
{download}`bus-ticket-sale.bpmn`
```


## Automating repeatable decisions

**DMN** stands for Decision Model and Notation. It is a standard approach for describing and modeling repeatable business decisions, and like BPMN, it is designed to be readable by business and IT users alike. **DMN is the recommended way to implement** {bpmn}`../bpmn/business-rule-task` **business rule tasks** for most use cases.

```{tip}
For really learn DMN, check [Camunda DMN Tutorial](https://camunda.com/dmn/) and take a free [Camunda DMN online course](https://academy.camunda.com/camunda-dmn).
```

This is, how a DMN decision table for deducing bus ticket price from the facts known about a passenger, could look like (designed using Camunda Modeler):

```{dmn-html} bus-ticket-price
```
{download}`bus-ticket-price.dmn`

```{note}
DMN decision table input rules are written as FEEL unary tests, and output results as FEEL expressions.
```


## Camunda DMN simulator

```{figure} ../playground/desktop-dmn.png
:alt: DMN simulator desktop shortcut
:align: right
```

The easiest way to understand, how and why DMN is used, is to try it out. Until a good open source solution for playing with DMN emerges, it is possible try out and learn how DMN models work with [Camunda DMN Simulator](https://consulting.camunda.com/dmn-simulator/).

Simply drag and drop DMN files into the simulator running on a browser window, and they are ready for play:

```{figure} dmn-simulator.png
:alt: Trying out bus-ticket-price.dmn with Camunda DMN Simulator
:width: 100%
```

```{warning}
This {download}`bus-ticket-price.dmn` is designed for [Camunda Platform 7](https://camunda.com/platform-7/) to support [Camunda's DMN Simulator](https://consulting.camunda.com/dmn-simulator/). Unfortunately, the simulator does not yet support all value types available in Zeebe.
```

## DMN beats "just coding it"

If a business decision can be described with a limited set deterministic rules for matching arguments to one or more resolutions, there is very high chance that DMN beats the traditional programming languages.

Decision tables

* are more visual than traditional code
* have less degrees of freedoms to do mistakes
* are usually more formal and easier to validate
* can be maintained separately from code (BPMN).

For example, our example decision table is a simple DMN, but could still already result in ugly nested *if-then-else* expressions with traditional "just coding it" approach:

```{dmn-html} bus-ticket-price-zeebe
```
<br/>

## Camunda Forms for user tasks

In our example, the DMN {bpmn}`../bpmn/business-rule-task` business rule task *Choose price*, depends on {bpmn}`../bpmn/user-task` user task *Recognize passanger type* to provide input facts for the decision table.

Most common way to implement a user task is to show the user a form. Camunda has developed its own [open source web form framework](https://bpmn.io/toolkit/form-js/), which has its editor integrated into Camunda Modeler. While a web form might not be the best possible final user interface for this process, it's still good enough for prototyping it.

```{figure} modeler-form-playground.png
:alt:
:width: 100%

Camunda Modeler includes [@bpmn-io/form-js-playground](https://www.npmjs.com/package/@bpmn-io/form-js-playground) for designing and previewing [@bpmn-io/form-js](https://bpmn.io/toolkit/form-js/) HTML forms, also known as Camunda Forms. To bind form with {bpmn}`../bpmn/user-task` user tasks on Zeebe, form JSON schema must be manually copied and pasted into task's BPMN properties.
```

## Configuring forms and decisions

Let's now put all this together into the next iteration of our example processs:

1. At first, {bpmn}`../bpmn/user-task` user task *Submit passanger fact* is completed with submitting required variables using a Camunda Form. *(In reality, this is where passengers scan their personal travel card.)*
2. Then, {bpmn}`../bpmn/business-rule-task` business rule task *Choose price* will take the submitted variables and decide the price by its rules.
3. The rest of the process is still left all manual, because this time we focus on, how forms and DMN works together.

```{bpmn-figure} bus-ticket-sale-executable
{download}`bus-ticket-sale-executable.bpmn`
```
Form and DMN:<br/>
{download}`bus-ticket-price.form`<br/>
{download}`bus-ticket-price-zeebe.dmn`{download}`bus-ticket-price-zeebe.html`

### Configuring Camunda Form

```{figure} bus-ticket-sale-user-task.png
:alt:
:width: 100%
This is how a {bpmn}`../bpmn/user-task` user task is configured with Camunda Form: by copying and pasting form's JSON schema in Camunda Modeler from the form editor's source view into dedicated BPMN editor task property field. Whether the form is actually displayed to end-users, depends on end-user user interface support for open source [@bpmn-io/form-js](https://bpmn.io/toolkit/form-js/).
```

### Configuring DMN decision table

```{figure} bus-ticket-sale-business-rule.png
:alt:
:width: 100%
This is how a {bpmn}`../bpmn/business-rule-task` business rule task is configured to execute DMN decision table. The DMN model is deployed separately, and its ID is configured into task's properties in Camunda Modeler.
```

## Camunda Forms at Play

```{figure} bus-ticket-sale-complete.png
:alt:
:align: right
```

Finally, once the DMN and BPMN files (with embedded forms) have been deployed to Zeebe, the process can be executed with **Zeebe Play**.

Play augments current {bpmn}`../bpmn/user-task` users tasks with the familiar task completion button. Clicking the button will popup the configured Camunda Form within Play's user interface, and the process can be completed as intended.

```{figure} bus-ticket-sale-play.png
:alt:
:width: 100%
After the {bpmn}`../bpmn/user-task` user task form is submitted, its variables are passed to the {bpmn}`../bpmn/business-rule-task` business rule tasks, which outputs the decided ticket price to be stored as a process variable. The result can be then checked on Zeebe Play variables table.
```
