# Enum & Interface Syntax Reference
## Enum
```al
enum 50100 "<AFFIX> Period Type" { Extensible = true; value(0; Quarter) { Caption='Quarter'; } value(10; Year) { Caption='Year'; } }
```
Leave numeric gaps; caption every value; never renumber a shipped value.
## Interface + implementation
```al
interface "<AFFIX> ICalc" { procedure Calculate(No: Code[20]): Decimal; }
codeunit 50101 "<AFFIX> Std Calc" implements "<AFFIX> ICalc" { Access=Internal; procedure Calculate(No: Code[20]): Decimal begin end; }
```
## Enum-implements-interface dispatch (no case statements)
```al
enum 50102 "<AFFIX> Method" implements "<AFFIX> ICalc" { value(0; Standard) { Caption='Standard'; Implementation = "<AFFIX> ICalc" = "<AFFIX> Std Calc"; } }
// var C: Interface "<AFFIX> ICalc"; C := Setup."<AFFIX> Method"; Result := C.Calculate(No);
```
Do NOT create an interface with a single implementation. Do NOT reuse a value ID.
