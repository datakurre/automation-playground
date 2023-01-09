# Exercise: PDF creation robot

This exercise has simpler process, but more complex robot. The goals is no less than create a **Certificate of participation** (PDF) with user submitted details.

```{bpmn-figure} create-certificate
{download}`create-certificate.bpmn`
```

# Re-use existing robot

Luckily, for this time, we have been delivered prepackaged robot &nbsp;{bpmn}`../bpmn/robot-task`&nbsp; {download}`create-certificate.zip`, and we only need to wire it up.

```{figure} ../playground/desktop-robots.png
:alt:
:align: right
```

Open the robots folder, and save the robot package as it is there.

Done. The Playground RCC integration is configured to find it from there.


# Form for the details

Next up, is designing the form. We've been told that the robot requires three input variables:

* `name` -- full name of the participant as string
* `email` -- email of the participant as string
* `achievements` -- list of achievements strings to print on the certificate

```{figure} submit-details.png
:alt:
:width: 100%
```

## Beam it up and play

```{figure} play-submit-details.png
:alt:
:width: 100%
```

## Resource summary

```{figure} certificate-pdf.png
:alt:
:width: 100%
```

{download}`create-certificate.bpmn`<br/>
{download}`create-certificate.form`{download}`create-certificate.json`<br/>
&nbsp;{bpmn}`../bpmn/robot-task`&nbsp; {download}`create-certificate.zip`


