let classname = $'net.tlater.firefox-webapp.($env.WEBAPP_NAME)'
let profile_path = [($env.XDG_DATA_HOME? | default ~/.local/share | path expand) $'firefox-webapps/($env.WEBAPP_NAME)'] | path join

mkdir $profile_path

# Delete existing symlinks into the nix store; they may be stale, if
# they are not, they will be immediately recreated in the next step
glob ($profile_path + "/**/*") | each {|file|
  if ($file | path type) == "symlink" and ($file | str starts-with "/nix/store") {
    rm $file
  }
}

# lndir sadly doesn't deal with recursive symlinks the way we want it
# to, so we have to hand-roll it
ls ($env.WEBAPP_PROFILE_TEMPLATE + "/**/*" | into glob) | each {|source|
  let target = [$profile_path ($source.name | path relative-to $env.WEBAPP_PROFILE_TEMPLATE)] | path join

  # If the target already exists and is not a directory, we delete it,
  # so that we can update it appropriately
  if ($target | path exists) and ($target | path type) != "dir" {
    rm $target
  }

  match $source.type {
    "symlink" => {
      let resolved = $source.name | path expand

      match ($resolved | path type) {
        "dir" => {
          mkdir $target
        }

        "file" => {
          ln -s $resolved $target
        }
      }
    }

    "file" => {
      ln -s $source.name $target
    }

    "dir" => {
      mkdir $target
    }
  }
}

(^$env.WEBAPP_EXE
  --no-remote
  --class $classname
  --name $classname
  --profile $profile_path
  ...($env.WEBAPP_ARGS? | default "" | split words)
  --new-window
  $env.WEBAPP_URL)
