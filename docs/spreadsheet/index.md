# Exercise: Spreadsheet robot

This exercise introduces the last robot implementation in this certificate of participation story, building on top of [the previous exercise](../mockoon/index.md). The new requirement is to create a summary spreadsheet to help reporting on the certificates.

```{bpmn-figure} create-certificate
{download}`create-certificate.bpmn`
```


## Multi-instance to rows

Because multi-instance *output element* definition is really a FEEL expression, it could be used to wrap local variables from single sub process execution into map added into output collection.

```feel
{name: name, email: email, filename: filename}
```

```{figure} modeler-multi-instance-output.png
:alt:
:width: 100%
```


## Mapping a row in FEEL

While the example FEEL expression looks like it does nothing, actually it collects selected individual variables from its execution context ito a single map value:

```{raw} html
<div style="background:white"><iframe src="../_static/feel/?e=%7Bname%3A+name%2C+email%3A+email%2C+filename%3A+filename%7D%0A&c=%7B%0A++%22name%22%3A+%22Quentin+Conn%22%2C%0A++%22email%22%3A+%22Terry.Toy%40gmail.com%22%2C%0A++%22filename%22%3A+%22Quentin+Conn.pdf%22%0A%7D&t=expression" width="100%" height="400"></iframe></div>
```
<br/>


## Spreadsheet as in Excel

After all the "hard work" has already done in BPMN (to make the its variables easy to use), the new {bpmn}`../bpmn/robot-task` *Create summary sheet* robot is straightforward with the default RPA framework keywords:

```robotframework
*** Settings ***

Library    RPA.Robocorp.WorkItems
Library    RPA.Excel.Files
Library    Collections


*** Variables ***

${filename}    summary.xlsx


*** Tasks ***

Create summary sheet
    ${rows}=    Create List

    Set task variables from work item

    Should Not Be Empty    ${filename}    Summary sheet filename is missing

    Create Workbook   ${OUTPUT_DIR}${/}${filename}
    Append Rows To Worksheet    ${rows}  header=${True}
    Save Workbook

    Create output work item
    Add Work Item File    ${OUTPUT_DIR}${/}${filename}
    Save work item
```

Just remember proper input mapping for mapping doain specific `participants` into generic `rows` for a our generic robot code.

## Resource summary

{download}`create-certificate.bpmn`<br/>
{download}`../mockoon/workshop-achievement.dmn`{download}`../mockoon/workshop-achievement.html`<br/>
&nbsp;{bpmn}`../bpmn/robot-task`&nbsp; {download}`summary-sheet.zip`<br/>
&nbsp;{bpmn}`../bpmn/robot-task`&nbsp; {download}`../mockoon/fetch-participants.zip`<br/>
&nbsp;{bpmn}`../bpmn/robot-task`&nbsp; {download}`../email/create-certificate.zip`


