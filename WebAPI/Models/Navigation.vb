Public Class Navigation

    Private _ident As Integer
    Private _parentIdent As Integer
    Private _displayName As String
    Private _sref As String
    Private _sequence As Integer
    Private _iconClasses As String
    Private _className As String
    Private _children As List(Of Navigation)

    Public Property ident() As Integer
        Get
            Return _ident
        End Get
        Set(value As Integer)
            _ident = value
        End Set
    End Property

    Public Property parentIdent() As Integer
        Get
            Return _parentIdent
        End Get
        Set(value As Integer)
            _parentIdent = value
        End Set
    End Property

    Public Property displayName() As String
        Get
            Return _displayName
        End Get
        Set(value As String)
            _displayName = value
        End Set
    End Property

    Public Property sref() As String
        Get
            Return _sref
        End Get
        Set(value As String)
            _sref = value
        End Set
    End Property

    Public Property sequence() As String
        Get
            Return _sequence
        End Get
        Set(value As String)
            _sequence = value
        End Set
    End Property

    Public Property iconClasses() As String
        Get
            Return _iconClasses
        End Get
        Set(value As String)
            _iconClasses = value
        End Set
    End Property

    Public Property className() As String
        Get
            Return _className
        End Get
        Set(value As String)
            _className = value
        End Set
    End Property

    Public Property children() As List(Of Navigation)
        Get
            If (_children Is Nothing) Then
                _children = New List(Of Navigation)
            End If
            Return _children
        End Get
        Set(value As List(Of Navigation))
            _children = value
        End Set
    End Property

End Class
