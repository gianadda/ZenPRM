Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class EntitySystemController
    Inherits ApiController

    Public Function post(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList

            slParameters.Add("EntityIdent", CType(putObject("EntityIdent"), Int64))
            slParameters.Add("SystemTypeIdent", CType(putObject("SystemTypeIdent"), Int64))
            slParameters.Add("Name1", CType(putObject("Name1"), String))

            If Not putObject("InstalationDate") Is Nothing Then

                slParameters.Add("InstalationDate", CType(putObject("InstalationDate"), JValue).Value)

            Else

                slParameters.Add("InstalationDate", Nothing)

            End If

            If Not putObject("GoLiveDate") Is Nothing Then

                slParameters.Add("GoLiveDate", CType(putObject("GoLiveDate"), JValue).Value)

            Else

                slParameters.Add("GoLiveDate", Nothing)

            End If

            If Not putObject("DecomissionDate") Is Nothing Then

                slParameters.Add("DecomissionDate", CType(putObject("DecomissionDate"), JValue).Value)

            Else

                slParameters.Add("DecomissionDate", Nothing)

            End If

            slParameters.Add("AddASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Active", CBool(putObject("Active")))

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntitySystem", slParameters, False, dsResults, dsMessage) Then

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

            Helper.CleanUp(dsResults)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function


    Public Function Put(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing


        Try

            slParameters = New SortedList

            slParameters.Add("Ident", putObject("Ident"))
            slParameters.Add("SystemTypeIdent", CType(putObject("SystemTypeIdent"), Int64))
            slParameters.Add("EntityIdent", CType(putObject("EntityIdent"), Int64))
            slParameters.Add("Name1", CType(putObject("Name1"), String))

            If Not putObject("InstalationDate") Is Nothing Then

                slParameters.Add("InstalationDate", CType(putObject("InstalationDate"), JValue).Value)

            Else

                slParameters.Add("InstalationDate", Nothing)

            End If

            If Not putObject("GoLiveDate") Is Nothing Then

                slParameters.Add("GoLiveDate", CType(putObject("GoLiveDate"), JValue).Value)

            Else

                slParameters.Add("GoLiveDate", Nothing)

            End If

            If Not putObject("DecomissionDate") Is Nothing Then

                slParameters.Add("DecomissionDate", CType(putObject("DecomissionDate"), JValue).Value)

            Else

                slParameters.Add("DecomissionDate", Nothing)

            End If

            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Active", CBool(putObject("Active")))

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspEditEntitySystemByIdent", slParameters, False, dsResults, dsMessage) Then

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


    Public Function Delete(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try


            slParameters = New SortedList

            slParameters.Add("Ident", putObject("Ident"))
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("EditDateTime", Helper.GetLocalTime)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeleteEntitySystemByIdent", slParameters, False, dsResults, dsMessage) Then

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
End Class

