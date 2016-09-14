Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class EntityEmailController
    Inherits ApiController

    Public Function post(putObject As JObject)

        Dim dsResults As DataSet = Nothing
        Dim bolAlreadyRegistered As Boolean = False
        Dim intExistingEntityIdent As Int64 = 0
        Dim strExistingEntityFullName As String = ""
        Dim package As JObject = Nothing

        Dim strEmail As String = ""
        Dim intEntityIdent As Int64 = 0

        Dim bolNotify As Boolean = False
        Dim bolVerified As Boolean = False
        Dim intVerifiedASUserIdent As Int64 = 0

        Try

            Call Int64.TryParse(putObject("EntityIdent"), intEntityIdent)

            If Not putObject("Email") Is Nothing AndAlso _
                intEntityIdent > 0 Then

                strEmail = CType(putObject("Email"), String)

                If Entity.CheckUniqueEntityEmail(strEmail, intExistingEntityIdent, strExistingEntityFullName) Then

                    Call Boolean.TryParse(putObject("Notify"), bolNotify)
                    Call Boolean.TryParse(putObject("Verified"), bolVerified)
                    Call Int64.TryParse(putObject("Verified"), intVerifiedASUserIdent)

                    If Entity.AddEntityEmail(intEntityIdent, strEmail, bolNotify, bolVerified, intVerifiedASUserIdent, dsResults) Then

                        package = New JObject
                        package.Add("IsUnique", True)
                        package.Add("Ident", CType(dsResults.Tables(0).Rows(0)("Ident"), Int64))
                        package.Add("AlreadyRegistered", CType(dsResults.Tables(0).Rows(0)("AlreadyRegistered"), Boolean))

                        '12/15/15: disabling the autosend of the verification email
                        Return Request.CreateResponse(HttpStatusCode.OK, package)

                    End If 'Entity.AddEntityEmail

                Else 'email not unique

                    package = New JObject
                    package.Add("IsUnique", False)
                    package.Add("EntityIdent", intExistingEntityIdent)
                    package.Add("EntityFullName", strExistingEntityFullName)

                    Return Request.CreateResponse(HttpStatusCode.BadRequest, package)

                End If 'If IsUniqueEmail(CType(putObject("Email"), String)) 

            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsResults)
            Helper.CleanUp(package)

        End Try

    End Function

    Public Function Put(putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList

            slParameters.Add("Ident", putObject("Ident"))
            slParameters.Add("EntityIdent", putObject("EntityIdent"))
            slParameters.Add("Email", putObject("Email"))
            slParameters.Add("Notify", putObject("Notify"))
            slParameters.Add("Verified", putObject("Verified"))
            slParameters.Add("VerifiedASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("EditDateTime", Helper.GetLocalTime)
            slParameters.Add("Active", putObject("Active"))

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspEditEntityEmailByIdent", slParameters, False, dsResults, dsMessage) Then

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

    <HttpDelete> _
    Public Function Delete(Ident As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", Ident)
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("EditDateTime", Helper.GetLocalTime)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspDeleteEntityEmailByIdent", slParameters, True, dsResults, dsMessage) Then

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

    <HttpPost> _
    <Route("api/EntityEmail/verify")> _
    Public Function FunctionVerifyEmail(postObject As JObject)

        Dim strIdents As String = ""

        Try

            If Not postObject("EntityEmailIdent") Is Nothing Then

                strIdents = postObject("EntityEmailIdent").ToString()

            End If

            If AddMessageQueueForVerifyEmail(strIdents) Then

                Return Request.CreateResponse(HttpStatusCode.OK)

            Else

                Return Request.CreateResponse(HttpStatusCode.BadRequest)

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        End Try

    End Function

    <AllowAnonymous> _
    <HttpGet> _
    <Route("api/verifyEmail")> _
    Public Function FunctionVerifyEmail(ByVal guid As String) As HttpResponseMessage

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing
        Dim intEntityEmailIdent As Int64 = 0
        Dim bolSuccess As Boolean = False

        Try

            
            If Helper.VerifyMessageQueueGUID(guid, Helper.enmMessageTemplate.VerifyEmail, dsResults) Then

                slParameters = New SortedList
                slParameters.Add("Ident", dsResults.Tables(0).Rows(0)("RecordIdent"))
                slParameters.Add("MessageQueueGUID", guid)

                If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspUpdateEntityEmailVerifiedByIdent", slParameters, intEntityEmailIdent, dsMessage) Then

                    If intEntityEmailIdent > 0 Then

                        bolSuccess = True

                    End If 'If intEntityEmailIdent > 0

                End If 'uspUpdateEntityEmailVerifiedByMessageQueueIdent

            End If 'If VerifyMessageQueueGUID

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            If (bolSuccess) Then

                Dim response = Request.CreateResponse(HttpStatusCode.Moved)
                response.Headers.Location = New Uri(HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + "/#/EmailValid")
                FunctionVerifyEmail = response

            Else

                Dim response = Request.CreateResponse(HttpStatusCode.Moved)
                response.Headers.Location = New Uri(HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + "/#/EmailNotValid")
                FunctionVerifyEmail = response

            End If

            Helper.CleanUp(dsResults)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    Protected Function AddMessageQueueForVerifyEmail(ByVal strEntityEmailIdents As String) As Boolean

        Dim bolSuccess As Boolean = False
        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing

        Try

            If strEntityEmailIdents.Trim.Length > 0 Then

                slParameters = New SortedList
                slParameters.Add("Idents", strEntityEmailIdents)

                If Helper.SQLAdapter.ExecuteNonQuery(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddMessageQueueForVerifyEmail", slParameters, dsMessage) Then

                    bolSuccess = True

                End If 'ExecuteNonQuery

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            AddMessageQueueForVerifyEmail = bolSuccess

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

End Class
