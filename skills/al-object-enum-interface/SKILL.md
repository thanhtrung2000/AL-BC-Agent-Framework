---
name: al-object-enum-interface
description: Create new AL enums and interfaces owned by this extension in Business Central — extensible value sets, interface contracts, and implementation dispatch. Use when defining a fixed set of options or a polymorphic contract with multiple implementations.
argument-hint: [enum or interface] [what it represents]
---

# Create an Enum or Interface

Both define **contracts** rather than storage or behaviour, which is why they
share a skill.

Start from [EnumInterface.al.template](./templates/EnumInterface.al.template).

## Enums

### When to use one

Any fixed set of options a field can hold. Prefer an enum over an Option field
in all new code — Options are not extensible and cannot carry captions cleanly.

### Rules

- `Extensible = true` unless the plan explicitly says otherwise. A closed enum
  cannot be extended by another app, and that decision is permanent.
- `Caption` on **every** value. Missing captions show the raw name to users.
- Value `0` should be the neutral or blank state where one exists.
- Leave numeric gaps between values (0, 10, 20) so extensions can slot in.
- Never renumber an existing value — stored data references the number.

```al
enum 50000 "<AFFIX> Statistics Period Type"
{
    Extensible = true;
    value(0; Quarter) { Caption = 'Quarter'; }
    value(10; Year)   { Caption = 'Year'; }
}
```

## Interfaces

### When to use one

When the same operation has genuinely different implementations chosen at
runtime — a calculation strategy per method, an export format per target, a
posting rule per document type.

**Do not** create an interface with one implementation. That is indirection
without benefit.

### Rules

- Contract only. No implementation, no variables, no triggers.
- Method names describe intent, not mechanism.
- Keep the surface small — every method must be implemented by every
  implementation.
- Implementations live in **separate codeunits**, one per strategy, each
  `Access = Internal` unless deliberately public.

```al
interface "<AFFIX> IStatisticsCalculator"
{
    procedure Calculate(VendorNo: Code[20]; FromDate: Date; ToDate: Date): Decimal;
    procedure GetCaption(): Text;
}
```

### Dispatch pattern

Pair an interface with an enum so the enum value selects the implementation:

```al
enum 50001 "<AFFIX> Calculation Method" implements "<AFFIX> IStatisticsCalculator"
{
    Extensible = true;
    value(0; Standard)
    {
        Caption = 'Standard';
        Implementation = "<AFFIX> IStatisticsCalculator" = "<AFFIX> Standard Calc";
    }
}
```

Then call it without branching:

```al
Calculator := Setup."<AFFIX> Calculation Method";
Result := Calculator.Calculate(VendorNo, FromDate, ToDate);
```

This is the pattern that removes `case` statements and lets other extensions add
methods without touching your code.

## Common failures

| Symptom | Cause |
|---|---|
| Another app cannot extend the enum | `Extensible = false` — permanent decision |
| Users see raw value names | `Caption` missing on values |
| Stored data points at the wrong option | An existing value was renumbered |
| Interface adds complexity, no benefit | Only one implementation exists |
| Cannot slot in a new value cleanly | Values numbered 0,1,2 with no gaps |
