#!/bin/bash

cities=$( ls *.obs | egrep -o '^[a-zA-Z]{1,}' )
for city in $cities;
do
  usms=$( ls -1 ${city}_*.???? | cut -d. -f 1 | uniq | sort )
  for usm in $usms; do
    usm_first=$( ls $usm.???? | head -1 )
    usm_last=$( ls $usm.???? | tail -1 )
    cat <<EOF >> usms.xml
    <usm nom="${usm}">
        <datedebut>345</datedebut>
        <datefin>730</datefin>
        <finit>vigne_ini.xml</finit>
        <nomsol>solvigne</nomsol>
        <fstation>${city}_sta.xml</fstation>
        <fclim1>${usm_first}</fclim1>
        <fclim2>${usm_last}</fclim2>
        <culturean>2</culturean>
        <nbplantes>1</nbplantes>
        <codesimul>0</codesimul>
        <plante dominance="1">
            <fplt>vine_MERLOT_plt.xml</fplt>
            <ftec>vigne_tec.xml</ftec>
            <flai>foo</flai>
        </plante>
    </usm>
EOF
done
done
