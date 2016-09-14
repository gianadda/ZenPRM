Imports System.Net
Imports System.Web.Http
Imports System.Collections.Generic
Imports System.Linq
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class ForgotPasswordController
    Inherits ApiController

    <AllowAnonymous> _
    Public Function PostEmailForForgotPassword(ByVal postObject As JObject) As HttpResponseMessage

        Dim response As HttpResponseMessage = Nothing
        Dim strEmail As String = ""

        Try

            If Not postObject("email") Is Nothing Then

                strEmail = postObject("email").ToString()

            End If

            If strEmail.Trim.Length > 0 Then

                If ForgotPassword.SendForgotPasswordEmail(strEmail) Then

                    response = Request.CreateResponse(HttpStatusCode.OK)

                Else

                    response = Request.CreateResponse(HttpStatusCode.BadRequest)

                End If

            Else

                response = Request.CreateResponse(HttpStatusCode.BadRequest)

            End If

            Return response

        Catch ex As Exception

            Call Messaging.LogError(ex)

            response = Request.CreateResponse(HttpStatusCode.InternalServerError)

            Return response

        Finally

            Helper.CleanUp(response)

        End Try

    End Function

End Class