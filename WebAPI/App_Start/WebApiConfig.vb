Imports System
Imports System.Collections.Generic
Imports System.Linq
Imports System.Web.Http
Imports System.Net.Http.Headers
Imports System.Web.Http.Tracing
Imports System.Web.Http.Cors

Public Module WebApiConfig

    Public ReadOnly Property UrlPrefix() As String
        Get
            Return "api"
        End Get
    End Property

    Public Sub Register(ByVal config As HttpConfiguration)

        ' Web API configuration and services

        'Only enable this locally or for debugging
        'config.EnableSystemDiagnosticsTracing()

        'config.Services.Replace(GetType(ITraceWriter), New MessageQueueTracer())

        Dim corsAttribute = New EnableCorsAttribute(System.Configuration.ConfigurationManager.AppSettings("CORS-URLs"), "*", "*")

        corsAttribute.SupportsCredentials = True
        config.EnableCors(corsAttribute)

        ' Web API routes
        config.MapHttpAttributeRoutes()

        config.Routes.MapHttpRoute(
            name:="DefaultApi",
            routeTemplate:="api/{controller}/{ident}",
            defaults:=New With {.ident = RouteParameter.Optional}
        )

        config.Formatters.JsonFormatter.SupportedMediaTypes.Add(New MediaTypeHeaderValue("text/html"))
        config.Filters.Add(New AddCustomHeaderFilter())
        config.Filters.Add(New ApplicationAuthorizationAttribute())

    End Sub

End Module

Public Class ApplicationAuthorizationAttribute
    Inherits AuthorizeAttribute
    Protected Overrides Function IsAuthorized(context As Http.Controllers.HttpActionContext) As Boolean

        Dim bolValid As Boolean = False

        Try

            bolValid = Login.CheckUserLoggedInAndValid()
            ' bolValid = True

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            IsAuthorized = bolValid

        End Try

    End Function

End Class

Public Class AddCustomHeaderFilter
    Inherits Filters.ActionFilterAttribute

    Public Overrides Sub OnActionExecuted(actionExecutedContext As Filters.HttpActionExecutedContext)
        actionExecutedContext.Response.Headers.Add("Access-Control-Expose-Headers", "ASUserIdent")
        actionExecutedContext.Response.Headers.Add("Access-Control-Expose-Headers", "Content-Security-Policy")
        actionExecutedContext.Response.Headers.Add("Access-Control-Expose-Headers", "VersionNumber")
        actionExecutedContext.Response.Headers.Add("ASUserIdent", Helper.ASUserIdent)
        actionExecutedContext.Response.Headers.Add("VersionNumber", Helper.VersionNumber)

        MyBase.OnActionExecuted(actionExecutedContext)
    End Sub

End Class
