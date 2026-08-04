---
name: al-extend-enum-profile
description: Create enum extensions and profile extensions in Business Central — adding values to base enums with implementations, and customising role centre profiles. Use when extending a base enum's value set or tailoring a role centre.
argument-hint: [base enum or profile] [what to add]
---

# Extend an Enum or Profile

Both extend **base configuration** rather than data or UI structure, which is
why they share a skill.

Start from [EnumProfileExt.al.template](./templates/EnumProfileExt.al.template).

## Enum extensions

### Prerequisite

The base enum must be `Extensible = true`. If it is not, you cannot extend it —
say so and return the constraint. There is no workaround.

### Rules

- **Value IDs come from your own `idRanges`**, never the base enum's numbering.
- `Caption` on every added value.
- Affix the value name.
- If the base enum implements an interface, your value **must** supply an
  `Implementation` — the compiler enforces this.

```al
enumextension 50000 "<AFFIX> Payment Method Ext" extends "Payment Method Type"
{
    value(50000; "<AFFIX> CryptoTransfer")
    {
        Caption = 'Crypto Transfer';
        Implementation = "Payment Method Handler" = "<AFFIX> Crypto Handler";
    }
}
```

### Never

- Renumber or remove a base value — stored data references the number.
- Reuse a base value's ID.

## Profile extensions

### What they do

A `profileextension` customises a base role centre for a specific role:
rearranging the navigation, adding cues, or changing the default page layout.

### Rules

- Reference the base profile by its **ID string**, not its caption.
- Customisations live in a paired page customization block.
- Keep changes minimal — users personalise role centres themselves, and heavy
  extension-level changes fight that.

```al
profileextension "<AFFIX> Business Manager Ext" extends "BUSINESS MANAGER"
{
    Caption = 'Business Manager (Contoso)';
}
```

### Page customization

Profile changes usually pair with `pagecustomization`, which is a separate
object type:

```al
pagecustomization "<AFFIX> BM Role Center" customizes "Business Manager Role Center"
{
    layout
    {
        modify(Control1)
        {
            Visible = false;
        }
    }
}
```

State clearly in NOTES if a page customization is also required — it is a
separate object and may belong in the same packet.

## Common failures

| Symptom | Cause |
|---|---|
| Cannot extend the enum | Base enum is `Extensible = false` — no workaround |
| Compile error on the enum extension | Base enum implements an interface, no `Implementation` supplied |
| Stored data points at the wrong value | A base value ID was reused |
| Role centre change does not appear | Profile extended but no page customization |
| Users see raw value names | `Caption` missing |
