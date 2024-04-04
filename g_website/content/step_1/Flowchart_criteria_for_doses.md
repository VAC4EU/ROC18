---
weight: 9
name_excel: "Flowchart_criteria_for_doses.xlsx"
description: "Flowchart of the exlusion of covid vaccines records"
slug: "Flowchart_criteria_for_doses"
datetime: 1.7122603e+09
title: Flowchart_criteria_for_doses
author: ''
date: '2024-04-04'
categories: []
tags: []
archetype: codebook
output: html_document
---

<script src="/rmarkdown-libs/core-js/shim.min.js"></script>
<script src="/rmarkdown-libs/react/react.min.js"></script>
<script src="/rmarkdown-libs/react/react-dom.min.js"></script>
<script src="/rmarkdown-libs/reactwidget/react-tools.js"></script>
<script src="/rmarkdown-libs/htmlwidgets/htmlwidgets.js"></script>
<link href="/rmarkdown-libs/reactable/reactable.css" rel="stylesheet" />
<script src="/rmarkdown-libs/reactable-binding/reactable.js"></script>
<div class="tab">
<button class="tablinks" onclick="openCity(event, &#39;Metadata&#39;)" id="defaultOpen">Metadata</button>
<button class="tablinks" onclick="openCity(event, &#39;Data Model&#39;)">Data Model</button>
<button class="tablinks" onclick="openCity(event, &#39;Parameters&#39;)">Parameters</button>
<button class="tablinks" onclick="openCity(event, &#39;Example&#39;)">Example</button>
</div>
<div id="Metadata" class="tabcontent">
<div id="htmlwidget-1" class="reactable html-widget" style="width:auto;height:600px;"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"medatata_name":["Name of the dataset","Content of the dataset","Unit of observation","Dataset where the list of UoOs is fully listed and with 1 record per UoO","How many observations per UoO","Variables capturing the UoO","Primary key","Parameters",null,null,null,null,null,null,null,null,null,null,null,null],"metadata_content":["Flowchart_criteria_for_doses","Flowchart of the exlusion of covid vaccines records","criteria",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null]},"columns":[{"id":"medatata_name","name":"medatata_name","type":"character"},{"id":"metadata_content","name":"metadata_content","type":"character"}],"sortable":false,"searchable":true,"pagination":false,"highlight":true,"bordered":true,"striped":true,"style":{"maxWidth":1800},"height":"600px","dataKey":"cac60bb964b060c44a711bb940dfc6f6"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
</div>
<div id="Data Model" class="tabcontent">
<div id="htmlwidget-2" class="reactable html-widget" style="width:auto;height:600px;"></div>
<script type="application/json" data-for="htmlwidget-2">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"VarName":["criteria","N",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Description":[null,"frequency of the combination",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Format":["binary",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Vocabulary":["0 = if all the previous value on the same row are 1 then N refers to this column\r\n1= otherwise",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Parameters":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Notes and examples":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Source tables and variables":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Retrieved":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Calculated":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Algorithm_id":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Rule":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null]},"columns":[{"id":"VarName","name":"VarName","type":"character"},{"id":"Description","name":"Description","type":"character"},{"id":"Format","name":"Format","type":"character"},{"id":"Vocabulary","name":"Vocabulary","type":"character"},{"id":"Parameters","name":"Parameters","type":"logical"},{"id":"Notes and examples","name":"Notes and examples","type":"logical"},{"id":"Source tables and variables","name":"Source tables and variables","type":"logical"},{"id":"Retrieved","name":"Retrieved","type":"logical"},{"id":"Calculated","name":"Calculated","type":"logical"},{"id":"Algorithm_id","name":"Algorithm_id","type":"logical"},{"id":"Rule","name":"Rule","type":"logical"}],"sortable":false,"searchable":true,"pagination":false,"highlight":true,"bordered":true,"striped":true,"style":{"maxWidth":1800},"height":"600px","dataKey":"6fd3c6475e76696d8eb9feead1e110b3"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
</div>
<div id="Parameters" class="tabcontent">
<div id="htmlwidget-3" class="reactable html-widget" style="width:auto;height:600px;"></div>
<script type="application/json" data-for="htmlwidget-3">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"parameter in the variable name":["criteria","criteria","criteria","criteria","criteria","criteria","criteria","criteria",null,null,null,null,null,null,null,null,null,null,null,null],"values":["A_duplicated_records","B_manufacturer_not_in_study","C_missing_date","D_date_before_start_vax","E_distance_btw_1_2_doses","F_distance_btw_2_3_doses","G_distance_btw_3_4_doses","H_dose_after_4",null,null,null,null,null,null,null,null,null,null,null,null],"name of macro":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null]},"columns":[{"id":"parameter in the variable name","name":"parameter in the variable name","type":"character"},{"id":"values","name":"values","type":"character"},{"id":"name of macro","name":"name of macro","type":"logical"}],"sortable":false,"searchable":true,"pagination":false,"highlight":true,"bordered":true,"striped":true,"style":{"maxWidth":1800},"height":"600px","dataKey":"0bcf3d321454cfd17ef70a30eaff7b06"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
</div>
<div id="Example" class="tabcontent">
<div id="htmlwidget-4" class="reactable html-widget" style="width:auto;height:600px;"></div>
<script type="application/json" data-for="htmlwidget-4">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"A_duplicated_records":[0,1,1,1,1,1,1,"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA"],"B_manufacturer_not_in_study":[0,1,1,1,1,1,1,"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA"],"C_missing_date":[0,0,1,1,1,1,1,"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA"],"D_date_before_start_vax":[0,0,1,1,1,1,1,"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA"],"E_distance_btw_1_2_doses":[0,0,0,1,1,1,1,"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA"],"F_distance_btw_2_3_doses":[0,0,0,0,1,1,1,"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA"],"G_distance_btw_3_4_doses":[0,0,0,0,0,1,1,"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA"],"H_dose_after_4":[0,0,0,0,0,0,1,"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA"],"N":[3,187,165,413,1320,51,18459,"NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA","NA"]},"columns":[{"id":"A_duplicated_records","name":"A_duplicated_records","type":"numeric"},{"id":"B_manufacturer_not_in_study","name":"B_manufacturer_not_in_study","type":"numeric"},{"id":"C_missing_date","name":"C_missing_date","type":"numeric"},{"id":"D_date_before_start_vax","name":"D_date_before_start_vax","type":"numeric"},{"id":"E_distance_btw_1_2_doses","name":"E_distance_btw_1_2_doses","type":"numeric"},{"id":"F_distance_btw_2_3_doses","name":"F_distance_btw_2_3_doses","type":"numeric"},{"id":"G_distance_btw_3_4_doses","name":"G_distance_btw_3_4_doses","type":"numeric"},{"id":"H_dose_after_4","name":"H_dose_after_4","type":"numeric"},{"id":"N","name":"N","type":"numeric"}],"sortable":false,"searchable":true,"pagination":false,"highlight":true,"bordered":true,"striped":true,"style":{"maxWidth":1800},"height":"600px","dataKey":"8eb5188f01b1179312335e454cb9cd80"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
</div>
