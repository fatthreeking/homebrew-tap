cask "dockmin" do
  version "1.0.0"
  sha256 "43d016bc73cc3b0ac123770b5b8ff76eb720b7e224d2571ecba9b02a802a2978"

  url "https://github.com/fatthreeking/DockMin/releases/download/#{version}/DockMin-#{version}.dmg"
  name "DockMin"
  desc "Click to minimize windows from the macOS Dock"
  homepage "https://github.com/fatthreeking/DockMin"

  depends_on macos: ">= :sonoma"

  app "DockMin.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/DockMin.app"]

    launch_agents_dir = "#{Dir.home}/Library/LaunchAgents"
    plist_path = "#{launch_agents_dir}/com.github.fatthreeking.DockMin.plist"
    FileUtils.mkdir_p(launch_agents_dir)
    File.write(plist_path, <<~EOS)
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>com.github.fatthreeking.DockMin</string>
          <key>ProgramArguments</key>
          <array>
              <string>#{appdir}/DockMin.app/Contents/MacOS/DockMin</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>KeepAlive</key>
          <false/>
          <key>StandardErrorPath</key>
          <string>/tmp/dockmin.err</string>
          <key>StandardOutPath</key>
          <string>/tmp/dockmin.log</string>
      </dict>
      </plist>
    EOS
    system_command "/usr/bin/open",
                   args: ["-a", "#{appdir}/DockMin.app"]
  end

  uninstall_postflight do
    system_command "/usr/bin/tccutil",
                   args: ["reset", "Accessibility", "com.github.fatthreeking.DockMin"]
  end

  uninstall launchctl: "com.github.fatthreeking.DockMin",
            quit:      "com.github.fatthreeking.DockMin",
            delete:    "#{Dir.home}/Library/LaunchAgents/com.github.fatthreeking.DockMin.plist"

  zap trash: [
    "~/Library/LaunchAgents/com.github.fatthreeking.DockMin.plist",
    "/tmp/dockmin.err",
    "/tmp/dockmin.log",
  ]
end
