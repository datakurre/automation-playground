# DMN, user tasks and forms

Until now, we have focused on only one BPMN activity type: {bpmn}`../bpmn/robot-task` *service task*. But there are more. Let's forget service tasks for the next example, and dive into {bpmn}`../bpmn/business-rule-task` **business rule task** and {bpmn}`../bpmn/user-task` **user task** instead.


## Collect facts, make decisions

Here's an imaginary process for selling bus tickets:

1. Driver looks into passenger to collect facts about them. Passenger may show some proofs to be eligble for discount.
2. Based on the collected facts, driver decides, intointo  which price group the passenger belongs to.
3. Driver charges the passenger and delivers the ticket.

```{bpmn-figure} bus-ticket-sale
In this naive interpretation of the bus ticket sale process, **fact collection** is modeled as {bpmn}`../bpmn/user-task` **user task** and the **decision** made from the facts as {bpmn}`../bpmn/business-rule-task` **business-rule-task**.
{download}`bus-ticket-sale.bpmn`
```


## Automating repeatable decisions

**DMN** stands for Decision Model and Notation. It is a standard approach for describing and modeling repeatable business decisions, and like BPMN, it is designed to be readable by business and IT users alike. **DMN is the casual way to implement** {bpmn}`../bpmn/business-rule-task` **business rule tasks**. Like BPMN, also DMN is well supported by Camunda Modeler.

This is, how a DMN decision table for deducing bus ticket price from the facts known about a passenger, could look like:

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

The easiest way to understand, how and why DMN is used, is to try it out. Untila good open source solution for playing with DMN emerges, it is possible try out and learn how DMN models work with [Camunda DMN Simulator](https://consulting.camunda.com/dmn-simulator/).

Simply drag and drop a DMN file into the simulator running on a browser window, and it's ready for play:

```{figure} dmn-simulator.png
:alt: Trying out bus-ticket-price.dmn with Camunda DMN Simulator
:width: 100%
```

```{warning}
{download}`bus-ticket-price.dmn` is designed for [Camunda Platform 7](https://camunda.com/platform-7/) to support [Camunda's DMN Simulator](https://consulting.camunda.com/dmn-simulator/). Unfortunately, it does not fully support value types available in Zeebe yet.
```

## DMN beats "just coding it"

If a business decision can be described with a limited set deterministic rules matching arguments to one or more resolution, there is high chance that DMN beats the traditional programming languages. Decision tables

* are more visual than code
* have less degrees of freedoms to do mistakes
* are usually more formal and easier to validate
* can be maintained separately from code (BPMN).

Again, our example decision table is a simple DMN, but could already result in ugly nested *if-then-else* expressions with "just coding it":

```{dmn-html} bus-ticket-price-zeebe
```
<br/>

## Camunda Forms for user tasks

In our example, the DMN {bpmn}`../bpmn/business-rule-task` business rule task *Choose price*, depends on {bpmn}`../bpmn/user-task` user task *Recognize passanger type* to provide input facts for the decision table.

Most common way to implement a user task is to show the user a form. Camunda has developed its own open source web form framework, which has its editor integrated into Camunda Modeler. While a web form might not be the best possible final user interface for this process, it's still good enough for prototyping it.

```{figure} modeler-form-playground.png
:alt:
:width: 100%

Camunda Modeler includes [@bpmn-io/form-js-playground](https://www.npmjs.com/package/@bpmn-io/form-js-playground) for designing and previewing [@bpmn-io/form-js](https://bpmn.io/toolkit/form-js/) HTML forms, also known as Camunda Forms. To bind form with {bpmn}`../bpmn/user-task` user tasks on Zeebe, form JSON schema is copied and pasted into task's BPMN properties.
```

## Configuring tasks properties


```{bpmn-figure} bus-ticket-sale-executable
{download}`bus-ticket-sale-executable.bpmn`
```
{download}`bus-ticket-price-zeebe.dmn`{download}`bus-ticket-price-zeebe.html`<br/>
{download}`bus-ticket-price.form`

### Configuring Camunda Form

```{figure} bus-ticket-sale-user-task.png
:alt:
:width: 100%
```

### Configuring DMN decision table

```{figure} bus-ticket-sale-business-rule.png
:alt:
:width: 100%
```

## Camunda Forms at Play

```{figure} bus-ticket-sale-play.png
:alt:
:width: 100%
```
