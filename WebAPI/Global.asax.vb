Imports System.Web.Http

Public Class WebApiApplication
    Inherits System.Web.HttpApplication

    Sub Application_Start()
        GlobalConfiguration.Configure(AddressOf WebApiConfig.Register)
    End Sub

    'Protected Sub Application_PostAuthorizeRequest()

    '    HttpContext.Current.SetSessionStateBehavior(SessionStateBehavior.Required)

    '    End Sub

    Private Function IsWebApiRequest() As Boolean
        Return HttpContext.Current.Request.AppRelativeCurrentExecutionFilePath.StartsWith(WebApiConfig.UrlPrefix)
    End Function

    Private Sub WebApiApplication_BeginRequest(sender As Object, e As EventArgs) Handles Me.BeginRequest

        If HttpContext.Current.Request.AppRelativeCurrentExecutionFilePath = "~/api/login" Or
            HttpContext.Current.Request.AppRelativeCurrentExecutionFilePath = "~/api/login/external" Or
            HttpContext.Current.Request.AppRelativeCurrentExecutionFilePath = "~/api/mustchangepassword" Or
            HttpContext.Current.Request.AppRelativeCurrentExecutionFilePath = "~/api/changepassword" Or
            HttpContext.Current.Request.AppRelativeCurrentExecutionFilePath = "~/api/register" Then

            HttpContext.Current.SetSessionStateBehavior(SessionStateBehavior.Required)

        Else

            HttpContext.Current.SetSessionStateBehavior(SessionStateBehavior.ReadOnly)

        End If

    End Sub

End Class
