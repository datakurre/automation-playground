# Exercise: API consuming robot

## Mockoon Mock APIs

[Mockoon](https://mockoon.com/) is a convenient open source tool for mocking HTTP APIs. It supports simple Open API import, but also allows to enrich end points with [Handlebars](https://handlebarsjs.com/) based response templating using [FakerJS](https://fakerjs.dev/) helpers for random mock data.

Mockoon provides a GUI application for mock API development and `mockoon-cli` command-line tool for CI use. The application can be started from the playground desktop **Mockoon** shortcut.

![Mockoon desktop icon](../playground/desktop-mockoon.png)

During the first run, Mockoon greets with a message

```{figure} mockoon-welcome.png
:alt:
:width: 100%
```

and then creates starts with a demo project containing a few mocked endpoints.

## Demo API

```{figure} mockoon-users.png
:alt:
:width: 100%
```

```{figure} mockoon-play.png
:alt:
:align: left
```

Mockoon Mock API server, by default at `http://localhost:3000/`, can be started by clicking a green play button (turning red stop button while the API is running). Mock API endpoint templates can be edited while the server is running.

### Enhance /users

Update `/users` endpoint to include fields `email`, `consent` and `achievements` by replacing the existing template (this will also remove `friends` field).

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

### Randomly missing data

Later we might want to introduce randomly missing data. The following would randomly leave empty values for fields `firstname` and `lastname`:

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


