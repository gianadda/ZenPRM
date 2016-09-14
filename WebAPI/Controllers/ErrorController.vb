Imports System.Net
Imports System.Web.Http
Imports System.Net.Http

Public Class ErrorController
    Inherits ApiController

    Public Function Post(err As ASError)

        If Not Login.CheckUserLoggedInAndValidWithPermission(Helper.enmSystemRole.Customer) AndAlso Not Login.CheckUserLoggedInAndValidWithPermission(Helper.enmSystemRole.ZenTeam) Then
            Dim errorMsg As String = "Unauthorized access attempted to Error API call: Post()."
            Messaging.AddMessage(Helper.AddEditASUserIdent, errorMsg, "", "", Environment.MachineName, "", "", Helper.ASUserFullName)
            Return Request.CreateResponse(HttpStatusCode.Unauthorized, "False")
        End If

        Try

            Messaging.AddMessage(Helper.AddEditASUserIdent,
                                 err.errorMessage, "", "",
                                 Environment.MachineName, "", "",
                                 Helper.ASUserFullName,
                                 err.errorURL,
                                 err.cause)

            Return Request.CreateResponse(HttpStatusCode.OK)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        End Try

    End Function


End Class
