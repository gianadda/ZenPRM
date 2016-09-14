Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

<RoutePrefix("api/entitysearch")> _
Public Class EntitySearchController
    Inherits ApiController

    <System.Web.Http.HttpPost> _
    <Route("")> _
    Public Function SearchEntity(searchObject As EntitySearch)

        Dim dsResults As System.Data.DataSet = Nothing

        Try

            If Not searchObject Is Nothing Then

                dsResults = New System.Data.DataSet

                If searchObject.addEntityProjectIdent > 0 AndAlso _
                    searchObject.addEntityIdents.Trim.Length > 0 Then

                    'if we receive an add entityProjectIdent and the list of Idents
                    'then the user manually selected a few resources to add to a project
                    Call EntityProject.AddEntitiesToProject(searchObject, dsResults)

                Else

                    'otherwise, they are performing a search
                    'or they are adding all resources from the search results
                    Call Entity.SearchEntity(searchObject, dsResults)

                End If

                If Not dsResults Is Nothing Then

                    If dsResults.Tables.Count >= 1 Then

                        dsResults.Tables(0).TableName = "ResultCounts"

                    End If

                    If dsResults.Tables.Count = 2 Then

                        dsResults.Tables(1).TableName = "Entities"

                    End If

                    Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

                End If 'If Not dsResults Is Nothing

            End If 'If Not searchObject Is Nothing

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsResults)

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("Demographics")> _
    Public Function Demographics(searchObject As EntitySearch)

        Dim cmdCommand As System.Data.SqlClient.SqlCommand = Nothing
        Dim daDataAdapter As System.Data.SqlClient.SqlDataAdapter = Nothing
        Dim cnnConnection As System.Data.SqlClient.SqlConnection = Nothing
        Dim dsResults As System.Data.DataSet = Nothing

        Try

            cnnConnection = New System.Data.SqlClient.SqlConnection
            cmdCommand = New System.Data.SqlClient.SqlCommand
            daDataAdapter = New SqlClient.SqlDataAdapter
            dsResults = New System.Data.DataSet

            If cnnConnection.State = ConnectionState.Closed Then

                cnnConnection.ConnectionString = ConfigurationManager.ConnectionStrings("DatabaseConnectionString").ConnectionString
                cnnConnection.Open()

            End If

            With cmdCommand

                .Connection = cnnConnection
                .CommandType = CommandType.StoredProcedure
                .CommandTimeout = cnnConnection.ConnectionTimeout
                .Parameters.Add("@bntEntityIdent", SqlDbType.BigInt).Value = Helper.ASUserIdent
                .Parameters.Add("@bntASUserIdent", SqlDbType.BigInt).Value = Helper.AddEditASUserIdent
                .Parameters.Add("@nvrKeyword", SqlDbType.NVarChar, -1).Value = searchObject.keyword
                .Parameters.Add("@nvrLocation", SqlDbType.NVarChar, -1).Value = searchObject.location
                .Parameters.Add("@decLatitude", SqlDbType.Decimal).Value = searchObject.latitude
                .Parameters.Add("@decLongitude", SqlDbType.Decimal).Value = searchObject.longitude
                .Parameters.Add("@intDistanceInMiles", SqlDbType.Int).Value = searchObject.radius
                .Parameters.Add("@bntResultsShown", SqlDbType.BigInt).Value = searchObject.resultsShown
                .Parameters.Add("@bitFullProjectExport", SqlDbType.Bit).Value = searchObject.fullProjectExport
                .Parameters.Add("@bntAddEntityProjectIdent", SqlDbType.BigInt).Value = searchObject.addEntityProjectIdent

                .CommandText = "uspSearchEntityNetworkDemographics"

                If searchObject.filters.Count > 0 Then

                    .Parameters.Add("@tblFilters", SqlDbType.Structured).Value = SQLDataTables.EntitySearchFilter(searchObject.filters)

                End If

                daDataAdapter.SelectCommand = cmdCommand
                daDataAdapter.Fill(dsResults)

                If Not dsResults Is Nothing Then

                    If dsResults.Tables.Count >= 1 Then

                        dsResults.Tables(0).TableName = "ResultCounts"
                        dsResults.Tables(1).TableName = "TopSpecialties"
                        dsResults.Tables(2).TableName = "TopSpecialtiesVsAcceptingNewPatients"
                        dsResults.Tables(3).TableName = "TopSpecialtiesGenderBreakdown"
                        dsResults.Tables(4).TableName = "MeaningfulUseTotals"
                        dsResults.Tables(5).TableName = "TopPayors"
                        dsResults.Tables(6).TableName = "Geography"
                        dsResults.Tables(7).TableName = "Gender"
                        dsResults.Tables(8).TableName = "TopLanguage"
                        dsResults.Tables(9).TableName = "TopLanguageByZipCode"

                    End If

                End If 'If Not dsResults Is Nothing

                Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

            End With 'With cmdCommand

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            If Not cmdCommand Is Nothing Then

                cmdCommand.Dispose()

            End If

            If Not daDataAdapter Is Nothing Then

                daDataAdapter.Dispose()

            End If

            If Not cnnConnection Is Nothing Then

                If cnnConnection.State = ConnectionState.Open Then

                    cnnConnection.Close()

                End If

                cnnConnection.Dispose()

            End If

            Helper.CleanUp(cmdCommand)
            Helper.CleanUp(daDataAdapter)
            Helper.CleanUp(cnnConnection)
            Helper.CleanUp(dsResults)

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("Insights")> _
    Public Function Insights(searchObject As EntitySearch)

        Dim cmdCommand As System.Data.SqlClient.SqlCommand = Nothing
        Dim daDataAdapter As System.Data.SqlClient.SqlDataAdapter = Nothing
        Dim cnnConnection As System.Data.SqlClient.SqlConnection = Nothing
        Dim dsResults As System.Data.DataSet = Nothing

        Try

            cnnConnection = New System.Data.SqlClient.SqlConnection
            cmdCommand = New System.Data.SqlClient.SqlCommand
            daDataAdapter = New SqlClient.SqlDataAdapter
            dsResults = New System.Data.DataSet

            If cnnConnection.State = ConnectionState.Closed Then

                cnnConnection.ConnectionString = ConfigurationManager.ConnectionStrings("DatabaseConnectionString").ConnectionString
                cnnConnection.Open()

            End If

            With cmdCommand

                .Connection = cnnConnection
                .CommandType = CommandType.StoredProcedure
                .CommandTimeout = cnnConnection.ConnectionTimeout
                .Parameters.Add("@bntEntityIdent", SqlDbType.BigInt).Value = Helper.ASUserIdent
                .Parameters.Add("@bntASUserIdent", SqlDbType.BigInt).Value = Helper.AddEditASUserIdent
                .Parameters.Add("@nvrKeyword", SqlDbType.NVarChar, -1).Value = searchObject.keyword
                .Parameters.Add("@nvrLocation", SqlDbType.NVarChar, -1).Value = searchObject.location
                .Parameters.Add("@decLatitude", SqlDbType.Decimal).Value = searchObject.latitude
                .Parameters.Add("@decLongitude", SqlDbType.Decimal).Value = searchObject.longitude
                .Parameters.Add("@intDistanceInMiles", SqlDbType.Int).Value = searchObject.radius
                .Parameters.Add("@bntResultsShown", SqlDbType.BigInt).Value = searchObject.resultsShown
                .Parameters.Add("@bitFullProjectExport", SqlDbType.Bit).Value = searchObject.fullProjectExport
                .Parameters.Add("@bntAddEntityProjectIdent", SqlDbType.BigInt).Value = searchObject.addEntityProjectIdent
                .Parameters.Add("@bntXAxisEntityProjectRequirementIdent", SqlDbType.Decimal).Value = searchObject.XAxisEntityProjectRequirementIdent
                .Parameters.Add("@bntYAxisEntityProjectRequirementIdent", SqlDbType.Decimal).Value = searchObject.YAxisEntityProjectRequirementIdent
                .Parameters.Add("@bntZAxisEntityProjectRequirementIdent", SqlDbType.Decimal).Value = searchObject.ZAxisEntityProjectRequirementIdent
                .Parameters.Add("@bntAlphaAxisEntityProjectRequirementIdent", SqlDbType.Decimal).Value = searchObject.AlphaAxisEntityProjectRequirementIdent

                .CommandText = "uspSearchEntityNetworkInsights"

                If searchObject.filters.Count > 0 Then

                    .Parameters.Add("@tblFilters", SqlDbType.Structured).Value = SQLDataTables.EntitySearchFilter(searchObject.filters)

                End If

                daDataAdapter.SelectCommand = cmdCommand
                daDataAdapter.Fill(dsResults)

                If Not dsResults Is Nothing Then

                    If dsResults.Tables.Count >= 1 Then

                        dsResults.Tables(0).TableName = "ResultCounts"
                        dsResults.Tables(1).TableName = "Entities"

                    End If

                End If 'If Not dsResults Is Nothing

                Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

            End With 'With cmdCommand

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            If Not cmdCommand Is Nothing Then

                cmdCommand.Dispose()

            End If

            If Not daDataAdapter Is Nothing Then

                daDataAdapter.Dispose()

            End If

            If Not cnnConnection Is Nothing Then

                If cnnConnection.State = ConnectionState.Open Then

                    cnnConnection.Close()

                End If

                cnnConnection.Dispose()

            End If

            Helper.CleanUp(cmdCommand)
            Helper.CleanUp(daDataAdapter)
            Helper.CleanUp(cnnConnection)
            Helper.CleanUp(dsResults)

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("Network")> _
    Public Function Network(searchObject As EntitySearch)

        Dim cmdCommand As System.Data.SqlClient.SqlCommand = Nothing
        Dim daDataAdapter As System.Data.SqlClient.SqlDataAdapter = Nothing
        Dim cnnConnection As System.Data.SqlClient.SqlConnection = Nothing
        Dim dsResults As System.Data.DataSet = Nothing

        Try

            cnnConnection = New System.Data.SqlClient.SqlConnection
            cmdCommand = New System.Data.SqlClient.SqlCommand
            daDataAdapter = New SqlClient.SqlDataAdapter
            dsResults = New System.Data.DataSet

            If cnnConnection.State = ConnectionState.Closed Then

                cnnConnection.ConnectionString = ConfigurationManager.ConnectionStrings("DatabaseConnectionString").ConnectionString
                cnnConnection.Open()

            End If

            With cmdCommand

                .Connection = cnnConnection
                .CommandType = CommandType.StoredProcedure
                .CommandTimeout = cnnConnection.ConnectionTimeout
                .Parameters.Add("@bntEntityIdent", SqlDbType.BigInt).Value = Helper.ASUserIdent
                .Parameters.Add("@bntASUserIdent", SqlDbType.BigInt).Value = Helper.AddEditASUserIdent
                .Parameters.Add("@nvrKeyword", SqlDbType.NVarChar, -1).Value = searchObject.keyword
                .Parameters.Add("@nvrLocation", SqlDbType.NVarChar, -1).Value = searchObject.location
                .Parameters.Add("@decLatitude", SqlDbType.Decimal).Value = searchObject.latitude
                .Parameters.Add("@decLongitude", SqlDbType.Decimal).Value = searchObject.longitude
                .Parameters.Add("@intDistanceInMiles", SqlDbType.Int).Value = searchObject.radius
                .Parameters.Add("@bntResultsShown", SqlDbType.BigInt).Value = searchObject.resultsShown
                .Parameters.Add("@bitFullProjectExport", SqlDbType.Bit).Value = searchObject.fullProjectExport
                .Parameters.Add("@bntAddEntityProjectIdent", SqlDbType.BigInt).Value = searchObject.addEntityProjectIdent

                .CommandText = "uspSearchEntityNetworkNetwork"

                If searchObject.filters.Count > 0 Then

                    .Parameters.Add("@tblFilters", SqlDbType.Structured).Value = SQLDataTables.EntitySearchFilter(searchObject.filters)

                End If

                daDataAdapter.SelectCommand = cmdCommand
                daDataAdapter.Fill(dsResults)

                If Not dsResults Is Nothing Then

                    If dsResults.Tables.Count >= 1 Then

                        dsResults.Tables(0).TableName = "ResultCounts"
                        dsResults.Tables(1).TableName = "nodes"
                        dsResults.Tables(2).TableName = "links"

                    End If

                End If 'If Not dsResults Is Nothing

                Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

            End With 'With cmdCommand

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            If Not cmdCommand Is Nothing Then

                cmdCommand.Dispose()

            End If

            If Not daDataAdapter Is Nothing Then

                daDataAdapter.Dispose()

            End If

            If Not cnnConnection Is Nothing Then

                If cnnConnection.State = ConnectionState.Open Then

                    cnnConnection.Close()

                End If

                cnnConnection.Dispose()

            End If

            Helper.CleanUp(cmdCommand)
            Helper.CleanUp(daDataAdapter)
            Helper.CleanUp(cnnConnection)
            Helper.CleanUp(dsResults)

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("Activity")> _
    Public Function Activity(searchObject As EntitySearch)

        Dim cmdCommand As System.Data.SqlClient.SqlCommand = Nothing
        Dim daDataAdapter As System.Data.SqlClient.SqlDataAdapter = Nothing
        Dim cnnConnection As System.Data.SqlClient.SqlConnection = Nothing
        Dim dsResults As System.Data.DataSet = Nothing

        Dim dteStartDate As DateTime = Nothing
        Dim dteEndDate As DateTime = Date.Now()

        Try

            cnnConnection = New System.Data.SqlClient.SqlConnection
            cmdCommand = New System.Data.SqlClient.SqlCommand
            daDataAdapter = New SqlClient.SqlDataAdapter
            dsResults = New System.Data.DataSet

            If cnnConnection.State = ConnectionState.Closed Then

                cnnConnection.ConnectionString = ConfigurationManager.ConnectionStrings("DatabaseConnectionString").ConnectionString
                cnnConnection.Open()

            End If

            'set the appropriate start date based on the last # days searching
            dteStartDate = Date.Now().AddDays(searchObject.activityDate * -1).Date

            'if yesterday, then set the end date to be yesterday at 23:59 
            If searchObject.activityDate = 1 Then

                dteEndDate = dteStartDate.AddHours(23).AddMinutes(59).AddSeconds(59)

            End If

            With cmdCommand

                .Connection = cnnConnection
                .CommandType = CommandType.StoredProcedure
                .CommandTimeout = cnnConnection.ConnectionTimeout
                .Parameters.Add("@bntEntityIdent", SqlDbType.BigInt).Value = Helper.ASUserIdent
                .Parameters.Add("@bntASUserIdent", SqlDbType.BigInt).Value = Helper.AddEditASUserIdent
                .Parameters.Add("@nvrKeyword", SqlDbType.NVarChar, -1).Value = searchObject.keyword
                .Parameters.Add("@nvrLocation", SqlDbType.NVarChar, -1).Value = searchObject.location
                .Parameters.Add("@decLatitude", SqlDbType.Decimal).Value = searchObject.latitude
                .Parameters.Add("@decLongitude", SqlDbType.Decimal).Value = searchObject.longitude
                .Parameters.Add("@intDistanceInMiles", SqlDbType.Int).Value = searchObject.radius
                .Parameters.Add("@bntResultsShown", SqlDbType.BigInt).Value = searchObject.resultsShown
                .Parameters.Add("@intPageNumber", SqlDbType.Int).Value = searchObject.pageNumber
                .Parameters.Add("@bitPageChanged", SqlDbType.Bit).Value = searchObject.pageChanged
                .Parameters.Add("@bntActivityTypeGroupIdent", SqlDbType.BigInt).Value = searchObject.activityTypeGroupIdent
                .Parameters.Add("@dteStartDate", SqlDbType.SmallDateTime).Value = dteStartDate
                .Parameters.Add("@dteEndDate", SqlDbType.SmallDateTime).Value = dteEndDate
                .Parameters.Add("@intDateDiff", SqlDbType.Int).Value = searchObject.activityDate

                .CommandText = "uspSearchEntityNetworkActivity"

                If searchObject.filters.Count > 0 Then

                    .Parameters.Add("@tblFilters", SqlDbType.Structured).Value = SQLDataTables.EntitySearchFilter(searchObject.filters)

                End If

                daDataAdapter.SelectCommand = cmdCommand
                daDataAdapter.Fill(dsResults)

                If Not dsResults Is Nothing Then

                    If dsResults.Tables.Count = 2 Then

                        dsResults.Tables(0).TableName = "Results"
                        dsResults.Tables(1).TableName = "ResultDetails"

                    ElseIf dsResults.Tables.Count = 5 Then

                        dsResults.Tables(0).TableName = "Results"
                        dsResults.Tables(1).TableName = "ResultDetails"
                        dsResults.Tables(2).TableName = "ResultCounts"
                        dsResults.Tables(3).TableName = "ActivityGroupCounts"
                        dsResults.Tables(4).TableName = "IntervalCounts"

                    End If

                End If 'If Not dsResults Is Nothing

                Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

            End With 'With cmdCommand

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            If Not cmdCommand Is Nothing Then

                cmdCommand.Dispose()

            End If

            If Not daDataAdapter Is Nothing Then

                daDataAdapter.Dispose()

            End If

            If Not cnnConnection Is Nothing Then

                If cnnConnection.State = ConnectionState.Open Then

                    cnnConnection.Close()

                End If

                cnnConnection.Dispose()

            End If

            Helper.CleanUp(cmdCommand)
            Helper.CleanUp(daDataAdapter)
            Helper.CleanUp(cnnConnection)
            Helper.CleanUp(dsResults)

        End Try

    End Function

    <System.Web.Http.HttpGet> _
    <Route("GetEntitySearchByEntityIdent")> _
    Public Function GetEntitySearchByEntityIdent()

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntitySearchByEntityIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count >= 2 AndAlso
                    dsResults.Tables(0).Rows.Count > 0 Then

                    dsResults.Tables(0).TableName = "EntitySearch"
                    dsResults.Tables(1).TableName = "filters"

                    'dsResults.Relations.Add("EntityEmailRelation", dsResults.Tables(0).Columns("Ident"), dsResults.Tables(1).Columns("EntityIdent"))
                    'dsResults.Relations("EntityEmailRelation").Nested = True

                    Return dsResults

                End If

                Return Request.CreateResponse(HttpStatusCode.OK)

            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsResults)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    <System.Web.Http.HttpPut> _
    <Route("AddEditEntitySearch")> _
    Public Function AddEditEntitySearch(putObject As EntitySearch, Optional ByVal ident As Int64 = 0)

        Dim cmdCommand As System.Data.SqlClient.SqlCommand = Nothing
        Dim daDataAdapter As System.Data.SqlClient.SqlDataAdapter = Nothing
        Dim cnnConnection As System.Data.SqlClient.SqlConnection = Nothing

        Try

            If Not putObject Is Nothing Then

                cnnConnection = New System.Data.SqlClient.SqlConnection
                cmdCommand = New System.Data.SqlClient.SqlCommand
                daDataAdapter = New SqlClient.SqlDataAdapter

                If cnnConnection.State = ConnectionState.Closed Then

                    cnnConnection.ConnectionString = ConfigurationManager.ConnectionStrings("DatabaseConnectionString").ConnectionString
                    cnnConnection.Open()

                End If

                With cmdCommand

                    .Connection = cnnConnection
                    .CommandType = CommandType.StoredProcedure
                    .CommandTimeout = cnnConnection.ConnectionTimeout
                    .CommandText = "uspAddEditEntitySearch"
                    .Parameters.Add("@bntIdent", SqlDbType.BigInt).Value = ident
                    .Parameters.Add("@bntASUserIdent", SqlDbType.BigInt).Value = Helper.AddEditASUserIdent
                    .Parameters.Add("@bntEntityIdent", SqlDbType.BigInt).Value = Helper.ASUserIdent
                    .Parameters.Add("@nvrName1", SqlDbType.NVarChar, -1).Value = putObject.name
                    .Parameters.Add("@nvrDesc1", SqlDbType.NVarChar, -1).Value = putObject.description
                    .Parameters.Add("@nvrCategory", SqlDbType.NVarChar, -1).Value = putObject.category
                    .Parameters.Add("@bitBookmarkSearch", SqlDbType.Bit).Value = putObject.bookmark
                    .Parameters.Add("@nvrKeyword", SqlDbType.NVarChar, -1).Value = putObject.keyword
                    .Parameters.Add("@nvrLocation", SqlDbType.NVarChar, -1).Value = putObject.location
                    .Parameters.Add("@decLatitude", SqlDbType.Decimal).Value = putObject.latitude
                    .Parameters.Add("@decLongitude", SqlDbType.Decimal).Value = putObject.longitude
                    .Parameters.Add("@intDistanceInMiles", SqlDbType.Int).Value = putObject.radius
                    .Parameters.Add("@tblFilters", SqlDbType.Structured).Value = SQLDataTables.EntitySearchFilter(putObject.filters)

                    ident = CType(.ExecuteScalar(), Int64)

                End With 'With cmdCommand

                If ident > 0 Then

                    Return Request.CreateResponse(HttpStatusCode.OK, ident)

                Else

                    Return Request.CreateResponse(HttpStatusCode.BadRequest)

                End If

            End If 'If Not searchObject Is Nothing

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            If Not cmdCommand Is Nothing Then

                cmdCommand.Dispose()

            End If

            If Not daDataAdapter Is Nothing Then

                daDataAdapter.Dispose()

            End If

            If Not cnnConnection Is Nothing Then

                If cnnConnection.State = ConnectionState.Open Then

                    cnnConnection.Close()

                End If

                cnnConnection.Dispose()

            End If

            Helper.CleanUp(cmdCommand)
            Helper.CleanUp(daDataAdapter)
            Helper.CleanUp(cnnConnection)

        End Try

    End Function

    <System.Web.Http.HttpDelete> _
    <Route("{ident}")> _
    Public Function DeleteEntitySearch(ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", ident)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("EntityIdent", Helper.ASUserIdent)

            If Helper.SQLAdapter.ExecuteNonQuery(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeleteEntitySearchByIdent", slParameters, dsMessage) Then

                Return Request.CreateResponse(HttpStatusCode.OK)

            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    <System.Web.Http.HttpGet> _
    <Route("{ident}")> _
    Public Function SearchEntityForFileDownload(ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsSearchResults As System.Data.DataSet = Nothing
        Dim dsResults As System.Data.DataSet = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing

        Dim drSearchRow As DataRow = Nothing
        Dim drFilterRow As DataRow = Nothing
        Dim searchObject As EntitySearch = Nothing
        Dim searchObjectFilter As EntitySearchFilter = Nothing

        Dim fileResponse As HttpResponseMessage = Nothing
        Dim strCSV As String = ""

        Dim strFileName As String = ""

        Try

            fileResponse = Request.CreateResponse(HttpStatusCode.BadRequest)

            slParameters = New SortedList
            slParameters.Add("Ident", ident)
            slParameters.Add("EntityIdent", Helper.ASUserIdent)

            'first, we need the previous search conducted by the user (well check in the SP to make sure it was theres)
            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntitySearchHistoryByIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso _
                    dsResults.Tables.Count = 2 AndAlso _
                    dsResults.Tables(0).Rows.Count > 0 Then

                    drSearchRow = dsResults.Tables(0).Rows(0)

                    'pass the search criteria back into our search object
                    searchObject = New EntitySearch
                    searchObject.searchGlobal = drSearchRow("GlobalSearch")
                    searchObject.keyword = drSearchRow("Keyword")
                    searchObject.location = drSearchRow("Location")
                    searchObject.latitude = drSearchRow("Latitude")
                    searchObject.longitude = drSearchRow("Longitude")
                    searchObject.radius = drSearchRow("DistanceInMiles")
                    searchObject.resultsShown = drSearchRow("SearchResultsReturned")
                    searchObject.fullProjectExport = True

                    For Each drFilterRow In dsResults.Tables(1).Rows

                        searchObjectFilter = New EntitySearchFilter
                        searchObjectFilter.entitySearchFilterTypeIdent = drFilterRow("EntitySearchFilterTypeIdent")
                        searchObjectFilter.entitySearchOperatorIdent = drFilterRow("EntitySearchOperatorIdent")
                        searchObjectFilter.entityProjectRequirementIdent = drFilterRow("EntityProjectRequirementIdent")
                        searchObjectFilter.referenceIdent = drFilterRow("ReferenceIdent")
                        searchObjectFilter.searchValue = drFilterRow("SearchValue")

                        searchObject.filters.Add(searchObjectFilter)

                    Next

                    'and refire the search
                    dsSearchResults = New DataSet
                    Call Entity.SearchEntity(searchObject, dsSearchResults)

                    If Not dsSearchResults Is Nothing Then

                        If dsSearchResults.Tables.Count >= 1 Then

                            dsSearchResults.Tables(0).TableName = "ResultCounts"

                        End If

                        If dsSearchResults.Tables.Count = 2 Then

                            dsSearchResults.Tables(1).TableName = "Entities"

                        End If

                        If searchObject.fullProjectExport And dsSearchResults.Tables.Count = 2 Then

                            'build the CSV file and return as an attachment
                            strCSV = Helper.ConvertDatatableToCSV(dsSearchResults.Tables(1))

                            'return as ProviderListYYYYMMDD.csv
                            strFileName = "ProviderList" & CType(Date.Now.Year, String) & Right("0" & CType(Date.Now.Month, String), 2) & Right("0" & CType(Date.Now.Day, String), 2) & ".csv"

                            fileResponse = New HttpResponseMessage(HttpStatusCode.OK)
                            fileResponse.Content = New ByteArrayContent(Encoding.ASCII.GetBytes(strCSV.ToCharArray))
                            fileResponse.Content.Headers.ContentType = New Headers.MediaTypeHeaderValue("text/csv")
                            fileResponse.Content.Headers.ContentDisposition = New Headers.ContentDispositionHeaderValue("attachment")
                            fileResponse.Content.Headers.ContentDisposition.FileName = strFileName

                        Else

                            'otherwise, just return an error
                            fileResponse = Request.CreateResponse(HttpStatusCode.InternalServerError)

                        End If

                    End If 'If Not dsResults Is Nothing

                End If 'If Not dsResults Is Nothing

            End If 'uspGetEntitySearchHistoryByIdent

        Catch ex As Exception

            Messaging.LogError(ex)

            fileResponse = Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            SearchEntityForFileDownload = fileResponse

            Helper.CleanUp(dsResults)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsSearchResults)
            Helper.CleanUp(dsMessage)

            Helper.CleanUp(drSearchRow)
            Helper.CleanUp(drFilterRow)
            Helper.CleanUp(searchObject)
            Helper.CleanUp(searchObjectFilter)

        End Try

    End Function

End Class