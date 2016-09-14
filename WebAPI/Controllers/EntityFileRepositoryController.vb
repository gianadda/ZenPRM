Imports System.Net
Imports System.Web.Http
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

<RoutePrefix("api/entity/{entityIdent}/files")> _
Public Class EntityFileRepositoryController
    Inherits ApiController

    <HttpGet> _
    <Route("")> _
    Public Function GetEntityFileRepositoryByEntityIdent(ByVal entityIdent As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            'check and see if we are getting another entities repo files (i.e. an admin is submitting on behalf of the user)
            'the SQL proc will make sure we have access to the entities files
            slParameters = New SortedList
            slParameters.Add("EntityIdent", entityIdent)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityFileRepositoryByEntityIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso _
                    dsResults.Tables.Count > 0 AndAlso _
                    dsResults.Tables(0).Rows.Count > 0 Then

                    Return Request.CreateResponse(HttpStatusCode.OK, dsResults.Tables(0))

                Else

                    'no files, still return ok, just no results
                    Return Request.CreateResponse(HttpStatusCode.OK)

                End If

            End If

            'User made a bad request, or there was some bad SQL code ran on what they entered
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

    <HttpGet> _
    <Route("{Ident}")> _
    Public Function GetFile(ByVal entityIdent As Int64, ByVal Ident As Int64, Optional ByVal thumbnail As Boolean = False)

        Dim bytFile As Byte() = Nothing
        Dim bytDecryptedFile As Byte() = Nothing
        Dim fileResponse As HttpResponseMessage = Nothing

        Dim slParameters As SortedList = Nothing
        Dim dsResults As DataSet = Nothing
        Dim dsMessage As DataSet = Nothing

        Dim strFileNameInAzure As String = ""
        Dim strFileNameToClient As String = ""
        Dim strMimeType As String = ""
        Dim strFileKey As String = ""

        Dim strFileContents As String = ""

        Dim intAnswerIdent As Int64 = 0

        Try

            slParameters = New SortedList
            slParameters.Add("AnswerIdent", Ident)
            slParameters.Add("EntityIdent", entityIdent)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityFileRepositoryByIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso _
                    dsResults.Tables.Count > 0 AndAlso _
                    dsResults.Tables(0).Rows.Count > 0 Then

                    strFileNameToClient = If(IsDBNull(dsResults.Tables(0).Rows(0)("FileName")), "", dsResults.Tables(0).Rows(0)("FileName"))
                    strMimeType = If(IsDBNull(dsResults.Tables(0).Rows(0)("MimeType")), "", dsResults.Tables(0).Rows(0)("MimeType"))
                    strFileKey = If(IsDBNull(dsResults.Tables(0).Rows(0)("FileKey")), "", dsResults.Tables(0).Rows(0)("FileKey"))
                    intAnswerIdent = CType(dsResults.Tables(0).Rows(0)("AnswerIdent"), Int64)

                    If thumbnail Then

                        strFileNameInAzure = CType(Ident, String) & "_thumb" & ".enc" 'stored as an encrypted file

                    Else

                        strFileNameInAzure = CType(Ident, String) & ".enc" 'stored as an encrypted file

                    End If

                    If AzureFiles.DownloadFileTextFromAzure(CType(entityIdent, String), strFileNameInAzure, strFileContents) Then

                        'if no mime type assigned, check the database if we have a matched mime type
                        If strMimeType.Length = 0 Then

                            strMimeType = Helper.GetMimeTypeFromFileName(strFileNameToClient)

                        End If

                        'decrypt the file stored in azure
                        bytDecryptedFile = Convert.FromBase64String(Encryption.DecryptFile(strFileContents, strFileKey))

                        fileResponse = New HttpResponseMessage(HttpStatusCode.OK)
                        fileResponse.Content = New ByteArrayContent(bytDecryptedFile)
                        fileResponse.Content.Headers.ContentType = New Headers.MediaTypeHeaderValue(strMimeType)
                        fileResponse.Content.Headers.ContentDisposition = New Headers.ContentDispositionHeaderValue("attachment")
                        fileResponse.Content.Headers.ContentDisposition.FileName = strFileNameToClient

                    Else

                        fileResponse = Request.CreateResponse(HttpStatusCode.Moved)
                        fileResponse.Headers.Location = New Uri(HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + "/#/404")

                    End If 'If Helper.DownloadFileFromAzure

                Else

                    fileResponse = Request.CreateResponse(HttpStatusCode.Unauthorized, "False")

                End If 'If Not dsResults Is Nothing 

            Else

                fileResponse = Request.CreateResponse(HttpStatusCode.BadRequest)

            End If 'uspGetEntityFileRepositoryByIdent

        Catch ex As Exception

            Messaging.LogError(ex)

            fileResponse = Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            GetFile = fileResponse

            Helper.CleanUp(bytFile)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsResults)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(bytDecryptedFile)

        End Try

    End Function

    <HttpPost> _
    <Route("")> _
    Public Function AddEntityProjectEntityAnswerByRequirementIdent(ByVal postObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing
        Dim intEntityProjectRequirementIdent As Int64 = 0
        Dim intFileRepositoryAnswerIdent As Int64 = 0
        Dim strClientIP As String = ""
        Dim intEntityIdent As Int64 = 0

        Try

            Call Int64.TryParse(postObject("requirementIdent"), intEntityProjectRequirementIdent)
            Call Int64.TryParse(postObject("answerIdent"), intFileRepositoryAnswerIdent)
            Call Int64.TryParse(postObject("entityIdent"), intEntityIdent)

            If intEntityProjectRequirementIdent > 0 And intFileRepositoryAnswerIdent > 0 Then

                If VerifyASUserAccessToEntityProjectRequirementIdent(intEntityProjectRequirementIdent, dsMessage) Then

                    If AddEntityProjectEntityAnswer(intEntityIdent, intEntityProjectRequirementIdent, intFileRepositoryAnswerIdent, dsResults, dsMessage) Then

                        strClientIP = HttpContext.Current.Request.Headers("CLIENT-IP")

                        If strClientIP Is Nothing Then

                            strClientIP = HttpContext.Current.Request.ServerVariables.Item("REMOTE_ADDR")

                        End If

                        'save an audit record of the number of requirements completed
                        'we need to capture a requirement ident so we can join back up to the parent table and get the EntityProjectEntity.Ident value
                        Call Helper.SaveASUserActivityRecordForCompletingRequirements(Helper.ASUserIdent, strClientIP, 1, intEntityProjectRequirementIdent, dsMessage)

                        Return Request.CreateResponse(HttpStatusCode.OK, dsResults.Tables(0))

                    End If

                Else ' not VerifyASUserAccessToEntityProjectRequirementIdent

                    'no access to this requirement
                    Return Request.CreateResponse(HttpStatusCode.Unauthorized, "False")

                End If

            End If

            'no data or couldnt save
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

    <HttpDelete> _
    <Route("{Ident}")> _
    Public Function DeleteEntityFileRepositoryByIdent(ByVal Ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim intIdent As Int64 = 0

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("AnswerIdent", Ident)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityFileRepositoryArchive", slParameters, intIdent, dsMessage) Then

                If intIdent > 0 Then

                    Return Request.CreateResponse(HttpStatusCode.OK)

                Else ' not uspAddEntityFileRepositoryArchive

                    'could delete file, they dont have permission
                    Return Request.CreateResponse(HttpStatusCode.Unauthorized, "False")

                End If

            End If

            'no data or couldnt save
            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    Protected Function VerifyASUserAccessToEntityProjectRequirementIdent(ByVal intEntityProjectRequirementIdent As Int64, _
                                                                         ByRef dsMessage As DataSet) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim bolValid As Boolean = False

        Try

            slParameters = New SortedList
            slParameters.Add("EntityProjectRequirementIdent", intEntityProjectRequirementIdent)
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)

            Call Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspVerifyASUserAccessToEntityProjectRequirementIdent", slParameters, bolValid, dsMessage)

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            VerifyASUserAccessToEntityProjectRequirementIdent = bolValid

            Helper.CleanUp(slParameters)

        End Try

    End Function

    Protected Function AddEntityProjectEntityAnswer(ByVal intEntityIdent As Int64, _
                                                    ByVal intEntityProjectRequirementIdent As Int64, _
                                                    ByVal intEntityProjectEntityAnswerIdent As Int64, _
                                                    ByRef dsResults As DataSet, _
                                                    ByRef dsMessage As DataSet) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim bolValid As Boolean = False
        Dim intAnswerIdent As Int64 = 0
        Dim strSourceFileName As String = ""
        Dim strDestinationFileName As String = ""

        Try

            'we may not receive this, so if this is 0, then it is the user the action is being performed for
            If intEntityIdent = 0 Then

                intEntityIdent = Helper.ASUserIdent

            End If

            slParameters = New SortedList
            slParameters.Add("EntityProjectRequirementIdent", intEntityProjectRequirementIdent)
            slParameters.Add("FromEntityProjectEntityAnswerIdent", intEntityProjectEntityAnswerIdent)
            slParameters.Add("EntityIdent", intEntityIdent)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspSaveEntityProjectEntityAnswerFromEntityFileRepository", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso _
                    dsResults.Tables.Count > 0 AndAlso _
                    dsResults.Tables(0).Rows.Count > 0 Then

                    strSourceFileName = CType(intEntityProjectEntityAnswerIdent, String) & ".enc"
                    strDestinationFileName = CType(dsResults.Tables(0).Rows(0)("Ident"), String) & ".enc"

                    If AzureFiles.CopyAzureFile(CType(intEntityIdent, String), strSourceFileName, strDestinationFileName) Then

                        bolValid = True

                        'if its a question type of image, we need to generate a thumbnail for the preview
                        If Helper.GetRequirementTypeIdentByEntityProjectRequirementIdent(intEntityProjectRequirementIdent) = Helper.enmRequirementType.ImageUpload Then

                            strSourceFileName = CType(intEntityProjectEntityAnswerIdent, String) & "_thumb.enc"
                            strDestinationFileName = CType(dsResults.Tables(0).Rows(0)("Ident"), String) & "_thumb.enc"

                            Call AzureFiles.CopyAzureFile(CType(intEntityIdent, String), strSourceFileName, strDestinationFileName)

                        End If

                    End If 'If Helper.CopyAzureFile

                End If 'If Not dsResults Is Nothing

            End If 'uspSaveEntityProjectEntityAnswerFromEntityFileRepository

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            AddEntityProjectEntityAnswer = bolValid

            Helper.CleanUp(slParameters)

        End Try

    End Function

End Class