## Installation

1. Install Fastlane.
   You may use any of the following options:
   * Via Fabric (https://fabric.io, recommended option).
   * Standalone distribution (https://fastlane.tools).
   * Homebrew bottle/package (`brew install fastlane`).
   * As a GEM package (`sudo gem install cocoapods`, not recommended unless you do know your stuff).
1. Clone this repo (`git clone -- https://github.com/byss/buran ~/Repos/buran`).
1. (Optional) Create symlink for a suitable pre-crafted Buran launcher (e.g. `ln -s ~/Repos/buran/buran-fabric-fastlane.sh ~/Repos/buran/buran.sh` for Fabric distribution).
1. (Optional) Add repo directory to `$PATH` (add `export PATH="~/Repos/buran:${PATH}"` into your `~/.bash_profile`) and restart your shell/terminal emulator.
1. Launch & enjoy fixed & downloaded profiles, simply typing `buran.sh -l <your-appple-dev-email> -t <your-team-id> -b <affected-bundle-regex> -a -d`. Example: `buran.sh -l kirrbyss@gmail.com -t 
LSKU6K4UN2 -b '^hk.walletkeeper.*'`.
   Full script name (`buran-fabric-fastlane.sh`) is required if symlink creation is skipped on third step.
   Full script path (`~/Repos/buran/buran.sh`) is required if `$PATH` is not edited on fourth step.

## Configuration

* You do not need to specify your login, team ID or bundle regex for subsequent launches, these settings are persisted at `~/.config/buran/last.conf`. Session cookie are saved in Spaceship storage 
(macOS Keychain by default), so logging in is not required each time you launch Buran.
* Full manual is revealed by launching Buran with one of default help option (`-h` or `--help`), proceed to that document for complete configuration options reference.

## License

This project is licensed under the terms of WTFPL, see [LICENSE](https://github.com/byss/buran/blob/master/LICENSE) for details.
