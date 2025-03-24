---
weight: 3
name_excel: "D3_TD_events_complete.xlsx"
description: "contains the time-dependent evolution of all events. Only changes of status are recorded, with date when the condition changes and period end; the components of the condition last 365 days if they are diagnosis, and 90 days if they are drug proxies; unique spells are created when the algorithm is 1 (if either a dianosis or a drug proxy is active), and the algorithm is reverted to values 0 whenever no component is active"
slug: "D3_TD_events_complete"
datetime: 1.7428125e+09
title: D3_TD_events_complete
author: ''
date: '2025-03-24'
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
<button class="tablinks" onclick="openCity(event, &#39;Examples&#39;)">Examples</button>
</div>
<div id="Metadata" class="tabcontent">
<div id="htmlwidget-1" class="reactable html-widget" style="width:auto;height:600px;"></div>
<script type="application/json" data-for="htmlwidget-1">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"medatata_name":["Name of the dataset","Content of the dataset","Unit of observation","Dataset where the list of UoOs is fully listed and with 1 record per UoO","How many observations per UoO","Variables capturing the UoO","Primary key","Parameters",null,null,null,null,null,null,null,null,null,null,null,null],"metadata_content":["D3_TD_events_complete","contains the time-dependent evolution of all events. Only changes of status are recorded, with date when the condition changes and period end; the components of the condition last 365 days if they are diagnosis, and 90 days if they are drug proxies; unique spells are created when the algorithm is 1 (if either a dianosis or a drug proxy is active), and the algorithm is reverted to values 0 whenever no component is active","a person in the readiness study population","D4_study_population","As many as the variation of the values of the variable from the moment the person enters to the moment the person exits the data source. Since the variable is expected to be non missing at any moment, the baseline value is recorded for all the units of observation","person_id","person_id date value_of_variable",null,null,null,null,null,null,null,null,null,null,null,null,null]},"columns":[{"id":"medatata_name","name":"medatata_name","type":"character"},{"id":"metadata_content","name":"metadata_content","type":"character"}],"sortable":false,"searchable":true,"pagination":false,"highlight":true,"bordered":true,"striped":true,"style":{"maxWidth":1800},"height":"600px","dataKey":"797eb5b321babb8801ce330842c03ecf"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
</div>
<div id="Data Model" class="tabcontent">
<div id="htmlwidget-2" class="reactable html-widget" style="width:auto;height:600px;"></div>
<script type="application/json" data-for="htmlwidget-2">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"VarName":["person_id","date","date_end","variable",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Description":["unique person identifier",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Format":["character","date","date","character",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Vocabulary":["from D4_study_population","date of start of period","date of end of period","name of the condition",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Parameters":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Notes and examples":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Source tables and variables":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Retrieved":["yes",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Calculated":[null,"yes","yes",null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Algorithm_id":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"Rule":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null]},"columns":[{"id":"VarName","name":"VarName","type":"character"},{"id":"Description","name":"Description","type":"character"},{"id":"Format","name":"Format","type":"character"},{"id":"Vocabulary","name":"Vocabulary","type":"character"},{"id":"Parameters","name":"Parameters","type":"logical"},{"id":"Notes and examples","name":"Notes and examples","type":"logical"},{"id":"Source tables and variables","name":"Source tables and variables","type":"logical"},{"id":"Retrieved","name":"Retrieved","type":"character"},{"id":"Calculated","name":"Calculated","type":"character"},{"id":"Algorithm_id","name":"Algorithm_id","type":"logical"},{"id":"Rule","name":"Rule","type":"logical"}],"sortable":false,"searchable":true,"pagination":false,"highlight":true,"bordered":true,"striped":true,"style":{"maxWidth":1800},"height":"600px","dataKey":"469a72b5678b74f479eaae948911336a"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
</div>
<div id="Parameters" class="tabcontent">
<div id="htmlwidget-3" class="reactable html-widget" style="width:auto;height:600px;"></div>
<script type="application/json" data-for="htmlwidget-3">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"parameter in the variable name":["condition","condition","condition","condition","condition","condition","condition","condition","condition",null,null,null,null,null,null,null,null,null,null,null],"values":["DIAB","CANCER","PULMON","OBES","CKD","HIV","IMMUNOSUP","SICKLE","CVD",null,null,null,null,null,null,null,null,null,null,null],"name of macro":["list_of_covariates_for_cohort","list_of_covariates_for_cohort","list_of_covariates_for_cohort","list_of_covariates_for_cohort","list_of_covariates_for_cohort","list_of_covariates_for_cohort","list_of_covariates_for_cohort","list_of_covariates_for_cohort","list_of_covariates_for_cohort",null,null,null,null,null,null,null,null,null,null,null]},"columns":[{"id":"parameter in the variable name","name":"parameter in the variable name","type":"character"},{"id":"values","name":"values","type":"character"},{"id":"name of macro","name":"name of macro","type":"character"}],"sortable":false,"searchable":true,"pagination":false,"highlight":true,"bordered":true,"striped":true,"style":{"maxWidth":1800},"height":"600px","dataKey":"69179a5332c32cece4778747e7c4b6ee"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
</div>
<div id="Examples" class="tabcontent">
<div id="htmlwidget-4" class="reactable html-widget" style="width:auto;height:600px;"></div>
<script type="application/json" data-for="htmlwidget-4">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"person_id":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"date":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"date_end":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null],"variable":[null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null]},"columns":[{"id":"person_id","name":"person_id","type":"logical"},{"id":"date","name":"date","type":"logical"},{"id":"date_end","name":"date_end","type":"logical"},{"id":"variable","name":"variable","type":"logical"}],"sortable":false,"searchable":true,"pagination":false,"highlight":true,"bordered":true,"striped":true,"style":{"maxWidth":1800},"height":"600px","dataKey":"4f7e8c07e9873b509398cdfe9a53d126"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
</div>
