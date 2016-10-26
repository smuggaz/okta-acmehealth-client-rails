# AcmeHealth Samples using Ruby on Rails
The following examples show best practices for using Okta's Sign-In Widget and AuthJS SDK with Rails

<p align="center"><img src ="https://raw.githubusercontent.com/jmelberg-okta/doc-assets/master/acmeHeath/login-long.png" /></p>


## Overview
AcmeHealth is a starter project for developers looking to incorporate OAuth2/OpenID Connect into their web applications. 
Using industry best practices, the AcmeHealth project will provide you with an end-to-end example of common authentication scenarios.

### Flow
| Scenario      | Summary  |
| :-------------: |:-------------: |
| Authentication | Using the [Authorization Code Grant](https://tools.ietf.org/html/rfc6749#section-4.1), the [Sign-In Widget](http://developer.okta.com/code/javascript/okta_sign-in_widget_ref#openid-connect-oauth-20-and-social-integrations) and [AuthJS SDK](http://developer.okta.com/code/javascript/okta_auth_sdk), request an authorization code from Okta or the [Social IDP](http://developer.okta.com/docs/api/resources/social_authentication.html)
| Code Extraction | Parsed from the `/callback` URL query parameter, the `code` is exchanged for an `id_token` and `access_token` from Okta |
| Validate Token | If an `id_token` is requested, it is validated per [OpenID Spec 3.1.3.7](http://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation). If `id_token` is valid, a local user is created / matched |
| Set Session | Sets a session cookie upon successful login |

### Samples Provided
| Sample   | Button |
| :-------------: |:-------------: |
| Redirect to IdP (Okta) | ![Okta Login](https://raw.githubusercontent.com/jmelberg-okta/doc-assets/master/acmeHeath/okta-button.png) |
| Simple Login Experience using [Sign-In Widget](http://developer.okta.com/code/javascript/okta_sign-in_widget_ref#openid-connect-oauth-20-and-social-integrations) | ![Widget Login](https://raw.githubusercontent.com/jmelberg-okta/doc-assets/master/acmeHeath/widget-button.png) |
| [Social IdP (LinkedIn)](http://developer.okta.com/docs/api/resources/social_authentication.html) | ![LinkedIn Login](https://raw.githubusercontent.com/jmelberg-okta/doc-assets/master/acmeHeath/linkedin-button.png)

## Running the Samples with your Okta Organization
###Pre-requisites
This sample application was tested with an Okta organization. If you do not have an Okta organization, you can easily [sign up for a free Developer Okta org](https://www.okta.com/developer/signup/).

1. Verify OpenID Connect is enabled for your Okta organization. `Admin -> Applications -> Add Application -> Create New App -> OpenID Connect`
  - If you do not see this option, email [developers@okta.com](mailto:developers@okta.com) to enable it.
2. In the **Create A New Application Integration** screen, click the **Platform** dropdown and select **Web**
3. Press **Create**. When the page appears, enter an **Application Name**. Press **Next**.
4. Add the following to the list of *Redirect URIs*:
  - `http://localhost:8080`
  - `http://localhost:8080/callback`
5. Click **Finish** to redirect back to the *General Settings* of your application.
6. Copy the **Client ID**, as it will be needed for the client configuration.
7. Select the **Edit** button and change the **Client Authentication** to *Client Secret*. Copy the *Client Secret*, as it will be needed for the client configuration.
8. Enable [CORS access](http://developer.okta.com/docs/api/getting_started/enabling_cors.html) to your Okta organization
  - In the navigation bar, select **Security** then **API**.
  - Select the *CORS* tab
  - Click the **Edit** button and add `http://localhost:8080`
  - Save
9. Finally, select the **People** tab and **Assign to People** in your organization.

### Build Instructions
Ensure [Rails](http://installrails.com) is properly [installed on your OS](http://installrails.com/steps/choose_os). 
With a local copy of the samples, use the following commands on Mac OS X or Linux:
```
    $ cd okta-acmehealth-rails/
    $ bundle install
```
This will install all required `gems`.

### Run the Samples
#### App Configuration
In the `config.yml` file located in `okta-acmehealth-rails/config/`, update the following:
```yaml
defaults: &defaults
  audience: https://example.oktapreview.com
  client_id: 8p10aJwClXD61oFx3SNT
  client_secret: client_secret_here
  scope: openid profile email
  grant_type: authorization_code
  redirect_uri: http://localhost:8080/callback
```

Next, sync the local database for User authentication.
```
    $ rake db:migrate
    $ bin/rails server -p 8080
```
This will start the server on [http://localhost:8080](http://localhost:8080/login).
