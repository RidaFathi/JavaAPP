<%--
    Document   : list
    Created on : Feb 2, 2011, 10:54:57 AM
    Author     : "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="/common/taglibs.jsp" %>
<c:set var="biocacheServiceUrl" scope="request"><ala:propertyLoader bundle="hubs" property="biocacheRestService.biocacheUriPrefix"/></c:set>
<c:set var="spatialPortalUrl" scope="request"><ala:propertyLoader bundle="hubs" property="spatialPortalUrl"/></c:set>
<c:set var="bieWebappContext" scope="request"><ala:propertyLoader bundle="hubs" property="bieWebappContext"/></c:set>    
<c:set var="queryContext" scope="request"><ala:propertyLoader bundle="hubs" property="biocacheRestService.queryContext"/></c:set>
<c:set var="hubDisplayName" scope="request"><ala:propertyLoader bundle="hubs" property="site.displayName"/></c:set>
<c:set var="queryContext" scope="request"><ala:propertyLoader bundle="hubs" property="biocacheRestService.queryContext"/></c:set>
<c:set var="facetLimit" scope="request"><ala:propertyLoader bundle="hubs" property="facetLimit"/></c:set>
<c:set var="defaultFacetMapColourBy" scope="request"><ala:propertyLoader bundle="hubs" property="facets.defaultColourBy"/></c:set>
<c:set var="defaultListView" scope="request"><ala:propertyLoader bundle="hubs" property="defaultListView"/></c:set>
<c:set var="queryDisplay">
    <c:choose>
        <c:when test="${fn:contains(searchRequestParams.displayString,'matchedTaxon')}">${searchRequestParams.displayString}</c:when>
        <c:when test="${not empty searchResults.queryTitle}">${searchResults.queryTitle}</c:when>
        <c:otherwise>${searchRequestParams.displayString}</c:otherwise></c:choose>
</c:set>
<c:set var="showImages" value="${hasImages}"/>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="decorator" content="${skin}"/>
        <meta name="section" content="search"/>
        <title><fmt:message key="heading.list"/> | ${hubDisplayName}</title>

        <%--<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/static/css/tabs-no-images.css" />--%>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/search.css" type="text/css" media="screen" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/button.css" type="text/css" media="screen" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/map.css" type="text/css" media="screen" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/redmond/jquery.ui.redmond.css" type="text/css" media="screen" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/jquery.qtip.min.css" type="text/css" media="screen" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/scrollableTable.css" type="text/css" media="screen" />
        <!--[if gt IE 7]> <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/scrollableTable-IE.css" type="text/css" media="screen" /> <![endif]-->

        <script type="text/javascript">
            // single global var for app conf settings
            <c:set var="fqParams"><c:if test="${not empty paramValues.fq}">&fq=<c:out escapeXml="false" value="${fn:join(paramValues.fq, '&fq=')}"/></c:if></c:set>
            var BC_CONF = {
                contextPath: "${pageContext.request.contextPath}",
                serverName: "${initParam.serverName}${pageContext.request.contextPath}",
                searchString: "${ala:escapeJS(searchResults.urlParameters)}", //  JSTL var can contain double quotes
                facetQueries: "${ala:escapeJS(fqParams)}",//"encodeURIComponent('${fn:escapeXml(fqParams)}')", //'${fqParams}',
                queryString: "${ala:escapeJS(queryDisplay)}",
                bieWebappUrl: "${bieWebappContext}",
                biocacheServiceUrl: "${biocacheServiceUrl}",
                skin: "${skin}",
                defaultListView: "${defaultListView}",
                resourceName: "${hubDisplayName}",
                facetLimit: "${(not empty facetLimit) ? facetLimit : '50'}",
                queryContext: "${queryContext}",
                zoomOutsideAustralia: Boolean("<ala:propertyLoader bundle="hubs" property="zoomOutsideAustralia"/>"),
                mapDefaultCentreCoords:"<ala:propertyLoader bundle="hubs" property="mapDefaultCentreCoords"/>",
                mapDefaultZoom:"<ala:propertyLoader bundle="hubs" property="mapDefaultZoom"/>",
                hasMultimedia: ${(not empty hasImages) ? hasImages : 'false'} // will be either true or false
            };
        </script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery-ui-1.8.10.core.slider.min.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery.ui.position.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery.cookie.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery.inview.min.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery.i18n.properties-1.0.9.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/jquery.qtip.min.js"></script>
        <jwr:script src="/js/getQueryParam.js"/>
        <jwr:script src="/js/search.js"/>
        <jwr:script src="/js/envlayers.js"/>
        <jwr:script src="/js/config.js"/>
        <jwr:script src="/js/map.js"/>
        <jwr:script src="/js/wms.js"/>
        <script type="text/javascript">
            // Conf for map JS (Ajay)
            Config.setupUrls("${biocacheServiceUrl}", "${queryContext}");
            google.load('maps','3.3',{ other_params: "sensor=false" });
            google.load("visualization", "1", {packages:["corechart"]});
        </script>
        <script src="${pageContext.request.contextPath}/static/js/jquery.tools.min-1.2.6.js"></script>
        <script type="text/javascript" src="http://google-maps-utility-library-v3.googlecode.com/svn/tags/keydragzoom/2.0.5/src/keydragzoom.js"></script>
    </head>
    <body>
        <div id="listHeader" class="row-fluid">
            <div class="span5">
                <h1><fmt:message key="heading.list"/><a name="resultsTop">&nbsp;</a></h1>
            </div>
            <div id="searchBoxZ" class="span7 text-right">
                <form action="${pageContext.request.contextPath}/occurrences/search" id="solrSearchForm">
                    <div id="advancedSearchLink"><a href="${pageContext.request.contextPath}/search#tab_advanceSearch">Advanced search</a></div>
                    <%--<span id="#searchLabel">Search:</span>--%>
                    <input type="text" id="taxaQuery" name="taxa" class="span6" value="<c:out value='${param.taxa}'/>">
                    <input type="submit" id="solrSubmit" class="btn" value="Quick search"/>
                </form>
            </div>
            <input type="hidden" id="userId" value="${userId}">
            <input type="hidden" id="lsid" value="${param.lsid}"/>
        </div>
        <c:choose>
            <c:when test="${not empty errors}">
                <div class="searchInfo">
                    <h2 style="padding-left: 15px;">Error</h2>
                    <p>${errors}</p>
                </div>
            </c:when>
            <c:when test="${searchResults.totalRecords == 0}">
                <div class="searchInfo">
                    <p>No Records found for <span class="queryDisplay">${not empty queryDisplay ? queryDisplay : param.q}</span></p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="row-fluid clearfix" id="searchInfoRow">
                    <div class="span3">
                        <div id="customiseFacetsButton" class="btn-group">
                            <a class="btn btn-small dropdown-toggle tooltips" data-toggle="dropdown" href="#" title="Customise the contents of this column">
                                <i class="icon-cog"></i>
                                <span class="caret"></span>
                            </a>
                            <div class="dropdown-menu" role="menu"> <%--facetOptions--%>
                                <h4>Select the filter categories that you want to appear in the &quot;Refine results&quot; column</h4>
                                    <%-- <form:checkboxes path="facets" items="${defaultFacets}" itemValue="key" itemLabel="value" /> --%>
                                <div id="facetCheckboxes">
                                    <input type="button" id="updateFacetOptions" class="btn btn-small" value="Update"/>
                                    &nbsp;&nbsp;
                                    Select:
                                    <a href="#" id="selectAll">All</a> | <a href="#" id="selectNone">None</a>
                                    <br/>
                                    <div class="facetsColumn">
                                        <c:forEach var="facet" items="${defaultFacets}" varStatus="status">
                                        <c:if test="${status.index > 0 && status.index % 18 == 0}">
                                    </div>
                                    <div class="facetsColumn">
                                        </c:if>
                                        <input type="checkbox" name="facets" class="facetOpts" value="${facet.key}"
                                            ${(facet.value) ? 'checked="checked"' : ''}>&nbsp;<fmt:message key="facet.${facet.key}"/><br>
                                        </c:forEach>
                                    </div>
                                </div>
                                <div class="clearfix"></div>
                            </div>
                        </div>
                    </div>
                    <div class="span9">
                        <a name="map" class="jumpTo"></a><a name="list" class="jumpTo"></a>
                        <div id="resultsReturned">
                            <span id="returnedText"><strong><fmt:formatNumber value="${searchResults.totalRecords}" pattern="#,###,###"/></strong> results for</span>
                            <span class="queryDisplay"><strong>${queryDisplay}</strong></span>
                                <%-- jQuery template used for taxon drop-downs --%>
                            <div class="btn-group hide" id="template">
                                <a class="btn btn-small" href="" id="taxa_" title="view species page" target="BIE">placeholder</a>
                                <button class="btn btn-small dropdown-toggle" data-toggle="dropdown" title="click for more info on this query">
                                    <span class="caret"></span>
                                </button>
                                <div class="dropdown-menu" aria-labelledby="taxa_">
                                    <div class="taxaMenuContent">
                                        The search results include records for synonyms and child taxa of
                                        <b class="nameString">placeholder</b> (<span class="speciesPageLink">link placeholder</span>).

                                        <form name="raw_taxon_search" class="rawTaxonSearch" action="${pageContext.request.contextPath}/occurrences/search/taxa" method="POST">
                                            <div class="refineTaxaSearch">
                                                The result set contains records provided under the following names:
                                                <input type="submit" class="btn btn-small rawTaxonSumbit"
                                                       value="Refine search" title="Restrict results to the selected names">
                                                <div class="rawTaxaList">placeholder taxa list</div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="row-fluid">
                    <div class="span3">
                        <jsp:include page="facetsDiv.jsp"/>
                    </div>
                    <div id="content2" class="span9">

                        <div style="display:none">
                            <div id="alert">
                                <h2>Email alerts</h2>
                                <br/>
                                <div class="buttonDiv centered">
                                    <a href="#alertNewRecords" id="alertNewRecords" class="tooltips" data-method="createBiocacheNewRecordsAlert" title="Notify me when new records come online for this search">Get
                                        email alerts for new <u>records</u> </a>
                                </div>
                                <br/>
                                <div class="buttonDiv centered">
                                    <a href="#alertNewAnnotations" id="alertNewAnnotations" data-method="createBiocacheNewAnnotationsAlert" class="tooltips" title="Notify me when new annotations (corrections, comments, etc) come online for this search">Get
                                        email alerts for new <u>annotations</u></a>
                                </div>
                                <p>&nbsp;</p>
                                <p><a href="http://alerts.ala.org.au/notification/myAlerts">View your current alerts</a></p>
                            </div>
                        </div>
                        <div style="display:none">
                            <jsp:include page="../downloadDiv.jsp"/>
                        </div>
                        <div style="display:none">
                            <jsp:include page="../mapDiv.jsp"/>
                        </div>
                        <div class="tabbable">
                            <ul class="nav nav-tabs" data-tabs="tabs">
                                <li><a id="t1" href="#recordsView" data-toggle="tab">Records</a></li>
                                <li><a id="t2" href="#mapView" data-toggle="tab">Map</a></li>
                                <li><a id="t3" href="#chartsView" data-toggle="tab">Charts</a></li>
                                <li><a id="t4" href="#speciesImages" data-toggle="tab">Species images</a></li>
                                <c:if test="${showImages}">
                                    <li><a id="t5" href="#recordImages" data-toggle="tab">Record images</a></li>
                                </c:if>
                            </ul>
                        </div>
                        <div class="tab-content clearfix">
                            <div class="tab-pane solrResults" id="recordsView">
                                <div id="searchControls" class="row-fluid">
                                    <div class="span4">
                                        <div id="downloads" class="btn btn-small">
                                            <a href="#download" id="downloadLink" title="Download all <fmt:formatNumber value="${searchResults.totalRecords}" pattern="#,###,###"/> records OR species checklist"><i class="icon-download"></i> Downloads</a>
                                        </div>
                                        <div id="alerts" class="btn btn-small">
                                            <a href="#alert" id="alertsLink" title="Get email alerts for this search"><i class="icon-bell"></i> Alerts</a>
                                        </div>
                                    </div>

                                    <div id="sortWidgets" class="span8">
                                        <span class="hidden-phone">per </span>page:
                                        <select id="per-page" name="per-page" class="input-small">
                                            <c:set var="pageSizeVar">
                                                <c:choose>
                                                    <c:when test="${not empty param.pageSize}">${param.pageSize}</c:when>
                                                    <c:otherwise>20</c:otherwise>
                                                </c:choose>
                                            </c:set>
                                            <option value="10" <c:if test="${pageSizeVar eq '10'}">selected</c:if>>10</option>
                                            <option value="20" <c:if test="${pageSizeVar eq '20'}">selected</c:if>>20</option>
                                            <option value="50" <c:if test="${pageSizeVar eq '50'}">selected</c:if>>50</option>
                                            <option value="100" <c:if test="${pageSizeVar eq '100'}">selected</c:if>>100</option>
                                        </select>&nbsp;
                                        <c:set var="useDefault" value="${empty param.sort && empty param.dir ? true : false }"/>
                                        sort:
                                        <select id="sort" name="sort" class="input-small">
                                            <option value="score" <c:if test="${param.sort eq 'score'}">selected</c:if>>Best match</option>
                                            <option value="taxon_name" <c:if test="${param.sort eq 'taxon_name'}">selected</c:if>>Taxon name</option>
                                            <option value="common_name" <c:if test="${param.sort eq 'common_name'}">selected</c:if>>Common name</option>
                                            <option value="occurrence_date" <c:if test="${param.sort eq 'occurrence_date'}">selected</c:if>>${skin == 'avh' ? 'Collecting date' : 'Record date'}</option>
                                            <c:if test="${skin != 'avh'}">
                                                <option value="record_type" <c:if test="${param.sort eq 'record_type'}">selected</c:if>>Record type</option>
                                            </c:if>
                                            <option value="first_loaded_date" <c:if test="${useDefault || param.sort eq 'first_loaded_date'}">selected</c:if>>Date added</option>
                                            <option value="last_assertion_date" <c:if test="${param.sort eq 'last_assertion_date'}">selected</c:if>>Last annotated</option>
                                        </select>&nbsp;
                                        <span class="hidden-phone">order:
                                        <select id="dir" name="dir" class="input-small">
                                            <option value="asc" <c:if test="${param.dir eq 'asc'}">selected</c:if>>Ascending</option>
                                            <option value="desc" <c:if test="${useDefault || param.dir eq 'desc'}">selected</c:if>>Descending</option>
                                        </select>
                                    </div><!-- sortWidget -->
                                </div><!-- searchControls -->
                                <div id="results">
                                    <c:forEach var="occurrence" items="${searchResults.occurrences}">
                                        <div class="recordRow" id="${occurrence.uuid}">
                                            <c:set var="rawScientificName">
                                                <c:choose>
                                                    <c:when test="${not empty occurrence.raw_scientificName}">${occurrence.raw_scientificName}</c:when>
                                                    <c:when test="${not empty occurrence.species}">${occurrence.species}</c:when>
                                                    <c:when test="${not empty occurrence.genus}">${occurrence.genus}</c:when>
                                                    <c:when test="${not empty occurrence.family}">${occurrence.family}</c:when>
                                                    <c:when test="${not empty occurrence.order}">${occurrence.order}</c:when>
                                                    <c:when test="${not empty occurrence.phylum}">${occurrence.phylum}</c:when>
                                                    <c:when test="${not empty occurrence.kingdom}">${occurrence.kingdom}</c:when>
                                                    <c:otherwise>No name supplied</c:otherwise>
                                                </c:choose>
                                            </c:set>
                                            <c:choose>
                                                <c:when test="${skin == 'avh'}"><%-- AVH hubs --%>
                                                    <p class="rowA">
                                                        <span class="occurrenceNames">${rawScientificName}</span>
                                                        <c:if test="${occurrence.raw_catalogNumber!= null && not empty occurrence.raw_catalogNumber}">
                                                                            <span style="display:inline-block;float:right;">
                                                                                <strong class="resultsLabel">Catalogue&nbsp;number:</strong>&nbsp;${occurrence.raw_catalogNumber}
                                                                            </span>
                                                        </c:if>
                                                    </p>
                                                    <table class="avhRowB">
                                                        <tr>
                                                            <c:if test="${not empty occurrence.stateProvince}">
                                                                <td><strong class="resultsLabel">State:</strong>&nbsp;${occurrence.stateProvince}</td>
                                                            </c:if>
                                                            <c:if test="${not empty occurrence.lga}">
                                                                <td colspan="2"><strong class="resultsLabel">Locality:</strong>&nbsp;<fmt:message key="${occurrence.lga}"/></td>
                                                            </c:if>
                                                        </tr>
                                                        <tr>
                                                            <td><strong class="resultsLabel">Collector:</strong>&nbsp;${occurrence.collector}&nbsp;&nbsp;${occurrence.recordNumber}</td>
                                                            <c:if test="${empty occurrence.collectionName && not empty occurrence.dataResourceName}">
                                                                <td><strong class="resultsLabel">Data&nbsp;Resource:</strong>&nbsp;${occurrence.dataResourceName}</td>
                                                            </c:if>
                                                            <c:choose>
                                                                <c:when test="${not empty occurrence.eventDate}">
                                                                    <td><strong class="resultsLabel">Date:</strong>&nbsp;<fmt:formatDate value="${occurrence.eventDate}" pattern="yyyy-MM-dd"/></td>
                                                                </c:when>
                                                                <c:when test="${empty occurrence.eventDate && not empty occurrence.year}">
                                                                    <td><strong class="resultsLabel">Date:</strong>&nbsp;${occurrence.year}</td>
                                                                </c:when>
                                                            </c:choose>
                                                        </tr>
                                                        <tr>
                                                            <c:if test="${not empty occurrence.collectionName}">
                                                                <td><strong class="resultsLabel">Herbarium:</strong>&nbsp;${occurrence.collectionName}</td>
                                                            </c:if>
                                                            <td class="viewRecord"><a href="<c:url value="/occurrences/${occurrence.uuid}"/>" class="occurrenceLink" style="margin-left: 15px;">View record</a></td>
                                                        </tr>
                                                    </table>
                                                    <p class="rowB" style="display:none">
                                                        <c:if test="${not empty occurrence.stateProvince}">
                                                            <span class="resultListItem"><strong class="resultsLabel">State:</strong>&nbsp;${occurrence.stateProvince}</span>
                                                        </c:if>
                                                        <c:if test="${not empty occurrence.lga}">
                                                            <span class="resultListItem"><strong class="resultsLabel">Locality:</strong>&nbsp;<fmt:message key="${occurrence.lga}"/></span>
                                                        </c:if>
                                                        <br/>
                                                            <%--<c:if test="${not empty occurrence.institutionName}">
                                                                <span class="resultListItem" style="text-transform: capitalize;white-space: nowrap;"><strong class="resultsLabel">Institution:</strong>&nbsp;${occurrence.institutionName}</span>
                                                            </c:if>--%>
                                                        <c:if test="${not empty occurrence.collectionName}">
                                                            <span class="resultListItem"><strong class="resultsLabel">Collection:</strong>&nbsp;${occurrence.collectionName}</span>
                                                        </c:if>
                                                        <c:if test="${empty occurrence.collectionName && not empty occurrence.dataResourceName}">
                                                            <span class="resultListItem"><strong class="resultsLabel">Data&nbsp;Resource:</strong>&nbsp;${occurrence.dataResourceName}</span>
                                                        </c:if>
                                                            <%--<c:if test="${occurrence.collector != null && not empty occurrence.collector}">
                                                                <span class="resultListItem"><strong class="resultsLabel">Collector:</strong>&nbsp;${occurrence.collector}</span>
                                                            </c:if>--%>
                                                        <c:choose>
                                                            <c:when test="${not empty occurrence.eventDate}">
                                                                <span class="resultListItem"><strong class="resultsLabel">Date:</strong>&nbsp;<fmt:formatDate value="${occurrence.eventDate}" pattern="yyyy-MM-dd"/></span>
                                                            </c:when>
                                                            <c:when test="${not empty occurrence.year}">
                                                                <span class="resultListItem"><strong class="resultsLabel">Date:</strong>&nbsp;${occurrence.year}</span>
                                                            </c:when>
                                                        </c:choose>

                                                                        <span style="display:inline-block;float:right;">
                                                                            <a href="<c:url value="/occurrences/${occurrence.uuid}"/>" class="occurrenceLink" style="margin-left: 15px;">View record</a>
                                                                        </span>
                                                    </p>
                                                </c:when>
                                                <c:otherwise><%-- All other hubs --%>
                                                    <p class="rowA">
                                                        <c:choose>
                                                            <c:when test="${not empty occurrence.taxonRank && not empty occurrence.scientificName}">
                                                                <span style="text-transform: capitalize">${occurrence.taxonRank}</span>:&nbsp;<span class="occurrenceNames"><alatag:formatSciName rankId="6000" name="${occurrence.scientificName}"/></span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="occurrenceNames">${occurrence.raw_scientificName}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <c:choose>
                                                            <c:when test="${not empty occurrence.vernacularName}">&nbsp;|&nbsp;<span class="occurrenceNames">${occurrence.vernacularName}</span></c:when>
                                                            <c:when test="${not empty occurrence.raw_vernacularName}">&nbsp;|&nbsp;<span class="occurrenceNames">${occurrence.raw_vernacularName}</span></c:when>
                                                        </c:choose>
                                                                <span style="margin-left: 8px;">
                                                                    <c:choose>
                                                                        <c:when test="${not empty occurrence.eventDate}">
                                                                            <span style="text-transform: capitalize;"><strong class="resultsLabel">Date:</strong>&nbsp;<fmt:formatDate value="${occurrence.eventDate}" pattern="yyyy-MM-dd"/></span>
                                                                        </c:when>
                                                                        <c:when test="${not empty occurrence.occurrenceYear}">
                                                                            <span style="text-transform: capitalize;"><strong class="resultsLabel">Year:</strong>&nbsp;<fmt:formatDate value="${occurrence.occurrenceYear}" pattern="yyyy"/></span>
                                                                        </c:when>
                                                                    </c:choose>
                                                                    <c:choose>
                                                                        <c:when test="${not empty occurrence.stateProvince}">
                                                                            <span style="text-transform: capitalize;"><strong class="resultsLabel">State:</strong>&nbsp;<fmt:message key="region.${occurrence.stateProvince}"/></span>
                                                                        </c:when>
                                                                        <c:when test="${not empty occurrence.country}">
                                                                            <span style="text-transform: capitalize;"><strong class="resultsLabel">Country:</strong>&nbsp;<fmt:message key="${occurrence.country}"/></span>
                                                                        </c:when>
                                                                    </c:choose>
                                                                </span>
                                                    </p>
                                                    <p class="rowB">
                                                        <c:if test="${not empty occurrence.institutionName}">
                                                            <span style="text-transform: capitalize;"><strong class="resultsLabel">Institution:</strong>&nbsp;${occurrence.institutionName}</span>
                                                        </c:if>
                                                        <c:if test="${not empty occurrence.collectionName}">
                                                            <span style="text-transform: capitalize;"><strong class="resultsLabel">Collection:</strong>&nbsp;${occurrence.collectionName}</span>
                                                        </c:if>
                                                        <c:if test="${empty occurrence.collectionName && not empty occurrence.dataResourceName}">
                                                            <span style="text-transform: capitalize;"><strong class="resultsLabel">Data&nbsp;Resource:</strong>&nbsp;${occurrence.dataResourceName}</span>
                                                        </c:if>
                                                        <c:if test="${not empty occurrence.basisOfRecord}">
                                                            <span style="text-transform: capitalize;"><strong class="resultsLabel">Basis&nbsp;of&nbsp;record:</strong>&nbsp;${occurrence.basisOfRecord}</span>
                                                        </c:if>
                                                        <c:if test="${occurrence.raw_catalogNumber!= null && not empty occurrence.raw_catalogNumber}">
                                                            <strong class="resultsLabel">Catalog&nbsp;number:</strong>&nbsp;${occurrence.raw_collectionCode}:${occurrence.raw_catalogNumber}
                                                        </c:if>
                                                        <a href="<c:url value="/occurrences/${occurrence.uuid}"/>" class="occurrenceLink" style="margin-left: 15px;">View record</a>
                                                    </p>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </c:forEach>
                                </div><!--close results-->
                                <div id="searchNavBar">
                                    <alatag:searchNavigationLinks totalRecords="${searchResults.totalRecords}" startIndex="${searchResults.startIndex}"
                                                                  queryString="${searchRequestParams.q}" lastPage="${lastPage}" pageSize="${searchResults.pageSize}"/>
                                </div>
                            </div><!--end solrResults-->
                            <div id="mapView" class="tab-pane">
                                <table id="mapLayerControls">
                                    <tr>
                                        <td>
                                            <label for="colourFacets">Colour by:&nbsp;</label>
                                            <div class="layerControls">
                                                <select name="colourFacets" id="colourFacets">
                                                    <option value=""> None </option>
                                                    <c:forEach var="facetResult" items="${searchResults.facetResults}">
                                                        <c:set var="Defaultselected">
                                                            <c:if test="${not empty defaultFacetMapColourBy && facetResult.fieldName == defaultFacetMapColourBy}">selected="selected"</c:if>
                                                        </c:set>
                                                        <c:if test="${fn:length(facetResult.fieldResult) > 1}">
                                                            <option value="${facetResult.fieldName}" ${Defaultselected}>
                                                                <c:choose>
                                                                    <c:when test="${fn:substring(facetResult.fieldName, fn:length(facetResult.fieldName)-2, fn:length(facetResult.fieldName)) eq '_s'}">${fn:replace(fn:substring(facetResult.fieldName, 0, fn:length(facetResult.fieldName)-2), '_', ' ')}</c:when>
                                                                    <c:otherwise><fmt:message key="facet.${facetResult.fieldName}"/></c:otherwise>
                                                                </c:choose>
                                                            </option>
                                                        </c:if>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                        </td>
                                        <c:if test="${skin == 'avh'}">
                                        <td>
                                            <label for="envLyrList">Environmental layer:&nbsp;</label>
                                            <div class="layerControls">
                                                <select id="envLyrList">
                                                    <option value="">None</option>
                                                </select>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        </c:if>
                                        <td>
                                            <label for="sizeslider">Size:</label>
                                            <div class="layerControls">
                                                <span id="sizeslider-val">4</span>
                                                <div id="sizeslider"></div>
                                            </div>
                                        </td>
                                        <td>
                                            <c:set var='spatialPortalLink'>${fn:replace(searchResults.urlParameters, "\"", "&#034;") }</c:set>
                                            <c:set var='spatialPortalUrlParams'><ala:propertyLoader bundle="hubs" property="spatialPortalUrlParams"/></c:set>
                                            <!--  <a class="buttonDiv" id="spatialPortalLink" href="${spatialPortalUrl}${spatialPortalLink}${spatialPortalUrlParams}">View in spatial portal</a>-->
                                            <div id="downloadMaps" class="buttonDiv btn">
                                                <a id="spatialPortalLink" href="${spatialPortalUrl}${spatialPortalLink}${spatialPortalUrlParams}">View in spatial portal</a>
                                            </div>
                                            <div id="downloadMaps" class="buttonDiv btn">
                                                <a href="#downloadMap" id="downloadMapLink" title="Download a publication quality map">Download map</a>
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                                <div id="maploading">Loading...</div>
                                <div id="mapcanvas"></div>
                                <div id="legend" title="Toggle layers/legend display">
                                    <div class="title">Legend<span>&nabla;</span></div>
                                    <div id="layerlist">
                                        <div id="toggleAll">Toggle all</div>
                                        <div id="legendContent"></div>
                                    </div>
                                </div>
                                <div id='envLegend'></div>
                            </div><!-- end #mapwrapper -->
                            <div id="chartsView" class="tab-pane">
                                <div id="charts"></div>
                            </div><!-- end #chartsWrapper -->
                            <div id="speciesImages" class="tab-pane">
                                <h3>Representative images of species</h3>
                                <div id="speciesGalleryControls">
                                    Filter by group
                                    <select id="speciesGroup">
                                        <option>no species groups loaded</option>
                                    </select>
                                    &nbsp;
                                    Sort by
                                    <select id="speciesGallerySort">
                                        <option value="common">Common name</option>
                                        <option value="taxa">Scientific name</option>
                                        <option value="count">Record count</option>
                                    </select>
                                </div>
                                <div id="speciesGallery">[image gallery should appear here]</div>
                                <div id="loadMoreSpecies" style="display:none;">
                                    <button>Show more images</button><img style="display:none;" src="${pageContext.request.contextPath}/static/images/indicator.gif"/>
                                </div>
                            </div><!-- end #speciesWrapper -->
                            <c:if test="${showImages}">
                                <div id="recordImages" class="tab-pane">
                                    <h3>Images from occurrence records</h3>
                                    <%--<p>(see also <a href="#tab_speciesImages">representative species images</a>)</p>--%>
                                    <div id="imagesGrid">
                                        loading images...
                                    </div>
                                    <div id="loadMoreImages" style="display:none;">
                                        <button>Show more images</button>
                                    </div>
                                </div><!-- end #imagesWrapper -->
                            </c:if>
                        </div><!-- end .css-panes -->
                        <form name="raw_taxon_search" class="rawTaxonSearch" id="rawTaxonSearchForm" action="${pageContext.request.contextPath}/occurrences/search/taxa" method="POST">
                                <%-- taxon concept search drop-down div are put in here via Jquery --%>
                            <div style="display:none;" >
                            </div>
                        </form>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </body>
</html>
