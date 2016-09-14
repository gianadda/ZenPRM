Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class EntityToDoController
    Inherits ApiController


    <System.Web.Http.HttpGet> _
    <Route("api/EntityToDo/{IncludeClosed}/{NumberOfDays}")> _
    Public Function GetEntityToDo(IncludeClosed As Boolean, NumberOfDays As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList

            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("IncludeClosed", IncludeClosed)
            slParameters.Add("NumberOfDays", NumberOfDays)
            slParameters.Add("AddEditASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityToDoByEntityIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 2 Then

                    dsResults.Tables(0).TableName = "EntityToDo"
                    dsResults.Tables(1).TableName = "EntityToDoCategory"
                    dsResults.Tables(2).TableName = "EntityToDoComment"

                    Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

                End If 'If Not dsResults Is Nothing

            End If 'If Not searchObject Is Nothing

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsResults)
            Helper.CleanUp(dsMessage)

        End Try

    End Function


    Public Function post(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList

            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("ToDoInitiatorTypeIdent", CType(putObject("ToDoInitiatorTypeIdent"), Int64))
            slParameters.Add("ToDoTypeIdent", CType(putObject("ToDoTypeIdent"), Int64))
            slParameters.Add("ToDoStatusIdent", CType(putObject("ToDoStatusIdent"), Int64))
            slParameters.Add("RegardingEntityIdent", CType(putObject("RegardingEntityIdent"), Int64))
            slParameters.Add("AssigneeEntityIdent", CType(putObject("AssigneeEntityIdent"), Int64))
            slParameters.Add("Title", CType(putObject("Title"), String))
            slParameters.Add("Desc1", CType(putObject("Desc1"), String))
            slParameters.Add("StartDate", CType(putObject("StartDate"), String))
            slParameters.Add("DueDate", CType(putObject("DueDate"), String))
            slParameters.Add("AddASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Active", CBool(putObject("Active")))

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityToDo", slParameters, False, dsResults, dsMessage) Then

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


    Public Function Put(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList

            slParameters.Add("Ident", putObject("Ident"))
            slParameters.Add("ToDoInitiatorTypeIdent", CType(putObject("ToDoInitiatorTypeIdent"), Int64))
            slParameters.Add("ToDoTypeIdent", CType(putObject("ToDoTypeIdent"), Int64))
            slParameters.Add("ToDoStatusIdent", CType(putObject("ToDoStatusIdent"), Int64))
            slParameters.Add("RegardingEntityIdent", CType(putObject("RegardingEntityIdent"), Int64))
            slParameters.Add("AssigneeEntityIdent", CType(putObject("AssigneeEntityIdent"), Int64))
            slParameters.Add("Title", CType(putObject("Title"), String))
            slParameters.Add("Desc1", CType(putObject("Desc1"), String))
            slParameters.Add("StartDate", IIf(CType(putObject("StartDate"), String) = Nothing, "", CType(putObject("StartDate"), String)))
            slParameters.Add("DueDate", IIf(CType(putObject("DueDate"), String) = Nothing, "", CType(putObject("DueDate"), String)))
            slParameters.Add("CategoryIdentCSV", CType(putObject("CategoryIdentCSV"), String))
            slParameters.Add("NewCategoryCSV", CType(putObject("NewCategoryCSV"), String))
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Active", CBool(putObject("Active")))

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspEditEntityToDoByIdent", slParameters, False, dsResults, dsMessage) Then

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

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeleteEntityToDoByIdent", slParameters, False, dsResults, dsMessage) Then

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
    <Route("api/EntityToDo/AddComment")> _
    Public Function AddComment(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList

            slParameters.Add("EntityToDoIdent", putObject("EntityToDoIdent"))
            slParameters.Add("CommentText", putObject("CommentText"))
            slParameters.Add("AddASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Active", CBool(putObject("Active")))

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityToDoComment", slParameters, False, dsResults, dsMessage) Then

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

    <System.Web.Http.HttpPost> _
    <Route("api/EntityToDo/EditComment")> _
    Public Function EditComment(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList

            slParameters.Add("Ident", putObject("Ident"))
            slParameters.Add("EntityToDoIdent", putObject("EntityToDoIdent"))
            slParameters.Add("CommentText", putObject("CommentText"))
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Active", CBool(putObject("Active")))

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspEditEntityToDoCommentByIdent", slParameters, False, dsResults, dsMessage) Then

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

    <System.Web.Http.HttpDelete> _
    <Route("api/EntityToDo/DeleteCategory")> _
    Public Function DeleteCategory(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try


            slParameters = New SortedList

            slParameters.Add("Ident", putObject("Ident"))
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("EditDateTime", Helper.GetLocalTime)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeleteEntityToDoCategoryByIdent", slParameters, False, dsResults, dsMessage) Then

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


    <System.Web.Http.HttpDelete> _
    <Route("api/EntityToDo/DeleteComment")> _
    Public Function DeleteComment(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try


            slParameters = New SortedList

            slParameters.Add("Ident", putObject("Ident"))
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("EditDateTime", Helper.GetLocalTime)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeleteEntityToDoCommentByIdent", slParameters, False, dsResults, dsMessage) Then

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

