Public Class EntityProjectMeasure

    Private intIdent As Int64 = 0
    Private intEntityIdent As Int64 = 0
    Private intOrganizationIdent As Int64 = 0
    Private strName1 As String = ""
    Private strDesc1 As String = ""
    Private intEntitySearchIdent As Int64 = 0
    Private intEntitySearchDataTypeIdent As Int64 = 0
    Private bolHasDenominator As Boolean = False
    Private bolHasTargetValue As Boolean = False
    Private bolIsAverage As Boolean = False
    Private bolIsPercentage As Boolean = False
    Private intMeasureTypeIdent As Int64 = 0
    Private strMeasureType As String = ""
    Private intEntityProject1Ident As Int64 = 0
    Private strEntityProject1Name As String = ""
    Private intQuestion1EntityProjectRequirementIdent As Int64 = 0
    Private intQuestion1RequirementTypeIdent As Int64 = 0
    Private intEntityProject2Ident As Int64 = 0
    Private strEntityProject2Name As String = ""
    Private intQuestion2EntityProjectRequirementIdent As Int64 = 0
    Private decTargetValue As Decimal = 0.0
    Private dteLastRecalculateDate As DateTime = "1/1/1900"
    Private decQuestion1Value As Decimal = 0.0
    Private decQuestion2Value As Decimal = 0.0
    Private intTotalResourcesComplete As Int64 = 0
    Private intTotalResourcesAvailable As Int64 = 0
    Private objRanges As List(Of EntityProjectMeasureRange)
    Private objLocation As List(Of EntityProjectMeasureLocation)
    Private objValues As List(Of EntityProjectMeasureValue)

    Public Property Ident() As Int64
        Get
            Return intIdent
        End Get
        Set(value As Int64)
            intIdent = value
        End Set
    End Property

    Public Property EntityIdent() As Int64
        Get
            Return intEntityIdent
        End Get
        Set(value As Int64)
            intEntityIdent = value
        End Set
    End Property

    Public Property OrganizationIdent() As Int64
        Get
            Return intOrganizationIdent
        End Get
        Set(value As Int64)
            intOrganizationIdent = value
        End Set
    End Property

    Public Property MeasureName() As String
        Get
            Return strName1
        End Get
        Set(value As String)
            strName1 = value
        End Set
    End Property

    Public Property MeasureDescription() As String
        Get
            Return strDesc1
        End Get
        Set(value As String)
            strDesc1 = value
        End Set
    End Property

    Public Property EntitySearchIdent() As Int64
        Get
            Return intEntitySearchIdent
        End Get
        Set(value As Int64)
            intEntitySearchIdent = value
        End Set
    End Property

    Public Property DataTypeIdent() As Int64
        Get
            Return intEntitySearchDataTypeIdent
        End Get
        Set(value As Int64)
            intEntitySearchDataTypeIdent = value
        End Set
    End Property

    Public Property HasDenominator() As Boolean
        Get
            Return bolHasDenominator
        End Get
        Set(value As Boolean)
            bolHasDenominator = value
        End Set
    End Property

    Public Property HasTargetValue() As Boolean
        Get
            Return bolHasTargetValue
        End Get
        Set(value As Boolean)
            bolHasTargetValue = value
        End Set
    End Property

    Public Property IsAverage() As Boolean
        Get
            Return bolIsAverage
        End Get
        Set(value As Boolean)
            bolIsAverage = value
        End Set
    End Property

    Public Property IsPercentage() As Boolean
        Get
            Return bolIsPercentage
        End Get
        Set(value As Boolean)
            bolIsPercentage = value
        End Set
    End Property

    Public Property MeasureTypeIdent() As Int64
        Get
            Return intMeasureTypeIdent
        End Get
        Set(value As Int64)
            intMeasureTypeIdent = value
        End Set
    End Property

    Public Property MeasureType() As String
        Get
            Return strMeasureType
        End Get
        Set(value As String)
            strMeasureType = value
        End Set
    End Property

    Public Property EntityProject1Ident() As Int64
        Get
            Return intEntityProject1Ident
        End Get
        Set(value As Int64)
            intEntityProject1Ident = value
        End Set
    End Property

    Public Property EntityProject1Name() As String
        Get
            Return strEntityProject1Name
        End Get
        Set(value As String)
            strEntityProject1Name = value
        End Set
    End Property

    Public Property Question1RequirementTypeIdent() As Int64
        Get
            Return intQuestion1RequirementTypeIdent
        End Get
        Set(value As Int64)
            intQuestion1RequirementTypeIdent = value
        End Set
    End Property

    Public Property Question1EntityProjectRequirementIdent() As Int64
        Get
            Return intQuestion1EntityProjectRequirementIdent
        End Get
        Set(value As Int64)
            intQuestion1EntityProjectRequirementIdent = value
        End Set
    End Property

    Public Property EntityProject2Ident() As Int64
        Get
            Return intEntityProject2Ident
        End Get
        Set(value As Int64)
            intEntityProject2Ident = value
        End Set
    End Property

    Public Property EntityProject2Name() As String
        Get
            Return strEntityProject2Name
        End Get
        Set(value As String)
            strEntityProject2Name = value
        End Set
    End Property

    Public Property Question2EntityProjectRequirementIdent() As Int64
        Get
            Return intQuestion2EntityProjectRequirementIdent
        End Get
        Set(value As Int64)
            intQuestion2EntityProjectRequirementIdent = value
        End Set
    End Property

    Public Property TargetValue() As Decimal
        Get
            Return decTargetValue
        End Get
        Set(value As Decimal)
            decTargetValue = value
        End Set
    End Property

    Public Property LastRecalculateDate() As DateTime
        Get
            Return dteLastRecalculateDate
        End Get
        Set(value As DateTime)
            dteLastRecalculateDate = value
        End Set
    End Property

    Public Property Question1Value() As Decimal
        Get
            Return decQuestion1Value
        End Get
        Set(value As Decimal)
            decQuestion1Value = value
        End Set
    End Property

    Public Property Question2Value() As Decimal
        Get
            Return decQuestion2Value
        End Get
        Set(value As Decimal)
            decQuestion2Value = value
        End Set
    End Property

    Public Property TotalResourcesComplete() As Int64
        Get
            Return intTotalResourcesComplete
        End Get
        Set(value As Int64)
            intTotalResourcesComplete = value
        End Set
    End Property

    Public Property TotalResourcesAvailable() As Int64
        Get
            Return intTotalResourcesAvailable
        End Get
        Set(value As Int64)
            intTotalResourcesAvailable = value
        End Set
    End Property

    Public Property Ranges() As List(Of EntityProjectMeasureRange)
        Get
            If IsNothing(objRanges) Then
                objRanges = New List(Of EntityProjectMeasureRange)
            End If
            Return objRanges
        End Get
        Set(value As List(Of EntityProjectMeasureRange))
            objRanges = value
        End Set
    End Property

    Public Property Location() As List(Of EntityProjectMeasureLocation)
        Get
            If IsNothing(objLocation) Then
                objLocation = New List(Of EntityProjectMeasureLocation)
            End If
            Return objLocation
        End Get
        Set(value As List(Of EntityProjectMeasureLocation))
            objLocation = value
        End Set
    End Property

    Public Property Values() As List(Of EntityProjectMeasureValue)
        Get
            If IsNothing(objValues) Then
                objValues = New List(Of EntityProjectMeasureValue)
            End If
            Return objValues
        End Get
        Set(value As List(Of EntityProjectMeasureValue))
            objValues = value
        End Set
    End Property

End Class
