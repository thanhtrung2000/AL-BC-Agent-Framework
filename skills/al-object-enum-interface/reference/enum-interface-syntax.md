# Enum & Interface Syntax
```al
enum 50100 "<AFFIX> Period Type" { Extensible=true; value(0; Quarter){Caption='Quarter';} value(10; Year){Caption='Year';} }
interface "<AFFIX> ICalc" { procedure Calculate(No: Code[20]): Decimal; }
codeunit 50101 "<AFFIX> Std Calc" implements "<AFFIX> ICalc" { Access=Internal; procedure Calculate(No: Code[20]): Decimal begin end; }
enum 50102 "<AFFIX> Method" implements "<AFFIX> ICalc" { value(0; Standard){Caption='Standard'; Implementation="<AFFIX> ICalc"="<AFFIX> Std Calc";} }
```
Gaps between values; never renumber a shipped value. No single-implementation interface.
