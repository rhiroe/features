
# saml2aws (saml2aws)

Provides saml2aws.

## Example Usage

```json
"features": {
    "ghcr.io/rhiroe/features/saml2aws:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| saml2awsVersion | Version of saml2aws to install. | string | latest |

## Available versions

The versions of saml2aws can be specified by version number or "latest".

## Support for bind mounting of host files

Bind mount the `$HOME/.aws/config` and `$HOME/.saml2aws` configuration files that exist on the host and attempt to log in based on those settings.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/rhiroe/features/blob/main/src/saml2aws/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
