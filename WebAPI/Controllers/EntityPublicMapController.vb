Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http
Imports Newtonsoft.Json.Linq
Public Class EntityPublicMapController
    Inherits ApiController

    <AllowAnonymous> _
    <System.Web.Http.HttpGet> _
    <Route("api/Entity/{guid}/map")> _
    Public Function GetEntityGeocodesByGUID(ByVal guid As String)

        Dim intEntityIdent As Int64 = 0
        Dim slParameters As SortedList = Nothing
        Dim dsData As DataSet = Nothing

        Try

            If Helper.VerifyEntityGUID(guid, Helper.enmEntityGUIDType.PublicMap, intEntityIdent) Then

                slParameters = New SortedList
                slParameters.Add("EntityIdent", intEntityIdent)

                If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetEntityNetworkGeocodesByEntityIdent", slParameters, False, dsData, dsData) Then

                    If Not dsData Is Nothing AndAlso _
                        dsData.Tables.Count >= 2 AndAlso _
                        dsData.Tables(0).Rows.Count > 0 AndAlso _
                        dsData.Tables(1).Rows.Count > 0 Then

                        dsData.Tables(0).TableName = "entity"
                        dsData.Tables(1).TableName = "entityConnections"
                        dsData.Tables(2).TableName = "entityTypes"

                        Return Request.CreateResponse(HttpStatusCode.OK, dsData)

                    End If 'If Not dsData Is Nothing

                End If 'uspGetEntityNetworkGeocodesByEntityIdent

            Else 'If Not Helper.VerifyEntityGUID

                Return Request.CreateResponse(HttpStatusCode.Unauthorized, "False")

            End If 'If Helper.VerifyEntityGUID

            Return Request.CreateResponse(HttpStatusCode.BadRequest)

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Request.CreateResponse(HttpStatusCode.InternalServerError)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsData)

        End Try

    End Function

End Class