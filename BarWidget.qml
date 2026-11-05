import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

BarWidget {
  id: root
  moduleName: "io.github.thestandardissue.fbdl"

  readonly property string scriptPath: Qt.resolvedUrl("scripts/fbdl").toString().replace("file://", "")
  readonly property string downloadLocation: setting("downloadLocation", "~/Downloads/facebook")
  readonly property string cookiesBrowser: setting("cookiesBrowser", "none")

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // Empty URL argument = read the link from the clipboard.
  Process {
    id: download
    command: [root.scriptPath, "", root.downloadLocation, root.cookiesBrowser]
  }

  // Create the folder first so opening it works before the first download.
  Process {
    id: openFolder
    command: ["sh", "-c", "mkdir -p \"$1\" && xdg-open \"$1\"", "sh",
              root.downloadLocation.replace(/^~/, Quickshell.env("HOME"))]
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: download.running ? "󰇚…" : "󰇚"
    active: download.running
    tooltipText: download.running
      ? "Downloading… (middle-click: cancel)"
      : "Download Facebook video from clipboard (right-click: open folder)"

    onPressed: function (buttonCode) {
      if (buttonCode === Qt.LeftButton) {
        if (!download.running) download.running = true
      } else if (buttonCode === Qt.RightButton) {
        openFolder.running = true
      } else if (buttonCode === Qt.MiddleButton) {
        // Sends SIGTERM; the script then stops yt-dlp too.
        download.running = false
      }
    }
  }
}
