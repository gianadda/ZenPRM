Public Class ASError

    Private _errorURL As String
    Private _errorMessage As String
    Private _stackTrace As String
    Private _cause As String

    Public Property errorURL() As String
        Get
            Return _errorURL
        End Get
        Set(value As String)
            _errorURL = value
        End Set
    End Property

    Public Property errorMessage() As String
        Get
            Return _errorMessage
        End Get
        Set(value As String)
            _errorMessage = value
        End Set
    End Property

    Public Property stackTrace() As String
        Get
            Return _stackTrace
        End Get
        Set(value As String)
            _stackTrace = value
        End Set
    End Property

    Public Property cause() As String
        Get
            Return _cause
        End Get
        Set(value As String)
            _cause = value
        End Set
    End Property

End Class
