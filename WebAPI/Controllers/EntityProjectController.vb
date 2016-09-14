Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class EntityProjectController
    Inherits ApiController

    Dim mbolAllowOptionsAdd As Boolean = False

    <System.Web.Http.HttpPost> _
    <Route("api/EntityProject")> _
    Public Function AddEntityProject(postObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim bolPrivateProject As Boolean = False
        Dim intIdent As Int64 = 0
        Dim intProjectTemplateIdent As Int64 = 0
        Dim bolIncludeParticipants As Boolean = False
        Dim bolIncludeQuestions As Boolean = False
        Dim bolShowOnProfile As Boolean = False
        Dim bolIncludeEntireNetwork As Boolean = False
        Dim bolAllowOpenRegistration As Boolean = False

        Try

            'if we dont check the private project on add, it wont be returned in the object
            Call Boolean.TryParse(postObject("PrivateProject"), bolPrivateProject)
            Call Boolean.TryParse(postObject("ShowOnProfile"), bolShowOnProfile)
            Call Boolean.TryParse(postObject("IncludeEntireNetwork"), bolIncludeEntireNetwork)

            'placeholder functionality for copy from logic
            Call Int64.TryParse(postObject("ProjectTemplateIdent"), intProjectTemplateIdent)
            Call Boolean.TryParse(postObject("IncludeParticipants"), bolIncludeParticipants)
            Call Boolean.TryParse(postObject("IncludeQuestions"), bolIncludeQuestions)

            Call Boolean.TryParse(postObject("AllowOpenRegistration"), bolAllowOpenRegistration)

            slParameters = New SortedList
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Name1", CType(postObject("Name1"), String))
            slParameters.Add("DueDate", postObject("DueDate"))
            slParameters.Add("PrivateProject", bolPrivateProject)
            slParameters.Add("ProjectManagerEntityIdent", CType(postObject("ProjectManagerIdent"), Int64))
            slParameters.Add("ProjectTemplateIdent", intProjectTemplateIdent)
            slParameters.Add("IncludeParticipants", bolIncludeParticipants)
            slParameters.Add("IncludeQuestions", bolIncludeQuestions)
            slParameters.Add("ShowOnProfile", bolShowOnProfile)
            slParameters.Add("IncludeEntireNetwork", bolIncludeEntireNetwork)
            slParameters.Add("AllowOpenRegistration", bolAllowOpenRegistration)

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityProject", slParameters, intIdent, dsMessage) Then

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

    <System.Web.Http.HttpPut> _
    <Route("api/EntityProject/{ident}")> _
    Public Function EditEntityProject(putObject As JObject, ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim bolPrivateProject As Boolean = False
        Dim intIdent As Int64 = 0
        Dim dteDueDate As Date = Nothing
        Dim bolShowOnProfile As Boolean = False
        Dim bolIncludeEntireNetwork As Boolean = False
        Dim bolAllowOpenRegistration As Boolean = False

        Try

            'if we dont check the private project on add, it wont be returned in the object
            Call Boolean.TryParse(putObject("PrivateProject"), bolPrivateProject)
            Call Boolean.TryParse(putObject("ShowOnProfile"), bolShowOnProfile)
            Call Boolean.TryParse(putObject("IncludeEntireNetwork"), bolIncludeEntireNetwork)

            Call Boolean.TryParse(putObject("AllowOpenRegistration"), bolAllowOpenRegistration)

            slParameters = New SortedList
            slParameters.Add("Ident", ident)
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Name1", CType(putObject("Name1"), String))

            If Not putObject("DueDate") Is Nothing AndAlso _
                putObject("DueDate").ToString <> "" Then

                Call Date.TryParse(putObject("DueDate"), dteDueDate)
                slParameters.Add("DueDate", dteDueDate)

            Else

                slParameters.Add("DueDate", Nothing)

            End If

            slParameters.Add("PrivateProject", bolPrivateProject)
            slParameters.Add("ProjectManagerEntityIdent", CType(putObject("ProjectManagerIdent"), Int64))
            slParameters.Add("ShowOnProfile", bolShowOnProfile)
            slParameters.Add("IncludeEntireNetwork", bolIncludeEntireNetwork)
            slParameters.Add("AllowOpenRegistration", bolAllowOpenRegistration)

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspEditEntityProjectByIdent", slParameters, intIdent, dsMessage) Then

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

    <System.Web.Http.HttpDelete> _
    <Route("api/EntityProject/{ident}")> _
    Public Function DeleteEntityProject(ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", ident)
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.ExecuteNonQuery(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeleteEntityProjectByIdent", slParameters, dsMessage) Then

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

    Private Function SaveEntityProjectEntityAnswerValue(intEntityProjectRequirementIdent As Int64, _
                                                        intEntityIdent As Int64, _
                                                        strName1 As String, _
                                                        strValue1 As String) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing
        Dim bolSuccess As Boolean = True

        Try

            slParameters = New SortedList

            slParameters.Add("EntityProjectRequirementIdent", intEntityProjectRequirementIdent)
            slParameters.Add("EntityIdent", intEntityIdent)
            slParameters.Add("Name1", strName1)
            slParameters.Add("Value1", strValue1)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("SuppressOutput", False)
            slParameters.Add("AllowOptionAdd", mbolAllowOptionsAdd)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspSaveEntityProjectEntityAnswerValue", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count >= 1 AndAlso
                    dsResults.Tables(0).Rows.Count > 0 Then

                    bolSuccess = bolSuccess And True

                End If

            Else

                bolSuccess = False

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            SaveEntityProjectEntityAnswerValue = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsResults)
            Helper.CleanUp(dsMessage)

        End Try
    End Function

    <System.Web.Http.HttpDelete> _
    <Route("api/EntityProject/ClearEntityProjectEntityAnswerValue")> _
    Public Function ClearEntityProjectEntityAnswerValue(postObject As JObject) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing
        Dim bolSuccess As Boolean = True

        Try

            slParameters = New SortedList

            slParameters.Add("EntityProjectRequirementIdent", postObject("EntityProjectRequirementIdent"))
            slParameters.Add("EntityIdent", postObject("EntityIdent"))
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspClearEntityProjectEntityAnswerValue", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count >= 1 AndAlso
                    dsResults.Tables(0).Rows.Count > 0 Then

                    bolSuccess = bolSuccess And True

                End If

            Else

                bolSuccess = False

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            ClearEntityProjectEntityAnswerValue = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsResults)
            Helper.CleanUp(dsMessage)

        End Try
    End Function

    <System.Web.Http.HttpPost> _
   <Route("api/EntityProject/Import")> _
    Public Function Import(projectData As JArray)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing
        Dim intEntityIdent As Int64 = 0
        Dim strNPICSV As String = ""

        Try


            For Each item As JObject In projectData.Children()

                intEntityIdent = CType(item("EntityIdent"), Int64)

                If intEntityIdent = 0 Then

                    If (strNPICSV = "") Then
                        strNPICSV = CType(item("NPI"), String)
                    Else
                        strNPICSV = strNPICSV + ", " + CType(item("NPI"), String)
                    End If

                End If
            Next

            slParameters = New SortedList
            dsResults = Nothing

            slParameters.Add("FromEntityIdent", Helper.ASUserIdent)
            slParameters.Add("NPICSV", strNPICSV)
            slParameters.Add("AddASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Active", 1)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityToNetworkByCSV", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 0 AndAlso
                    dsResults.Tables(0).Rows.Count > 0 Then

                

                    intEntityIdent = dsResults.Tables(0).Rows(0)("Ident")

                End If


            End If

            For Each item As JObject In projectData.Children()

                intEntityIdent = CType(item("EntityIdent"), Int64)


                If intEntityIdent = 0 Then

                    For Each drRow In dsResults.Tables(0).Rows
                        If drRow("NPI") = CType(item("NPI"), String) Then
                            intEntityIdent = drRow("Ident")
                        End If
                    Next

                End If

                If intEntityIdent <> 0 Then

                    mbolAllowOptionsAdd = True 'we should add new options that are imported from the file

                    Call post(intEntityIdent, item("Data"))
                End If
            Next

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(dsResults)

        End Try

    End Function


    <System.Web.Http.HttpPost> _
    <Route("api/EntityProject/{ident}")> _
    Public Function post(ident As Int64, projectData As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing
        Dim bolSuccess As Boolean = True
        Dim intRequirementUpdateCount As Int64 = 0
        Dim strClientIP As String = ""
        Dim intEntityProjectRequirementIdent As Int64 = 0

        Dim objFileUpload As JObject = Nothing
        Dim bolFileUploadNotValid As Boolean = False

        Dim strSelectedOptionsList As String = ""

        Try

            For Each item As JProperty In projectData.Children().ToList

                'item.Name
                'item.Value.ToString
                If item.Children().Children().ToList.Count = 0 Then

                    intEntityProjectRequirementIdent = CType(item.Name, Int64)

                    'split this out from an inline function so we can increment the requirement update count on success
                    If SaveEntityProjectEntityAnswerValue(intEntityProjectRequirementIdent, ident, "", item.Value.ToString) Then

                        bolSuccess = bolSuccess And True
                        intRequirementUpdateCount += 1

                    Else

                        bolSuccess = bolSuccess And False

                    End If

                ElseIf item.Children().Children().ToList.Count > 0 Then

                    If item.Children().Children().ToList(0).Type.ToString = "Property" Then

                        objFileUpload = CType(item.Children().ToList(0), JObject)

                        If Not objFileUpload("FileName") Is Nothing AndAlso _
                           Not objFileUpload("FileSize") Is Nothing AndAlso _
                           Not objFileUpload("MimeType") Is Nothing AndAlso _
                           Not objFileUpload("FileContents") Is Nothing AndAlso _
                           Not objFileUpload("FileKey") Is Nothing Then

                            intEntityProjectRequirementIdent = CType(item.Name, Int64)

                            If Helper.ValidateMimeTypeForFileUpload(objFileUpload("MimeType")) Then

                                'split this out from an inline function so we can increment the requirement update count on success
                                If SaveAnswerFileUpload(objFileUpload, intEntityProjectRequirementIdent, ident) Then

                                    bolSuccess = bolSuccess And True
                                    intRequirementUpdateCount += 1

                                Else

                                    bolSuccess = bolSuccess And False

                                End If

                            Else 'invalid file type

                                bolFileUploadNotValid = True

                                bolSuccess = bolSuccess And False


                            End If

                        Else

                            For Each innerItem As JProperty In item.Children().Children().ToList

                                If innerItem.Value.ToString.ToLower = "true" Or innerItem.Value.ToString.ToLower = "false" Then
                                    innerItem.Value = CBool(innerItem.Value.ToString.ToLower)
                                End If

                                'if its selected as true, then we want to make sure its not cleared in the options list sync below
                                If innerItem.Value.ToString.ToLower = "true" Then
                                    strSelectedOptionsList &= innerItem.Name.ToString & "|"
                                End If

                                intEntityProjectRequirementIdent = CType(item.Name, Int64)

                                'split this out from an inline function so we can increment the requirement update count on success
                                If SaveEntityProjectEntityAnswerValue(intEntityProjectRequirementIdent, ident, innerItem.Name, innerItem.Value) Then

                                    bolSuccess = bolSuccess And True
                                    intRequirementUpdateCount += 1

                                Else

                                    bolSuccess = bolSuccess And False

                                End If

                            Next 'For Each innerItem As JProperty

                            'now that weve saved all the selected options, make sure we deactivate any old ones
                            Call ValidateOptionsListForSelectedValues(strSelectedOptionsList, intEntityProjectRequirementIdent, ident)

                        End If 'If Not objFileUpload("FileName") Is Nothing AndAlso

                    ElseIf item.Children().Children().ToList(0).Type.ToString = "Object" Then

                        For Each innerItem As JObject In item.Children().Children().ToList

                            strSelectedOptionsList &= innerItem("name").ToString & "|"

                            intEntityProjectRequirementIdent = CType(item.Name, Int64)
                            'split this out from an inline function so we can increment the requirement update count on success
                            If SaveEntityProjectEntityAnswerValue(intEntityProjectRequirementIdent, ident, innerItem("name"), "true".ToLower) Then

                                bolSuccess = bolSuccess And True
                                intRequirementUpdateCount += 1

                            Else

                                bolSuccess = bolSuccess And False

                            End If

                        Next

                        'now that weve saved all the selected options, make sure we deactivate any old ones
                        Call ValidateOptionsListForSelectedValues(strSelectedOptionsList, intEntityProjectRequirementIdent, ident)

                    End If

                End If

            Next

            strClientIP = HttpContext.Current.Request.Headers("CLIENT-IP")

            If strClientIP Is Nothing Then

                strClientIP = HttpContext.Current.Request.ServerVariables.Item("REMOTE_ADDR")

            End If

            'save an audit record of the number of requirements completed
            'we need to capture a requirement ident so we can join back up to the parent table and get the EntityProjectEntity.Ident value
            Call Helper.SaveASUserActivityRecordForCompletingRequirements(ident, strClientIP, intRequirementUpdateCount, intEntityProjectRequirementIdent, dsMessage)

            If bolSuccess Then

                Return Request.CreateResponse(HttpStatusCode.OK)

            ElseIf bolFileUploadNotValid Then

                Return Request.CreateResponse(HttpStatusCode.UnsupportedMediaType)

            Else

                Return Request.CreateResponse(HttpStatusCode.BadRequest)

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsResults)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(objFileUpload)

        End Try

    End Function

    Protected Function ValidateOptionsListForSelectedValues(ByVal strSelectedOptions As String, ByVal intEntityProjectRequirementIdent As Int64, ByVal intEntityIdent As Int64) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim bolSuccess As Boolean = False

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", intEntityIdent)
            slParameters.Add("EntityProjectRequirementIdent", intEntityProjectRequirementIdent)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("SelectedOptions", strSelectedOptions)

            ' save the file data to the DB, we need the answer ident to store the file in Azure
            If Helper.SQLAdapter.ExecuteNonQuery(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspSaveEntityProjectEntityAnswerValueValidateOptions", slParameters, dsMessage) Then

                bolSuccess = True

            End If 'uspSaveEntityProjectEntityAnswerValueForFileUpload

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            ValidateOptionsListForSelectedValues = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    Protected Function SaveAnswerFileUpload(ByVal objFileUpload As JObject, ByVal intEntityProjectRequirementIdent As Int64, ByVal intEntityIdent As Int64) As Boolean

        Dim strFileName As String = ""
        Dim strFileSize As String = ""
        Dim strMimeType As String = ""
        Dim strFileContents As String = ""
        Dim strFileKey As String = ""

        Dim slParameters As SortedList = Nothing
        Dim intAnswerIdent As Int64 = 0
        Dim strContentToUpload As String = ""
        Dim strFileNameToUpload As String = ""
        Dim strStringToReplace As String = ""

        Dim bytFileContents As Byte() = Nothing
        Dim bytEncryptedFile As Byte() = Nothing
        Dim bolSuccess As Boolean = False
        Dim dsMessage As DataSet = Nothing

        Dim strEncryptedText As String = ""
        Dim strThumbnail As String = ""

        Try

            strFileName = CType(objFileUpload("FileName"), JValue).Value
            strFileSize = CType(objFileUpload("FileSize"), JValue).Value
            strMimeType = CType(objFileUpload("MimeType"), JValue).Value
            strFileContents = CType(objFileUpload("FileContents"), JValue).Value
            strFileKey = CType(objFileUpload("FileKey"), JValue).Value

            If strFileKey.Length = 0 Then

                strFileKey = Encryption.GenerateNewEncryptionKey()

            End If


            'Its possible that the project object is passed to the API w/o base64 encoded content. If so, ignore and more on
            If strFileContents.Length > 0 Then

                slParameters = New SortedList
                slParameters.Add("EntityProjectRequirementIdent", intEntityProjectRequirementIdent)
                slParameters.Add("EntityIdent", intEntityIdent)
                slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)
                slParameters.Add("FileName", strFileName)
                slParameters.Add("FileSize", strFileSize)
                slParameters.Add("MimeType", strMimeType)
                slParameters.Add("FileKey", strFileKey)

                ' save the file data to the DB, we need the answer ident to store the file in Azure
                If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspSaveEntityProjectEntityAnswerValueForFileUpload", slParameters, intAnswerIdent, dsMessage) Then

                    If intAnswerIdent > 0 Then

                        strStringToReplace = "data:" & strMimeType & ";base64,"
                        strContentToUpload = Replace(strFileContents, strStringToReplace, "")

                        'convert our base64 to a byte array to save in Azure
                        bytFileContents = System.Convert.FromBase64String(strContentToUpload)

                        'save as AnswerIdent.enc (for example) so that the file name is always unique. This is assist with file versioning
                        'always save as .txt since we're uploaded the encrypted string value
                        strFileNameToUpload = CType(intAnswerIdent, String) & ".enc" 'stored as an encrypted file

                        'encrypt the file to be stored in azure
                        strEncryptedText = Encryption.EncryptFile(strContentToUpload, strFileKey)

                        bolSuccess = AzureFiles.UploadFileTextToAzure(CType(intEntityIdent, String), strFileNameToUpload, strEncryptedText)

                        'if its a question type of image, we need to generate a thumbnail for the preview
                        If Helper.GetRequirementTypeIdentByEntityProjectRequirementIdent(intEntityProjectRequirementIdent) = Helper.enmRequirementType.ImageUpload Then

                            strThumbnail = Helper.ConvertBase64ImageStringToThumbnail(strContentToUpload, 300)

                            'encrypt the file to be stored in azure
                            strEncryptedText = Encryption.EncryptFile(strThumbnail, strFileKey)

                            strFileNameToUpload = CType(intAnswerIdent, String) & "_thumb" & ".enc" 'stored as an encrypted file

                            Call AzureFiles.UploadFileTextToAzure(CType(intEntityIdent, String), strFileNameToUpload, strEncryptedText)

                        End If

                    End If 'If intAnswerIdent > 0

                End If 'uspSaveEntityProjectEntityAnswerValueForFileUpload

            Else

                'Ignore and move on
                bolSuccess = True

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            SaveAnswerFileUpload = bolSuccess

            Helper.CleanUp(bytFileContents)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(bytEncryptedFile)

        End Try

    End Function

    <System.Web.Http.HttpPost> _
    <Route("api/EntityProject/{ident}/sendemail")> _
    Public Function SendProjectEmail(ByVal ident As Int64, ByVal postData As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing
        Dim strCustomMessage As String = ""

        Try

            If Not postData Is Nothing AndAlso _
                Not postData("customMessage") Is Nothing Then

                strCustomMessage = postData("customMessage")

            End If

            slParameters = New SortedList
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)
            slParameters.Add("AddEditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("EntityProjectIdent", ident)
            slParameters.Add("CustomMessage", strCustomMessage)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddMessageQueueForProjectNotification", slParameters, True, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso _
                    dsResults.Tables.Count > 0 AndAlso _
                    dsResults.Tables(0).Rows.Count > 0 Then

                    dsResults.Tables(0).TableName = "resultCounts"

                    Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

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


    <System.Web.Http.HttpPost> _
    <Route("api/EntityProject/Archive")> _
    Public Function Archive(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try


            slParameters = New SortedList

            slParameters.Add("Ident", CType(putObject("EntityProjectIdent"), Int64))
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspArchiveEntityProjectByIdent", slParameters, False, dsResults, dsMessage) Then

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

    '
    <System.Web.Http.HttpPost> _
    <Route("api/EntityProject/AddEntityToProject")> _
    Public Function AddEntityToProject(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try


            slParameters = New SortedList

            slParameters.Add("FromEntityIdent", Helper.ASUserIdent)
            slParameters.Add("ToEntityIdent", CType(putObject("EntityIdent"), Int64))
            slParameters.Add("EntityProjectIdent", CType(putObject("EntityProjectIdent"), Int64))
            slParameters.Add("AddASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityToEntityProject", slParameters, False, dsResults, dsMessage) Then

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

            Helper.CleanUp(dsResults)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    '
    <System.Web.Http.HttpPost> _
    <Route("api/EntityProject/RemoveEntityFromProject")> _
    Public Function RemoveEntityFromProject(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try


            slParameters = New SortedList

            slParameters.Add("FromEntityIdent", Helper.ASUserIdent)
            slParameters.Add("ToEntityIdent", CType(putObject("EntityIdent"), Int64))
            slParameters.Add("EntityProjectIdent", CType(putObject("EntityProjectIdent"), Int64))
            slParameters.Add("AddASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspRemoveEntityFromEntityProject", slParameters, False, dsResults, dsMessage) Then

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
    <Route("api/EntityProject/Reactivate")> _
    Public Function Reactivate(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try


            slParameters = New SortedList

            slParameters.Add("Ident", CType(putObject("EntityProjectIdent"), Int64))
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspReactivateEntityProjectByIdent", slParameters, False, dsResults, dsMessage) Then

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

    <System.Web.Http.HttpGet> _
    <Route("api/EntityProject/{ident}")> _
    Public Function GetProject(ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("EntityProjectIdent", ident)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityProjectRequirementByEntityProjectIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count >= 1 AndAlso
                    dsResults.Tables(0).Rows.Count > 0 Then

                    dsResults.Tables(0).TableName = "EntityProjectRequirement"
                    dsResults.Tables(1).TableName = "EntityProject"

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
    <Route("api/EntityProject/Details/{ident}")> _
    Public Function GetProjectDetails(ident As Int64, Optional ByVal bolIncludeQuestions As Boolean = False, Optional ByVal bolIncludeParticipants As Boolean = False, Optional ByVal bolIncludeAnswerCount As Boolean = False)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing
        Dim strProjectShareLink As String = ""

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("EntityProjectIdent", ident)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)
            slParameters.Add("IncludeQuestions", bolIncludeQuestions)
            slParameters.Add("IncludeParticipants", bolIncludeParticipants)
            slParameters.Add("IncludeAnswerCount", bolIncludeAnswerCount)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.ASUserIdent, "uspGetEntityProjectDetailsByEntityProjectIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count >= 3 AndAlso
                    dsResults.Tables(1).Rows.Count > 0 Then  'there may not be requirements just yet, still need to load parent data

                    dsResults.Tables(0).TableName = "EntityProjectRequirement"
                    dsResults.Tables(1).TableName = "EntityProject"
                    dsResults.Tables(2).TableName = "EntityProjectEntity"
                    dsResults.Tables(3).TableName = "EntityProjectEntityCounts"

                    If dsResults.Tables("EntityProject").Columns.Contains("AllowOpenRegistration") AndAlso _
                        CType(dsResults.Tables("EntityProject").Rows(0)("AllowOpenRegistration"), Boolean) = True Then

                        strProjectShareLink = System.Configuration.ConfigurationManager.AppSettings("ProjectRegistrationLink")
                        strProjectShareLink = Replace(strProjectShareLink, "{{GUID}}", CType(dsResults.Tables("EntityProject").Rows(0)("ProjectGUID"), Guid).ToString.ToUpper)

                        dsResults.Tables("EntityProject").Columns.Add("ProjectShareLink", GetType(String))
                        dsResults.Tables("EntityProject").Rows(0)("ProjectShareLink") = strProjectShareLink

                    End If

                    Return dsResults

                End If

                Return Request.CreateResponse(HttpStatusCode.NotFound)

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
    <Route("api/EntityProject/GetEntityProjectsByEntityIdent/{entityIdent}")> _
    Public Function GetEntityProjectsByEntityIdent(entityIdent As Int64)

        Dim dsResults As DataSet = Nothing

        Try

            If EntityProject.GetEntityProjectsByEntityIdent(entityIdent, dsResults) Then

                Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

            Else


                Return Request.CreateResponse(HttpStatusCode.OK)


            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsResults)

        End Try

    End Function


    <System.Web.Http.HttpGet> _
    <Route("api/EntityProject/{ident}/{entityIdent}")> _
    Public Function GetProjectForEntity(ident As Int64, entityIdent As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", entityIdent)
            slParameters.Add("EntityProjectIdent", ident)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.ASUserIdent, "uspGetEntityProjectRequirementByEntityProjectIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count >= 1 AndAlso
                    dsResults.Tables(1).Rows.Count > 0 Then  'there may not be requirements just yet, still need to load parent data

                    dsResults.Tables(0).TableName = "EntityProjectRequirement"
                    dsResults.Tables(1).TableName = "EntityProject"

                    Return dsResults

                End If

                Return Request.CreateResponse(HttpStatusCode.NotFound)

            End If

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

    <HttpPost> _
    <Route("api/EntityProject/{ident}/export")> _
    Public Function ExportProject(ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsData As DataSet = Nothing
        Dim intReturnIdent As Int64 = 0

        Try

            slParameters = New SortedList
            slParameters.Add("EntityProjectIdent", ident)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityProjectByIdent", slParameters, False, dsData, dsMessage) Then

                If Not dsData Is Nothing AndAlso _
                    dsData.Tables.Count > 0 AndAlso _
                    dsData.Tables(0).Rows.Count > 0 Then

                    slParameters.Add("NumberOfEntitiesIncluded", dsData.Tables(0).Rows(0)("TotalEntityProjectEntity"))
                    slParameters.Add("NumberOfFilesAttached", dsData.Tables(0).Rows(0)("TotalEntityProjectFiles"))

                    If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityProjectExport", slParameters, intReturnIdent, dsMessage) Then

                        If intReturnIdent > 0 Then

                            'Return the ident, that way we may request the single object if need be on the client
                            Return Request.CreateResponse(HttpStatusCode.OK, ident)

                        End If 'If ident > 0 

                    End If 'If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "usp"

                Else

                    'if the data request didnt return the project, then the user doesnt have access to this project
                    Return Request.CreateResponse(HttpStatusCode.Unauthorized, "False")

                End If ' If Not dsData Is Nothing

            End If 'If Helper.SQLAdapter.GetDataSet

            'catch all if it didnt complete successfully
            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(dsData)

        End Try

    End Function

    <HttpGet> _
    <Route("api/EntityProject/{ProjectIdent}/export")> _
    Public Function GetExportedProjectsByUser(ByVal ProjectIdent As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsData As DataSet = Nothing
        Dim intReturnIdent As Int64 = 0

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("EntityProjectIdent", ProjectIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityProjectExportByProjectIdent", slParameters, False, dsData, dsMessage) Then

                If Not dsData Is Nothing AndAlso _
                    dsData.Tables.Count > 0 Then

                    'Return the ident, that way we may request the single object if need be on the client
                    Return Request.CreateResponse(HttpStatusCode.OK, dsData.Tables(0))

                End If ' If Not dsData Is Nothing

            End If 'If Helper.SQLAdapter.GetDataSet

            'catch all if it didnt complete successfully
            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(dsData)

        End Try

    End Function

    <HttpGet> _
    <Route("api/EntityProject/export/{Ident}")> _
    Public Function GetExportedProjectFileByIdent(ByVal Ident As Int64)

        Dim fileResponse As FileHttpResponseMessage = Nothing

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsData As DataSet = Nothing
        Dim strFileName As String = ""
        Dim strDestinationPath As String = ""
        Dim strDestinationFile As String = ""
        Dim objFileStream As IO.FileStream = Nothing
        Dim intTimeout As Int64 = 0

        Try

            intTimeout = CType(Helper.GetASApplicationVariableByName1("EntityProjectExportFileDownloadTimeout"), Int64)

            'manually override the request timeout for this function. We may need to allow more time for large files to process
            HttpContext.Current.Server.ScriptTimeout = intTimeout

            'default the response if it doesnt complete successfully
            fileResponse = New FileHttpResponseMessage("")
            fileResponse.StatusCode = HttpStatusCode.BadRequest

            slParameters = New SortedList
            slParameters.Add("Ident", Ident)
            slParameters.Add("EntityIdent", Helper.ASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityProjectExportByIdent", slParameters, False, dsData, dsMessage) Then

                If Not dsData Is Nothing AndAlso _
                    dsData.Tables.Count > 0 AndAlso _
                    dsData.Tables(0).Rows.Count > 0 Then

                    strFileName = dsData.Tables(0).Rows(0)("ProjectFileName")

                    strDestinationPath = System.IO.Path.GetTempPath & "ZenPRM\" & CType(Helper.AddEditASUserIdent, String) & "\" 'include user ident to prevent download collision
                    strDestinationFile = strDestinationPath & strFileName

                    If AzureFiles.DownloadEncryptedFileFromAzure(CType(Helper.ASUserIdent, String), strFileName, strDestinationPath, dsData.Tables(0).Rows(0)("ProjectFileKey")) Then

                        objFileStream = IO.File.OpenRead(strDestinationFile)

                        fileResponse = New FileHttpResponseMessage(strDestinationFile)
                        fileResponse.StatusCode = HttpStatusCode.OK
                        fileResponse.Content = New StreamContent(objFileStream)
                        fileResponse.Content.Headers.ContentType = New Headers.MediaTypeHeaderValue("application/zip")
                        fileResponse.Content.Headers.ContentDisposition = New Headers.ContentDispositionHeaderValue("attachment")
                        fileResponse.Content.Headers.ContentDisposition.FileName = dsData.Tables(0).Rows(0)("ProjectFileName")

                    Else

                        fileResponse.StatusCode = HttpStatusCode.Moved
                        fileResponse.Headers.Location = New Uri(HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + "/#/404")

                    End If 'DownloadFileTextFromAzure

                Else

                    'if no data returned, then they are trying to download a file they shouldnt be
                    fileResponse.StatusCode = HttpStatusCode.Moved
                    fileResponse.Content = New StringContent("False")

                End If ' If Not dsData Is Nothing

            End If 'If Helper.SQLAdapter.GetDataSet

        Catch ex As Exception

            Messaging.LogError(ex)

            fileResponse.StatusCode = HttpStatusCode.InternalServerError

        Finally

            GetExportedProjectFileByIdent = fileResponse

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(dsData)

        End Try

    End Function

    <System.Web.Http.HttpGet> _
    <Route("api/EntityProject/{ident}/Entity")> _
    Public Function SearchEntityForProjectAdd(ByVal ident As Int64, Optional ByVal keyword As String = "")

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            If keyword Is Nothing Then

                keyword = ""

            End If

            slParameters = New SortedList
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("EntityProjectIdent", ident)
            slParameters.Add("Keyword", keyword)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspSearchEntityNetworkForProjectAdd", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count >= 1 AndAlso
                    dsResults.Tables(0).Rows.Count > 0 Then

                    dsResults.Tables(0).TableName = "Providers"

                    Return Request.CreateResponse(HttpStatusCode.OK, dsResults.Tables(0))

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

    <AllowAnonymous> _
    <System.Web.Http.HttpGet> _
    <Route("api/entityProject/{guid}/VerifyOpenProjectLink")> _
    Public Function VerifyOpenProjectLink(ByVal guid As String)

        Dim dsResults As DataSet = Nothing

        Try

            If EntityProject.VerifyProjectGUIDForOpenRegistration(guid, dsResults) Then

                Return Request.CreateResponse(HttpStatusCode.OK, dsResults.Tables(0))

            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsResults)

        End Try

    End Function

    <AllowAnonymous> _
    <System.Web.Http.HttpPost> _
    <Route("api/entityProject/{guid}/register")> _
    Public Function RegisterForOpenProject(ByVal guid As String, ByVal objEntity As JObject)

        Dim dsProject As DataSet = Nothing
        Dim dsEmail As DataSet = Nothing
        Dim intCustomerIdent As Int64 = 0
        Dim intEntityIdent As Int64 = 0
        Dim strEmail As String = ""
        Dim intExistingEntityIdent As Int64 = 0
        Dim strExistingEntity As String = ""
        Dim bolCheckUniqueNPIFailed As Boolean = False
        Dim intEntityProjectIdent As Int64 = 0
        Dim intIDIdent As Int64 = 0

        Try

            If EntityProject.VerifyProjectGUIDForOpenRegistration(guid, dsProject) Then

                intCustomerIdent = CType(dsProject.Tables(0).Rows(0)("EntityIdent"), Int64)
                intEntityProjectIdent = CType(dsProject.Tables(0).Rows(0)("Ident"), Int64)

                If Not objEntity("Email") Is Nothing AndAlso _
                    Not objEntity("FirstName") Is Nothing AndAlso _
                    Not objEntity("LastName") Is Nothing Then

                    strEmail = CType(objEntity("Email"), String)

                    If Entity.CheckUniqueEntityEmail(strEmail, intExistingEntityIdent, strExistingEntity) Then

                        'anybody registering to answer open projects need to login, therefore is a public contact
                        objEntity("EntityTypeIdent") = Helper.enmEntityType.PublicContact

                        If Not objEntity("PrimaryState") Is Nothing Then

                            objEntity("PrimaryStateIdent") = LookupTables.GetStatesIdentByName(objEntity("PrimaryState"))

                        End If

                        'so we will have to add them to ZenPRM
                        If Entity.AddEntity(objEntity, intCustomerIdent, True, bolCheckUniqueNPIFailed, intEntityIdent) Then

                            'attach the email
                            If Entity.AddEntityEmail(intEntityIdent, strEmail, False, False, 0, dsEmail) Then

                                'and send them the verify registration email
                                If Login.SendEntityRegistrationEmail(intEntityIdent, strEmail, objEntity("FirstName")) Then

                                    'IF so, make sure the user is added to the entity network and participating in the project
                                    Call EntityProject.VerifyEntitySetupForOpenRegistration(intEntityIdent, intEntityProjectIdent)

                                    'Add the Other ID as well - we wont put in in the NPI field since we cant confirm its an NPI (but we want to store the value from registration)
                                    If Not objEntity("ProviderID") Is Nothing Then

                                        'Store the Provider ID under Other ID
                                        Call Entity.AddEntityOtherID(intEntityIdent, "Provider ID", objEntity("ProviderID"), intEntityIdent, intIDIdent)

                                    End If 'If Not objEntity("ProviderID")

                                    Return Request.CreateResponse(HttpStatusCode.OK)

                                End If 'If Login.SendEntityRegistrationEmail

                            End If 'If Entity.AddEntityEmail

                        End If 'If Entity.AddEntity

                    Else

                        'Entity Email already exists, send them an email so they can access their account
                        Call ForgotPassword.SendForgotPasswordEmailExistingAccount(strEmail)

                        'And make sure the user is added to the entity network and participating in the project
                        Call EntityProject.VerifyEntitySetupForOpenRegistration(intExistingEntityIdent, intEntityProjectIdent)

                        Return Request.CreateResponse(HttpStatusCode.OK)

                    End If 'If Entity.CheckUniqueEntityEmail

                End If 'If Not objEntity("Email") Is Nothing

            End If 'If EntityProject.VerifyProjectGUIDForOpenRegistration

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsProject)
            Helper.CleanUp(dsEmail)

        End Try

    End Function

End Class