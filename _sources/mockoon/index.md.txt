# Exercise: API consuming robot

Also this exercise continues to iterate on top of the [the previous exercise](../email/index.md) by replacing the {bpmn}`../bpmn/user-task` with a new {bpmn}`../bpmn/robot-task` Robot Famework service task for fetching the participants and their achievements from an API instead.

```{bpmn-figure} create-certificate
{download}`create-certificate.bpmn`
```

## Mockoon for API mocks

[Mockoon](https://mockoon.com/) is a convenient open source tool for mocking HTTP APIs. It supports simple Open API import, but also allows to enrich end points with [Handlebars](https://handlebarsjs.com/) based response templating using [FakerJS](https://fakerjs.dev/) helpers for random mock data.

Mockoon provides a GUI application for mock API development and `mockoon-cli` command-line tool for CI use. The application can be started from the playground desktop **Mockoon** shortcut.

![Mockoon desktop icon](../playground/desktop-mockoon.png)

During the first run, Mockoon greets with a message

```{figure} mockoon-welcome.png
:alt:
:width: 100%
```

and then starts with a demo project containing a few mocked endpoints.

## Serving the mock API

```{figure} mockoon-play.png
:alt:
:align: left
```

Mockoon Mock API server, by default at `http://localhost:3000/`, can be started by clicking a green play button (turning red stop button while the API is running). Mock API endpoint templates can be edited while the server is running.

```{figure} mockoon-users.png
:alt:
:width: 100%
```

### Participants mock API

Let's re-use the built-in demo API as our participants API. Update `/users` endpoint to include fields `email`, `consent` and `achievements` by replacing the existing template (this will also remove `friends` field).

```
{
  "users": [
    {{# repeat (queryParam 'total' '10') }}
      {
        "firstname": "{{ faker 'name.firstName' }}",
        "lastname": "{{ faker 'name.lastName' }}",
        "email": "{{ faker 'internet.email' }}",
        "consent": {{ faker 'datatype.boolean' }},
        "achievements": {{{ faker 'helpers.arrayElements' }}}
      },
    {{/ repeat }}
  ],
  "total": "{{queryParam 'total' '10'}}"
}
```

## Calling for participants

At this point, it should be clear, that fetching participants from an API endpoint requires {bpmn}`../bpmn/robot-task` *Fetch participants* robot task, which exports list of participants on its output mapping.

RPA framework, which is included in every new robot created in Robocorp Code by default, comes with [RPA.HTTP keyword library](https://robocorp.com/docs/libraries/rpa-framework/rpa-http), its usage may not be obvious.

So, take a look at this reference implementation:

```robotframework
*** Settings ***

Library  RPA.HTTP
Library  RPA.Robocorp.WorkItems

*** Variables ***

${PARTICIPANTS_API}    %{PARTICIPANTS_API=http://localhost:3000}
${TOTAL}    6


*** Tasks ***
Fetch participants
    ${url}          Set variable    ${PARTICIPANTS_API}/users?total=${TOTAL}
    ${response}=    Http Get        ${url}
    ${users}=       Set Variable    ${response.json()}[users]

    Create Output Work Item
    Set Work Item Variable    participants    ${users}
    Save Work Item
```


## Looping through a list

Now that `participants` is a list of workshop participants, the [previous process](../email/index.md) need to be iterated with for every participant. This is possible by copying th previous process and wrapping it into expanded embedded subprocess, which is then configured as multi-instance.

```{figure} modeler-multi-instance.png
:alt:
:width: 100%
```

## DMN for mapping values

Another change caused by the API is that instead of full achievement texts for the certificates, we now get a list of codes from `["a", "b", "c"]`. This list can be turned into list of full text descriptions with {bpmn}`../bpmn/business-rule-task` *Map achievements* business-rule task.: A multi-instance task for mapping list of codes into text with DMN:

```{dmn-html} workshop-achievement
```
{download}`workshop-achievement.dmn`


## Resource summary

{download}`create-certificate.bpmn`<br/>
{download}`workshop-achievement.dmn`{download}`workshop-achievement.html`<br/>
&nbsp;{bpmn}`../bpmn/robot-task`&nbsp; {download}`fetch-participants.zip`<br/>
&nbsp;{bpmn}`../bpmn/robot-task`&nbsp; {download}`../email/create-certificate.zip`


