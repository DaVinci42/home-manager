modulePath:
{
  config,
  lib,
  ...
}:

let

  cfg = lib.getAttrFromPath modulePath config;

  firefoxMockOverlay = import ../../setup-firefox-mock-overlay.nix modulePath;

in
{
  imports = [ firefoxMockOverlay ];

  config = lib.mkIf config.test.enableBig (
    lib.setAttrByPath modulePath {
      enable = true;
      profiles.bookmarks = {
        settings = {
          "general.smoothScroll" = false;
        };
        bookmarks = {
          force = true;
          settings = [
            {
              toolbar = true;
              bookmarks = [
                {
                  name = "Home Manager";
                  url = "https://wiki.nixos.org/wiki/Home_Manager";
                }
              ];
            }
            {
              name = "kernel.org";
              url = "https://www.kernel.org";
            }
            "separator"
            {
              name = "Nix sites";
              bookmarks = [
                {
                  name = "homepage";
                  url = "https://nixos.org/";
                }
                {
                  name = "wiki";
                  tags = [
                    "wiki"
                    "nix"
                  ];
                  url = "https://wiki.nixos.org/";
                }
                {
                  name = "Nix sites";
                  bookmarks = [
                    {
                      name = "homepage";
                      url = "https://nixos.org/";
                    }
                    {
                      name = "wiki";
                      url = "https://wiki.nixos.org/";
                    }
                  ];
                }
              ];
            }
            {
              name = "wikipedia";
              tags = [ "wiki" ];
              keyword = "wiki";
              url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
            }
          ];
        };
      };
    }
    // {
      nmt.script = ''
        bookmarksUserJs=$(normalizeStorePaths \
          "home-files/${cfg.profilesPath}/bookmarks/user.js")

        assertFileContent \
          $bookmarksUserJs \
          ${./expected-bookmarks-user.js}

        bookmarksFile="$(sed -n \
          '/browser.bookmarks.file/ {s|^.*\(/nix/store[^"]*\).*|\1|;p}' \
          "$TESTED/home-files/${cfg.profilesPath}/bookmarks/user.js")"

        assertFileContent \
          $bookmarksFile \
          ${./expected-bookmarks-list.html}
      '';
    }
  );
}
