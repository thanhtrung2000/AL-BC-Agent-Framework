# Enum & Interface Syntax
```al
enum 50100 "<AFFIX> Period Type" { Extensible=true; value(0; Quarter){Caption='Quarter';} }
interface "<AFFIX> ICalc" { procedure Calculate(No: Code[20]): Decimal; }
codeunit 50101 "<AFFIX> Std Calc" implements "<AFFIX> ICalc" { Access=Internal; procedure Calculate(No: Code[20]): Decimal begin end; }
```
Gaps between values; never renumber. No single-implementation interface.
