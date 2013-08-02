<!---

    Slatwall - An Open Source eCommerce Platform
    Copyright (C) 2011 ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

--->
<cfcomponent accessors="true" persistent="false" output="false" extends="HibachiReport">
	
	<cfproperty name="reportStartDateTime" />
	<cfproperty name="reportEndDateTime" />
	<cfproperty name="reportDateTimeGroupBy" />
	
	<cfproperty name="data" />
	<cfproperty name="chartDataQuery" />
	<cfproperty name="chartData" />
	<cfproperty name="tableDataQuery" />
	
	<cffunction name="getData" returnType="Query">
		
		<cfif not structKeyExists(variables, "data")>
			<cfquery name="variables.data">
				SELECT
					SlatwallSku.skuID,
					SlatwallSku.skuCode,
					SlatwallProduct.productID,
					SlatwallProduct.productName,
					SlatwallProductType.productTypeID,
					SlatwallProductType.productTypeName,
					SlatwallBrand.brandID,
					SlatwallBrand.brandName,
					SlatwallOrderItem.quantity,
					SlatwallOrderItem.price,
					(SlatwallOrderItem.price * SlatwallOrderItem.quantity) as extendedPrice,
					SlatwallOrder.orderID,
					#getReportDateTimeSelect('SlatwallOrder.orderOpenDateTime')#
				FROM
					SlatwallOrderItem
				  INNER JOIN
				  	SlatwallOrderFulfillment on SlatwallOrderItem.orderFulfillmentID = SlatwallOrderFulfillment.orderFulfillmentID
				  INNER JOIN
				  	SlatwallOrder on SlatwallOrderFulfillment.orderID = SlatwallOrder.orderID
				  INNER JOIN
				  	SlatwallAccount on SlatwallOrder.accountID = SlatwallAccount.accountID
				  INNER JOIN
				  	SlatwallSku on SlatwallOrderItem.skuID = SlatwallSku.skuID
				  INNER JOIN
				  	SlatwallProduct on SlatwallSku.productID = SlatwallProduct.productID
				  INNER JOIN
				  	SlatwallProductType on SlatwallProduct.productTypeID = SlatwallProductType.productTypeID
				  LEFT JOIN
				  	SlatwallBrand on SlatwallProduct.brandID = SlatwallBrand.brandID
				  LEFT JOIN
				  	SlatwallAddress on SlatwallOrderFulfillment.shippingAddressID = SlatwallAddress.addressID
				WHERE
					SlatwallOrder.orderOpenDateTime is not null
				  AND
				  	SlatwallOrder.orderOpenDateTime >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#getReportStartDateTime()#" />
				  AND
				  	SlatwallOrder.orderOpenDateTime <= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#getReportEndDateTime()#" />
			</cfquery>
		</cfif>
		
		<cfreturn variables.data />
	</cffunction>
	
	<cffunction name="getReportStartDateTime">
		<cfif not structKeyExists(variables, "reportStartDateTime")>
			<cfset variables.reportStartDateTime = dateFormat(now() - 30, "yyyy-mm-dd") />
		</cfif>
		<cfreturn variables.reportStartDateTime />
	</cffunction>
	
	<cffunction name="getReportEndDateTime">
		<cfif not structKeyExists(variables, "reportEndDateTime")>
			<cfset variables.reportEndDateTime = dateFormat(now(), "yyyy-mm-dd") />
		</cfif>
		<cfreturn variables.reportEndDateTime />
	</cffunction>
	
	<cffunction name="getReportDateTimeGroupBy">
		<cfif not structKeyExists(variables, "reportDateTimeGroupBy")>
			<cfset variables.reportDateTimeGroupBy = "day" />
		</cfif>
		<cfreturn variables.reportDateTimeGroupBy />
	</cffunction>
	
	<cffunction name="getReportDateTimeSelect">
		<cfargument name="column" />
		
		<cfset var reportDateTimeSelect="" />
		<cfsavecontent variable="reportDateTimeSelect">
			<cfoutput>
				<cfif getApplicationValue('databaseType') eq "MySQL">
					YEAR( #arguments.column# ) as reportDateTimeYear,
					MONTH( #arguments.column# ) as reportDateTimeMonth,
					WEEK( #arguments.column# ) as reportDateTimeWeek,
					DAY( #arguments.column# ) as reportDateTimeDay,
					HOUR( #arguments.column# ) as reportDateTimeHour
				<cfelse>
					DATEPART( year, #arguments.column# ) as reportDateTimeYear,
					DATEPART( month, #arguments.column# ) as reportDateTimeMonth,
					DATEPART( week, #arguments.column# ) as reportDateTimeWeek,
					DATEPART( day, #arguments.column# ) as reportDateTimeDay,
					DATEPART( hour, #arguments.column# ) as reportDateTimeHour  
				</cfif>
			</cfoutput>
		</cfsavecontent>
		<cfreturn reportDateTimeSelect />
	</cffunction>
	
	<cffunction name="getChartDataQuery">
		<cfif not structKeyExists(variables, "chartDataQuery")>
			
			<cfset var data = getData() />
			
			<cfquery name="variables.chartDataQuery" dbtype="query">
				SELECT
					SUM(data.extendedPrice) as series1,
					AVG(data.price) as series2,
					COUNT(quantity) as series3,
					COUNT(data.orderID) as series4
					<cfif listFindNoCase('year,month,week,day,hour', getReportDateTimeGroupBy())>
						,data.reportDateTimeYear
					</cfif>
					<cfif listFindNoCase('month,week,day,hour', getReportDateTimeGroupBy())>
						,data.reportDateTimeMonth
					</cfif>
					<cfif listFindNoCase('week,day,hour', getReportDateTimeGroupBy())>
						,data.reportDateTimeWeek
					</cfif>
					<cfif listFindNoCase('day,hour', getReportDateTimeGroupBy())>
						,data.reportDateTimeDay
					</cfif>
					<cfif listFindNoCase('hour', getReportDateTimeGroupBy())>
						,data.reportDateTimeHour
					</cfif>
				FROM
					data
				GROUP BY
					<cfif listFindNoCase('year,month,week,day,hour', getReportDateTimeGroupBy())>
						data.reportDateTimeYear
					</cfif>
					<cfif listFindNoCase('month,week,day,hour', getReportDateTimeGroupBy())>
						,data.reportDateTimeMonth
					</cfif>
					<cfif listFindNoCase('week,day,hour', getReportDateTimeGroupBy())>
						,data.reportDateTimeWeek
					</cfif>
					<cfif listFindNoCase('day,hour', getReportDateTimeGroupBy())>
						,data.reportDateTimeDay
					</cfif>
					<cfif listFindNoCase('hour', getReportDateTimeGroupBy())>
						,data.reportDateTimeHour
					</cfif>
				ORDER BY
					<cfif listFindNoCase('year,month,week,day,hour', getReportDateTimeGroupBy())>
						data.reportDateTimeYear
					</cfif>
					<cfif listFindNoCase('month,week,day,hour', getReportDateTimeGroupBy())>
						,data.reportDateTimeMonth
					</cfif>
					<cfif listFindNoCase('week,day,hour', getReportDateTimeGroupBy())>
						,data.reportDateTimeWeek
					</cfif>
					<cfif listFindNoCase('day,hour', getReportDateTimeGroupBy())>
						,data.reportDateTimeDay
					</cfif>
					<cfif listFindNoCase('hour', getReportDateTimeGroupBy())>
						,data.reportDateTimeHour
					</cfif>
			</cfquery>
		</cfif>
		
		<cfreturn variables.chartDataQuery />
	</cffunction>
	
	<cffunction name="getChartData">
		<cfif not structKeyExists(variables, "chartData")>
			
			<cfset var chartDataQuery = getChartDataQuery() />
			<cfset var chartDataStruct = structNew() />
			
			<cfset var thisDate = "" />
			<cfset var chartRow = 1 />
			
			<cfset variables.chartData = {} />
			<cfset variables.chartData["chart"] = {} />
			<cfset variables.chartData["chart"]["type"] = "line" />
			<cfset variables.chartData["legend"] = {} />
			<cfset variables.chartData["legend"]["enabled"] = false />
			<cfset variables.chartData["title"] = {} />
			<cfset variables.chartData["title"]["text"] = "Sales Report" />
			<cfset variables.chartData["xAxis"] = {} />
			<cfset variables.chartData["xAxis"]["type"] = "datetime" />
			<cfset variables.chartData["yAxis"] = {} />
			<cfset variables.chartData["yAxis"]["title"] = {} />
			<cfset variables.chartData["yAxis"]["title"]["text"] = '' />
			<cfset variables.chartData["series"] = [] />
			<cfset arrayAppend(variables.chartData["series"], {})>
			<cfset variables.chartData["series"][1]["name"] = "Extended Price" />
			<cfset variables.chartData["series"][1]["data"] = [] />
			
			<cfset var loopdatepart = "d" />
			<cfif getReportDateTimeGroupBy() eq 'year'>
				<cfset loopdatepart = "yyyy" />
			<cfelseif getReportDateTimeGroupBy() eq 'month'>
				<cfset loopdatepart = "m" />
			<cfelseif getReportDateTimeGroupBy() eq 'week'>
				<cfset loopdatepart = "ww" />
			<cfelseif getReportDateTimeGroupBy() eq 'hour'>
				<cfset loopdatepart = "h" />	
			</cfif>
			
			<cf_HibachiDateLoop index="thisDate" from="#getReportStartDateTime()#" to="#getReportEndDateTime()#" datepart="#loopdatepart#">
				<cfset var thisData = [] />
				<cfset arrayAppend(thisData, dateDiff("s", createdatetime( '1970','01','01','00','00','00' ), dateAdd("h", 1, thisDate))*1000) />
				<cfif year(thisDate) eq chartDataQuery['reportDateTimeYear'][chartRow] and 
						(!listFindNoCase('month,day,hour', getReportDateTimeGroupBy()) or month(thisDate) eq chartDataQuery['reportDateTimeMonth'][chartRow]) and
						(!listFindNoCase('day,hour', getReportDateTimeGroupBy()) or day(thisDate) eq chartDataQuery['reportDateTimeDay'][chartRow]) and
						(!listFindNoCase('hour', getReportDateTimeGroupBy()) or hour(thisDate) eq chartDataQuery['reportDateTimeHour'][chartRow])>
					<cfset arrayAppend(thisData, chartDataQuery['series1'][chartRow]) />
					<cfset chartRow ++ />
				<cfelse>
					<cfset arrayAppend(thisData, 0) />
				</cfif>
				<cfset arrayAppend(variables.chartData["series"][1]["data"], thisData) />
			</cf_HibachiDateLoop>
			<!---
			<cfloop index="thisDate" from="#getReportStartDateTime()#" to="#getReportEndDateTime()#" step="#CreateTimeSpan( 1, 0, 0, 0 )#">
				<cfset var thisData = [] />
				<cfset arrayAppend(thisData, dateDiff("s", createdatetime( '1970','01','01','00','00','00' ), dateConvert("local2Utc", thisDate))*1000) />
				<cfif year(thisDate) eq chartDataQuery['reportDateTimeYear'][chartRow] and 
						(!listFindNoCase('month,day,hour', getReportDateTimeGroupBy()) or month(thisDate) eq chartDataQuery['reportDateTimeMonth'][chartRow]) and
						(!listFindNoCase('day,hour', getReportDateTimeGroupBy()) or day(thisDate) eq chartDataQuery['reportDateTimeDay'][chartRow]) and
						(!listFindNoCase('hour', getReportDateTimeGroupBy()) or hour(thisDate) eq chartDataQuery['reportDateTimeHour'][chartRow])>
					<cfset arrayAppend(thisData, chartDataQuery['series1'][chartRow]) />
					<cfset chartRow ++ />
				<cfelse>
					<cfset arrayAppend(thisData, 0) />
				</cfif>
				<cfset arrayAppend(variables.chartData["series"][1]["data"], thisData) />
			</cfloop>
			--->
		</cfif>
		
		<cfreturn variables.chartData />
	</cffunction>
	
	<cffunction name="getTableDataQuery">
		<cfif not structKeyExists(variables, "tableDataQuery")>
			
			<cfset var data = getData() />
			<cfset var unsortedData = "" />
			
			<cfquery name="unsortedData" dbtype="query">
				SELECT
					SUM(data.extendedPrice) as series1,
					data.productID,
					data.productName
				FROM
					data
				GROUP BY
					data.productID, data.productName
			</cfquery>
			
			<cfquery name="variables.tableDataQuery" dbtype="query">
				SELECT
					*
				FROM
					unsortedData
				ORDER BY
					series1
			</cfquery>
		</cfif>
		
		<cfreturn variables.tableDataQuery />
	</cffunction>
</cfcomponent>