# Toyhouse API

Welcome! This is a Golang API for the popular content sharing website [Toyhou.se](https://toyhou.se).

# Usage

## API

The routes for the API are as follows:

- /user/:userId

  - /user/:userId/details
  - /user/:userId/gallery

- /character/:characterId
  - /character/:characterId/details
  - /character/:characterId/gallery

The code for this API can be found in ./lib.

## GUI App

The code for the GUI app is located in ./gui.
You can start a development environment by running `npm i && npm run tauri dev`

> **Note**
> Please ensure that you have all the [prerequisites](https://tauri.app/v1/guides/getting-started/prerequisites/) for Tauri for this step.

# License

Distributed under the MIT License. See LICENSE for more information.
