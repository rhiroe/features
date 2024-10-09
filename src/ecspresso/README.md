
# ecspresso (ecspresso)

Provides ecspresso.

## Example Usage

```json
"features": {
    "ghcr.io/rhiroe/features/ecspresso:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| ecspressoVersion | Version of ecspresso to install. | string | latest |
| useSessionManagerPlugin | Install session manager plugin. | boolean | false |
| jqVersion | Version of jq to install. | string | none |
| yqVersion | Version of yq to install. | string | none |

## Available versions

The versions of ecspresso can be specified by version number or "latest".

The versions of jq and yq can be specified by version number or "latest" or "none".


## Other jq-like command

If you need this other jq-like command, you may find it useful [here](https://github.com/eitsupi/devcontainer-features/tree/main/src/jq-likes).


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/rhiroe/features/blob/main/src/ecspresso/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
