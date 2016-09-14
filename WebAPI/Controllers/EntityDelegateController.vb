Imports System.Net
Imports System.Web.Http
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class EntityDelegateController
    Inherits ApiController

    <HttpPost> _
    Public Function AddEntityDelegate(ByVal postObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim bolSuccess As Boolean = False
        Dim intIdent As Int64 = 0
        Dim intDelegateIdent As Int64 = 0

        Try

            Call Int64.TryParse(postObject("DelegateIdent"), intDelegateIdent)

            If intDelegateIdent > 0 Then

                slParameters = New SortedList
                slParameters.Add("EntityIdent", Helper.ASUserIdent) 'entities can only update their own account
                slParameters.Add("EntityDelegateIdent", intDelegateIdent)
                slParameters.Add("SuppressOutput", False)

                If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityDelegate", slParameters, intIdent, dsMessage) Then

                    'Return the update result, mostly for client code convenience
                    If intIdent > 0 Then
                        bolSuccess = True
                        Return Request.CreateResponse(HttpStatusCode.OK, bolSuccess)
                    End If

                End If

            End If

            'User made a bad request, or there was some bad SQL code ran on what they entered
            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            'Perform clean up on objects who extend IDisposable
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try
    End Function

    <HttpPost> _
    <Route("api/EntityDelegate/{entityIdent}")> _
    Public Function ClaimResource(entityIdent As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim bolSuccess As Boolean = False
        Dim intIdent As Int64 = 0

        Try

            If ValidateResourceClaim(entityIdent) Then

                slParameters = New SortedList
                slParameters.Add("EntityIdent", entityIdent)
                slParameters.Add("EntityDelegateIdent", Helper.AddEditASUserIdent) 'delegation isnt allowed on multiple tiers, so we need to add the actual user, not the customer account
                slParameters.Add("SuppressOutput", False)

                If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityDelegate", slParameters, intIdent, dsMessage) Then

                    'Return the update result, mostly for client code convenience
                    If intIdent > 0 Then
                        bolSuccess = True
                        Return Request.CreateResponse(HttpStatusCode.OK, bolSuccess)
                    End If

                End If 'uspAddEntityDelegate

            Else

                'if the claim isnt allowed, then fail with the forbidden HTTP code
                Return Request.CreateResponse(HttpStatusCode.Forbidden)

            End If 'ValidateResourceClaim

            'User made a bad request, or there was some bad SQL code ran on what they entered
            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            'Perform clean up on objects who extend IDisposable
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try
    End Function

    <AllowAnonymous> _
    <HttpPut> _
    Public Function AddEntityDelegateByEmailAddress(ByVal putObject As JObject)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim bolSuccess As Boolean = False
        Dim intIdent As Int64 = 0
        Dim intDelegateIdent As Int64 = 0
        Dim strEmailAddress As String = ""
        Dim strFirstName As String = ""
        Dim strLastName As String = ""
        Dim drEntity As DataRow = Nothing
        Dim bolAddedEntity As Boolean = False
        Dim bolAlreadyRegistered As Boolean = False
        Dim intASUserIdent As Int64 = 0
        Dim intAddEditASUserIdent As Int64 = 0
        Dim objReturn As JObject = Nothing

        Try

            If Login.CheckUserLoggedInAndValid() Or Login.UserIsLockedToRegistration() Then

                'if the user is completing the registration process, their ASUserIdent is not yet set
                If Login.UserIsLockedToRegistration() Then

                    intASUserIdent = Login.UserIsLockedToRegistrationEntityIdent
                    intAddEditASUserIdent = Login.UserIsLockedToRegistrationEntityIdent

                Else

                    intASUserIdent = Helper.ASUserIdent
                    intAddEditASUserIdent = Helper.AddEditASUserIdent

                End If


                If Not putObject Is Nothing Then

                    If Not putObject("email") Is Nothing Then

                        strEmailAddress = putObject("email")

                        'check if there is an existing account with this email address
                        If Helper.GetEntityByEmailAddress(strEmailAddress, drEntity) Then

                            'if found, use this entity as the delegate
                            intDelegateIdent = CType(drEntity("Ident"), Int64)
                            bolAlreadyRegistered = CType(drEntity("AlreadyRegistered"), Boolean)
                            strFirstName = CType(drEntity("FirstName"), String)
                            strLastName = CType(drEntity("LastName"), String)

                            If intDelegateIdent = intASUserIdent Then

                                'if they entered their own email address, fail the process
                                Return Request.CreateResponse(HttpStatusCode.Forbidden)

                            End If

                            If Helper.CheckExistingEntityConnection(intASUserIdent, intDelegateIdent, True) Then

                                'if they entered the email of an existing delegate, fail the process
                                Return Request.CreateResponse(HttpStatusCode.Forbidden)

                            End If

                            If Not bolAlreadyRegistered Then

                                'has an entity record, but not already registered
                                'Send Registration email
                                Call Login.SendEntityRegistrationEmail(intDelegateIdent, strEmailAddress, strFirstName)

                            End If

                        End If 'GetEntityByEmailAddress

                    End If 'If Not putObject("email") Is Nothing

                    'if there isnt an existing user, then go create one
                    If intDelegateIdent = 0 Then

                        If Not putObject("firstName") Is Nothing Then

                            strFirstName = putObject("firstName")

                        End If

                        If Not putObject("lastName") Is Nothing Then

                            strLastName = putObject("lastName")

                        End If

                        intDelegateIdent = AddEntityForDelegationIdent(strFirstName, strLastName, strEmailAddress)

                        If intDelegateIdent > 0 Then

                            bolAddedEntity = True

                            'once we add the delegate, send them the registration email
                            Call Login.SendEntityRegistrationEmail(intDelegateIdent, strEmailAddress, strFirstName)

                        End If

                    End If

                    'if we get to this point, we should have an entityIdent
                    If intDelegateIdent > 0 Then

                        slParameters = New SortedList
                        slParameters.Add("EntityIdent", intASUserIdent) 'entities can only update their own account
                        slParameters.Add("EntityDelegateIdent", intDelegateIdent)
                        slParameters.Add("SuppressOutput", False)

                        If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, intAddEditASUserIdent, "uspAddEntityDelegate", slParameters, intIdent, dsMessage) Then

                            'Return the update result, mostly for client code convenience
                            If intIdent > 0 Then

                                bolSuccess = True

                                If Not bolAddedEntity And bolAlreadyRegistered Then

                                    'If the entity is not added, and we didnt resend the register email,
                                    'send an email to the existing entity that they are now a delegate of this user
                                    Call AddMessageQueueDelegateEmail(intDelegateIdent, strEmailAddress, strFirstName)

                                End If

                                objReturn = New JObject
                                objReturn.Add("addedEntity", bolAddedEntity)
                                objReturn.Add("alreadyRegistered", bolAlreadyRegistered)
                                objReturn.Add("entityName", strFirstName & " " & strLastName)
                                objReturn.Add("email", strEmailAddress)
                                objReturn.Add("delegateCreated", bolSuccess)

                                Return Request.CreateResponse(HttpStatusCode.OK, objReturn)

                            End If 'If intIdent > 0

                        End If 'uspAddEntityDelegate

                    End If ' intDelegateIdent > 0

                End If ' if not putObject is nothing

                'User made a bad request, or there was some bad SQL code ran on what they entered
                Return Request.CreateResponse(HttpStatusCode.BadRequest)

            Else

                'if they aren't logged in or at registartion, then not auth to complete process
                Return Request.CreateResponse(HttpStatusCode.Unauthorized)

            End If


        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            'Perform clean up on objects who extend IDisposable
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(drEntity)
            Helper.CleanUp(objReturn)

        End Try
    End Function

    Protected Sub AddMessageQueueDelegateEmail(ByVal intDelegateIdent As Int64, ByVal strEmailAddress As String, ByVal strFirstName As String)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("EmailAddress", strEmailAddress)
            slParameters.Add("DelegateIdent", intDelegateIdent)
            slParameters.Add("DelegateFirstName", strFirstName)
            slParameters.Add("EntityFullName", Helper.ASUserFullName)

            Call Helper.SQLAdapter.ExecuteNonQuery(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddMessageQueueForDelegateEmail", slParameters, dsMessage)

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Sub

    Protected Function AddEntityForDelegationIdent(ByVal strFirstName As String, ByVal strLastName As String, ByVal strEmailAddress As String) As Int64

        Dim dsResults As DataSet = Nothing
        Dim intIdent As Int64 = 0
        Dim objEntity As JObject = Nothing
        Dim bolCheckNPIUniqueFailed As Boolean = False

        Try

            objEntity = New JObject
            objEntity("EntityTypeIdent") = Helper.enmEntityType.PublicContact
            objEntity("FirstName") = strFirstName
            objEntity("LastName") = strLastName
            objEntity("Active") = True

            If Entity.AddEntity(objEntity, Helper.ASUserIdent, False, bolCheckNPIUniqueFailed, intIdent) Then

                Call Entity.AddEntityEmail(intIdent, strEmailAddress, False, False, 0, dsResults)

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            AddEntityForDelegationIdent = intIdent

            Helper.CleanUp(dsResults)
            Helper.CleanUp(objEntity)

        End Try

    End Function

    <HttpGet> _
    Public Function GetEntityDelegateByASUserIdent()

        Dim dtDelegates As DataTable = Nothing

        Try

            dtDelegates = New DataTable

            'only return the users delegates
            If Helper.GetEntityDelegateByASUserIdent(Helper.AddEditASUserIdent, dtDelegates) Then

                Return Request.CreateResponse(HttpStatusCode.OK, dtDelegates)

            Else

                'no delegates, still return ok, just no results
                Return Request.CreateResponse(HttpStatusCode.OK)

            End If

            'User made a bad request, or there was some bad SQL code ran on what they entered
            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dtDelegates)

        End Try
    End Function

    Protected Function ValidateResourceClaim(ByVal entityIdent As Int64) As Boolean

        Dim bolValid As Boolean = False
        Dim slParameters As SortedList = Nothing
        Dim intEntityIdent As Int64 = 0
        Dim dsMessage As System.Data.DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", entityIdent)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent) 'we need to validate the customer account to ensure if we can add the user as a delegate

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspValidateResourceClaim", slParameters, intEntityIdent, dsMessage) Then

                If intEntityIdent > 0 Then

                    bolValid = True

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            ValidateResourceClaim = bolValid

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

End Class