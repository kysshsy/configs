# ==============================================================================
# PostgreSQL environment (lab-local build)
# ==============================================================================
#
# This snippet exposes the locally-installed PostgreSQL tools under
# /home/kyss/labs/pg_install for interactive fish sessions.
#
# It:
# - defines PG_INSTALL_ROOT as the canonical prefix
# - prepends bin/ to PATH so psql, pg_ctl, etc. are found first
# - prepends lib/ to LD_LIBRARY_PATH for client/server binaries
# - prepends lib/pkgconfig to PKG_CONFIG_PATH for building against libpq

set -gx PG_INSTALL_ROOT /home/kyss/labs/pg_install

# Prepend a path-like variable only when the directory exists and is not
# already present. This keeps interactive reloads idempotent.
function __prepend_env_path --argument-names var_name dir_path
    if not test -d "$dir_path"
        return
    end

    if set -q $var_name
        if not contains -- "$dir_path" $$var_name
            set -gx $var_name "$dir_path" $$var_name
        end
    else
        set -gx $var_name "$dir_path"
    end
end

# Ensure the lab build wins over any system PostgreSQL.
if test -d "$PG_INSTALL_ROOT/bin"
    fish_add_path -g -p "$PG_INSTALL_ROOT/bin"
end

# Make sure the dynamic linker can locate PostgreSQL shared libraries.
__prepend_env_path LD_LIBRARY_PATH "$PG_INSTALL_ROOT/lib"

# Make pkg-config aware of libpq and related client libraries.
__prepend_env_path PKG_CONFIG_PATH "$PG_INSTALL_ROOT/lib/pkgconfig"

