---
weight: 8
name_excel: "D3_vaccines_curated.xlsx"
description: "This dataset contains only the records of  a COVID vaccine that enter the study"
slug: "D3_vaccines_curated"
datetime: 1.7134467e+09
title: D3_vaccines_curated
author: ''
date: '2024-04-18'
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
<script type="application/json" data-for="htmlwidget-1">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"medatata_name":["Name of the dataset","Content of the dataset","Unit of observation","Dataset where the list of UoOs is fully listed and with 1 record per UoO","How many observations per UoO","Variables capturing the UoO","Primary key","Parameters",null,null,null,null,null,null,null,null,null,null,null,null],"metadata_content":["D3_vaccines_curated","This dataset contains only the records of  a COVID vaccine that enter the study","a record of covid vaccines that does not meet any of the exclusion criteria, that is a record of D3_clean_vaccines that has all the exlcusion criteria == 0",null,"1","person_id dose","person_id dose",null,null,null,null,null,null,null,null,null,null,null,null,null]},"columns":[{"id":"medatata_name","name":"medatata_name","type":"character"},{"id":"metadata_content","name":"metadata_content","type":"character"}],"sortable":false,"searchable":true,"pagination":false,"highlight":true,"bordered":true,"striped":true,"style":{"maxWidth":1800},"height":"600px","dataKey":"da8bed6124e3aab79d27035fe957a81b"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
</div>
<div id="Data Model" class="tabcontent">
<div id="htmlwidget-2" class="reactable html-widget" style="width:auto;height:600px;"></div>
<script type="application/json" data-for="htmlwidget-2">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"VarName":["person_id","date_curated","dose_curated","manufacturer_curated",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Description":["unique person identifier",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Format":["character","date","integer","character",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Vocabulary":[null,null,"1, 2 , 3,4",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Parameters":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Notes and examples":["from CDM PERSONS",null,"doses higher than 4 are excluded",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Source tables and variables":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Retrieved":["yes","yes","yes","yes",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Calculated":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Algorithm_id":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Rule":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null]},"columns":[{"id":"VarName","name":"VarName","type":"character"},{"id":"Description","name":"Description","type":"character"},{"id":"Format","name":"Format","type":"character"},{"id":"Vocabulary","name":"Vocabulary","type":"character"},{"id":"Parameters","name":"Parameters","type":"logical"},{"id":"Notes and examples","name":"Notes and examples","type":"character"},{"id":"Source tables and variables","name":"Source tables and variables","type":"logical"},{"id":"Retrieved","name":"Retrieved","type":"character"},{"id":"Calculated","name":"Calculated","type":"logical"},{"id":"Algorithm_id","name":"Algorithm_id","type":"logical"},{"id":"Rule","name":"Rule","type":"logical"}],"sortable":false,"searchable":true,"pagination":false,"highlight":true,"bordered":true,"striped":true,"style":{"maxWidth":1800},"height":"600px","dataKey":"650ef282b3c56d228a0f4fafa861b98d"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
</div>
<div id="Parameters" class="tabcontent">
<div id="htmlwidget-3" class="reactable html-widget" style="width:auto;height:600px;"></div>
<script type="application/json" data-for="htmlwidget-3">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"parameter in the variable name":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"values":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"name of macro":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null]},"columns":[{"id":"parameter in the variable name","name":"parameter in the variable name","type":"logical"},{"id":"values","name":"values","type":"logical"},{"id":"name of macro","name":"name of macro","type":"logical"}],"sortable":false,"searchable":true,"pagination":false,"highlight":true,"bordered":true,"striped":true,"style":{"maxWidth":1800},"height":"600px","dataKey":"f545894952d01490ab535e7af1d88bc2"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
</div>
<div id="Example" class="tabcontent">
<div id="htmlwidget-4" class="reactable html-widget" style="width:auto;height:600px;"></div>
<script type="application/json" data-for="htmlwidget-4">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"person_id":["P001","P001","P001","P001","P002","P003","P004","P004","P008","P010","P010","P013","P013","P014","P014","P015","P015","P016","P016","P018"],"date_curated":["2021-01-01T00:00:00Z","2021-01-25T00:00:00Z","2021-04-01T00:00:00Z","2021-06-12T00:00:00Z","2021-08-20T00:00:00Z","2021-07-30T00:00:00Z","2021-05-02T00:00:00Z","2021-07-27T00:00:00Z","2021-08-03T00:00:00Z","2021-05-21T00:00:00Z","2021-06-30T00:00:00Z","2021-05-22T00:00:00Z","2021-07-06T00:00:00Z","2021-04-18T00:00:00Z","2021-05-12T00:00:00Z","2021-05-15T00:00:00Z","2021-06-24T00:00:00Z","2021-04-10T00:00:00Z","2021-07-03T00:00:00Z","2021-06-13T00:00:00Z"],"dose_curated":[1,2,3,4,1,1,1,2,1,1,2,1,2,1,2,1,2,1,2,1],"manufacturer_curated":["pfizer","pfizer","pfizer","pfizer","pfizer","pfizer","astrazeneca","astrazeneca","moderna","pfizer","pfizer","pfizer","pfizer","pfizer","pfizer","pfizer","pfizer","astrazeneca","pfizer","pfizer"]},"columns":[{"id":"person_id","name":"person_id","type":"character"},{"id":"date_curated","name":"date_curated","type":"Date"},{"id":"dose_curated","name":"dose_curated","type":"numeric"},{"id":"manufacturer_curated","name":"manufacturer_curated","type":"character"}],"sortable":false,"searchable":true,"pagination":false,"highlight":true,"bordered":true,"striped":true,"style":{"maxWidth":1800},"height":"600px","dataKey":"1c1b83d6c1c673a9a7750f74f995edf9"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
</div>
