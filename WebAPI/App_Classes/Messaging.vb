Public Class Messaging

    Public Shared Sub AddMessage(ByVal intASUserIdent As Int64, _
                                    ByVal strMessageDescription As String, _
                                    ByVal strExceptionToString As String, _
                                    ByVal strClientComputerName As String, _
                                    ByVal strServerComputerName As String, _
                                    ByVal strGeneratingMethod As String, _
                                    ByVal strParentMethod As String, _
                                    ByVal strUsername As String, _
                                    Optional ByVal strMessageURL As String = "", _
                                    Optional ByVal strCause As String = "")

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("ASUserIdent", intASUserIdent)
            slParameters.Add("MessageDescription", strMessageDescription)
            slParameters.Add("ExceptionToString", strExceptionToString)
            slParameters.Add("ClientComputerName", strClientComputerName)
            slParameters.Add("ServerComputerName", strServerComputerName)
            slParameters.Add("GeneratingMethod", strGeneratingMethod)
            slParameters.Add("ParentMethod", strParentMethod)
            slParameters.Add("UserName", strUsername)
            slParameters.Add("MessageTime", Helper.GetLocalTime)
            slParameters.Add("MessageURL", strMessageURL)
            slParameters.Add("Cause", strCause)

            Call Helper.SQLAdapter.ExecuteNonQuery(Helper.ApplicationName, intASUserIdent, "uspAddASMessageLog", slParameters, dsMessage)

        Catch ex As Exception

            'Throw ex

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Sub

    Public Shared Sub LogError(ByVal ex As Exception)

        Try

            Call AddMessage(Helper.AddEditASUserIdent, ex.Message, ex.ToString, "", Environment.MachineName, "", "", "")

        Catch exLocal As Exception

            Throw exLocal

        End Try

    End Sub

End Class
