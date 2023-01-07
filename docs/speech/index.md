# DMN exercise with forms

This is a single exercise with simple process to practice, how {bpmn}`../bpmn/business-rule-task` business rule tasks with DMN decision tables work, and how {bpmn}`../user-task` user tasks with forms could be used tolet users interact with the process.

## I have a dream...

... to build a process for generating a nonsensical speech by picking random sentences from a list, sentence by sentence.

1. At first, use output mapping of {bpmn}`../bpmn/start-event` start event to initialize the global process variables for the latest `dice` throw result and also for the `speech` to be build. FEEL expression for an empty string is:
   ```feel
   ""
   ```
2. Then, really start the process with a {bpmn}`../bpmn/user-task` user task, in which user should prompted to throw a dice and then submit the result of the throw to complete the task.
3. The next task should be a {bpmn}`../bpmn/business-rule-task` business rule task, which uses the dice throw result of previous task as a number input, executes a DMN decision table to map the number to a sentence, and outputs the next sentence to be appended to the speech.
4. Use output mapping of the {bpmn}`../bpmn/business-rule-task` business rule task to append the sentence to `speech`. You may use the following FEEL expression to merge the parts, while trimming possible surrounding spaces:
   ```feel
   replace(speech + " " + sentence, "^\s+|\s+$", "")
   ```
5. Next should come another {bpmn}`../bpmn/user-task` user task, which displays the current speech, and allows the user to decide, whether to continue adding sentences or conclude and complete the process.
6. Finally, add required {bpmn}`../exclusive-gateway` exclusive gateways to return the token back to the first {bpmn}`../bpmn/user-task` user task, until user accpets the process to continue to {bpmn}`../bpmn/end-event` end event.

{download}`speech-request.bpmn`

## Decisions first

After modeling the first draft, continue with building the required DMN decision table. It really helps to have the DMN ready, and its requirements clear, before building the user task forms required to collect those inputs. (For the same reasons, you should write the required exclusive gateway path expressions, possibly even before the DMN.)

{download}`pick-a-sentence.dmn`{download}`pick-a-sentence.html`

Zeebe Play does not support manual completion of {bpmn}`../bpmn/business-rule-task` business rule tasks yet. But **as soon as you've modeled and deployed both BPMN and DMN models, you can start executing the developed process at Play** – well before implementing the forms.

## Dry run next

```{figure} ../execution/play-with-variables-menu.png
:alt:
:align: right
```

At this point, you should have been able to:

1. Design and deploy the DMN decision table.
2. Design and deploy the BPMN process model.
3. Start and execute the process at Zeebe Play using the task completion action **with variables**.

This way, you should have been able to confirm that your process is correctly designed and confirmed, before investing time for user interface (the user task forms).

## Best things last


Finally it's time for the forms. Just remember to wrap the correct variables to form field keys, and you should be fine. Use *Window -> Toggle validation mode* to enable preview while designing the forms.

```{figure} modeler-toggle-json.png
:alt:
:align: right
```

When you are ready, save the form and toggle JSON source view to be able to copy the form JSON schema and then paste it into process {bpmn}`../bpmn/user-task` user task configuration.

```{tip}
Values collected and submitted by forms, could be further transformed using output mapping of the BPMN user task. For example, a string variable could be transformed into boolean with a FEEL expression:
   ```feel
   ready = "yes"
```

{download}`submit-d20.form`<br/>
{download}`speech-approval.form`{download}`speech-approval.json`


## Enjoy the ride


Now you should be able to complete the process together with embedded user task forms using **Zeebe Play** and enjoy the speech you come up with.

```{figure} speech-approval-completed.png
:alt:
:width: 100%
```

## Resource summary

{download}`speech-request.bpmn`<br/>
{download}`pick-a-sentence.dmn`{download}`pick-a-sentence.html`<br/>
{download}`submit-d20.form`<br/>
{download}`speech-approval.form`{download}`speech-approval.json`<br/>

