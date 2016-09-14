Public Class ForgotPassword

    Public Shared Function SendForgotPasswordEmail(ByVal strEmailAddress As String) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim intMessageQueueIdent As Int64 = 0
        Dim dsMessage As System.Data.DataSet = Nothing
        Dim bolSuccess As Boolean = False

        Try

            slParameters = New SortedList
            slParameters.Add("EmailAddress", strEmailAddress)

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddMessageQueueForForgotPassword", slParameters, intMessageQueueIdent, dsMessage) Then

                If intMessageQueueIdent > 0 Then

                    bolSuccess = True

                End If

            End If 'If Helper.SQLAdapter.ExecuteScalar

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            SendForgotPasswordEmail = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    Public Shared Function SendForgotPasswordEmailExistingAccount(ByVal strEmailAddress As String) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim intMessageQueueIdent As Int64 = 0
        Dim dsMessage As System.Data.DataSet = Nothing
        Dim bolSuccess As Boolean = False

        Try

            slParameters = New SortedList
            slParameters.Add("EmailAddress", strEmailAddress)

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddMessageQueueForForgotPasswordExistingAccount", slParameters, intMessageQueueIdent, dsMessage) Then

                If intMessageQueueIdent > 0 Then

                    bolSuccess = True

                End If

            End If 'If Helper.SQLAdapter.ExecuteScalar

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            SendForgotPasswordEmailExistingAccount = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function
End Class
