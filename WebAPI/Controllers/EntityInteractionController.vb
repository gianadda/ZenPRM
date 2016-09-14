

Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class EntityInteractionController
    Inherits ApiController


    <System.Web.Http.HttpPost> _
    Public Function post(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList

            slParameters.Add("FromEntityIdent", Helper.ASUserIdent)
            slParameters.Add("ToEntityIdent", CType(putObject("ToEntityIdent"), Int64))
            slParameters.Add("InteractionText", CType(putObject("InteractionText"), String))
            slParameters.Add("InteractionTypeIdents", CType(putObject("InteractionTypeIdents"), String))
            slParameters.Add("Important", CType(putObject("Important"), Boolean))
            slParameters.Add("AddASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Active", CBool(putObject("Active")))

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityInteraction", slParameters, False, dsResults, dsMessage) Then

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

    <System.Web.Http.HttpPut> _
    <Route("api/EntityInteraction/{ident}")> _
    Public Function put(ByVal ident As Int64, putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim intIdent As Int64 = 0

        Try

            slParameters = New SortedList

            slParameters.Add("Ident", ident)
            slParameters.Add("FromEntityIdent", Helper.ASUserIdent)
            slParameters.Add("InteractionText", CType(putObject("InteractionText"), String))
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspEditEntityInteractionByIdent", slParameters, intIdent, dsMessage) Then

                If intIdent > 0 Then

                    Return Request.CreateResponse(HttpStatusCode.OK)

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

    <System.Web.Http.HttpGet> _
    <Route("api/EntityInteraction/{ident}")> _
    Public Function GetEntityInteraction(ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("FromEntityIdent", Helper.ASUserIdent)
            slParameters.Add("ToEntityIdent", ident)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityInteractionByIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count >= 1 Then

                    dsResults.Tables(0).TableName = "EntityInteraction"

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

    Public Function Delete(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try


            slParameters = New SortedList

            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("EntityInteractionIdent", putObject("EntityInteractionIdent"))
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("EditDateTime", Helper.GetLocalTime)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeleteEntityInteractionByIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 0 Then

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

End Class
