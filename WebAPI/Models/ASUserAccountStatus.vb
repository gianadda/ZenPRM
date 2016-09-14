Public Class ASUserAccountStatus

    Private _userIsLocked As Boolean
    Private _lastPasswordChangedDate As String
    Private _lastSuccessfulLogin As String
    Private _addDateTime As String

    Public Property userIsLocked() As Boolean
        Get
            Return _userIsLocked
        End Get
        Set(value As Boolean)
            _userIsLocked = value
        End Set
    End Property

    Public Property lastPasswordChangedDate() As String
        Get
            If (_lastPasswordChangedDate = "1/1/1900") Then
                Return ""
            End If
            Return _lastPasswordChangedDate
        End Get
        Set(value As String)
            _lastPasswordChangedDate = value
        End Set
    End Property

    Public Property lastSuccessfulLogin() As String
        Get
            If (_lastSuccessfulLogin = "1/1/1900") Then
                Return ""
            End If
            Return _lastSuccessfulLogin
        End Get
        Set(value As String)
            _lastSuccessfulLogin = value
        End Set
    End Property

    Public Property addDateTime() As String
        Get
            If (_addDateTime = "1/1/1900") Then
                Return ""
            End If
            Return _addDateTime
        End Get
        Set(value As String)
            _addDateTime = value
        End Set
    End Property

End Class
