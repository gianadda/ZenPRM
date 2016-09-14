Public Class EntityProject

    Public Shared Sub AddEntitiesToProject(ByVal searchObject As EntitySearch, ByRef dsResults As System.Data.DataSet)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("AddEntityProjectIdent", searchObject.addEntityProjectIdent)
            slParameters.Add("EntityIdents", searchObject.addEntityIdents)

            Call Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntitiesToEntityProject", slParameters, True, dsResults, dsMessage)

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Sub

    Public Shared Function GetEntityProjectsByEntityIdent(entityIdent As Int64, ByRef dsResults As DataSet) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim bolSuccess As Boolean = False

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", entityIdent)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.ASUserIdent, "uspGetEntityProjectByEntityIdent", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count >= 0 Then

                    dsResults.Tables(0).TableName = "EntityProject"

                    bolSuccess = True

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetEntityProjectsByEntityIdent = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    Public Shared Sub VerifyEntitySetupForOpenRegistration(ByVal intASUserIdent As Int64, ByVal intEntityProjectIdent As Int64)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing

        Try

            slParameters = New SortedList

            'Additon of parameters
            slParameters.Add("ASUserIdent", intASUserIdent)
            slParameters.Add("EntityProjectIdent", intEntityProjectIdent)

            'Call Stored procedure 
            Call Helper.SQLAdapter.ExecuteNonQuery(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspVerifyEntityProjectEntityForOpenRegistration", slParameters, dsMessage)

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Sub

    Public Shared Function VerifyProjectGUIDForOpenRegistration(ByVal strGUID As String, ByRef dsProjectData As DataSet) As Boolean

        Dim bolValid As Boolean = False
        Dim slParameters As SortedList = Nothing
        Dim dsMessage As System.Data.DataSet = Nothing

        Try

            If strGUID.Trim.Length > 0 Then

                slParameters = New SortedList

                'Additon of parameters
                slParameters.Add("Guid", strGUID)

                'Call Stored procedure 
                If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspCheckProjectGUIDForOpenRegistration", slParameters, False, dsProjectData, dsMessage) Then

                    If Not dsProjectData Is Nothing AndAlso _
                        dsProjectData.Tables.Count > 0 AndAlso _
                        dsProjectData.Tables(0).Rows.Count > 0 Then

                        bolValid = True

                    End If 'If intEntityProjectIdent

                End If 'If Helper.SQLAdapter.ExecuteScalar("uspCheckASUserEmailAccessByASUserIdent", _

            End If 'strGUID.Trim.Length > 0

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            VerifyProjectGUIDForOpenRegistration = bolValid

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

End Class
