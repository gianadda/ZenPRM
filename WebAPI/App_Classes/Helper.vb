Imports SQLDataAccess.Data

Public Class Helper

    Public Enum enmSystemRole

        Customer = 1
        Entity = 2
        ZenTeam = 3

    End Enum

    Public Enum enmMessageTemplate

        ForgotPassword = 1
        ForgotPasswordNoEmailOnFile = 2
        Registration = 3
        VerifyEmail = 4
        AddedAsDelegate = 5
        ProjectNotification = 6
        ForgotPasswordExistingAccount = 7

    End Enum

    Public Enum enmEntityGUIDType

        PublicMap = 1

    End Enum

    Public Enum enmActivityType

        Login = 1
        Logout = 2
        LoginAsDelegate = 3
        LogoutAsDelegate = 4
        EditProfile = 5
        CompletedRequirement = 6
        LoginFailed = 52
        UserAccountLocked = 53

    End Enum

    Public Enum enmEntityType

        Organization = 2
        Provider = 3
        Facility = 4
        PrivateContact = 6
        Committee = 7
        Other = 8
        PublicContact = 9

    End Enum

    Public Enum enmMessageType

        Email = 1

    End Enum

    Public Enum enmRequirementType

        ImageUpload = 19

    End Enum

    Public Enum enmEntitySearchFilterType

        ProjectSpecific = 1
        EntityType = 2
        Specialty = 3
        AcceptingNewPatients = 4
        SoleProvider = 5
        Payor = 6
        Language = 7
        Gender = 8
        Degree = 9
        RegisteredUser = 10
        Organizations = 11



    End Enum

    Public Enum enmMeasureLocation

        Dashboard = 1
        ProjectOverview = 2
        ResourceProfile = 3
        OrganizationStructure = 4

    End Enum

    Public Shared ReadOnly Property ApplicationName() As String
        Get

            Return "Zen_PRM"

        End Get
    End Property

    Public Shared ReadOnly Property LocalTimeOffset() As Double

        Get

            If Not HttpContext.Current.Session Is Nothing Then

                If HttpContext.Current.Session("LocalTimeOffset") Is Nothing Then

                    HttpContext.Current.Session("LocalTimeOffset") = CType(System.Configuration.ConfigurationManager.AppSettings("LocalTimeOffset").ToString, Double)

                End If

                Return HttpContext.Current.Session("LocalTimeOffset")

            Else

                Return CType(System.Configuration.ConfigurationManager.AppSettings("LocalTimeOffset").ToString, Double)

            End If

        End Get

    End Property

    Public Shared ReadOnly Property VersionNumber() As String

        Get

            If HttpContext.Current.Cache("VersionNumber") Is Nothing Then

                HttpContext.Current.Cache.Add("VersionNumber", System.Configuration.ConfigurationManager.AppSettings("VersionNumber"), Nothing, _
                                                System.Web.Caching.Cache.NoAbsoluteExpiration, New TimeSpan(1, 0, 0, 0), CacheItemPriority.Default, Nothing)

            End If

            Return HttpContext.Current.Cache("VersionNumber")

        End Get

    End Property


    Public Shared Property ASUserIdent() As Int64

        Get

            If Not HttpContext.Current.Session Is Nothing Then

                If HttpContext.Current.Session("ASUserIdent") Is Nothing Then

                    HttpContext.Current.Session("ASUserIdent") = 0

                End If

                Return HttpContext.Current.Session("ASUserIdent")

            Else

                Return 0

            End If

        End Get
        Set(value As Int64)

            HttpContext.Current.Session("ASUserIdent") = value

        End Set

    End Property

    'if a user switches over to delegation mode, this stores the users ident where ASUserIdent is switched to the user they are delegating for
    Public Shared Property DelegateASUserIdent() As Int64

        Get

            If Not HttpContext.Current.Session Is Nothing Then

                If HttpContext.Current.Session("DelegateASUserIdent") Is Nothing Then

                    HttpContext.Current.Session("DelegateASUserIdent") = 0

                End If

                Return HttpContext.Current.Session("DelegateASUserIdent")

            Else

                Return 0

            End If

        End Get
        Set(value As Int64)

            HttpContext.Current.Session("DelegateASUserIdent") = value

        End Set

    End Property

    Public Shared Property DelegateASUserFullName() As String

        Get

            If Not HttpContext.Current.Session Is Nothing Then

                If HttpContext.Current.Session("DelegateASUserFullName") Is Nothing Then

                    HttpContext.Current.Session("DelegateASUserFullName") = ""

                End If

                Return HttpContext.Current.Session("DelegateASUserFullName")

            Else

                Return 0

            End If

        End Get
        Set(value As String)

            HttpContext.Current.Session("DelegateASUserFullName") = value

        End Set

    End Property

    'Because we are introducing delegation, this variable will store who the actual editing user is. 
    Public Shared ReadOnly Property AddEditASUserIdent() As Int64

        Get

            If DelegateASUserIdent > 0 Then

                Return DelegateASUserIdent

            Else

                Return ASUserIdent

            End If

        End Get

    End Property

    'Because we are introducing delegation, this variable will store who the actual editing user is. 
    Public Shared ReadOnly Property AddEditASUserFullName() As String

        Get

            If DelegateASUserIdent > 0 Then

                Return DelegateASUserFullName

            Else

                Return ASUserFullName

            End If

        End Get

    End Property

    Public Shared ReadOnly Property DelegationMode() As Boolean

        Get

            If DelegateASUserIdent > 0 Then

                Return True

            Else

                Return False

            End If

        End Get

    End Property

    Public Shared Property ASUserFullName() As String

        Get

            If Not HttpContext.Current.Session Is Nothing Then

                If HttpContext.Current.Session("ASUserFullName") Is Nothing Then

                    HttpContext.Current.Session("ASUserFullName") = ""

                End If

                Return HttpContext.Current.Session("ASUserFullName")

            Else

                Return 0

            End If

        End Get
        Set(value As String)

            HttpContext.Current.Session("ASUserFullName") = value

        End Set

    End Property

    Public Shared Property SystemRoleIdent() As Int64

        Get

            If Not HttpContext.Current.Session Is Nothing Then

                If HttpContext.Current.Session("SystemRoleIdent") Is Nothing Then

                    HttpContext.Current.Session("SystemRoleIdent") = 0

                End If

                Return HttpContext.Current.Session("SystemRoleIdent")

            Else

                Return 0

            End If

        End Get
        Set(value As Int64)

            HttpContext.Current.Session("SystemRoleIdent") = value

        End Set

    End Property

    Public Shared Property IsCustomer() As Boolean

        Get

            If Not HttpContext.Current.Session Is Nothing Then

                If HttpContext.Current.Session("IsCustomer") Is Nothing Then

                    HttpContext.Current.Session("IsCustomer") = False

                End If

                Return HttpContext.Current.Session("IsCustomer")

            Else

                Return 0

            End If

        End Get

        Set(value As Boolean)

            HttpContext.Current.Session("IsCustomer") = value

        End Set

    End Property

    Public Shared ReadOnly Property SQLAdapter As DataAccess

        Get

            Return New DataAccess

        End Get

    End Property

    Public Shared Sub CleanUp(ByRef objObject As Object, ByVal bolObjectSupportsDispose As Boolean)

        Try

            If Not objObject Is Nothing AndAlso bolObjectSupportsDispose Then

                CType(objObject, IDisposable).Dispose()

            End If

            objObject = Nothing

        Catch ex As Exception

            Throw ex

        Finally

            objObject = Nothing

        End Try

    End Sub

    Public Shared Sub RemoveSessionVar(ByVal name As String)

        Try

            If Not HttpContext.Current.Session(name) Is Nothing Then

                HttpContext.Current.Session.Remove(name)

            End If

        Catch ex As Exception

            Throw ex

        End Try

    End Sub

    Public Shared Sub CleanUp(ByRef objObject As Object)

        Try

            If Not objObject Is Nothing AndAlso Not objObject.GetType.GetInterface("IDisposable", True) Is Nothing Then

                CType(objObject, IDisposable).Dispose()

            End If

            objObject = Nothing

        Catch ex As Exception

            Throw ex

        Finally

            objObject = Nothing

        End Try

    End Sub

    Public Shared Function GetReturnValueFromDataset(ByVal dsResults As System.Data.DataSet) As System.Xml.XmlNode

        Dim xmlDoc As System.Xml.XmlDocument = Nothing

        Try

            xmlDoc = New System.Xml.XmlDocument()
            xmlDoc.LoadXml(dsResults.GetXml())

            Return xmlDoc.FirstChild().FirstChild()

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Nothing

        Finally

            CleanUp(xmlDoc)

        End Try

    End Function

    Public Shared Function GetASApplicationVariableByName1(ByVal strAppVarName As String) As String

        Dim dsData As System.Data.DataSet = Nothing
        Dim slParameters As SortedList = Nothing
        Dim strAppVarValue As String = ""
        Dim dsMessage As System.Data.DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("Name1", strAppVarName)

            If SQLAdapter.GetDataSet(ApplicationName, ASUserIdent, "uspGetASApplicationVariableByName1", slParameters, False, dsData, dsMessage) Then

                If Not dsData Is Nothing AndAlso _
                    dsData.Tables.Count > 0 AndAlso _
                    dsData.Tables(0).Rows.Count > 0 Then

                    strAppVarValue = dsData.Tables(0).Rows(0)("Value1").ToString

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetASApplicationVariableByName1 = strAppVarValue

            CleanUp(slParameters)
            CleanUp(dsData)
            CleanUp(dsMessage)

        End Try

    End Function

    Public Shared Function VerifyMessageQueueGUID(ByVal strGUID As String, ByVal enmMessageTemplateIdent As Helper.enmMessageTemplate, ByRef dsData As System.Data.DataSet) As Boolean

        Dim bolValid As Boolean = False
        Dim slParameters As SortedList = Nothing
        Dim dsResults As System.Data.DataSet = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing

        Try

            slParameters = New SortedList
            dsResults = New System.Data.DataSet

            'Additon of parameters
            slParameters.Add("Guid", strGUID)
            slParameters.Add("MessageTemplateIdent", enmMessageTemplateIdent)

            'Call Stored procedure 
            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspCheckMessageQueueGUIDByMessageTemplateIdent", slParameters, True, dsResults, dsMessage) Then

                If Not dsResults Is Nothing _
                    AndAlso dsResults.Tables.Count > 0 _
                    AndAlso dsResults.Tables(0).Rows.Count > 0 Then

                    dsData = dsResults
                    bolValid = True

                End If 'If Not dsResults Is Nothing

            End If 'If MyBase.Helper.CallStoredProcedure("uspCheckASUserEmailAccessByASUserIdent", _

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            VerifyMessageQueueGUID = bolValid

            CleanUp(slParameters)
            CleanUp(dsResults)
            CleanUp(dsMessage)

        End Try

    End Function

    Public Shared Function DeactivateMessageQueueGUID(ByVal strGUID As String) As Boolean

        Dim bolValid As Boolean = False
        Dim slParameters As SortedList = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing

        Try

            slParameters = New SortedList

            'Additon of parameters
            slParameters.Add("Guid", strGUID)

            'Call Stored procedure 
            If Helper.SQLAdapter.ExecuteNonQuery(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeactivateMessageQueueGUID", slParameters, dsMessage) Then

                bolValid = True

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            DeactivateMessageQueueGUID = bolValid

            CleanUp(slParameters)
            CleanUp(dsMessage)

        End Try

    End Function

    Public Shared Sub AddASUserActivity(ByVal bolOverrideAddEditASUser As Boolean, _
                                        ByVal intActivityTypeIdent As enmActivityType, _
                                        ByVal intRecordIdent As Int64, _
                                        ByVal intCustomerEntityIdent As Int64, _
                                        ByVal slReplacementText As SortedList, _
                                        ByRef intASUserActivityIdent As Int64, _
                                        ByRef dsMessage As DataSet)

        Dim dsActivityType As DataSet = Nothing
        Dim slParameters As SortedList = Nothing
        Dim deDictionaryEntry As System.Collections.DictionaryEntry = Nothing
        Dim strActivityDescription As String = ""
        Dim strClientIP As String = ""

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", intActivityTypeIdent)

            If SQLAdapter.GetDataSet(ApplicationName, AddEditASUserIdent, "uspGetActivityTypeByIdent", slParameters, False, dsActivityType, dsMessage) Then

                If Not dsActivityType Is Nothing AndAlso _
                    dsActivityType.Tables.Count > 0 AndAlso _
                    dsActivityType.Tables(0).Rows.Count > 0 Then

                    strActivityDescription = dsActivityType.Tables(0).Rows(0)("Desc1")

                    If Not slReplacementText Is Nothing Then

                        For Each deDictionaryEntry In slReplacementText

                            strActivityDescription = Replace(strActivityDescription, deDictionaryEntry.Key, deDictionaryEntry.Value)

                        Next

                    End If 'If Not slReplacementText Is Nothing 

                    strClientIP = HttpContext.Current.Request.Headers("CLIENT-IP")

                    If strClientIP Is Nothing Then

                        strClientIP = HttpContext.Current.Request.ServerVariables.Item("REMOTE_ADDR")

                    End If

                    slParameters = New SortedList

                    If bolOverrideAddEditASUser Then

                        slParameters.Add("ASUserIdent", intRecordIdent)

                    Else

                        slParameters.Add("ASUserIdent", AddEditASUserIdent)

                    End If

                    slParameters.Add("ActivityTypeIdent", intActivityTypeIdent)
                    slParameters.Add("ActivityDescription", strActivityDescription)
                    slParameters.Add("ClientIPAddress", strClientIP)
                    slParameters.Add("RecordIdent", intRecordIdent)
                    slParameters.Add("CustomerEntityIdent", intCustomerEntityIdent)

                    Call SQLAdapter.ExecuteScalar(ApplicationName, AddEditASUserIdent, "uspAddASUserActivity", slParameters, intASUserActivityIdent, dsMessage)

                End If 'If Not dsActivityType Is Nothing

            End If 'uspGetActivityTypeByIdent

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            CleanUp(slParameters)
            CleanUp(dsActivityType)
            CleanUp(deDictionaryEntry)

        End Try

    End Sub

    Public Shared Sub SaveASUserActivityRecordForCompletingRequirements(ByVal intEntityIdent As Int64, _
                                                                    ByVal strClientIPAddress As String, _
                                                                    ByVal intNumberOfRequirements As Int64, _
                                                                    ByVal intEntityProjectRequirementIdent As Int64, _
                                                                    ByRef dsMessage As DataSet)

        Dim slParameters As SortedList = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("ASUserIdent", AddEditASUserIdent)
            slParameters.Add("EntityIdent", intEntityIdent)
            slParameters.Add("ClientIPAddress", strClientIPAddress)
            slParameters.Add("NumberOfRequirements", CType(intNumberOfRequirements, String))
            slParameters.Add("EntityProjectRequirementIdent", intEntityProjectRequirementIdent)

            Call SQLAdapter.ExecuteNonQuery(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddASUserActivityForCompletedRequirements", slParameters, dsMessage)

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            CleanUp(slParameters)

        End Try

    End Sub

    Public Shared Function VerifyEntityGUID(ByVal strGUID As String, ByVal intEntityGUIDTypeIdent As Helper.enmEntityGUIDType, ByRef intEntityIdent As Int64) As Boolean

        Dim bolValid As Boolean = False
        Dim slParameters As SortedList = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("Guid", strGUID)
            slParameters.Add("EntityGUIDTypeIdent", intEntityGUIDTypeIdent)

            'Call Stored procedure 
            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspCheckEntityGUIDByEntityGUIDTypeIdent", slParameters, intEntityIdent, dsMessage) Then

                If intEntityIdent > 0 Then

                    bolValid = True

                End If 'If Not dsResults Is Nothing

            End If 'If MyBase.Helper.CallStoredProcedure("uspCheckASUserEmailAccessByASUserIdent", _

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            VerifyEntityGUID = bolValid

            CleanUp(slParameters)
            CleanUp(dsMessage)

        End Try

    End Function

    Public Shared Function GetLocalTime() As DateTime

        'this function is designed to handle EST no matter where it is hosted
        Return DateTime.UtcNow().AddHours(LocalTimeOffset)

    End Function

    Public Shared Function GetAPIXML(ByVal strURL As String, _
                               ByRef XmlDocument As System.Xml.XmlDocument) As Boolean

        Dim request As System.Net.HttpWebRequest = Nothing
        Dim response As System.Net.HttpWebResponse = Nothing
        Dim reader As IO.StreamReader = Nothing
        Dim bolSuccess As Boolean = False

        Try

            request = System.Net.WebRequest.Create(strURL)

            Try

                response = request.GetResponse

            Catch ex As Net.WebException

                'Debug mode. The test API key doesnt allow more than 1 request per second. We are sleeping for 1 second
                'and retrying
                System.Threading.Thread.Sleep(1000)

                'Retry once after waiting 1 sec to determine if this is the reason we see the 403- forbidden error
                response = request.GetResponse

            End Try

            If response.StatusCode = System.Net.HttpStatusCode.OK Then

                reader = New IO.StreamReader(response.GetResponseStream())
                XmlDocument = New System.Xml.XmlDocument()

                XmlDocument.Load(reader)
                reader.Close()

                bolSuccess = True

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetAPIXML = bolSuccess

            'Cleanup
            If Not response Is Nothing Then

                response.Close()

            End If

            CleanUp(request)
            CleanUp(response)
            CleanUp(reader)

        End Try

    End Function

    Public Shared Function GetAPIJSON(ByVal strURL As String, _
                               ByRef objJSON As Newtonsoft.Json.Linq.JObject,
                                     Optional ByVal slHeaders As SortedList = Nothing) As Boolean

        Dim request As System.Net.HttpWebRequest = Nothing
        Dim response As System.Net.HttpWebResponse = Nothing
        Dim reader As IO.StreamReader = Nothing
        Dim objJSONReader As Newtonsoft.Json.JsonTextReader = Nothing
        Dim objSerializer As Newtonsoft.Json.JsonSerializer = Nothing
        Dim bolSuccess As Boolean = False

        Try

            request = System.Net.WebRequest.Create(strURL)

            If Not slHeaders Is Nothing Then

                For Each objItem As DictionaryEntry In slHeaders

                    'http://stackoverflow.com/questions/239725/cannot-set-some-http-headers-when-using-system-net-webrequest
                    'The WebHeaderCollection class is generally accessed through WebRequest.Headers or WebResponse.Headers. 
                    'Some common headers are considered restricted and are either exposed directly by the API (such as Content-Type) or protected by the system and cannot be changed.
                    Select Case objItem.Key.ToString.ToUpper

                        Case "ACCEPT"

                            request.Accept = objItem.Value

                        Case "CONNECTION"

                            request.Connection = objItem.Value

                        Case "CONTENT-LENGTH"

                            request.ContentLength = objItem.Value

                        Case "CONTENT-TYPE"

                            request.ContentType = objItem.Value

                        Case "DATE"

                            request.Date = objItem.Value

                        Case "EXPECT"

                            request.Expect = objItem.Value

                        Case "HOST"

                            request.Host = objItem.Value

                        Case "IF-MODIFIED-SINCE"

                            request.IfModifiedSince = objItem.Value

                        Case "REFERER"

                            request.Referer = objItem.Value

                        Case "TRANSFER-ENCODING"

                            request.TransferEncoding = objItem.Value

                        Case "USER-AGENT"

                            request.UserAgent = objItem.Value

                        Case "PROXY-CONNECTION"

                            request.Proxy = objItem.Value

                        Case Else

                            request.Headers(objItem.Key) = objItem.Value

                    End Select

                Next

            End If

            Try

                response = request.GetResponse

            Catch ex As Net.WebException

                Messaging.LogError(ex)

            End Try

            If response.StatusCode = System.Net.HttpStatusCode.OK Then

                reader = New IO.StreamReader(response.GetResponseStream())
                objJSONReader = New Newtonsoft.Json.JsonTextReader(reader)
                objSerializer = New Newtonsoft.Json.JsonSerializer()
                objJSON = objSerializer.Deserialize(objJSONReader)

                reader.Close()

                bolSuccess = True

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetAPIJSON = bolSuccess

            'Cleanup
            If Not response Is Nothing Then

                response.Close()

            End If

            CleanUp(request)
            CleanUp(response)
            CleanUp(reader)

        End Try

    End Function

    Public Shared Function GetXMLNodeInnerText(ByVal xmlNode As System.Xml.XmlNode, _
                                                ByVal strChildNodeName As String, _
                                                ByVal nsmManager As System.Xml.XmlNamespaceManager) As String

        Dim strInnerText As String = ""

        Try

            If Not xmlNode Is Nothing AndAlso _
                Not xmlNode.SelectSingleNode(strChildNodeName, nsmManager) Is Nothing Then

                strInnerText = xmlNode.SelectSingleNode(strChildNodeName, nsmManager).InnerText

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetXMLNodeInnerText = strInnerText

        End Try

    End Function

    Public Shared Function GetEntityByEmailAddress(ByVal strEmailAddress As String, _
                                                    ByRef drEntity As DataRow) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing
        Dim dsResults As System.Data.DataSet = Nothing
        Dim bolSuccess As Boolean = False

        Try

            slParameters = New SortedList
            slParameters.Add("EmailAddress", strEmailAddress)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspSearchEntityByEmailAddress", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso _
                    dsResults.Tables.Count > 0 AndAlso _
                    dsResults.Tables(0).Rows.Count > 0 Then

                    drEntity = dsResults.Tables(0).Rows(0)

                    bolSuccess = True

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetEntityByEmailAddress = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(dsResults)

        End Try

    End Function

    Public Shared Function GetEntityRegistrationStatusByIdent(ByVal intEntityIdent As Int64, _
                                                                ByRef drEntity As DataRow, _
                                                                ByRef dtEntityEmail As DataTable) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing
        Dim dsResults As System.Data.DataSet = Nothing
        Dim bolSuccess As Boolean = False

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", intEntityIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityRegistrationStatusByIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso _
                    dsResults.Tables.Count = 2 AndAlso _
                    dsResults.Tables(0).Rows.Count > 0 Then

                    drEntity = dsResults.Tables(0).Rows(0)
                    dtEntityEmail = dsResults.Tables(1)

                    bolSuccess = True

                End If 'If Not dsResults

            End If 'uspSearchEntityByEmailAddress

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetEntityRegistrationStatusByIdent = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(dsResults)

        End Try

    End Function

    Public Shared Function CheckExistingEntityConnection(ByVal intFromEntityIdent As Int64, _
                                                         ByVal intToEntityIdent As Int64, _
                                                         ByVal bolDelegate As Boolean) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing
        Dim bolExisting As Boolean = False
        Dim intEntityConnectionIdent As Int64 = 0

        Try

            slParameters = New SortedList
            slParameters.Add("FromEntityIdent", intFromEntityIdent)
            slParameters.Add("ToEntityIdent", intToEntityIdent)
            slParameters.Add("Delegate", bolDelegate)

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspVerifyExistingEntityConnection", slParameters, intEntityConnectionIdent, dsMessage) Then

                If intEntityConnectionIdent > 0 Then

                    bolExisting = True

                End If 'If intEntityConnectionIdent > 0

            End If 'uspVerifyExistingEntityConnection

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            CheckExistingEntityConnection = bolExisting

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    Public Shared Function GetMimeTypeFromFileName(ByVal strFileName As String) As String

        Dim strMimeType As String = ""
        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim strExtension As String = ""

        Try

            strExtension = IO.Path.GetExtension(strFileName)

            slParameters = New SortedList
            slParameters.Add("Extension", strExtension)

            Call SQLAdapter.ExecuteScalar(ApplicationName, AddEditASUserIdent, "uspGetMimeTypeByExtension", slParameters, strMimeType, dsMessage)

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetMimeTypeFromFileName = strMimeType

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    Public Shared Function ValidateMimeTypeForFileUpload(ByVal strMimeType As String) As String

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim intIdent As Int64 = 0
        Dim bolValid As Boolean = False

        Try

            slParameters = New SortedList
            slParameters.Add("Name1", strMimeType)

            If SQLAdapter.ExecuteScalar(ApplicationName, AddEditASUserIdent, "uspGetMimeTypeByName1", slParameters, intIdent, dsMessage) Then

                If intIdent > 0 Then

                    bolValid = True

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            ValidateMimeTypeForFileUpload = bolValid

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    Public Shared Function GetRequirementTypeIdentByEntityProjectRequirementIdent(ByVal intEntityProjectRequirementIdent As String) As Int64

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim intIdent As Int64 = 0

        Try

            slParameters = New SortedList
            slParameters.Add("EntityProjectRequirementIdent", intEntityProjectRequirementIdent)

            Call SQLAdapter.ExecuteScalar(ApplicationName, AddEditASUserIdent, "uspGetRequirementTypeIdentByEntityProjectRequirementIdent", slParameters, intIdent, dsMessage)

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetRequirementTypeIdentByEntityProjectRequirementIdent = intIdent

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    Public Shared Function ConvertDatatableToCSV(ByVal dtTable As DataTable) As String

        Dim strData As String = ""
        Dim strReturn As String = ""
        Dim objStringBuilder As StringBuilder = Nothing
        Dim drRow As DataRow = Nothing
        Dim intColumnCount As Integer = 0

        Try

            intColumnCount = (dtTable.Columns.Count - 1)

            objStringBuilder = New StringBuilder()

            For i As Integer = 0 To intColumnCount

                strData = dtTable.Columns(i).ColumnName
                strData = Replace(strData, """", """""") ' replace quotes with double quotes

                'encapsulate the text in quotes
                objStringBuilder.Append("""")
                objStringBuilder.Append(strData)
                objStringBuilder.Append("""")
                objStringBuilder.Append(If(i = intColumnCount, vbCrLf, ","))

            Next

            For Each drRow In dtTable.Rows

                For i As Integer = 0 To intColumnCount

                    strData = drRow(i).ToString()

                    If strData.Trim.Length > 0 Then

                        strData = Replace(strData, """", """""") ' replace quotes with double quotes

                        'encapsulate text in quotes
                        objStringBuilder.Append("""")
                        objStringBuilder.Append(strData)
                        objStringBuilder.Append("""")
                        objStringBuilder.Append(If(i = intColumnCount, vbCrLf, ","))


                    Else

                        objStringBuilder.Append(strData)
                        objStringBuilder.Append(If(i = intColumnCount, vbCrLf, ","))

                    End If

                Next

            Next

            strReturn = objStringBuilder.ToString()

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            ConvertDatatableToCSV = strReturn

            Helper.CleanUp(drRow)
            Helper.CleanUp(objStringBuilder)

        End Try

    End Function

    Public Shared Function ConvertBase64ImageStringToThumbnail(ByVal strImageContent As String, ByVal intMaxWidth As Integer) As String

        Dim objImageBytes As Byte() = Nothing
        Dim objMemoryStream As IO.MemoryStream = Nothing
        Dim objImage As System.Drawing.Image = Nothing

        Dim intHeight As Integer = 0
        Dim intWidth As Integer = 0
        Dim objSmallerImage As System.Drawing.Bitmap = Nothing
        Dim objGR As System.Drawing.Graphics = Nothing
        Dim objRectangle As System.Drawing.Rectangle = Nothing

        Dim objThumbnailBytes As Byte() = Nothing
        Dim strBase64Thumbnail As String = ""

        Try

            'The built in Image.GetThumbnailImage created fuzzy images. This functionality
            'basically scales down the 

            'convert our base64 string to bytes to memory stream to image object (oh .NET!)
            objImageBytes = Convert.FromBase64String(strImageContent)
            objMemoryStream = New IO.MemoryStream(objImageBytes, 0, objImageBytes.Length)
            objImage = System.Drawing.Image.FromStream(objMemoryStream, True)

            If (objImage.Width > intMaxWidth) Then

                'if the image is larger than a thumbnail set the scale here
                intHeight = (objImage.Height * (intMaxWidth / objImage.Width))
                intWidth = intMaxWidth

            Else

                intHeight = objImage.Height
                intWidth = objImage.Width

            End If

            objSmallerImage = New Drawing.Bitmap(intWidth, intHeight)
            objGR = System.Drawing.Graphics.FromImage(objSmallerImage)
            objGR.SmoothingMode = Drawing.Drawing2D.SmoothingMode.HighQuality
            objGR.CompositingQuality = Drawing.Drawing2D.CompositingQuality.HighQuality
            objGR.InterpolationMode = Drawing.Drawing2D.InterpolationMode.High

            objRectangle = New Drawing.Rectangle(0, 0, intWidth, intHeight)
            objGR.DrawImage(objImage, objRectangle, 0, 0, objImage.Width, objImage.Height, Drawing.GraphicsUnit.Pixel)

            'clear the streams and convert our thumbnail base to base64
            objMemoryStream = New IO.MemoryStream()
            objSmallerImage.Save(objMemoryStream, objImage.RawFormat) 'store the thumbnail as the same type as the original image

            objThumbnailBytes = objMemoryStream.ToArray()

            strBase64Thumbnail = Convert.ToBase64String(objThumbnailBytes)

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            ConvertBase64ImageStringToThumbnail = strBase64Thumbnail

            Helper.CleanUp(objImageBytes)
            Helper.CleanUp(objImage)
            Helper.CleanUp(objMemoryStream)
            Helper.CleanUp(objThumbnailBytes)
            Helper.CleanUp(objGR)
            Helper.CleanUp(objRectangle)
            Helper.CleanUp(objSmallerImage)

        End Try

    End Function

    Public Shared Function GetEntityDelegateByASUserIdent(ByVal intEntityIdent As Int64, ByRef dtDelegates As DataTable) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing
        Dim bolHasDelegates As Boolean = False

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", intEntityIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityDelegateByIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso _
                    dsResults.Tables.Count > 0 AndAlso _
                    dsResults.Tables(0).Rows.Count > 0 Then

                    bolHasDelegates = True
                    dtDelegates = dsResults.Tables(0)

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetEntityDelegateByASUserIdent = bolHasDelegates

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(dsResults)

        End Try
    End Function

    Public Shared Function GetEntityProjectMeasureValuesByOrganizationIdent(ByVal intOrganizationIdent As Int64, _
                                                                                ByVal dtValue As DataTable) As List(Of EntityProjectMeasureValue)

        Dim objValues As New List(Of EntityProjectMeasureValue)

        Try

            For Each drRow In dtValue.Select("OrganizationIdent = " & CType(intOrganizationIdent, String))

                objValues.Add(
                    New EntityProjectMeasureValue() With {
                        .Ident = drRow.Item("Ident"),
                        .OrganizationIdent = intOrganizationIdent,
                        .Value1 = drRow.Item("Value1"),
                        .ValueCount = drRow.Item("ValueCount")
                    }
                )
            Next

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetEntityProjectMeasureValuesByOrganizationIdent = objValues

            Helper.CleanUp(objValues)

        End Try

    End Function

End Class
