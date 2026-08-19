---
name: 'AL Language Fundamentals'
description: 'Universal AL syntax rules that apply to EVERY .al file. Kept small on purpose — detailed per-object syntax loads on demand from each skill reference file.'
applyTo: '**/*.al'
---
# AL Language Fundamentals (universal — applies to every AL object)
Small on purpose. Object-specific syntax loads only when that type is built.

## Procedure structure — three parts, in order
```al
procedure Name()   // 1. signature
var                // 2. DECLARATIONS ONLY  (Name: Type;)
    Rec: Record "Some Table";
    Total: Decimal;
begin              // 3. STATEMENTS ONLY  (assignments, calls, if/case/repeat, exit)
    Rec.Reset();
    Total := Rec.Amount;
end;
```
## The two rules that cause most syntax errors
1. **`var` holds declarations only** — every line is `Name: Type;`. A statement here
   (`X := ...;` or `X.Method();`) causes `',' expected` / `':' expected`.
2. **Every variable used in `begin` MUST be declared in `var`** with a type, or you get
   `The name '<X>' does not exist in the current context`. Fix = add the declaration.
## Other universals
- Assign `:=`; compare `=`. Statements separated by `;`.
- Strings single-quoted `'Hi'`; object names with spaces double-quoted `Record "Purch. Inv. Line"`.
- Temporary record: `Buffer: Record "X" temporary;`.
- Declaration order: complex types (Record, Report, Codeunit, Page, Query) first, then Integer/Decimal/Date/Text/Boolean.
## Fixing a syntax / "does not exist" error
- `',' expected` / `':' expected` in var → a statement is misplaced → MOVE it to begin.
- `'<X>' does not exist` → add `<X>: <Type>;` to var.
- Edit the broken lines in place — never regenerate the whole object.
