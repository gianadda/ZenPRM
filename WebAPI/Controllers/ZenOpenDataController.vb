Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq
Imports System.IO

<RoutePrefix("api/open-data")> _
Public Class ZenOpenDataController
    Inherits ApiController

    <System.Web.Http.HttpGet> _
    <Route("NPPESLookup/{npi}")> _
    Public Function NPPESLookup(npi As String)

        Dim objJSON As Newtonsoft.Json.Linq.JObject = Nothing

        Try

            Helper.GetAPIJSON("https://npiregistry.cms.hhs.gov/api/?number=" + npi, objJSON)
            Return Request.CreateResponse(HttpStatusCode.OK, objJSON)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(objJSON)

        End Try

    End Function

    <System.Web.Http.HttpGet> _
    <Route("referrals")> _
    Public Function GetReferralsData(ByVal NPI As String)

        Dim objJSON As JObject = Nothing
        Dim strReferralsURL As String = ""

        Dim cmdCommand As System.Data.SqlClient.SqlCommand = Nothing
        Dim daDataAdapter As System.Data.SqlClient.SqlDataAdapter = Nothing
        Dim cnnConnection As System.Data.SqlClient.SqlConnection = Nothing

        Dim dsResults As DataSet = Nothing
        Dim slHeaders As SortedList = Nothing

        Try

            If Not NPI Is Nothing AndAlso _
                NPI.Trim.Length > 0 Then

                dsResults = New DataSet

                strReferralsURL = Helper.GetASApplicationVariableByName1("ZenOpenDataReferralURL")
                strReferralsURL = Replace(strReferralsURL, "{{NPI}}", NPI)

                slHeaders = New SortedList
                slHeaders.Add("Accept", "application/json;odata=nometadata")
                slHeaders.Add("x-ms-version", "2013-08-15")
                slHeaders.Add("MaxDataServiceVersion", "3.0;NetFx")

                If Helper.GetAPIJSON(strReferralsURL, objJSON, slHeaders) Then

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
                        .CommandTimeout = cnnConnection.ConnectionTimeout ' match the command timeout from the connection string (so we have a single variable that stores this value)
                        .CommandText = "uspGetEntityByNPIForZenOpenDataReferrals"
                        .Parameters.Add("@bntEntityIdent", SqlDbType.BigInt).Value = Helper.ASUserIdent
                        .Parameters.Add("@tblReferral", SqlDbType.Structured).Value = CreateReferralsDataTableForSQLParameter(objJSON, NPI)

                        daDataAdapter.SelectCommand = cmdCommand
                        daDataAdapter.Fill(dsResults)

                        If Not dsResults Is Nothing AndAlso _
                            dsResults.Tables.Count > 0 Then

                            dsResults.Tables(0).TableName = "Referrals"

                            Return Request.CreateResponse(HttpStatusCode.OK, dsResults)

                        End If

                    End With

                End If 'Helper.GetAPIJSON

            End If 'If Not NPI Is Nothing


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
            Helper.CleanUp(objJSON)
            Helper.CleanUp(dsResults)
            Helper.CleanUp(slHeaders)

        End Try

    End Function

    Private Shared Function CreateReferralsDataTableForSQLParameter(ByVal objReferral As JObject, ByVal strNPI As String) As DataTable

        Dim dtReferral As New DataTable()
        Dim drRow As DataRow = Nothing

        Try

            dtReferral.Columns.Add("NPI", GetType(String))
            dtReferral.Columns.Add("ReferredTo", GetType(Boolean))
            dtReferral.Columns.Add("SharedTransactionCount", GetType(Int64))
            dtReferral.Columns.Add("PatientTotal", GetType(Int64))
            dtReferral.Columns.Add("SameDayTotal", GetType(Int64))

            For Each item As JObject In objReferral("value").Children().ToList

                drRow = dtReferral.NewRow

                'if the NPI we are searching for is NPI2, then it means that provider 1 referred a patient to the provider we are searching on
                If item("NPI2") = strNPI Then

                    drRow("NPI") = item("NPI1")
                    drRow("ReferredTo") = True

                Else

                    drRow("NPI") = item("NPI2")
                    drRow("ReferredTo") = False

                End If

                drRow("SharedTransactionCount") = item("SharedTransactionCount")
                drRow("PatientTotal") = item("PatientTotal")
                drRow("SameDayTotal") = item("SameDayTotal")

                dtReferral.Rows.Add(drRow)

            Next

            Return dtReferral

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Nothing

        Finally

            Helper.CleanUp(dtReferral)
            Helper.CleanUp(drRow)

        End Try

    End Function

    <HttpPost> _
    <Route("WatsonToneAnalyzerByIdent")> _
    Public Function WatsonToneAnalyzerByIdent(putObject As JObject)

        Dim objJSON As Newtonsoft.Json.Linq.JObject = Nothing
        Dim strAnswer As String = ""
        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("EntityProjectRequirementIdent", putObject("ident"))
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)


            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityProjectAnswerValueStringByIdent", slParameters, strAnswer, dsMessage) Then

                GetWatsonAPIJSON("https://gateway.watsonplatform.net/tone-analyzer/api/v3/tone?version=2016-05-19", "{""text"":""" + strAnswer + """}", objJSON)

                Return Request.CreateResponse(HttpStatusCode.OK, objJSON)

            Else

                Return Request.CreateResponse(HttpStatusCode.InternalServerError)

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(objJSON)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    <HttpPost> _
    <Route("WatsonToneAnalyzer")> _
    Public Function WatsonToneAnalyzer(putObject As JObject)

        Dim objJSON As Newtonsoft.Json.Linq.JObject = Nothing

        Try

            GetWatsonAPIJSON("https://gateway.watsonplatform.net/tone-analyzer/api/v3/tone?version=2016-05-19", putObject.ToString, objJSON)

            Return Request.CreateResponse(HttpStatusCode.OK, objJSON)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(objJSON)

        End Try

    End Function

    Public Shared Function GetWatsonAPIJSON(ByVal strURL As String, _
                               ByVal strPostData As String,
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
            request.Accept = "application/json"
            request.MediaType = "application/json"
            request.ContentType = "application/json"
            request.Credentials = New System.Net.NetworkCredential("", "")
            request.Method = "POST"

            Dim byteArray As Byte() = Encoding.UTF8.GetBytes(strPostData)
            request.ContentLength = byteArray.Length
            Dim dataStream As Stream = request.GetRequestStream()
            dataStream.Write(byteArray, 0, byteArray.Length)
            dataStream.Close()
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
                objJSONReader = New Newtonsoft.Json.JsonTextReader(reader)
                objSerializer = New Newtonsoft.Json.JsonSerializer()
                objJSON = objSerializer.Deserialize(objJSONReader)

                reader.Close()

                bolSuccess = True

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetWatsonAPIJSON = bolSuccess

            'Cleanup
            If Not response Is Nothing Then

                response.Close()

            End If

            Helper.CleanUp(request)
            Helper.CleanUp(response)
            Helper.CleanUp(reader)
            Helper.CleanUp(objJSONReader)
            Helper.CleanUp(objSerializer)

        End Try

    End Function

End Class