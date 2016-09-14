Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq

Public Class ASUserController
    Inherits ApiController

    <System.Web.Http.HttpGet> _
    <Route("api/asuser/IsUnique")>
    Public Shared Function IsUniqueUsername(username As String) As Boolean

        Dim usernameIsunique As Boolean = False
        Dim dsMessage As DataSet = Nothing
        Dim slParameters As SortedList = Nothing

        Try

            slParameters = New SortedList

            slParameters.Add("Username", username)

            Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspCheckASUserUsernameUnique", slParameters, usernameIsunique, dsMessage)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Nothing

        Finally

            IsUniqueUsername = usernameIsunique
            Helper.CleanUp(dsMessage)

        End Try

    End Function

End Class