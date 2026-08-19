---
name: 'al-tables'
applyTo: '**/*.Table.al,**/*.TableExt.al'
---

# AL Table Conventions
- Caption, DataClassification, TableRelation on every field. Missing DataClassification blocks release.
- Primary key clustered; secondary keys only for a real filter pattern; SumIndexFields for aggregation.
- FlowField over stored where derivable. DropDown + Brick field groups on lookups.
- Extensions: field IDs from your OWN range; affix every field; never modify base field properties.
