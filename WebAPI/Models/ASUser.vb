Public Class ASUser

    Private _ident As Int64
    Private _firstName As String
    Private _lastName As String
    Private _username As String
    Private _password As String
    Private _passwordSalt As String
    Private _eMail As String
    Private _systemRole As String
    Private _isLocked As Boolean
    Private _mustChangePassword As Boolean
    Private _lastSuccessfulLogin As Date
    Private _projectGUID As String

    Public Property ident() As Int64
        Get
            Return _ident
        End Get
        Set(value As Int64)
            _ident = value
        End Set
    End Property

    Public Property firstName() As String
        Get
            Return _firstName
        End Get
        Set(value As String)
            _firstName = value
        End Set
    End Property

    Public Property lastName() As String
        Get
            Return _lastName
        End Get
        Set(value As String)
            _lastName = value
        End Set
    End Property

    Public Property username() As String
        Get
            Return _username
        End Get
        Set(value As String)
            _username = value
        End Set
    End Property

    Public Property password() As String
        Get
            Return _password
        End Get
        Set(value As String)
            _password = value
        End Set
    End Property

    Public Property passwordSalt() As String
        Get
            Return _passwordSalt
        End Get
        Set(value As String)
            _passwordSalt = value
        End Set
    End Property

    Public Property eMail() As String
        Get
            Return _eMail
        End Get
        Set(value As String)
            _eMail = value
        End Set
    End Property

    Public Property systemRole() As String
        Get
            Return _systemRole
        End Get
        Set(value As String)
            _systemRole = value
        End Set
    End Property

    Public Property mustChangePassword() As Boolean
        Get
            Return _mustChangePassword
        End Get
        Set(value As Boolean)
            _mustChangePassword = value
        End Set
    End Property

    Public Property isLocked() As Boolean
        Get
            Return _isLocked
        End Get
        Set(value As Boolean)
            _isLocked = value
        End Set
    End Property

    Public Property lastSuccessfulLogin() As Date
        Get
            Return _lastSuccessfulLogin
        End Get
        Set(value As Date)
            _lastSuccessfulLogin = value
        End Set
    End Property

    Public Property projectGUID() As String
        Get
            Return _projectGUID
        End Get
        Set(value As String)
            _projectGUID = value
        End Set
    End Property

End Class
