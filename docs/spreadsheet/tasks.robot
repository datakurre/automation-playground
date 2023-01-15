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
