Imports System.Net
Imports System.Web.Http
Imports System.Web.SessionState.HttpSessionState
Imports System.Net.Http
Imports System.Web.Http.Cors
Imports System.Security.Claims
Imports Newtonsoft.Json.Linq

Public Class LoginController
    Inherits ApiController

    <AllowAnonymous> _
    <HttpDelete> _
    Public Function Delete() As HttpResponseMessage

        Dim slReplacementText As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing

        Try

            'if our session is already dead, dont log a blank entry in the activity table
            If Helper.AddEditASUserIdent > 0 Then

                slReplacementText = New SortedList
                slReplacementText.Add("@@Name", Helper.AddEditASUserFullName)

                Call Helper.AddASUserActivity(False, Helper.enmActivityType.Logout, Helper.AddEditASUserIdent, 0, slReplacementText, Nothing, dsMessage)

            End If

            HttpContext.Current.Session.Clear()

            Return Request.CreateResponse(HttpStatusCode.OK)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slReplacementText)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    <AllowAnonymous> _
    Public Function GetAllAsValidation()

        Dim package As List(Of Object) = New List(Of Object)
        Dim bolValid As Boolean = False

        Try

            bolValid = Login.CheckUserLoggedInAndValid()

            package.Add(bolValid)
            package.Add(Login.MustChangePassword)

            If (bolValid = True) Then

                package.Add(Helper.SystemRoleIdent)
                package.Add(Helper.ASUserFullName)
                package.Add(Helper.ASUserIdent)
                package.Add(Helper.DelegationMode)

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetAllAsValidation = package

        End Try

    End Function

    <AllowAnonymous> _
    <HttpPost> _
    Public Function LoginUser(ByVal user As ASUser)

        Dim ASUserIdent As Int64
        Dim systemRoleIdent As Int64
        Dim mustChangePassword As Boolean
        Dim userIsLocked As Boolean
        Dim userIsAdminLocked As Boolean
        Dim passExpired As Boolean
        Dim lastSuccessLogin As Date
        Dim fullName As String = ""
        Dim dsMessage As DataSet = New DataSet
        Dim package As List(Of Object) = New List(Of Object)
        Dim intFailedLoginCount As Integer = 0
       
        Dim bolHasDelegates As Boolean = False
        Dim bolHasProjects As Boolean = False
        Dim intProjectIdent As Int64 = 0
        Dim intEntityProjectIdent As Int64 = 0

        Try

            If user.projectGUID Is Nothing Then

                user.projectGUID = ""

            End If

            'if the user session is locked, then return forbidden
            If Login.CheckUserSessionForLockout(intFailedLoginCount) Then

                Return Request.CreateResponse(HttpStatusCode.Forbidden)

            Else ' User session is not locked, attempt to login

                If Login.LoginUser(Helper.ApplicationName,
                                          user.username,
                                          user.password,
                                          user.projectGUID,
                                          ASUserIdent,
                                          systemRoleIdent,
                                          fullName,
                                          mustChangePassword,
                                          userIsLocked,
                                          userIsAdminLocked,
                                          passExpired,
                                          lastSuccessLogin,
                                          False,
                                          True,
                                          bolHasDelegates,
                                          intEntityProjectIdent,
                                          dsMessage) Then

                    'If successful login
                    Call Login.CreateLoginSuccessResponse(bolHasDelegates, intEntityProjectIdent, package)

                    Return Request.CreateResponse(HttpStatusCode.OK, package)

                Else 'LoginUser = False

                    'Login failed because was locked by admin or multiple attempts
                    'must return the package, not an http response
                    If userIsAdminLocked Or userIsLocked Then

                        package.Add(systemRoleIdent)
                        package.Add(fullName)
                        package.Add(mustChangePassword)
                        package.Add(userIsAdminLocked)
                        package.Add(userIsLocked)
                        package.Add(ASUserIdent)

                        Return Request.CreateResponse(HttpStatusCode.Forbidden, package)

                    End If

                    'if the user session is locked, then return forbidden
                    If Login.IncrementUserSessionFailedLoginCount(intFailedLoginCount) Then

                        Return Request.CreateResponse(HttpStatusCode.Forbidden)

                    Else

                        Return Request.CreateResponse(HttpStatusCode.Unauthorized)

                    End If ' If Login.IncrementUserSessionFailedLoginCount

                End If 'If Login.LoginUser

            End If  'If Login.CheckUserSessionForLockout

            Return Nothing 'default/failover

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(package)

        End Try

    End Function

    <HttpGet> _
    <Route("api/login/delegate/{DelegateIdent}")> _
    Public Function LoginAsDelegate(ByVal DelegateIdent As Int64)

        Dim intDelegateASUserIdent As Int64 = 0
        Dim strCurrentEntityFullname As String = ""
        Dim dsMessage As System.Data.DataSet = Nothing
        Dim package As List(Of Object) = New List(Of Object)

        Try

            If Helper.DelegateASUserIdent > 0 Then

                'if you are already logged in as a delegate, you cannot switch context to another user 
                'that this entity has delegation rights to. this isnt Inception
                Return Request.CreateResponse(HttpStatusCode.Forbidden)

            Else 'continue to try and switch context

                'next, make sure the entity the user is trying to switch context to is authorized in the system
                If Login.VerifyASUserIdentDelegate(DelegateIdent) Then

                    'store ident local as we are going to flush session
                    intDelegateASUserIdent = Helper.ASUserIdent
                    strCurrentEntityFullname = Helper.ASUserFullName

                    'log the user out
                    HttpContext.Current.Session.Clear()

                    If Login.DelegationLoginUser(intDelegateASUserIdent, DelegateIdent, strCurrentEntityFullname, False, dsMessage) Then

                        Call Login.CreateLoginSuccessResponse(False, 0, package) 'HasDelegates will always be false when logging in as a delegate since we dont allow multiple tiers of delegation

                        Return Request.CreateResponse(HttpStatusCode.OK, package)

                    Else

                        'switching context failed, redirect user back to login screen?
                        Return Request.CreateResponse(HttpStatusCode.BadRequest)

                    End If

                Else

                    Return Request.CreateResponse(HttpStatusCode.Forbidden)

                End If

            End If


        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(package)

        End Try

    End Function

    <HttpDelete> _
    <Route("api/login/delegate")> _
    Public Function LogoutAsDelegate()

        Dim intDelegateASUserIdent As Int64 = 0
        Dim dsMessage As System.Data.DataSet = Nothing
        Dim package As List(Of Object) = New List(Of Object)

        Try

            If Helper.DelegateASUserIdent = 0 Then

                'if you arent logged in as a delegate, then you shouldnt be able to perform this action
                Return Request.CreateResponse(HttpStatusCode.Forbidden)

            Else 'continue to try and switch context

                'store ident local as we are going to flush session
                intDelegateASUserIdent = Helper.DelegateASUserIdent

                'log the user out
                HttpContext.Current.Session.Clear()

                If Login.DelegationLoginUser(0, intDelegateASUserIdent, "", True, dsMessage) Then

                    Call Login.CreateLoginSuccessResponse(False, 0, package) 'HasDelegates will always be false when logging in as a delegate since we dont allow multiple tiers of delegation

                    Return Request.CreateResponse(HttpStatusCode.OK, package)

                Else

                    'switching context failed, redirect user back to login screen?
                    Return Request.CreateResponse(HttpStatusCode.BadRequest)

                End If

            End If


        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(package)

        End Try

    End Function

    <AllowAnonymous> _
    <System.Web.Http.HttpGet> _
    <Route("api/Login/GetUserIdent")> _
    Public Function GetUserIdent()
        Dim package As List(Of Object) = New List(Of Object)
        Try

            package.Add(Helper.SystemRoleIdent)
            package.Add(Helper.ASUserFullName)
            package.Add(Login.MustChangePassword)
            package.Add(Login.UserIsAdminLocked)
            package.Add(Login.UserIsLocked)
            package.Add(Helper.ASUserIdent)
            package.Add(Helper.DelegationMode)
            package.Add(Helper.DelegateASUserIdent)

            Return Request.CreateResponse(HttpStatusCode.OK, package)
        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        End Try

    End Function

    'this is only an API call for the website to get the Content-Security-Policy response header
    <AllowAnonymous> _
    <System.Web.Http.HttpGet> _
    <Route("api/Login/GetCSP")> _
    Public Function GetCSP()

        Return Request.CreateResponse(HttpStatusCode.OK, "true")

    End Function

    <AllowAnonymous> _
    <HttpGet> _
    <Route("api/oauth/{guid}/redirect")> _
    Public Function RedirectOAuthUSerWithProjectGUID(ByVal guid As String)

        ' OK this is going to require a little explanation
        ' This is the redirect back from the Azure SSO process. What we are doing is moving the user over to an HTML page to let them know we are finalizing the login/registration
        ' Unfortunately, we cant do this with a link directly to one of our Angular views since they include a # character that breaks when passing the value via query string
        ' So, we redirect the user to this API, resolve the proper URL to display the "Almost Finished!" message, and then finalize the process

        Dim response As HttpResponseMessage = Nothing
        response = Request.CreateResponse(HttpStatusCode.Moved)
        response.Headers.Location = New Uri(HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + "/#/oauth-redirect/" & guid)

        Return response

    End Function

    <AllowAnonymous> _
    <HttpGet> _
    <Route("api/oauth")> _
    Public Function RedirectOAuthUSerWithoutProjectGUID()

        ' OK this is going to require a little explanation
        ' This is the redirect back from the Azure SSO process. What we are doing is moving the user over to an HTML page to let them know we are finalizing the login/registration
        ' Unfortunately, we cant do this with a link directly to one of our Angular views since they include a # character that breaks when passing the value via query string
        ' So, we redirect the user to this API, resolve the proper URL to display the "Almost Finished!" message, and then finalize the process

        Dim response As HttpResponseMessage = Nothing
        response = Request.CreateResponse(HttpStatusCode.Moved)
        response.Headers.Location = New Uri(HttpContext.Current.Request.Url.GetLeftPart(UriPartial.Authority) + "/#/oauth-redirect/")

        Return response

    End Function

    <AllowAnonymous> _
    <HttpGet> _
    <Route("api/login/external")> _
    Public Function LoginExternalUser(Optional ByVal guid As String = "")

        Dim objPrincipal As ClaimsPrincipal = Nothing

        Dim strExternalSource As String = ""
        Dim strExternalNameIdentifier As String = ""
        Dim strExternalEmailAddress As String = ""
        Dim objEntity As JObject = Nothing

        Dim lngASUserIdent As Int64 = 0
        Dim lngSystemRoleIdent As Int64 = 0
        Dim strFullname As String = ""
        Dim bolUserAdminIsLocked As Boolean = False
        Dim datLastSuccessfulLogin As DateTime = Nothing
        Dim bolHasDelegates As Boolean = False
        Dim intEntityProjectIdent As Int64 = 0

        Dim dsOpenProject As DataSet = Nothing
        Dim package As List(Of Object) = New List(Of Object)
        Dim bolHasProjects As Boolean = False
        Dim intProjectIdent As Int64 = 0
        Dim strExistingSource As String = ""

        Dim strDebugCode As String = ""

        Try

            If guid Is Nothing Then

                guid = ""

            End If

            objPrincipal = New ClaimsPrincipal(HttpContext.Current.User.Identity)

            'make sure we have an authenticated session
            If objPrincipal.Identity.IsAuthenticated Then

                objEntity = New JObject

                'get our user information from the principal claim
                Call Login.GetUserDataFromSSOClaim(objPrincipal, strExternalSource, strExternalEmailAddress, strExternalNameIdentifier, objEntity)

                'Log the External Login Request
                strDebugCode = "ExternalSource: " & strExternalSource & " - ExternalNameIdentifier: " & strExternalNameIdentifier & " - ExternalEmailAddress: " & strExternalEmailAddress & " - FirstName: " & CType(objEntity("FirstName"), String).Trim & " - LastName: " & CType(objEntity("LastName"), String).Trim
                Messaging.AddMessage(lngASUserIdent, "Social Account SSO Attempt", strDebugCode, "", Environment.MachineName, "LoginController.LoginExternalUser", "", "")

                '8/10/16: The Twitter Auth Token doesn't return the user email address, so we need to go get it , at least today. We'll continue to debug to see if we can return 
                ' the email address from Twitter through the default Azure oAuth token
                If strExternalEmailAddress.Trim.Length = 0 And strExternalSource.ToLower = "twitter" Then

                    'Get the users email Address from Twitter
                    strExternalEmailAddress = Login.GetTwitterEmailAddress()

                End If

                'Only continue if we have the required first, last and email
                If strExternalEmailAddress.Trim.Length > 0 AndAlso _
                    strExternalNameIdentifier.Trim.Length > 0 AndAlso _
                    (CType(objEntity("FirstName"), String).Trim.Length > 0 Or CType(objEntity("LastName"), String).Trim.Length > 0) AndAlso _
                    strExternalSource.Trim.Length > 0 Then

                    'First check to see if the external Login is successful
                    If Login.ExternalLogin(Helper.ApplicationName, _
                                           strExternalSource, _
                                           strExternalNameIdentifier, _
                                           strExternalEmailAddress, _
                                           guid, _
                                           lngASUserIdent, _
                                           lngSystemRoleIdent, _
                                           strFullname, _
                                           bolUserAdminIsLocked, _
                                           datLastSuccessfulLogin, _
                                           bolHasDelegates, _
                                           intEntityProjectIdent) Then

                        'If so, let them continue
                        Call Login.CreateLoginSuccessResponse(bolHasDelegates, intEntityProjectIdent, package)

                        Return Request.CreateResponse(HttpStatusCode.OK, package)

                        'Otherwise, see if they are already registered under a different account
                    ElseIf Login.VerifyExistingUserByEmail(strExternalEmailAddress, lngASUserIdent, strExistingSource) Then

                        package.Add(strExistingSource)

                        'otherwise, tell them cannot login within this 
                        Return Request.CreateResponse(HttpStatusCode.Forbidden, package)

                    ElseIf EntityProject.VerifyProjectGUIDForOpenRegistration(guid, dsOpenProject) Then

                        'if they dont already exist, then add them, login them in, and ensure they are on the project
                        If Login.RegisterExternalLogin(strExternalSource, strExternalEmailAddress, strExternalNameIdentifier, objEntity, lngASUserIdent) Then

                            'and then log them in
                            If Login.ExternalLogin(Helper.ApplicationName, _
                                           strExternalSource, _
                                           strExternalNameIdentifier, _
                                           strExternalEmailAddress, _
                                           guid, _
                                           lngASUserIdent, _
                                           lngSystemRoleIdent, _
                                           strFullname, _
                                           bolUserAdminIsLocked, _
                                           datLastSuccessfulLogin, _
                                           bolHasDelegates, _
                                           intEntityProjectIdent) Then

                                'If so, let them continue
                                Call Login.CreateLoginSuccessResponse(bolHasDelegates, intEntityProjectIdent, package)

                                Return Request.CreateResponse(HttpStatusCode.OK, package)

                            End If 'If Login.ExternalLogin()

                        End If 'If Login.RegisterExternalLogin()

                    End If 'If Login.ExternalLogin()

                Else 'some required fields are missing

                    If strExternalSource.Trim.Length > 0 Then

                        package.Add(strExternalSource.Substring(0, 1).ToUpper() & strExternalSource.Substring(1)) 'make sure the first letter is capitalized

                    Else

                        package.Add("Unknown")

                    End If

                    Return Request.CreateResponse(HttpStatusCode.BadRequest, package)

                End If ' If strExternalEmailAddress.Trim.Length > 0

            Else ' objPrincipal.Identity.IsAuthenticated = False

                Return Request.CreateResponse(HttpStatusCode.Unauthorized)

            End If

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Finally

            Helper.CleanUp(objEntity)
            Helper.CleanUp(objPrincipal)
            Helper.CleanUp(package)
            Helper.CleanUp(dsOpenProject)

        End Try

    End Function

End Class