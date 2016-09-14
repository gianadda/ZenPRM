Imports System.Net
Imports System.Web.Http
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

<RoutePrefix("api/entityhierarchy")> _
Public Class EntityHierarchyController
    Inherits ApiController

    <HttpPost> _
    <Route("")> _
    Public Function AddEntityHierarchy(ByVal postObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim intIdent As Int64

        Try

            slParameters = New SortedList
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("HierarchyTypeIdent", CType(postObject("HierarchyTypeIdent"), Int64))
            slParameters.Add("FromEntityIdent", CType(postObject("FromEntityIdent"), Int64))
            slParameters.Add("ToEntityIdent", CType(postObject("ToEntityIdent"), Int64))

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityHierarchy", slParameters, intIdent, dsMessage) Then

                If intIdent > 0 Then

                    Return Request.CreateResponse(HttpStatusCode.OK, intIdent)

                End If

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

    <HttpGet> _
    <Route("{entityIdent}")> _
    Public Function GetEntityHierarchy(ByVal entityIdent As Int64, Optional ByVal reverseLookup As Boolean = False)

        Dim slParameters As SortedList = Nothing
        Dim dsResults As DataSet = Nothing
        Dim dsMessage As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", Helper.ASUserIdent)

            If reverseLookup Then

                slParameters.Add("FromEntityIdent", 0)
                slParameters.Add("ToEntityIdent", entityIdent)

            Else

                slParameters.Add("FromEntityIdent", entityIdent)
                slParameters.Add("ToEntityIdent", 0)

            End If

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityHierarchyByEntityIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                     dsResults.Tables.Count > 0 Then

                    dsResults.Tables(0).TableName = "FromEntity"
                    dsResults.Tables(1).TableName = "Hierarchy"

                    Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

                End If

            End If

            'No user input, something went wrong at the server level
            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsResults)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    <HttpDelete> _
    <Route("{ident}")> _
    Public Function DeleteEntityHierarchy(ByVal ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", ident)
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.ExecuteNonQuery(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeleteEntityProjectHierarchyByIdent", slParameters, dsMessage) Then

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

End Class