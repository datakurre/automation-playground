# Exercise: Exception handling

During the [previous exercises](../spreadsheet/index.md) we have build a process generating certificates of participation for the workshop attendees. Unfortunately, at the production, we face issues with the data we get from the participants API. Also, we don't have consent from all of the participants to email the certificates digitally.

This exercise is about handling these exceptions. This is all about modeling, and requires no changes for the previously implemented robots.

```{bpmn-figure} create-certificate
{download}`create-certificate.bpmn`
```

### Randomly missing data

The following Mockoon template would randomly leave empty values for fields `firstname` and `lastname`:

```
{
  "users": [
    {{# repeat (queryParam 'total' '10') }}
      {
        {{#if (faker 'datatype.boolean')}}
        "firstname": "{{ faker 'name.firstName' }}",
        "lastname": "{{ faker 'name.lastName' }}",
        {{else}}
        "firstname": "",
        "lastname": "",
        {{/if}}
        "email": "{{ faker 'internet.email' }}",
        "consent": {{ faker 'datatype.boolean' }},
        "achievements": {{{ faker 'helpers.arrayElements' }}}
      },
    {{/ repeat }}
  ],
  "total": "{{queryParam 'total' '10'}}"
}
```



## Resource summary

{download}`create-certificate.bpmn`<br/>
{download}`participant-info.form`{download}`participant-info.json`<br/>
{download}`../mockoon/workshop-achievement.dmn`{download}`../mockoon/workshop-achievement.html`<br/>
&nbsp;{bpmn}`../bpmn/robot-task`&nbsp; {download}`../email/create-certificate.zip`<br/>
&nbsp;{bpmn}`../bpmn/robot-task`&nbsp; {download}`../mockoon/fetch-participants.zip`<br/>
&nbsp;{bpmn}`../bpmn/robot-task`&nbsp; {download}`../spreadsheet/summary-sheet.zip`


