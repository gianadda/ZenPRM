Public Class SystemRole

    Private _ident As Int64
    Private _name As String

    Public Property ident() As Int64
        Get
            Return _ident
        End Get
        Set(value As Int64)
            _ident = value
        End Set
    End Property

    Public Property name() As String
        Get
            Return _name
        End Get
        Set(value As String)
            _name = value
        End Set
    End Property

End Class