
Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class EntityController
    Inherits ApiController

    <System.Web.Http.HttpGet> _
    <Route("api/Entity/")> _
    Public Function GetEntity()

        Try

            Return GetEntityProfile(Helper.ASUserIdent)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        End Try

    End Function

    <System.Web.Http.HttpGet> _
    <Route("api/Entity/{ident}")> _
    Public Function GetEntity(ident As Int64, Optional ByVal summaryView As Boolean = False)

        Dim dsData As DataSet = Nothing

        Try

            dsData = New DataSet

            'make sure this user can access this profile
            If Login.CheckUserAccessToEntityProfile(ident) Then

                If summaryView Then

                    dsData = GetEntityProfileSummary(ident)

                Else

                    dsData = GetEntityProfile(ident)

                End If

            End If

            If Not dsData Is Nothing Then

                If dsData.Tables.Count > 0 AndAlso _
                    dsData.Tables(0).Rows.Count > 0 Then

                    Return Request.CreateResponse(HttpStatusCode.OK, dsData)

                Else

                    'if we dont find this resource, then return 404
                    Return Request.CreateResponse(HttpStatusCode.NotFound)

                End If

            Else

                'if we dont find this resource, then return 404
                Return Request.CreateResponse(HttpStatusCode.NotFound)

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsData)

        End Try

    End Function

    Protected Function GetEntityProfile(ByVal intEntityIdent As Int64) As DataSet

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", intEntityIdent)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)
            slParameters.Add("AddEditASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityByIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count >= 12 AndAlso
                    dsResults.Tables(0).Rows.Count > 0 Then

                    dsResults.Tables(0).TableName = "Entity"
                    dsResults.Tables(1).TableName = "EntityEmail"
                    dsResults.Tables(2).TableName = "Taxonomy"
                    dsResults.Tables(3).TableName = "Services"
                    dsResults.Tables(4).TableName = "Payor"
                    dsResults.Tables(5).TableName = "Language"
                    dsResults.Tables(6).TableName = "Speciality"
                    dsResults.Tables(7).TableName = "Degree"
                    dsResults.Tables(8).TableName = "EntityLicense"
                    dsResults.Tables(9).TableName = "EntitySystem"
                    dsResults.Tables(10).TableName = "EntityOtherID"
                    dsResults.Tables(11).TableName = "EntityProject"
                    dsResults.Tables(12).TableName = "EntityDelegate"
                    dsResults.Tables(13).TableName = "EntityToDo"
                    dsResults.Tables(14).TableName = "EntityToDoCategory"

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetEntityProfile = dsResults

            Helper.CleanUp(dsResults)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    Protected Function GetEntityProfileSummary(ByVal intEntityIdent As Int64) As DataSet

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", intEntityIdent)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)
            slParameters.Add("AddEditASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntitySummaryByIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 0 Then

                    dsResults.Tables(0).TableName = "Entity"

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetEntityProfileSummary = dsResults

            Helper.CleanUp(dsResults)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    <System.Web.Http.HttpGet> _
    <Route("api/Entity/CommunityNetworkMap/{ident}")> _
    Public Function CommunityNetworkMapByIdent(ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsResults As DataSet = Nothing
        Dim dsMessage As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", ident)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)
            slParameters.Add("AddEditASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityNetworkMapByIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 0 Then

                    dsResults.Tables(0).TableName = "EntityConnections"
                    dsResults.Tables(1).TableName = "EntityNodes"
                    dsResults.Tables(2).TableName = "EntityEdges"

                    If dsResults.Tables.Count = 5 Then
                        dsResults.Tables(3).TableName = "nodes"
                        dsResults.Tables(4).TableName = "links"
                    End If

                    Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

                End If

                Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

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

    <System.Web.Http.HttpGet> _
    <Route("api/Entity/CommunityNetworkMap")> _
    Public Function CommunityNetworkMap()

        Return CommunityNetworkMapByIdent(Helper.ASUserIdent)

    End Function

    <System.Web.Http.HttpGet> _
    <Route("api/Entity/GetTopASUserActivity/{ident}")> _
    Public Function GetTopASUserActivity(ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsResults As DataSet = Nothing
        Dim dsMessage As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", ident)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetASUserActivityByEntityIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 0 Then

                    dsResults.Tables(0).TableName = "ASUserActivity"

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

    <System.Web.Http.HttpGet> _
    <Route("api/Entity/GetAuditHistory/{ident}")> _
    Public Function GetAuditHistory(ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsResults As DataSet = Nothing
        Dim dsMessage As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", ident)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityAuditHistoryByEntityIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 0 Then

                    dsResults.Tables(0).TableName = "ASUserActivity"

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

    <System.Web.Http.HttpGet> _
    <Route("api/Entity/SearchEntityForAssignment")> _
    Public Function SearchEntityForAssignment(Optional ByVal keyword As String = "")

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            If keyword Is Nothing Then

                keyword = ""

            End If

            slParameters = New SortedList
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("Keyword", keyword)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspSearchEntityNetworkForToDoAssignment", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 0 Then

                    dsResults.Tables(0).TableName = "Entity"

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

    <System.Web.Http.HttpGet> _
    <Route("api/Entity/SearchEntityForConnection")> _
    Public Function SearchEntityForConnection(ByVal keyword As String, ByVal entityTypeIdent As Int64, ByVal entityIdent As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("Keyword", keyword)
            slParameters.Add("EntityIdent", entityIdent)
            slParameters.Add("EntityTypeIdent", entityTypeIdent)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspSearchEntityGlobalListForNewEntityConnection", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 0 Then

                    dsResults.Tables(0).TableName = "Entity"

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

    <System.Web.Http.HttpPost> _
    <Route("api/Entity/AddEntityToNetwork")> _
    Public Function AddEntityToNetwork(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList

            slParameters.Add("FromEntityIdent", Helper.ASUserIdent)
            slParameters.Add("ToEntityIdent", CType(putObject("Ident"), String))
            slParameters.Add("AddASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Active", CBool(putObject("Active")))
            slParameters.Add("SuppressOutput", CBool(False))

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityToNetwork", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 0 AndAlso
                    dsResults.Tables(0).Rows.Count > 0 Then

                    Return Request.CreateResponse(HttpStatusCode.OK, dsResults.Tables(0))

                End If


            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(dsResults)

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("api/Entity/AddEntityToNetworkByNPI")> _
    Public Function AddEntityToNetworkByNPI(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList

            slParameters.Add("FromEntityIdent", Helper.ASUserIdent)
            slParameters.Add("NPI", CType(putObject("NPI"), String))
            slParameters.Add("AddASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Active", CBool(putObject("Active")))

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityToNetworkByNPI", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 0 AndAlso
                    dsResults.Tables(0).Rows.Count > 0 Then

                    Return Request.CreateResponse(HttpStatusCode.OK, dsResults.Tables(0))

                End If


            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(dsResults)

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("api/Entity/AddEntityToNetworkByCSV")> _
    Public Function AddEntityToNetworkByCSV(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing
        Dim strSPName As String = ""

        Try

            slParameters = New SortedList

            slParameters.Add("FromEntityIdent", Helper.ASUserIdent)
            If CType(putObject("NPICSV"), String) <> "" Then
                slParameters.Add("NPICSV", CType(putObject("NPICSV"), String))
                strSPName = "uspAddEntityToNetworkByCSV"
            Else
                slParameters.Add("CSVOfIdents", CType(putObject("CSVOfIdents"), String))
                strSPName = "uspAddEntityToNetworkByCSVOfIdents"

            End If

            slParameters.Add("AddASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Active", CBool(putObject("Active")))

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, strSPName, slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 0 AndAlso
                    dsResults.Tables(0).Rows.Count > 0 Then

                    Return Request.CreateResponse(HttpStatusCode.OK, dsResults.Tables(0))

                End If


            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(dsResults)

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("api/Entity/RemoveEntityFromNetwork")> _
    Public Function RemoveEntityFromNetwork(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList

            slParameters.Add("FromEntityIdent", Helper.ASUserIdent)
            slParameters.Add("ToEntityIdent", CType(putObject("EntityIdent"), String))
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspRemoveEntityFromNetwork", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 1 Then

                    If dsResults.Tables(1).Rows.Count > 0 Then
                        If dsResults.Tables(1).Rows(0)("ProjectsFound") > 0 Then

                            Return Request.CreateResponse(HttpStatusCode.BadRequest, "This provider is still attached to one or more projects. Please remove them from the project(s) and retry.")

                        End If

                    End If

                    Return Request.CreateResponse(HttpStatusCode.OK, dsResults.Tables(0))

                End If


            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(dsResults)

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("api/Entity")> _
    Public Function post(putObject As JObject)

        Dim bolCheckUniqueNPIFailed As Boolean = False
        Dim intEntityIdent As Int64 = 0
        Dim objReturn As JObject = Nothing

        Try

            If Entity.AddEntity(putObject, Helper.ASUserIdent, False, bolCheckUniqueNPIFailed, intEntityIdent) Then

                objReturn = New JObject
                objReturn("Ident") = intEntityIdent

                Return Request.CreateResponse(HttpStatusCode.OK, objReturn)

            ElseIf bolCheckUniqueNPIFailed Then

                'HTTP 403 : Not allowed, Already Exists
                Return Request.CreateResponse(HttpStatusCode.Forbidden)

            Else

                Return Request.CreateResponse(HttpStatusCode.BadRequest)

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Finally

            Helper.CleanUp(objReturn)

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("api/Entity/import")> _
    Public Function ImportBulkResources(postObject As JArray)

        Try

            If Entity.BulkAddImportEntity(postObject) Then

                Return Request.CreateResponse(HttpStatusCode.OK, postObject)

            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("api/Entity/import/verify")> _
    Public Function ImportBulkResourcesVerifyEntity(postObject As JArray)

        Try

            If Entity.BulkAddVerifyEntity(True, postObject) Then

                Return Request.CreateResponse(HttpStatusCode.OK, postObject)

            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        End Try

    End Function

    <System.Web.Http.HttpPut> _
    <Route("api/Entity")> _
    Public Function Put(putObject As JObject)

        Dim dsResults As DataSet = Nothing
        Dim bolAccessDenied As Boolean = False

        Try

            If Entity.EditEntityByIdent(putObject, dsResults, bolAccessDenied) Then

                Return Request.CreateResponse(HttpStatusCode.OK, dsResults.Tables(0))

            ElseIf bolAccessDenied Then

                Return Request.CreateResponse(HttpStatusCode.Unauthorized)

            Else

                Return Request.CreateResponse(HttpStatusCode.BadRequest)

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("api/Entity/SaveNPI")>
    Public Function postNPI(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim intIdent As Int64 = 0
        Dim bolSuccess As Boolean = False

        Try

            If Entity.CheckUniqueNPI(CType(putObject("EntityIdent"), Int64), CType(putObject("NPI"), String)) Then

                slParameters = New SortedList
                slParameters.Add("Ident", CType(putObject("EntityIdent"), Int64))
                slParameters.Add("NPI", CType(putObject("NPI"), String))
                slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)

                If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspEditEntityNPIByIdent", slParameters, intIdent, dsMessage) Then

                    If intIdent > 0 Then

                        Return Request.CreateResponse(HttpStatusCode.OK, True)

                    End If

                End If 'uspEditEntityNPIByIdent

            Else

                Return Request.CreateResponse(HttpStatusCode.BadRequest, False)

            End If ' If Entity.CheckUniqueNPI

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("api/Entity/SetAsCustomer")>
    Public Function SetAsCustomer(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing
        Dim bolAlreadyRegistered As Boolean = False

        Try

            If Not Login.CheckUserLoggedInAndValidWithPermission(Helper.enmSystemRole.ZenTeam) Then
                Dim errorMsg As String = "Unauthorized access attempted to System Role API call: SetAsCustomer()."
                Messaging.AddMessage(Helper.AddEditASUserIdent, errorMsg, "", "", Environment.MachineName, "", "", Helper.ASUserFullName)
                Return Request.CreateResponse(HttpStatusCode.Unauthorized, "False")
            End If

            slParameters = New SortedList
            slParameters.Add("Ident", CType(putObject("EntityIdent"), Int64))
            slParameters.Add("SystemRoleIdent", CType(putObject("SystemRoleIdent"), Int64))
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspSetEntityAsCustomerByIdent", slParameters, True, dsResults, dsMessage) Then
                
                Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    <System.Web.Http.HttpGet> _
    <Route("api/Entity/IsUniqueNPI")>
    Public Function IsUniqueNPI(Ident As Int64, NPI As String) As Boolean

        Dim bolUnique As Boolean = False

        Try

            bolUnique = Entity.CheckUniqueNPI(Ident, NPI)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Nothing

        Finally

            IsUniqueNPI = bolUnique

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("api/Entity/{ident}/change")> _
    Public Function UpdateEntityEntityType(ByVal ident As Int64, ByVal postObject As JObject)

        Dim intEntityTypeIdent As Int64 = 0
        Dim strNPI As String = ""
        Dim bolAccessDenied As Boolean = False
        Dim intNewEntityIdent As Int64 = 0

        Try

            Call Int64.TryParse(postObject("EntityTypeIdent"), intEntityTypeIdent)

            If Not postObject("NPI") Is Nothing Then

                strNPI = postObject("NPI")

            End If

            If Login.CheckUserAccessToEntityProfile(ident) Then

                If intEntityTypeIdent > 0 Then

                    If Entity.ChangeEntityType(ident, intEntityTypeIdent, strNPI, bolAccessDenied, intNewEntityIdent) Then

                        If Not bolAccessDenied Then

                            Return Request.CreateResponse(HttpStatusCode.OK, intNewEntityIdent)

                        Else

                            Return Request.CreateResponse(HttpStatusCode.BadRequest, "False")

                        End If

                    End If

                End If 'intEntityTypeIdent > 0

            Else 'Login.CheckUserAccessToEntityProfile(ident) = false

                Return Request.CreateResponse(HttpStatusCode.Unauthorized, "False")

            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        End Try

    End Function

    <System.Web.Http.HttpGet> _
    <Route("api/Entity/Network")> _
    Public Function GetEntityNetwork(ByVal includePersons As Boolean, ByVal includeOrganizations As Boolean)

        Dim dsResults As DataSet = Nothing

        Try

            If Entity.GetEntityNetwork(includePersons, includeOrganizations, dsResults) Then

                Return Request.CreateResponse(HttpStatusCode.OK, dsResults.Tables(0))

            Else

                Return Request.CreateResponse(HttpStatusCode.BadRequest)

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsResults)

        End Try

    End Function

End Class