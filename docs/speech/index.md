# DMN exercise with forms

This is a single exercise with simple process to practice, how {bpmn}`../bpmn/business-rule-task` business rule tasks with DMN decision tables work, and how {bpmn}`../user-task` user tasks with forms could be used tolet users interact with the process.

## I have a dream...

... to build a process for generating a nonsensical speechby picking random sentences from a list, sentence by sentence.

1. Use output mapping of {bpmn}`../bpmn/start-event` start event to initialize the process variable for the speech to build. FEEL expression for an empty string is:
   ```feel
   ""
   ```
3. The next tasks should be a {bpmn}`../bpmn/business-rule-task` business rule task, which accepts the input from the previous task, executes a DMN decision table with the number input, and results the next sentence to be appended to the speech.
4. Use output mapping of the {bpmn}`../bpmn/business-rule-task` business rule task to append the sentence to the story. You may use the following FEEL expression to merge the parts  and strip possible surrounding spaces:
   ```feel
   replace(speech + " " + sentence, "^\s+|\s+$", "")
   ```
5. Next should come another {bpmn}`../user-task` user task, which displays the current speech, and allowsthe user to decide, whether to continue adding sentences or conclude.
6. Be aware that output mapping of a user task could be used to transform the values submitted by form. For example, a string variable could be transformed into boolean with a FEEL expression:
   ```feel
   accepted = "yes"
   ```
7. Finally, add requied {bpmn}`../exclusive-gateway` exclusive gateways to return the token back to the first {bpmn}`../bpmn/user-task` user task, until user accpets the process to continue to {bpmn}`../bpmn/end-event` end event.

{download}`speech-request.bpmn`

## Decisions first

After modeling the first draft, continue with building the required DMN decision table. It should make sense to model the decision before the form for gathering the required inputs. For the same reasons, before continuing, you should also write the required exclusive gateway path expressions to know their requirements.

{download}`pick-a-sentence.dmn`{download}`pick-a-sentence.html`

**Zeebe Play** does not yet support manual completion of {bpmn}`../bpmn/business-rule-task` business rule tasks. But as soon as you've modeled and deployed both BPMN and DMN models, you can start executing the developed process at Play – even before implementing the forms.

## Forms for inputs

{download}`submit-d20.form`<br/>
{download}`speech-approval.form`{download}`speech-approval.json`


