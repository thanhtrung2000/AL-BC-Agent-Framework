---
name: 'AL Language Fundamentals'
description: 'Universal AL syntax rules that apply to EVERY .al file. Small on purpose; per-object syntax loads on demand from skill reference files.'
applyTo: '**/*.al'
---
# AL Language Fundamentals (applies to every AL object)
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
1. **`var` holds declarations only** — every line `Name: Type;`. A statement here (`X:=..;`/`X.Method();`) → `',' expected` / `':' expected`.
2. **Every variable used in `begin` MUST be declared in `var`** with a type, or `The name '<X>' does not exist`. Fix = add the declaration.
## Universals
Assign `:=`, compare `=`. Strings 'single'; object names "double". Temp record: `Buf: Record "X" temporary;`. Declaration order: complex types first, simple after.
## Fixing errors
`',' expected`/`':' expected` in var → move the statement to begin. `'<X>' does not exist` → add `<X>: <Type>;` to var. OVERWRITE the whole object — never regenerate a second copy.
