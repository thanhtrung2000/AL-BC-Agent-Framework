---
name: 'AL Language Fundamentals'
description: 'Universal AL syntax rules that apply to EVERY .al file. Per-object syntax loads on demand from skill reference files.'
applyTo: '**/*.al'
---
# AL Language Fundamentals
## Procedure structure — three parts, in order
```al
procedure Name()   // signature
var                // DECLARATIONS ONLY (Name: Type;)
    Rec: Record "Some Table";
    Total: Decimal;
begin              // STATEMENTS ONLY
    Rec.Reset(); Total := Rec.Amount;
end;
```
## The two rules that cause most syntax errors
1. **`var` holds declarations only** — every line `Name: Type;`. A statement here → `',' expected` / `':' expected`.
2. **Every variable used in `begin` MUST be declared in `var`** or `The name '<X>' does not exist`. Fix = add the declaration.
## Universals
Assign `:=`, compare `=`. Strings 'single'; object names "double". Temp: `Buf: Record "X" temporary;`. Complex types declared first.
## Fixing errors
`',' expected`/`':' expected` in var → move the statement to begin. `'<X>' does not exist` → add `<X>: <Type>;`. OVERWRITE the whole object — never a second copy.
