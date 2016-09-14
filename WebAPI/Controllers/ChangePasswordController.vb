Imports System.Net
Imports System.Web.Http
Imports System.Collections.Generic
Imports System.Linq
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class ChangePasswordController
    Inherits ApiController

    <AllowAnonymous> _
    <System.Web.Http.HttpPost> _
    <Route("api/mustchangepassword")> _
    Public Function MustChangePassword(ByVal postObject As JObject) As List(Of Object)

        Dim response As HttpResponseMessage = Nothing
        Dim package As List(Of Object) = Nothing
        Dim password As String = ""

        Try

            If Not postObject("password") Is Nothing Then

                password = postObject("password")

            End If

            If Helper.ASUserIdent > 0 Then

                If password.Trim.Length > 0 Then

                    If UpdateUserPassword(password) Then

                        package = New List(Of Object)

                        package.Add(Helper.SystemRoleIdent)
                        package.Add(Helper.ASUserFullName)

                    End If

                End If 'If password.Trim

            End If 'If Helper.ASUserIdent > 0

        Catch ex As Exception

            Call Messaging.LogError(ex)

        Finally

            MustChangePassword = package

            Helper.CleanUp(package)
            Helper.CleanUp(response)

        End Try

    End Function

    <AllowAnonymous> _
    <System.Web.Http.HttpPost> _
    Public Function ChangePassword(ByVal postObject As JObject)

        Dim response As HttpResponseMessage = Nothing
        Dim package As List(Of Object) = Nothing
        Dim newPassword As String = ""
        Dim currentPassword As String = ""
        Dim bolCurrentPasswordCorrect As Boolean = False

        Try

            If Not postObject("newPassword") Is Nothing Then

                newPassword = postObject("newPassword")

            End If

            If Not postObject("currentPassword") Is Nothing Then

                currentPassword = postObject("currentPassword")

            End If

            If Helper.ASUserIdent > 0 Then

                If newPassword.Trim.Length > 0 AndAlso currentPassword.Trim.Length > 0 Then

                    If ValidateAndUpdateUserPassword(currentPassword, newPassword, bolCurrentPasswordCorrect) Then

                        package = New List(Of Object)

                        package.Add(Helper.SystemRoleIdent)
                        package.Add(Helper.ASUserFullName)

                        Return Request.CreateResponse(HttpStatusCode.OK, package)

                    ElseIf bolCurrentPasswordCorrect = False Then

                        Return Request.CreateResponse(HttpStatusCode.Forbidden, "False")

                    Else

                        Return Request.CreateResponse(HttpStatusCode.Unauthorized)

                    End If

                Else 'If newPassword.Trim.Length = 0

                    Return Request.CreateResponse(HttpStatusCode.BadRequest)

                End If 'If password.Trim

            Else 'Helper.ASUserIdent = 0 

                Return Request.CreateResponse(HttpStatusCode.Unauthorized)

            End If 'If Helper.ASUserIdent > 0

        Catch ex As Exception

            Call Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(package)
            Helper.CleanUp(response)

        End Try

    End Function

    Protected Function UpdateUserPassword(ByVal strPassword As String) As Boolean

        Dim bolSuccess As Boolean = False
        Dim slParameters As SortedList = Nothing
        Dim intIdent As Int64 = 0
        Dim dsMessage As System.Data.DataSet = Nothing
        Dim dsResults As System.Data.DataSet = Nothing
        Dim strSaltKey As String = ""

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", Helper.ASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.ASUserIdent, "uspGetASUserByIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso _
                    dsResults.Tables.Count > 0 AndAlso _
                    dsResults.Tables(0).Rows.Count > 0 Then

                    'MAKE SURE THE NEW PASSWORD DOES NOT MATCH THE OLD PASSWORD
                    If Not Encryption.VerifyHashMatch(strPassword, dsResults.Tables(0).Rows(0)("Password1"), dsResults.Tables(0).Rows(0)("PasswordSalt")) Then

                        strSaltKey = Encryption.GenerateNewSalt()

                        slParameters = New SortedList
                        slParameters.Add("ASUserIdent", Helper.ASUserIdent)
                        slParameters.Add("Password1", Encryption.CreateHash(strPassword, strSaltKey))
                        slParameters.Add("PasswordSalt", strSaltKey)

                        If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspUpdateASUserPasswordByIdent", slParameters, intIdent, dsMessage) Then

                            If intIdent > 0 Then

                                Login.MustChangePassword = False
                                Login.PasswordExpired = False
                                Login.UserIsLocked = False
                                bolSuccess = True

                                'if the user is coming from the reset password, clear the onetime use link upon completion
                                If Login.UserMessageQueueGUID <> "" Then

                                    Call Helper.DeactivateMessageQueueGUID(Login.UserMessageQueueGUID)
                                    Login.UserMessageQueueGUID = ""

                                End If

                            End If 'If intIdent > 0 

                        End If 'uspUpdateASUserPasswordByIdent

                    End If 'If Not Encryption.VerifyHashMatch

                End If ' If Not dsResults Is Nothing

            End If 'uspGetASUserByIdent

        Catch ex As Exception

            Call Messaging.LogError(ex)

        Finally

            UpdateUserPassword = bolSuccess

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsResults)

        End Try

    End Function

    Protected Function ValidateAndUpdateUserPassword(ByVal strCurrentPassword As String, strNewPassword As String, ByRef bolCurrentPasswordCorrect As Boolean) As Boolean

        Dim bolSuccess As Boolean = False
        Dim slParameters As SortedList = Nothing
        Dim intIdent As Int64 = 0
        Dim dsMessage As System.Data.DataSet = Nothing
        Dim dsResults As System.Data.DataSet = Nothing
        Dim strSaltKey As String = ""

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", Helper.ASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetASUserByIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso _
                    dsResults.Tables.Count > 0 AndAlso _
                    dsResults.Tables(0).Rows.Count > 0 Then

                    'MAKE SURE THE CURRENT PASSWORD DOES MATCH THE DB PASSWORD
                    'AND MAKE SURE THE NEW PASSWORD DOES NOT MATCH THE DB PASSWORD

                    bolCurrentPasswordCorrect = Encryption.VerifyHashMatch(strCurrentPassword, dsResults.Tables(0).Rows(0)("Password1"), dsResults.Tables(0).Rows(0)("PasswordSalt"))

                    If bolCurrentPasswordCorrect AndAlso _
                    Not Encryption.VerifyHashMatch(strNewPassword, dsResults.Tables(0).Rows(0)("Password1"), dsResults.Tables(0).Rows(0)("PasswordSalt")) Then

                        strSaltKey = Encryption.GenerateNewSalt()

                        slParameters = New SortedList
                        slParameters.Add("ASUserIdent", Helper.ASUserIdent)
                        slParameters.Add("Password1", Encryption.CreateHash(strNewPassword, strSaltKey))
                        slParameters.Add("PasswordSalt", strSaltKey)

                        If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspUpdateASUserPasswordByIdent", slParameters, intIdent, dsMessage) Then

                            If intIdent > 0 Then

                                Login.MustChangePassword = False
                                Login.PasswordExpired = False
                                bolSuccess = True

                            End If 'If intIdent > 0 

                        End If 'uspUpdateASUserPasswordByIdent

                    End If 'If Encryption.VerifyHashMatch

                End If ' If Not dsResults Is Nothing

            End If 'uspGetASUserByIdent

        Catch ex As Exception

            Call Messaging.LogError(ex)

        Finally

            ValidateAndUpdateUserPassword = bolSuccess

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsResults)

        End Try

    End Function

    <AllowAnonymous> _
    <System.Web.Http.HttpGet> _
    Public Function GetASUserByGUIDForEmailPasswordReset(ByVal guid As String) As HttpResponseMessage

        Dim slParameters As SortedList = Nothing
        Dim dsResults As System.Data.DataSet = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing
        Dim strUsername As String = ""
        Dim strPassword As String = ""
        Dim bolSuccess As Boolean = False
        Dim strFullname As String = ""
        Dim datLastSuccessfulLogin As Date = Nothing
        Dim intEntityProjectIdent As Int64 = 0

        Dim ASUserIdent As Int64
        Dim systemRoleIdent As Int64
        Dim mustChangePassword As Boolean
        Dim userIsLocked As Boolean
        Dim userIsAdminLocked As Boolean
        Dim passExpired As Boolean
        Dim fullName As String = ""

        Dim bolHasDelegates As Boolean = False

        Try

            'Clear Session State so old Session ASUserIdents don't hang around before logging in to change password
            HttpContext.Current.Session.Clear()

            If Helper.VerifyMessageQueueGUID(guid, Helper.enmMessageTemplate.ForgotPassword, dsResults) Then

                slParameters = New SortedList
                slParameters.Add("Ident", dsResults.Tables(0).Rows(0)("RecordIdent"))

                dsResults = New System.Data.DataSet

                If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetASUserByIdent", slParameters, True, dsResults, dsMessage) Then

                    If Not dsResults Is Nothing _
                        AndAlso dsResults.Tables.Count > 0 _
                        AndAlso dsResults.Tables(0).Rows.Count > 0 Then

                        strUsername = dsResults.Tables(0).Rows(0)("Username")
                        strPassword = dsResults.Tables(0).Rows(0)("Password1")

                        If Login.LoginUser(Helper.ApplicationName,
                                            strUsername,
                                            strPassword,
                                            "",
                                            ASUserIdent,
                                            systemRoleIdent,
                                            strFullname,
                                            mustChangePassword,
                                            userIsLocked,
                                            userIsAdminLocked,
                                            passExpired,
                                            datLastSuccessfulLogin,
                                            True,
                                            False,
                                            bolHasDelegates,
                                            intEntityProjectIdent,
                                            dsMessage) Then

                            'set the session variable so that the user is forced to stay on the change password screen
                            Login.MustChangePassword = True

                            'and store the GUID so we can deactivate after completion
                            Login.UserMessageQueueGUID = guid

                            'If successful redirect user to destination form
                            bolSuccess = True

                        End If 'If Login.LoginUser

                    End If 'If Not dsResults Is Nothing _

                End If 'uspGetASUserByIdent

            End If 'If VerifyMessageQueueGUID

        Catch ex As Exception

            Call Messaging.LogError(ex)
            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            If (bolSuccess) Then

                Dim response = Request.CreateResponse(HttpStatusCode.OK)
                GetASUserByGUIDForEmailPasswordReset = response

            Else

                Dim response = Request.CreateResponse(HttpStatusCode.BadRequest)
                GetASUserByGUIDForEmailPasswordReset = response

            End If

            Helper.CleanUp(dsResults)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(datLastSuccessfulLogin)

        End Try

    End Function

End Class