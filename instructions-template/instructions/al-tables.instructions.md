---
name: 'AL Table Conventions'
description: 'Conventions for AL table and table extension objects in Business Central'
applyTo: '**/*.Table.al,**/*.TableExt.al'
---
# AL Table Conventions
- Caption, DataClassification, TableRelation on every field. Missing DataClassification blocks release.
- Primary key clustered; secondary keys only for a real filter pattern; SumIndexFields for aggregation.
- FlowField over stored where derivable. Match base widths. DropDown + Brick field groups on lookups.
- Extensions: field IDs from your range; affix; never modify base field properties; behaviour belongs in a subscriber.
