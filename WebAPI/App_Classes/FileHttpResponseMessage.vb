Imports System.Net.Http

Public Class FileHttpResponseMessage
    Inherits HttpResponseMessage

    Private filePath As String

    Public Sub New(filePath As String)
        Me.filePath = filePath
    End Sub

    Protected Overrides Sub Dispose(disposing As Boolean)

        Try

            'manually overriding the dispose function and adding in a cleanup of the temp file
            If disposing Then

                Call Content.Dispose()

                'make sure there is a file path and the file exists
                If filePath.Length > 0 AndAlso _
                IO.File.Exists(filePath) Then

                    Call IO.File.Delete(filePath)

                End If

                Call MyBase.Dispose(disposing)

            End If 'if disposing

        Catch ex As Exception

            Messaging.LogError(ex)

        End Try

    End Sub

End Class
