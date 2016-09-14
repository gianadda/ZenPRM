Imports System.Security.Claims
Imports System.Security.Cryptography
Imports Newtonsoft.Json.Linq

Public Class Login

#Region "Properties"

    Public Shared Property MustChangePassword() As Boolean

        Get

            If Not HttpContext.Current.Session Is Nothing Then

                If HttpContext.Current.Session("MustChangePassword") Is Nothing Then

                    HttpContext.Current.Session("MustChangePassword") = False

                End If

                Return HttpContext.Current.Session("MustChangePassword")

            Else

                Return 0

            End If

        End Get
        Set(value As Boolean)

            HttpContext.Current.Session("MustChangePassword") = value

        End Set

    End Property

    Public Shared Property PasswordExpired() As Boolean

        Get

            If Not HttpContext.Current.Session Is Nothing Then

                If HttpContext.Current.Session("PasswordExpired") Is Nothing Then

                    HttpContext.Current.Session("PasswordExpired") = False

                End If

                Return HttpContext.Current.Session("PasswordExpired")

            Else

                Return 0

            End If

        End Get
        Set(value As Boolean)

            HttpContext.Current.Session("PasswordExpired") = value

        End Set

    End Property

    Public Shared Property UserIsLocked() As Boolean

        Get

            If Not HttpContext.Current.Session Is Nothing Then

                If HttpContext.Current.Session("UserIsLocked") Is Nothing Then

                    HttpContext.Current.Session("UserIsLocked") = False

                End If

                Return HttpContext.Current.Session("UserIsLocked")

            Else

                Return 0

            End If

        End Get
        Set(value As Boolean)

            HttpContext.Current.Session("UserIsLocked") = value

        End Set

    End Property

    Public Shared Property UserIsAdminLocked() As Boolean

        Get

            If Not HttpContext.Current.Session Is Nothing Then

                If HttpContext.Current.Session("UserIsAdminLocked") Is Nothing Then

                    HttpContext.Current.Session("UserIsAdminLocked") = False

                End If

                Return HttpContext.Current.Session("UserIsAdminLocked")

            Else

                Return 0

            End If

        End Get
        Set(value As Boolean)

            HttpContext.Current.Session("UserIsAdminLocked") = value

        End Set

    End Property

    Public Shared Property UserIsLockedToRegistration() As Boolean

        Get

            If Not HttpContext.Current.Session Is Nothing Then

                If HttpContext.Current.Session("UserIsLockedToRegistration") Is Nothing Then

                    HttpContext.Current.Session("UserIsLockedToRegistration") = False

                End If

                Return HttpContext.Current.Session("UserIsLockedToRegistration")

            Else

                Return 0

            End If

        End Get
        Set(value As Boolean)

            HttpContext.Current.Session("UserIsLockedToRegistration") = value

        End Set

    End Property

    Public Shared Property UserIsLockedToRegistrationEntityIdent() As Int64

        Get

            If Not HttpContext.Current.Session Is Nothing Then

                If HttpContext.Current.Session("UserIsLockedToRegistrationEntityIdent") Is Nothing Then

                    HttpContext.Current.Session("UserIsLockedToRegistrationEntityIdent") = 0

                End If

                Return HttpContext.Current.Session("UserIsLockedToRegistrationEntityIdent")

            Else

                Return 0

            End If

        End Get
        Set(value As Int64)

            HttpContext.Current.Session("UserIsLockedToRegistrationEntityIdent") = value

        End Set

    End Property

    Public Shared Property UserMessageQueueGUID() As String

        Get

            If Not HttpContext.Current.Session Is Nothing Then

                If HttpContext.Current.Session("UserMessageQueueGUID") Is Nothing Then

                    HttpContext.Current.Session("UserMessageQueueGUID") = ""

                End If

                Return HttpContext.Current.Session("UserMessageQueueGUID")

            Else

                Return 0

            End If

        End Get
        Set(value As String)

            HttpContext.Current.Session("UserMessageQueueGUID") = value

        End Set

    End Property

#End Region

    Public Shared Function CheckUserSessionForLockout(ByRef intFailedLoginCount As Int64) As Boolean

        Dim bolLockedOut As Boolean = False
        Dim intAccountLockedAttempts As Integer = 0
        Dim intAccountLockedMinutes As Integer = 0
        Dim dteInitialFailedTime As DateTime = Nothing

        Try

            'If the login request failed, perform the failed login logic. If they fail X times (5 initially) in Y minutes (5 initially) lock the user
            intAccountLockedAttempts = Helper.GetASApplicationVariableByName1("MaxLoginAttemptBeforeUserLocked")
            intAccountLockedMinutes = (Helper.GetASApplicationVariableByName1("MaxLoginAttemptUserLockedPeriod") * -1)

            Call Integer.TryParse(HttpContext.Current.Session("FailedLoginCount"), intFailedLoginCount)

            'determine if the initial failed date time was set
            If HttpContext.Current.Session("FailedLoginDateTime") Is Nothing Then

                dteInitialFailedTime = Helper.GetLocalTime

            Else

                dteInitialFailedTime = HttpContext.Current.Session("FailedLoginDateTime")

            End If

            If intFailedLoginCount >= intAccountLockedAttempts AndAlso _
                dteInitialFailedTime >= (Helper.GetLocalTime.AddMinutes(intAccountLockedMinutes)) Then

                bolLockedOut = True

            End If

        Catch ex As Exception

            Call Messaging.LogError(ex)

        Finally

            CheckUserSessionForLockout = bolLockedOut

        End Try

    End Function

    Public Shared Function IncrementUserSessionFailedLoginCount(ByVal intFailedLoginCount As Int64) As Boolean

        Dim bolLockedOut As Boolean = False
        Dim intAccountLockedAttempts As Integer = 0
        Dim intAccountLockedMinutes As Integer = 0
        Dim dteInitialFailedTime As DateTime = Nothing

        Try

            intAccountLockedMinutes = (Helper.GetASApplicationVariableByName1("MaxLoginAttemptUserLockedPeriod") * -1)
            intAccountLockedAttempts = Helper.GetASApplicationVariableByName1("MaxLoginAttemptBeforeUserLocked")

            'determine if the initial failed date time was set
            If HttpContext.Current.Session("FailedLoginDateTime") Is Nothing Then

                dteInitialFailedTime = Helper.GetLocalTime
                HttpContext.Current.Session("FailedLoginDateTime") = dteInitialFailedTime

                'or if the initial failed time is older than the locked account timeframe
            Else

                dteInitialFailedTime = HttpContext.Current.Session("FailedLoginDateTime")

                If dteInitialFailedTime.AddMinutes(intAccountLockedMinutes) < Helper.GetLocalTime Then

                    'If the initial failed time is older than the lock window, then reset the counters
                    dteInitialFailedTime = Helper.GetLocalTime
                    HttpContext.Current.Session("FailedLoginDateTime") = dteInitialFailedTime
                    HttpContext.Current.Session("FailedLoginCount") = 0
                    intFailedLoginCount = 0

                End If

            End If 'If HttpContext.Current.Session("FailedLoginDateTime") Is Nothing

            'increment the failed login count by 1
            intFailedLoginCount += 1
            HttpContext.Current.Session("FailedLoginCount") = intFailedLoginCount

            If intFailedLoginCount >= intAccountLockedAttempts AndAlso _
                        dteInitialFailedTime >= (Helper.GetLocalTime.AddMinutes(intAccountLockedMinutes)) Then

                bolLockedOut = True

            End If

        Catch ex As Exception

            Call Messaging.LogError(ex)

        Finally

            IncrementUserSessionFailedLoginCount = bolLockedOut

        End Try

    End Function

    Public Shared Function CheckUserLoggedInAndValid() As Boolean

        Dim bolValid As Boolean = False

        Try

            'If the User is Logged in and not in a "locked" status, return True
            If Helper.ASUserIdent > 0 AndAlso _
                Not Login.MustChangePassword AndAlso _
                Not Login.PasswordExpired AndAlso _
                Not Login.UserIsLocked Then

                bolValid = True

            Else
                bolValid = False

            End If

        Catch ex As Exception

            Call Messaging.LogError(ex)

        Finally

            CheckUserLoggedInAndValid = bolValid

        End Try

    End Function

    Public Shared Function CheckUserLoggedInAndValidWithPermission(ByVal intSystemRoleIdent As Int64) As Boolean

        Dim bolValid As Boolean = False
        Dim intIdent As Int64 = 0
        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing

        Try

            If CheckUserLoggedInAndValid() Then

                'this has been changed to query the database because Helper.SystemRoleIdent is for the active resource (i.e. could be the customer)
                'and isnt a true representation of the role of the logged in user
                slParameters = New SortedList
                slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)
                slParameters.Add("SystemRoleIdent", intSystemRoleIdent)

                If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspCheckASUserSystemRole", slParameters, intIdent, dsMessage) Then

                    If intIdent > 0 AndAlso _
                        intIdent = Helper.AddEditASUserIdent Then

                        bolValid = True

                    End If

                End If

            End If 'If CheckUserLoggedInAndValid()

        Catch ex As Exception

            Call Messaging.LogError(ex)

        Finally

            CheckUserLoggedInAndValidWithPermission = bolValid

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    Public Shared Function CheckUserAccessToEntityProfile(ByVal intEntityIdent As Int64) As Boolean

        Dim bolValid As Boolean = False

        Try

            'Should only be able to access profile IF
            ' 1. It is your profile
            ' 2. It is your delegated user profile
            ' 3. You are a customer
            If intEntityIdent = Helper.ASUserIdent Or _
                intEntityIdent = Helper.AddEditASUserIdent Or _
                Helper.IsCustomer Then

                bolValid = True

            End If


        Catch ex As Exception

            Call Messaging.LogError(ex)

        Finally

            CheckUserAccessToEntityProfile = bolValid

        End Try

    End Function

    Protected Shared Function EditASUserForLoginAttempt(ByVal strApplicationName As String, _
                                                  ByVal lngASUserIdent As Int64, _
                                                  ByVal strUsername As String, _
                                                  ByVal bolLoginSuccess As Boolean, _
                                                  ByVal bolSkipMustChangePasswordCheck As Boolean, _
                                                  ByRef intFailedCount As Int32, _
                                                  ByRef intUserLockedPeriodMinutes As Int32, _
                                                  ByRef bolUserIsLocked As Boolean, _
                                                  ByRef intMaxLoginAttemptBeforeUserLocked As Int32, _
                                                  ByRef datTimeUserAccountWillUnLocked As Date, _
                                                  ByRef bolMustChangePassword As Boolean, _
                                                  ByRef bolPasswordExpired As Boolean, _
                                                  ByRef dsMessage As System.Data.DataSet) As Boolean

        Dim dsData As System.Data.DataSet = Nothing
        Dim drRow As System.Data.DataRow = Nothing
        Dim slParameters As SortedList = Nothing
        Dim strDaysBeforePasswordMustBeChanged As String = ""
        Dim bolSuccess As Boolean = False

        Try

            slParameters = New SortedList

            slParameters.Add("UserName", strUsername)
            slParameters.Add("LoginSuccess", bolLoginSuccess)
            slParameters.Add("ASUserIdent", lngASUserIdent)

            bolSuccess = Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, lngASUserIdent, "uspEditASUserForLoginAttempt", slParameters, False, _
                            dsData, dsMessage)

            If Not dsData Is Nothing AndAlso _
                dsData.Tables.Count > 0 AndAlso _
                dsData.Tables(0).Rows.Count > 0 Then

                drRow = dsData.Tables(0).Rows(0)

                intFailedCount = CType(drRow("FailedCount"), Int32)
                intUserLockedPeriodMinutes = CType(drRow("UserLockedPeriodMinutes"), Int32)
                bolUserIsLocked = CType(drRow("UserIsLocked"), Boolean)
                intMaxLoginAttemptBeforeUserLocked = CType(drRow("MaxLoginAttemptBeforeUserLocked"), Int32)
                datTimeUserAccountWillUnLocked = CType(drRow("TimeUserAccountWillUnLocked"), Date)

            End If

            If bolSkipMustChangePasswordCheck = False AndAlso bolMustChangePassword = False AndAlso bolSuccess AndAlso bolLoginSuccess AndAlso bolUserIsLocked = False Then

                strDaysBeforePasswordMustBeChanged = Helper.GetASApplicationVariableByName1("IntervalUserMustChangePassword")

                'check if user must change password
                If Not strDaysBeforePasswordMustBeChanged Is Nothing AndAlso _
                                            strDaysBeforePasswordMustBeChanged.Trim.Length > 0 AndAlso _
                                            IsNumeric(strDaysBeforePasswordMustBeChanged) AndAlso _
                                            CType(strDaysBeforePasswordMustBeChanged, Int32) > 0 Then

                    dsData = New System.Data.DataSet
                    slParameters.Clear()
                    slParameters.Add("ASUserIdent", lngASUserIdent)
                    slParameters.Add("DaysBeforePasswordMustBeChanged", strDaysBeforePasswordMustBeChanged)

                    bolSuccess = Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspEditASUserForMustChangePasswordInterval", slParameters, False, _
                                dsData, dsMessage)

                    If bolSuccess AndAlso Not dsData Is Nothing AndAlso dsData.Tables.Count > 0 AndAlso dsData.Tables(0).Rows.Count > 0 Then

                        bolPasswordExpired = CType(dsData.Tables(0).Rows(0)(0), Boolean)
                        bolMustChangePassword = bolPasswordExpired

                        If bolMustChangePassword Then

                            Login.MustChangePassword = True

                        End If

                    End If 'If bolSuccess

                End If 'If Not strDaysBeforePasswordMustBeChanged 

            End If ' If bolMustChangePassword = False

        Catch ex As Exception

            Call Messaging.LogError(ex)

        Finally

            EditASUserForLoginAttempt = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsData)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(drRow)

        End Try

    End Function

    Public Shared Function LoginUser(ByVal strApplicationName As String, _
                              ByVal strUsername As String, _
                              ByVal strPassword1 As String, _
                              ByVal strGUID As String, _
                              ByRef lngASUserIdent As Int64, _
                              ByRef lngSystemRoleIdent As Int64, _
                              ByRef strFullname As String, _
                              ByRef bolMustChangePassword As Boolean, _
                              ByRef bolUserIsLocked As Boolean, _
                              ByRef bolUserAdminIsLocked As Boolean, _
                              ByRef bolPasswordExpired As Boolean, _
                              ByRef datLastSuccessfulLogin As Date, _
                              ByVal bolIsResetLogin As Boolean, _
                              ByVal bolAttemptAutoDelegation As Boolean,
                              ByRef bolHasDelegates As Boolean, _
                              ByRef intEntityProjectIdent As Int64, _
                              ByRef dsMessage As System.Data.DataSet) As Boolean

        Dim dsData As System.Data.DataSet = Nothing
        Dim dsDelegates As DataTable = Nothing
        Dim slParameters As SortedList = Nothing
        Dim slReplacementText As SortedList = Nothing
        Dim bolLoginSuccess As Boolean = False
        Dim intFailedCount As Int32 = 0
        Dim intUserLockedPeriodMinutes As Int32 = 0
        Dim intMaxLoginAttemptBeforeUserLocked As Int32 = 0
        Dim datTimeUserAccountWillUnLocked As Date
        Dim strMessage As String = ""
        Dim dsOpenProject As DataSet = Nothing

        Try

            'TJF - changed this to allow empty passwords for initially added users
            If strUsername.Trim.Length > 0 And strPassword1.Trim.Length > 0 Then

                bolUserIsLocked = False
                bolUserAdminIsLocked = False
                datLastSuccessfulLogin = Now

                dsData = New DataSet
                dsDelegates = New DataTable

                slParameters = New SortedList
                slParameters.Add("UserName", strUsername)

                bolLoginSuccess = False
                bolMustChangePassword = True

                If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetASUserByUserName", slParameters, False, _
                            dsData, dsMessage) Then

                    If Not dsData Is Nothing AndAlso _
                        dsData.Tables.Count > 0 AndAlso _
                        dsData.Tables(0).Rows.Count > 0 AndAlso _
                        VerifyUserPasswordMatch(bolIsResetLogin, strPassword1, dsData.Tables(0).Rows(0)("Password1"), dsData.Tables(0).Rows(0)("PasswordSalt")) Then
                        'bring the hashed pw and salt key back from db, and verify the entered value hash matches the stored value

                        lngASUserIdent = CType(dsData.Tables(0).Rows(0)("Ident"), Int64)
                        lngSystemRoleIdent = CType(dsData.Tables(0).Rows(0)("SystemRoleIdent"), Int64)
                        bolMustChangePassword = CType(dsData.Tables(0).Rows(0)("MustChangePassword"), Boolean)
                        bolUserAdminIsLocked = CBool(dsData.Tables(0).Rows(0)("IsLocked"))
                        strFullname = CType(dsData.Tables(0).Rows(0)("FullName"), String)

                        If dsData.Tables(0).Columns.Contains("LastSuccessfulLogin") Then

                            datLastSuccessfulLogin = CType(dsData.Tables(0).Rows(0)("LastSuccessfulLogin"), Date)

                        End If

                        'setup the user account status
                        Login.MustChangePassword = bolMustChangePassword
                        Login.PasswordExpired = bolPasswordExpired
                        Login.UserIsAdminLocked = bolUserAdminIsLocked
                        Login.UserIsLocked = False

                        Helper.ASUserIdent = lngASUserIdent
                        Helper.SystemRoleIdent = lngSystemRoleIdent
                        Helper.ASUserFullName = strFullname
                        Helper.IsCustomer = CType(dsData.Tables(0).Rows(0)("Customer"), Boolean)

                        'Check if we're passed a project GUID for login/registration
                        If EntityProject.VerifyProjectGUIDForOpenRegistration(strGUID, dsOpenProject) Then

                            intEntityProjectIdent = CType(dsOpenProject.Tables(0).Rows(0)("Ident"), Int64)

                            'IF so, make sure the user is added to the entity network and participating in the project
                            Call EntityProject.VerifyEntitySetupForOpenRegistration(lngASUserIdent, intEntityProjectIdent)

                        End If

                        'check and see if there are delegates for this user
                        'if only 1, autologin to that account
                        'otherwise, return HasDelegates = true, and we'll redirect the user to the delegate screen
                        If intEntityProjectIdent = 0 AndAlso _
                            Helper.GetEntityDelegateByASUserIdent(lngASUserIdent, dsDelegates) Then

                            bolHasDelegates = True

                            'make sure this is a scenario where we want to auto delegate
                            If bolAttemptAutoDelegation AndAlso _
                                dsDelegates.Rows.Count = 1 Then

                                bolHasDelegates = False 'tell the client to ignore the redirect to the delegate menu

                                Call DelegationLoginUser(lngASUserIdent, dsDelegates.Rows(0)("ToEntityIdent"), strFullname, False, dsMessage)

                            End If

                        End If

                        bolLoginSuccess = True

                        slReplacementText = New SortedList
                        slReplacementText.Add("@@Name", strFullname)

                        Call Helper.AddASUserActivity(False, Helper.enmActivityType.Login, lngASUserIdent, 0, slReplacementText, Nothing, dsMessage)

                    End If

                    'If user is admin locked, don't execute EditASUserForLoginAttempt
                    If bolUserAdminIsLocked = True Then
                        bolLoginSuccess = False
                    Else
                        'call login for locking user
                        Call EditASUserForLoginAttempt(strApplicationName, lngASUserIdent, strUsername, _
                                        bolLoginSuccess, False, intFailedCount, intUserLockedPeriodMinutes, _
                                        bolUserIsLocked, intMaxLoginAttemptBeforeUserLocked, datTimeUserAccountWillUnLocked, bolMustChangePassword, _
                                        bolPasswordExpired, dsMessage)

                        If bolLoginSuccess = False AndAlso bolUserIsLocked = False Then

                            'temp store this value so we can match the login attempt to the user account
                            If Not dsData Is Nothing AndAlso _
                                dsData.Tables.Count > 0 AndAlso _
                                dsData.Tables(0).Rows.Count > 0 Then

                                lngASUserIdent = dsData.Tables(0).Rows(0)("Ident")

                            End If

                            ' add the failed login to the activity table
                            slReplacementText = New SortedList
                            slReplacementText.Add("@@Name", strUsername)

                            Call Helper.AddASUserActivity(True, Helper.enmActivityType.LoginFailed, lngASUserIdent, 0, slReplacementText, Nothing, dsMessage)

                            bolLoginSuccess = False
                            lngASUserIdent = 0

                        ElseIf (bolUserIsLocked = True) Then

                            'temp store this value so we can match the login attempt to the user account
                            If Not dsData Is Nothing AndAlso _
                                dsData.Tables.Count > 0 AndAlso _
                                dsData.Tables(0).Rows.Count > 0 Then

                                lngASUserIdent = dsData.Tables(0).Rows(0)("Ident")

                            End If

                            ' add the failed login to the activity table
                            slReplacementText = New SortedList
                            slReplacementText.Add("@@Name", strUsername)

                            Call Helper.AddASUserActivity(True, Helper.enmActivityType.UserAccountLocked, lngASUserIdent, 0, slReplacementText, Nothing, dsMessage)

                            'locked message
                            bolLoginSuccess = False
                            Login.UserIsLocked = bolUserIsLocked
                            lngASUserIdent = 0

                        End If 'If bolLoginSuccess = False AndAlso bolUserIsLocked = False

                    End If

                End If

            Else

                strMessage = "User Name or Password are Blank:" & " Username: " & strUsername

                Call Messaging.AddMessage(lngASUserIdent, strMessage, "", "", Environment.MachineName, "", "", strUsername)

            End If 'strUsername.Trim.Length > 0 And strPassword1.Trim.Length > 0

        Catch ex As Exception

            Call Messaging.LogError(ex)

        Finally

            LoginUser = bolLoginSuccess

            Helper.CleanUp(dsData)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(datLastSuccessfulLogin)
            Helper.CleanUp(slReplacementText)
            Helper.CleanUp(dsOpenProject)

        End Try

    End Function

    Public Shared Function DelegationLoginUser(ByVal lngASUserIdent As Int64, _
                                                ByVal lngASUserIdentForDelegation As Int64, _
                                                  ByVal strCurrentEntityFullname As String, _
                                                  ByVal bolReturningFromDelegation As Boolean, _
                                                  ByRef dsMessage As System.Data.DataSet) As Boolean

        Dim dsData As System.Data.DataSet = Nothing
        Dim slParameters As SortedList = Nothing
        Dim bolLoginSuccess As Boolean = False
        Dim slReplacementText As SortedList = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", lngASUserIdentForDelegation)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityByIdentForDelegation", slParameters, False, _
                        dsData, dsMessage) Then

                If Not dsData Is Nothing AndAlso _
                    dsData.Tables.Count > 0 AndAlso _
                    dsData.Tables(0).Rows.Count > 0 Then

                    Helper.ASUserIdent = CType(dsData.Tables(0).Rows(0)("Ident"), Int64)
                    Helper.SystemRoleIdent = CType(dsData.Tables(0).Rows(0)("SystemRoleIdent"), Int64)
                    Helper.IsCustomer = CType(dsData.Tables(0).Rows(0)("Customer"), Boolean)

                    'now put the actual user ident into session as the delegate ident (this is the person who is performing the action)
                    'if we're logging out as the delegate, this will be set to 0
                    Helper.DelegateASUserIdent = lngASUserIdent
                    Helper.DelegateASUserFullName = strCurrentEntityFullname

                    If bolReturningFromDelegation Then

                        slReplacementText = New SortedList
                        slReplacementText.Add("@@Name", dsData.Tables(0).Rows(0)("FullName"))

                        Call Helper.AddASUserActivity(False, Helper.enmActivityType.LogoutAsDelegate, Helper.ASUserIdent, Helper.ASUserIdent, slReplacementText, Nothing, dsMessage)

                        Helper.ASUserFullName = CType(dsData.Tables(0).Rows(0)("FullName"), String)

                        'TODO - determine how this affects delegation. For now, override all account maintenance
                        Login.MustChangePassword = False
                        Login.PasswordExpired = False
                        Login.UserIsAdminLocked = False
                        Login.UserIsLocked = False

                    Else

                        slReplacementText = New SortedList
                        slReplacementText.Add("@@Name", strCurrentEntityFullname)
                        slReplacementText.Add("@@Delegate", dsData.Tables(0).Rows(0)("FullName"))

                        Call Helper.AddASUserActivity(False, Helper.enmActivityType.LoginAsDelegate, Helper.ASUserIdent, Helper.ASUserIdent, slReplacementText, Nothing, dsMessage)

                        Helper.ASUserFullName = CType(dsData.Tables(0).Rows(0)("FullName"), String)

                        'TODO - determine how this affects delegation. For now, override all account maintenance
                        Login.MustChangePassword = False
                        Login.PasswordExpired = False
                        Login.UserIsAdminLocked = False
                        Login.UserIsLocked = False

                    End If

                    bolLoginSuccess = True

                End If 'If Not dsData Is Nothing 

            End If 'If Helper.SQLAdapter.GetDataSet

        Catch ex As Exception

            Call Messaging.LogError(ex)

        Finally

            DelegationLoginUser = bolLoginSuccess

            Helper.CleanUp(dsData)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(slReplacementText)

        End Try

    End Function

    Public Shared Function VerifyUserPasswordMatch(ByVal bolPasswordIsAlreadyHashed As Boolean, ByVal strPasswordToVerify As String, ByVal strPassword As String, ByVal strPasswordSalt As String) As Boolean

        Dim bolSuccess As Boolean = False

        Try

            If bolPasswordIsAlreadyHashed Then

                If strPasswordToVerify = strPassword Then

                    bolSuccess = True

                End If

            Else 'not bolPasswordIsAlreadyHashed

                bolSuccess = Encryption.VerifyHashMatch(strPasswordToVerify, strPassword, strPasswordSalt)

            End If

        Catch ex As Exception

            Call Messaging.LogError(ex)

        Finally

            VerifyUserPasswordMatch = bolSuccess

        End Try

    End Function

    Public Shared Function VerifyASUserIdentDelegate(ByVal intEntityIdentForDelegation As Int64) As Boolean

        Dim bolAuthorized As Boolean = False
        Dim slParameters As SortedList = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing
        Dim intEntityConnectionIdent As Int64 = 0

        Try

            slParameters = New SortedList
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)
            slParameters.Add("EntityIdent", intEntityIdentForDelegation)

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspVerifyEntityDelegateByASUserIdent", slParameters, intEntityConnectionIdent, dsMessage) Then

                If intEntityConnectionIdent > 0 Then

                    bolAuthorized = True

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            VerifyASUserIdentDelegate = bolAuthorized

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    Public Shared Function SendEntityRegistrationEmail(ByVal intEntityIdent As Int64, ByVal strEmailAddress As String, ByVal strFirstName As String) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing
        Dim bolSuccess As Boolean = False
        Dim intMessageQueueIdent As Int64 = 0

        Try

            slParameters = New SortedList
            slParameters.Add("EmailAddress", strEmailAddress)
            slParameters.Add("EntityIdent", intEntityIdent)
            slParameters.Add("EntityFirstName", strFirstName)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)
            slParameters.Add("ASUserFullname", Helper.ASUserFullName)
            slParameters.Add("AddEditASUserIdent", Helper.AddEditASUserIdent)

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddMessageQueueForRegistration", slParameters, intMessageQueueIdent, dsMessage) Then

                If intMessageQueueIdent > 0 Then

                    bolSuccess = True

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            SendEntityRegistrationEmail = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    Public Shared Function ExternalLogin(ByVal strApplicationName As String, _
                                         ByVal strExternalSource As String, _
                                         ByVal strExternalNameIdentifier As String, _
                                         ByVal strExternalEmailAddress As String, _
                                         ByVal strGUID As String, _
                                         ByRef lngASUserIdent As Int64, _
                                         ByRef lngSystemRoleIdent As Int64, _
                                         ByRef strFullname As String, _
                                         ByRef bolUserAdminIsLocked As Boolean, _
                                         ByRef datLastSuccessfulLogin As DateTime, _
                                         ByRef bolHasDelegates As Boolean, _
                                         ByRef intEntityProjectIdent As Int64) As Boolean

        Dim bolUserIsLocked As Boolean = False

        Dim dsOpenProject As DataSet = Nothing
        Dim dsData As DataSet = Nothing
        Dim dtDelegates As DataTable = Nothing
        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim slReplacementText As SortedList = Nothing

        Dim bolLoginSuccess As Boolean = False

        Dim intFailedCount As Int32 = 0
        Dim intUserLockedPeriodMinutes As Int32 = 0
        Dim intMaxLoginAttemptBeforeUserLocked As Int32 = 0
        Dim datTimeUserAccountWillUnLocked As Date

        Try

            bolUserIsLocked = False
            bolUserAdminIsLocked = False
            datLastSuccessfulLogin = Now

            dsData = New DataSet
            dtDelegates = New DataTable

            'Debug Code
            'Dim strDebugCode As String = "ExternalSource: " & strExternalSource & " - " & "ExternalNameIdentifier: " & strExternalNameIdentifier & " - " & "ExternalEmailAddress: " & strExternalEmailAddress
            'Messaging.AddMessage(lngASUserIdent, "Social Account SSO Attempt", strDebugCode, "", Environment.MachineName, "Login.ExternalLogin", "", "")

            slParameters = New SortedList
            slParameters.Add("ExternalSource", strExternalSource)
            slParameters.Add("ExternalNameIdentifier", strExternalNameIdentifier)
            slParameters.Add("ExternalEmailAddress", strExternalEmailAddress)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetASUserByExternalLogin", slParameters, False, _
                        dsData, dsMessage) Then

                If Not dsData Is Nothing AndAlso _
                    dsData.Tables.Count > 0 AndAlso _
                    dsData.Tables(0).Rows.Count > 0 Then

                    lngASUserIdent = CType(dsData.Tables(0).Rows(0)("Ident"), Int64)
                    lngSystemRoleIdent = CType(dsData.Tables(0).Rows(0)("SystemRoleIdent"), Int64)
                    bolUserAdminIsLocked = CBool(dsData.Tables(0).Rows(0)("IsLocked"))
                    strFullname = CType(dsData.Tables(0).Rows(0)("FullName"), String)

                    If dsData.Tables(0).Columns.Contains("LastSuccessfulLogin") Then

                        datLastSuccessfulLogin = CType(dsData.Tables(0).Rows(0)("LastSuccessfulLogin"), Date)

                    End If

                    'setup the user account status
                    Login.MustChangePassword = False ' cannot force pw reset on external user
                    Login.PasswordExpired = False ' cannot force pw reset on external user
                    Login.UserIsAdminLocked = bolUserAdminIsLocked
                    Login.UserIsLocked = False

                    Helper.ASUserIdent = lngASUserIdent
                    Helper.SystemRoleIdent = lngSystemRoleIdent
                    Helper.ASUserFullName = strFullname
                    Helper.IsCustomer = CBool(dsData.Tables(0).Rows(0)("Customer"))

                    'Check if we're passed a project GUID for login/registration
                    If EntityProject.VerifyProjectGUIDForOpenRegistration(strGUID, dsOpenProject) Then

                        intEntityProjectIdent = CType(dsOpenProject.Tables(0).Rows(0)("Ident"), Int64)

                        'IF so, make sure the user is added to the entity network and participating in the project
                        Call EntityProject.VerifyEntitySetupForOpenRegistration(lngASUserIdent, intEntityProjectIdent)

                    End If

                    'check and see if there are delegates for this user
                    'if only 1, autologin to that account
                    'otherwise, return HasDelegates = true, and we'll redirect the user to the delegate screen

                    'but first, make sure we arent logging into a project. We dont want to delegate if we have the project GUID
                    If intEntityProjectIdent = 0 AndAlso _
                        Helper.GetEntityDelegateByASUserIdent(lngASUserIdent, dtDelegates) Then

                        bolHasDelegates = True

                        'make sure this is a scenario where we want to auto delegate
                        If dtDelegates.Rows.Count = 1 Then

                            bolHasDelegates = False 'tell the client to ignore the redirect to the delegate menu

                            Call DelegationLoginUser(lngASUserIdent, dtDelegates.Rows(0)("ToEntityIdent"), strFullname, False, dsMessage)

                        End If

                    End If

                    bolLoginSuccess = True

                    slReplacementText = New SortedList
                    slReplacementText.Add("@@Name", strFullname)

                    Call Helper.AddASUserActivity(False, Helper.enmActivityType.Login, lngASUserIdent, 0, slReplacementText, Nothing, dsMessage)

                End If

                'If user is admin locked, don't execute EditASUserForLoginAttempt
                If bolUserAdminIsLocked = True Then
                    bolLoginSuccess = False
                Else
                    'call login for locking user
                    Call EditASUserForLoginAttempt(strApplicationName, lngASUserIdent, strExternalSource & ":" & strExternalNameIdentifier, _
                                    bolLoginSuccess, True, intFailedCount, intUserLockedPeriodMinutes, _
                                    bolUserIsLocked, intMaxLoginAttemptBeforeUserLocked, datTimeUserAccountWillUnLocked, False, _
                                    False, dsMessage)

                    If bolUserIsLocked Then

                        'temp store this value so we can match the login attempt to the user account
                        If Not dsData Is Nothing AndAlso _
                            dsData.Tables.Count > 0 AndAlso _
                            dsData.Tables(0).Rows.Count > 0 Then

                            lngASUserIdent = dsData.Tables(0).Rows(0)("Ident")

                        End If

                        ' add the failed login to the activity table
                        slReplacementText = New SortedList
                        slReplacementText.Add("@@Name", strExternalEmailAddress)

                        Call Helper.AddASUserActivity(True, Helper.enmActivityType.UserAccountLocked, lngASUserIdent, 0, slReplacementText, Nothing, dsMessage)

                        'locked message
                        bolLoginSuccess = False
                        Login.UserIsLocked = bolUserIsLocked
                        lngASUserIdent = 0

                    End If 'If bolUserIsLocked

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            ExternalLogin = bolLoginSuccess

            Helper.CleanUp(dtDelegates)
            Helper.CleanUp(dsData)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slReplacementText)
            Helper.CleanUp(dsOpenProject)

        End Try

    End Function

    Public Shared Sub CreateLoginSuccessResponse(ByVal bolHasDelegates As Int64, ByVal intEntityProjectIdent As Int64, ByRef objResponse As List(Of Object))

        Dim bolHasProjects As Boolean = False
        Dim intProjectIdent As Int64 = 0

        Try

            'If successful login, remove any failed login attempt info
            Helper.RemoveSessionVar("FailedLoginCount")
            Helper.RemoveSessionVar("FailedLoginDateTime")

            objResponse.Add(Helper.SystemRoleIdent)
            objResponse.Add(Helper.ASUserFullName)
            objResponse.Add(Login.MustChangePassword)
            objResponse.Add(Login.UserIsAdminLocked)
            objResponse.Add(Login.UserIsLocked)
            objResponse.Add(Helper.ASUserIdent)
            objResponse.Add(Helper.DelegationMode)
            objResponse.Add(bolHasDelegates)

            If Not bolHasDelegates Then

                If intEntityProjectIdent > 0 Then

                    'if were coming here specifically because of an open project and logging in, just take us to that project (even if other open projects exist)
                    bolHasProjects = True
                    intProjectIdent = intEntityProjectIdent

                Else

                    'If the user isnt a delegate, check and see if they have any open projects, if so, well direct them over there instead of the profile page
                    Call CheckUserForOpenProjects(Helper.ASUserIdent, bolHasProjects, intProjectIdent)

                End If

            End If 'bolHasDelegates

            objResponse.Add(bolHasProjects)
            objResponse.Add(intProjectIdent)

        Catch ex As Exception

            Messaging.LogError(ex)

        End Try

    End Sub

    Public Shared Sub CheckUserForOpenProjects(ByVal intASUserIdent As Int64, ByRef bolHasProjects As Boolean, ByRef intProjectIdent As Int64)

        Dim dsResults As DataSet = Nothing
        Dim dvOpenProjects As DataRow() = Nothing

        Try

            'were only going to redirect to the project screen if they dont have delegates, so no need to check
            'for projects if we know we have delegates
            If EntityProject.GetEntityProjectsByEntityIdent(Helper.ASUserIdent, dsResults) Then

                dvOpenProjects = dsResults.Tables(0).Select("Archived = 0")

                If dvOpenProjects.Length > 0 Then

                    bolHasProjects = True

                    If dvOpenProjects.Length = 1 Then

                        intProjectIdent = dsResults.Tables(0).Rows(0)("Ident")

                    End If

                End If 'If dvOpenProjects.Length > 0 

            End If 'GetEntityProjectsByEntityIdent

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            Helper.CleanUp(dsResults)
            Helper.CleanUp(dvOpenProjects)

        End Try

    End Sub

    Public Shared Sub GetUserDataFromSSOClaim(ByVal objPrincipal As ClaimsPrincipal, _
                                              ByRef strExternalSource As String, _
                                              ByRef strExternalEmailAddress As String, _
                                              ByRef strExternalNameIdentifier As String, _
                                              ByRef objEntity As JObject)

        Dim objClaim As Claim = Nothing
        Dim strName As String() = Nothing
        Dim strDebugCode As String = ""
        Dim strClaimType As String = ""

        Try

            strExternalSource = objPrincipal.Identity.AuthenticationType

            'get the user context from the claim. These property names are standardized by Azure SSO
            For Each objClaim In objPrincipal.Claims

                'Log the External Login Request
                'strDebugCode = "ClaimType: " & Replace(objClaim.Type, "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/", "") & " - Value: " & objClaim.Value
                'Messaging.AddMessage(0, "Social Account SSO Attempt", strDebugCode, "", Environment.MachineName, "Login.GetUserDataFromSSOClaim", "", "")

                strClaimType = Replace(objClaim.Type, "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/", "") 'shorthand, ignore the initial identifier
                strClaimType = Replace(strClaimType, "http://schemas.microsoft.com/identity/claims/", "") 'shorthand, ignore the initial identifier
                strClaimType = Replace(strClaimType, "http://schemas.microsoft.com/ws/2008/06/identity/claims/", "") 'shorthand, ignore the initial identifier

                Select Case strClaimType

                    Case "dateofbirth"

                        objEntity("BirthDate") = objClaim.Value

                    Case "emailaddress"

                        strExternalEmailAddress = objClaim.Value

                    Case "emails"

                        strExternalEmailAddress = objClaim.Value

                    Case "gender"

                        objEntity("Gender") = objClaim.Value

                    Case "givenname"

                        objEntity("FirstName") = objClaim.Value

                    Case "identityprovider"

                        'If the user auth occurred through Azure AD B2C, the external source is the IdentityProvider, not AAD (Azure Active Directory)
                        If strExternalSource = "aad" Then

                            strExternalSource = objClaim.Value

                        End If

                    Case "name"

                        If objEntity("FirstName") Is Nothing And objEntity("LastName") Is Nothing Then

                            'to do - find a better way to parse this
                            'Basic default - if 3 names, then split out first name and remainder is last name
                            'if 2 names, then split first/last
                            'else all stuffed into first name
                            strName = objClaim.Value.Split(" ")

                            If strName.Length >= 3 Then

                                objEntity("FirstName") = strName(0)
                                objEntity("LastName") = Replace(objClaim.Value, strName(0), "").Trim

                            ElseIf strName.Length = 2 Then

                                objEntity("FirstName") = strName(0).Trim
                                objEntity("LastName") = strName(1).Trim

                            ElseIf strName.Length = 1 Then

                                objEntity("FirstName") = objClaim.Value.Trim
                                objEntity("LastName") = ""

                            Else

                                objEntity("FirstName") = objClaim.Value.Trim
                                objEntity("LastName") = ""

                            End If

                        End If

                    Case "nameidentifier"

                        If objClaim.Value <> "Not supported currently. Use oid claim." Then

                            strExternalNameIdentifier = objClaim.Value

                        End If

                    Case "objectidentifier"

                        'LinkedIn through Azure AD doesnt provide a name identifer
                        strExternalNameIdentifier = objClaim.Value

                    Case "surname"

                        objEntity("LastName") = objClaim.Value

                End Select

            Next

        Catch ex As Exception

            Messaging.LogError(ex)

        End Try

    End Sub

    Public Shared Function RegisterExternalLogin(ByVal strExternalSource As String, _
                                                 ByVal strExternalEmailAddress As String, _
                                                 ByVal strExternalNameIdentifier As String, _
                                                 ByVal objEntity As JObject, _
                                                 ByRef lngASUserIdent As Int64) As Boolean

        Dim bolSuccess As Boolean = False
        Dim bolCheckNPIFailed As Boolean = False
        Dim dsEmail As DataSet = Nothing

        Try

            'anybody registering to answer open projects need to login, therefore is a public contact
            objEntity("EntityTypeIdent") = Helper.enmEntityType.PublicContact

            'Registration = Add Entity, then Email, then store External Login info
            If Entity.AddEntity(objEntity, 0, True, bolCheckNPIFailed, lngASUserIdent) Then

                If Entity.AddEntityEmail(lngASUserIdent, strExternalEmailAddress, True, True, lngASUserIdent, dsEmail) Then

                    If Entity.AddEntityExternalLogin(lngASUserIdent, strExternalSource, strExternalNameIdentifier, strExternalEmailAddress, lngASUserIdent) Then

                        bolSuccess = True

                    End If

                End If 'Entity.AddEntityEmail

            End If 'Entity.AddEntity

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            RegisterExternalLogin = bolSuccess

            Helper.CleanUp(dsEmail)

        End Try

    End Function

    Public Shared Function VerifyExistingUserByEmail(ByVal strEmailAddress As String, ByRef intEntityIdent As Int64, ByRef strSource As String) As Boolean

        Dim bolSuccess As Boolean = False
        Dim slParameters As SortedList = Nothing
        Dim dsUser As DataSet = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim strExternalSource As String = ""

        Try

            slParameters = New SortedList
            slParameters.Add("Email", strEmailAddress)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.ASUserIdent, "uspGetASUserByEmail", slParameters, False, dsUser, dsMessage) Then

                If Not dsUser Is Nothing AndAlso
                    dsUser.Tables.Count = 2 AndAlso _
                    dsUser.Tables(0).Rows.Count > 0 Then

                    bolSuccess = True
                    intEntityIdent = CType(dsUser.Tables(0).Rows(0)("Ident"), Int64)
                    strSource = "ZenPRM" 'default the source to be ZenPRM

                    If dsUser.Tables(1).Rows.Count > 0 Then

                        strExternalSource = dsUser.Tables(1).Rows(0)("ExternalSource")
                        strSource = strExternalSource.Substring(0, 1).ToUpper() & strExternalSource.Substring(1) 'make sure the first letter is capitalized

                    End If 'If dsUser.Tables(1).Rows.Count > 0

                End If 'If Not dsUser Is Nothing 

            End If 'uspGetASUserByEmail

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            VerifyExistingUserByEmail = bolSuccess

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(dsUser)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    Public Shared Function GetTwitterEmailAddress() As String

        Dim strEmail As String = ""
        Dim strTokenURL As String = ""
        Dim strURL As String = ""
        Dim strBaseFormat As String = ""
        Dim strBase As String = ""
        Dim strHeaderFormat As String = ""
        Dim strHeader As String = ""

        Dim strOAuthToken As String = ""
        Dim strOAuthTokenSecret As String = ""
        Dim strOAuthConsumerKey As String = ""
        Dim strOAuthConsumerSecret As String = ""
        Dim strOAuthVersion As String = ""
        Dim strOAuthSigMethod As String = ""
        Dim strOAuthNonce As String = ""
        Dim strOAuthTimestamp As String = ""
        Dim strOAuthSignature As String = ""

        Dim tsTimeSpan As TimeSpan = Nothing
        Dim strKey As String = ""
        Dim objHash As HMACSHA1 = Nothing
        Dim objReturn As JObject = Nothing
        Dim slHeaders As SortedList = Nothing

        Try

            'were going to GET the users info and extract the email address from there
            strURL = "https://api.twitter.com/1.1/account/verify_credentials.json"

            'these are hardcoded values to pass to Twitter
            strOAuthVersion = "1.0"
            strOAuthSigMethod = "HMAC-SHA1"

            'these are specific to the user/session
            strOAuthToken = HttpContext.Current.Request.Headers.Get("X-MS-TOKEN-TWITTER-ACCESS-TOKEN")
            strOAuthTokenSecret = HttpContext.Current.Request.Headers.Get("X-MS-TOKEN-TWITTER-ACCESS-TOKEN-SECRET")

            'Debug Step 1
            'Messaging.AddMessage(0, "Twitter API Call - Access Token", "strOAuthToken: " & strOAuthToken & " - strOAuthTokenSecret: " & strOAuthTokenSecret, "", Environment.MachineName, "Login.GetTwitterEmailAddress", "", "", "", "")

            'validate that we have the oAuth token
            If strOAuthToken.Trim.Length > 0 AndAlso _
                strOAuthTokenSecret.Trim.Length > 0 Then

                'these are specific the ZenPRM Twitter App (Dev/Alpha/Prod)
                strOAuthConsumerKey = System.Configuration.ConfigurationManager.AppSettings("TwitterAPIConsumerKey")
                strOAuthConsumerSecret = System.Configuration.ConfigurationManager.AppSettings("TwitterAPIConsumerSecret")

                'create the Twitter signature
                'https://dev.twitter.com/oauth/overview/creating-signatures
                strOAuthNonce = Guid.NewGuid().ToString("N") 'Convert.ToBase64String(New ASCIIEncoding().GetBytes(DateTime.Now.Ticks.ToString()))
                tsTimeSpan = (DateTime.UtcNow - New DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc))
                strOAuthTimestamp = Convert.ToInt64(tsTimeSpan.TotalSeconds).ToString()

                strBaseFormat = "include_email=true&oauth_consumer_key={0}&oauth_nonce={1}&oauth_signature_method={2}&oauth_timestamp={3}&oauth_token={4}&oauth_version={5}"

                strBase = String.Format(strBaseFormat, _
                                        strOAuthConsumerKey, _
                                        strOAuthNonce, _
                                        strOAuthSigMethod, _
                                        strOAuthTimestamp, _
                                        strOAuthToken, _
                                        strOAuthVersion)

                strBase = String.Concat("GET&", Uri.EscapeDataString(strURL), "&", Uri.EscapeDataString(strBase))

                strKey = String.Concat(Uri.EscapeDataString(strOAuthConsumerSecret), "&", Uri.EscapeDataString(strOAuthTokenSecret))
                objHash = New HMACSHA1(ASCIIEncoding.ASCII.GetBytes(strKey))
                strOAuthSignature = Convert.ToBase64String(objHash.ComputeHash(ASCIIEncoding.ASCII.GetBytes(strBase)))

                strHeaderFormat = "OAuth " +
                                    "oauth_consumer_key=""{0}"", " +
                                    "oauth_nonce=""{1}"", " +
                                    "oauth_signature=""{2}"", " +
                                    "oauth_signature_method=""{3}"", " +
                                    "oauth_timestamp=""{4}"", " +
                                    "oauth_token=""{5}"", " +
                                    "oauth_version=""{6}"""

                strHeader = String.Format(strHeaderFormat, _
                                    Uri.EscapeDataString(strOAuthConsumerKey), _
                                    Uri.EscapeDataString(strOAuthNonce), _
                                    Uri.EscapeDataString(strOAuthSignature), _
                                    Uri.EscapeDataString(strOAuthSigMethod), _
                                    Uri.EscapeDataString(strOAuthTimestamp), _
                                    Uri.EscapeDataString(strOAuthToken), _
                                    Uri.EscapeDataString(strOAuthVersion))

                'Messaging.AddMessage(0, "Twitter API Call - API Call Header", strHeader, "", Environment.MachineName, "Login.GetTwitterEmailAddress", "", "", "", "")

                slHeaders = New SortedList
                slHeaders.Add("Authorization", strHeader)

                If Helper.GetAPIJSON(strURL & "?include_email=true", objReturn, slHeaders) Then

                    'Messaging.AddMessage(0, "Twitter API Call - Response Success", "Response: " & objReturn.ToString, "", Environment.MachineName, "Login.GetTwitterEmailAddress", "", "", "", "")

                    If Not objReturn.SelectToken("email") Is Nothing Then

                        strEmail = objReturn.SelectToken("email")

                    End If

                End If 'If Helper.GetAPIJSON

            End If 'If strOAuthToken.Trim.Length > 0 AndAlso strOAuthTokenSecret.Trim.Length > 0

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetTwitterEmailAddress = strEmail

            Helper.CleanUp(objHash)
            Helper.CleanUp(tsTimeSpan)
            Helper.CleanUp(objReturn)
            Helper.CleanUp(slHeaders)

        End Try

    End Function

End Class
