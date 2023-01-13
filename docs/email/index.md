# Exercise: Email sending robot

This exercise continues from [the previous one](../pdf/index.md) by adding a new {bpmn}`../bpmn/robot-task` Robot Famework service task for delivering the generated certificate by email.

```{bpmn-figure} create-certificate
{download}`create-certificate.bpmn`
```

## Extracting robot package

Start implementing the new automation task by extracting the provided {bpmn}`../bpmn/robot-task` {download}`create-certificate.zip` and then deleting the obsoleted package.

```{figure} robot-extract.png
:alt:
```


## What? Dependencies?

But now that we have access also to the PDF robot code, why not to look into how it worked? Especially into Robot dependency file, `conda.yaml`, which tells immediately PDF creations is based on combined powers of [xhtml2pdf](https://pypi.org/project/xhtml2pdf/) PDF-converter and [Chamelon](https://pypi.org/project/xhtml2pdf/) HTML templating.

```yaml
channels:
  - conda-forge

dependencies:
  - python=3.9.13               # https://pyreadiness.org/3.9/ 
  - pip=22.1.2                  # https://pip.pypa.io/en/stable/news/
  - pip:
      - rpaframework==19.4.1    # https://rpaframework.org/releasenotes.html
      - chameleon
      - xhtml2pdf
```

## Send message

The playground has a local SMTP mock server listening at `localhost:1025`. Let's follow the examples of RPA framework's [Email.ImapSmtp](https://rpaframework.org/libraries/email_imapsmtp/) keyword libray to send the attachment as email.

```robotframework
*** Settings ***

Library    RPA.Email.ImapSmtp   smtp_server=%{SMTP_HOST=localhost}    smtp_port=%{SMTP_PORT=1025}
Library    RPA.Robocorp.WorkItems
Library    String


*** Variables ***

${name}
${email}
${filename}
${template}    SEPARATOR=\n
...            Dear {name},
...
...            thank you for participating the workshop.
...
...            Please, check the attachments for your certificate.
...
...            Yours sincerely,
...            The Organizers


*** Tasks ***

Mail certificate PDF
    Set Task Variables From Work Item

    ${name}=   Strip String    ${name}
    ${email}=  Strip String    ${email}

    ${certificate}=  Get Work Item File    ${filename}
    ${body}=  Format String    ${template}  name=${name}

    Send Message  sender=noreply@example.com
    ...           recipients="${name}" <${email}>
    ...           subject=Certificate of Participation
    ...           body=${body}
    ...           attachments=${certificate}
```
## Multiple tasks per package

```yaml
# For more details on the format and content:
# https://github.com/robocorp/rcc/blob/master/docs/recipes.md#what-is-in-robotyaml

tasks:
  # Task names here are used when executing the bots, so renaming these is recommended.
  Create certificate:
    robotTaskName: Create certificate PDF

  Email certificate:
    robotTaskName: Mail certificate PDF

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

## You've got mail

```{figure} ../playground/desktop-mailhog.png
:alt:
```

```{figure} mailhog-notification.png
:alt:
:width: 100%
```

## Resource summary

```{figure} mailhog-pdf.png
:alt:
:width: 100%
```

{download}`create-certificate.bpmn`<br/>
{download}`../pdf/create-certificate.form`{download}`../pdf/create-certificate.json`<br/>
&nbsp;{bpmn}`../bpmn/robot-task`&nbsp; {download}`create-certificate.zip`


