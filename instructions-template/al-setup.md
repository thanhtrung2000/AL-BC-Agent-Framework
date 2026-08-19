<!-- al-setup-version: 1.0.0 -->
# AL Framework SETUP — team-owned, fill in once
This file holds YOUR project's settings. The framework NEVER overwrites it. Fill in
every value below by hand, then commit. No AI needed.
```
AFFIX / PREFIX      : <e.g. VSA>
PRODUCTION ID RANGE : <e.g. 50000..50099>   (from app.json -> idRanges)
TEST ID RANGE       : <e.g. 50100..50149>   (outside the production range)
TARGET BC VERSION   : <e.g. 26.0>           (from app.json -> application)
PUBLISHER           : <e.g. Contoso>        (from app.json -> publisher)
```
If any placeholder remains, agents return NEEDS_SETUP. A wrong ID range compiles fine
and fails AppSourceCop at release, which is why they refuse until this is complete.
