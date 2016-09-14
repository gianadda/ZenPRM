Imports System.Net
Imports System.Web.Http
Imports SQLDataAccess.Data
Imports System.Net.Http

Public Class SystemRoleController
    Inherits ApiController

    Public Function GetAllSystemRoles()

        Dim dsResults As DataSet = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim records As New List(Of SystemRole)

        Try

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetAllSystemRoles", Nothing, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 0 AndAlso
                    dsResults.Tables(0).Rows.Count > 0 Then

                    For Each drRow In dsResults.Tables(0).Rows
                        records.Add(
                            New SystemRole() With {
                                .ident = drRow.Item("Ident"),
                                .name = drRow.Item("Name1")
                            }
                        )
                    Next

                End If

            End If

            Return records

        Catch ex As Exception

            Call Messaging.LogError(ex)

            Return Nothing

        Finally

            Helper.CleanUp(dsResults)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(records)

        End Try

    End Function

End Class