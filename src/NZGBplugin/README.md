# Plugin Documentation
* Developer notes: [/src/NZGBplugin/help/devnotes.html](/linz/gazetteer/blob/master/src/NZGBplugin/help/devnotes.html).
* User help: [/src/NZGBplugin/help/index.html](/linz/gazetteer/blob/master/src/NZGBplugin/help/index.html).
* Project introduction: [root README.md](/linz/gazetteer/blob/master/README.md).
* Plugin deployment below

## Plugin Deployment
The NZGB QGIS Plugin is deployed directly to the LINZ QGIS plugin repository automatically when
specific Git Tags are pushed.

### Release Strategy
When preparing for a release, the release source code must be pushed to a release branch that
follows the naming convention `release-x.y`.

### Deploying the NZGB plugin to LINZ Plugin Repository
The [LINZ Plugin Repository](https://github.com/linz/qgis-plugin-repository) segregates development
and production versions of plugins. This allows the controlled release of plugins in development to plugin testers and production code to general users.

To start the automated release process, a release branch needs to be tag following the below conventions.

* `v.x.x.x` (e.g. v1.0.0) - Such a Git tag will result in a deployment being kicked off to the
production plugin repository.
* `v.x.x.x-UAT` (e.g. v1.0.0-UAT) - A such a Git tag suffixed with `-UAT` will result in the plugin being
deployed to the development plugin repository.

For more on the LINZ QGIS Plugin Repository, see the [GitHub Repository](https://github.com/linz/qgis-plugin-repository)

#### GitHub Release
As well as deploying the plugin to the LINZ Plugin Repository ready for users and tester to consume, the
deployment also automates the creation the [GitHub Release](https://github.com/linz/gazetteer/releases).

#### Plugin Dependencies
The NZGB plugin depends on the Geoalchemy2 and Sqlalchemy packages that are not part of the
standard Python Library. For this reason, the automated deployment downloads and packages these
dependencies with the plugin itself. If we were not to do this the plugin users at LINZ would
require LINZ Service Desk to install these dependencies and would make installation much more
difficult than need be.
