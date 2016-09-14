Imports System.Net
Imports System.Web.Http
Imports System.Collections.Generic
Imports System.Linq
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class RegisterController
    Inherits ApiController

    <AllowAnonymous> _
    <System.Web.Http.HttpGet> _
    Public Function GetASUserByGUIDForEmailRegistration(ByVal guid As String) As HttpResponseMessage

        Dim dsResults As System.Data.DataSet = Nothing

        Try

            'Clear Session State so old Session ASUserIdents don't hang around before logging in to change password
            HttpContext.Current.Session.Clear()

            If Helper.VerifyMessageQueueGUID(guid, Helper.enmMessageTemplate.Registration, dsResults) Then

                Login.UserIsLockedToRegistration = True
                Login.UserIsLockedToRegistrationEntityIdent = dsResults.Tables(0).Rows(0)("RecordIdent")
                Login.UserMessageQueueGUID = guid

                Return Request.CreateResponse(HttpStatusCode.OK)

            End If 'If VerifyMessageQueueGUID

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Call Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(dsResults)

        End Try

    End Function

    <AllowAnonymous> _
    <System.Web.Http.HttpPost> _
    Public Function UpdateEntitySetUsernamePassword(ByVal postObject As JObject) As HttpResponseMessage

        Dim bolSuccess As Boolean = False
        Dim intEntityIdent As Int64 = 0
        Dim strSaltKey As String = ""
        Dim slParameters As SortedList = Nothing
        Dim dsResults As System.Data.DataSet = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing
        Dim response As HttpResponseMessage = Nothing
        Dim dteLastLogin As Date = Nothing

        Dim bolHasDelegates As Boolean = False

        Try

            'First make sure the entity is setup to register their account
            If Login.UserIsLockedToRegistration AndAlso _
                Login.UserIsLockedToRegistrationEntityIdent > 0 Then

                intEntityIdent = Login.UserIsLockedToRegistrationEntityIdent

                'Next make sure the appropriate data is there
                If Not postObject("Username") Is Nothing AndAlso _
                    Not postObject("Password") Is Nothing Then

                    'Next make sure the username is unique in the system
                    If ASUserController.IsUniqueUsername(postObject("Username")) Then

                        strSaltKey = Encryption.GenerateNewSalt()

                        slParameters = New SortedList
                        slParameters.Add("Ident", intEntityIdent)
                        slParameters.Add("Username", postObject("Username"))
                        slParameters.Add("Password", Encryption.CreateHash(postObject("Password"), strSaltKey))
                        slParameters.Add("PasswordSalt", strSaltKey)
                        slParameters.Add("MessageQueueGUID", Login.UserMessageQueueGUID)

                        If Helper.SQLAdapter.ExecuteNonQuery(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspEditEntityUsernamePasswordByIdent", slParameters, dsMessage) Then

                            'clear the lock to screen
                            Login.UserIsLockedToRegistration = False
                            Login.UserIsLockedToRegistrationEntityIdent = 0
                            Login.UserMessageQueueGUID = ""

                            'and return success
                            bolSuccess = True

                            response = Request.CreateResponse(HttpStatusCode.OK)

                        Else 'otherwise the save failed and its a bad request

                            response = Request.CreateResponse(HttpStatusCode.BadRequest)

                        End If 'uspEditEntityUsernamePasswordByIdent

                    Else 'otherwise, the save cannot complete

                        response = Request.CreateResponse(HttpStatusCode.Forbidden)

                    End If 'If ASUserController.IsUniqueUsername(postObject("Username"))

                Else 'otherwise data is missing and its a bad request

                    response = Request.CreateResponse(HttpStatusCode.BadRequest)

                End If ' If Not postObject("Username") Is Nothing

            Else 'otherwise, they are not authorized to complete this process

                response = Request.CreateResponse(HttpStatusCode.Unauthorized, "False")

            End If 'If Login.UserIsLockedToRegistration 

        Catch ex As Exception

            Call Messaging.LogError(ex)
            response = Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            UpdateEntitySetUsernamePassword = response

            Helper.CleanUp(dsResults)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    <System.Web.Http.HttpPut> _
    <Route("api/register/{EntityIdent}/sendemail")> _
    Public Function SendEntityRegistrationEmail(ByVal EntityIdent As Int64) As HttpResponseMessage

        Dim drEntity As DataRow = Nothing
        Dim dtEntityEmail As DataTable = Nothing
        Dim bolEntityCanBeRegistered As Boolean = False
        Dim intEmailCount As Integer = 0
        Dim objReturn As JObject = Nothing

        Try

            If Helper.GetEntityRegistrationStatusByIdent(EntityIdent, drEntity, dtEntityEmail) Then

                bolEntityCanBeRegistered = True

                For Each drRow In dtEntityEmail.Rows

                    If Login.SendEntityRegistrationEmail(EntityIdent, drRow("Email"), drEntity("FirstName")) Then

                        intEmailCount += 1

                    End If

                Next

            End If

            
            If intEmailCount > 0 Then

                objReturn = New JObject
                objReturn.Add("entityCanBeRegistered", bolEntityCanBeRegistered)
                objReturn.Add("emailCount", intEmailCount)

                Return Request.CreateResponse(HttpStatusCode.OK, objReturn)

            ElseIf bolEntityCanBeRegistered Then

                objReturn = New JObject
                objReturn.Add("entityCanBeRegistered", bolEntityCanBeRegistered)
                objReturn.Add("emailCount", intEmailCount)

                Return Request.CreateResponse(HttpStatusCode.BadRequest, objReturn)

            Else

                'default stance for all other cases to bad request
                Return Request.CreateResponse(HttpStatusCode.BadRequest)

            End If

        Catch ex As Exception

            Call Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(drEntity)
            Helper.CleanUp(dtEntityEmail)
            Helper.CleanUp(objReturn)

        End Try

    End Function

    <System.Web.Http.HttpPut> _
    <Route("api/register/{EntityIdent}/sendemail/{EntityEmailIdent}")> _
    Public Function SendEntityRegistrationEmailByEmailIdent(ByVal EntityIdent As Int64, ByVal EntityEmailIdent As Int64) As HttpResponseMessage

        Dim drEntity As DataRow = Nothing
        Dim dtEntityEmail As DataTable = Nothing
        Dim bolEntityCanBeRegistered As Boolean = False
        Dim intEmailCount As Integer = 0
        Dim objReturn As JObject = Nothing
        Dim drEmail As DataRow() = Nothing

        Try

            If Helper.GetEntityRegistrationStatusByIdent(EntityIdent, drEntity, dtEntityEmail) Then

                bolEntityCanBeRegistered = True

                drEmail = dtEntityEmail.Select("Ident = " & CType(EntityEmailIdent, String))

                'the get by Ident should only return 1 row
                If drEmail.Length = 1 Then

                    If Login.SendEntityRegistrationEmail(EntityIdent, drEmail(0)("Email"), drEntity("FirstName")) Then

                        intEmailCount = 1

                    End If

                End If

            End If

            If intEmailCount > 0 Then

                objReturn = New JObject
                objReturn.Add("entityCanBeRegistered", bolEntityCanBeRegistered)
                objReturn.Add("emailCount", intEmailCount)

                Return Request.CreateResponse(HttpStatusCode.OK, objReturn)

            ElseIf bolEntityCanBeRegistered Then

                objReturn = New JObject
                objReturn.Add("entityCanBeRegistered", bolEntityCanBeRegistered)
                objReturn.Add("emailCount", intEmailCount)

                Return Request.CreateResponse(HttpStatusCode.BadRequest, objReturn)

            Else

                'default stance for all other cases to bad request
                Return Request.CreateResponse(HttpStatusCode.BadRequest)

            End If

        Catch ex As Exception

            Call Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(drEntity)
            Helper.CleanUp(dtEntityEmail)
            Helper.CleanUp(objReturn)

        End Try

    End Function


End Class